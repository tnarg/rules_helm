ChartInfo = provider(fields=["chartname", "version", "repository"])

def _helm_chart_impl(ctx):
    # make the dependencies.yaml template
    requirements  = "cat <<EOF\ndependencies:\n"
    for dep in ctx.attr.deps:
        requirements += "- name: \"%s\"\n" % (dep[ChartInfo].chartname,)
        requirements += "  version: \"%s\"\n" % (dep[ChartInfo].version,)
        requirements += "  repository: \"%s\"\n" % (dep[ChartInfo].repository,)
    requirements += "EOF"

    requirements_sh = ctx.actions.declare_file("requirements.sh")
    ctx.actions.write(output = requirements_sh, content = requirements)

    # Copy dependencies into charts directory
    cpdeps  = "# BEGIN cpdeps\n"
    for dep in ctx.attr.deps:
        cpdeps += "cp %s $CHART/charts/%s-%s.tgz\n" % (list(dep.files.to_list())[0].path, dep[ChartInfo].chartname, dep[ChartInfo].version)
    cpdeps += "# END cpdeps\n"

    cpdeps_sh = ctx.actions.declare_file("cpdeps.sh")
    ctx.actions.write(output = cpdeps_sh, content = cpdeps)

    # package the chart
    package = " ".join([
        ctx.executable.helmbin.path,
        "package",
        "--debug",
        "--version=$_CHART_VERSION",
        "--destination=%s" % ctx.outputs.package.dirname,
    ])

    depfiles = []
    for dep in ctx.attr.deps:
        for f in dep.files.to_list():
            depfiles += [f]

    cp_cmds = []
    for f in ctx.files.srcs:
        suffix = f.path[len(ctx.label.package) + 1:]
        cp_cmds.append("mkdir -p $(dirname $CHART/%s) && cp %s $CHART/%s" % (suffix, f.path, suffix))

    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.info_file, ctx.version_file, requirements_sh, cpdeps_sh] + depfiles,
        tools = ctx.files.helmbin,
        outputs = [ctx.outputs.package],
        command = "\n".join([
            "set -e",
            "export _VARS=$(cat %s %s | awk '{printf \"%%s=%%s \", $1, $2}')" % (ctx.info_file.path, ctx.version_file.path),
            "export _CHART_VERSION=$(env -i $_VARS bash -c 'echo %s')" % (ctx.attr.version,),
            "TMP=`mktemp -d`",
            "CHART=$TMP/%s" % (ctx.attr.name,),
            "\n".join(cp_cmds),
            "echo \"version: $_CHART_VERSION\" >> $CHART/Chart.yaml",
            "mkdir $CHART/charts",
            "env -i $_VARS bash %s > $CHART/requirements.yaml" % (requirements_sh.path,),
            "env -i CHART=$CHART $_VARS bash %s" % (cpdeps_sh.path,),
            "%s $CHART" % (package,),
            "mv %s/%s-$_CHART_VERSION.tgz %s" % (ctx.outputs.package.dirname, ctx.attr.name, ctx.outputs.package.path),
            "rm -r $TMP",
        ])
    )

    return [ChartInfo(chartname=ctx.attr.name, version=ctx.attr.version, repository=ctx.attr.repository)]

helm_chart = rule(
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
        "repository": attr.string(
            mandatory = True,
        ),
        "deps": attr.label_list(providers = [ChartInfo]),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
    },
    outputs = {
        "package": "%{name}.tgz",
    },
    implementation = _helm_chart_impl,
    executable = False,
)

def _helm_s3_push_impl(ctx):
    s3_push_sh = ctx.actions.declare_file("s3-push.sh")
    ctx.actions.expand_template(
        template = ctx.file._s3_push_tpl,
        output = s3_push_sh,
        substitutions = {
            "%{CHART}": ctx.file.chart.short_path,
            "%{REPO}": ctx.attr.chart[ChartInfo].repository,
            "%{AWS_REGION}": ctx.attr.aws_region,
            "%{HELM}": ctx.executable.helmbin.short_path,
            "%{HELMS3}": ctx.executable.helms3bin.short_path,
        },
    )

    return DefaultInfo(
        executable = s3_push_sh,
        runfiles = ctx.runfiles(files = [
            ctx.executable.helmbin,
            ctx.executable.helms3bin,
            ctx.file.chart,
        ]),
    )

helm_s3_push = rule(
    attrs = {
        "_s3_push_tpl": attr.label(
            default = Label("//helm:s3-push.sh.tpl"),
            allow_single_file = True,
        ),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
        "helms3bin": attr.label(
            default = Label("//helm:helm_s3_runtime"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
        "chart": attr.label(
            mandatory = True,
            allow_single_file = True,
            providers = [ChartInfo],
        ),
        "aws_region": attr.string(
            mandatory = True,
        ),
    },
    implementation = _helm_s3_push_impl,
    executable = True,
)

def _helm_push_impl(ctx):
    push_sh = ctx.actions.declare_file("push.sh")
    ctx.actions.expand_template(
        template = ctx.file._push_tpl,
        output = push_sh,
        substitutions = {
            "%{CHART}": ctx.file.chart.short_path,
            "%{REPO}": ctx.attr.chart[ChartInfo].repository,
            "%{HELM_REPO_CONTEXT_PATH}": ctx.attr.contextpath,
            "%{HELM}": ctx.executable.helmbin.short_path,
            "%{HELMPUSH}": ctx.executable.helmpushbin.short_path,
        },
    )

    return DefaultInfo(
        executable = push_sh,
        runfiles = ctx.runfiles(files = [
            ctx.executable.helmbin,
            ctx.executable.helmpushbin,
            ctx.file.chart,
        ]),
    )

helm_push = rule(
    attrs = {
        "_push_tpl": attr.label(
            default = Label("//helm:push.sh.tpl"),
            allow_single_file = True,
        ),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
        "helmpushbin": attr.label(
            default = Label("//helm:helm_push_runtime"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
        "chart": attr.label(
            mandatory = True,
            allow_single_file = True,
            providers = [ChartInfo],
        ),
        "contextpath": attr.string(
            mandatory = False,
        ),
    },
    implementation = _helm_push_impl,
    executable = True,
)


def _helm_lint_impl(ctx):
    args = ""
    if ctx.attr.strict:
        args = "--strict"

    lint_sh = ctx.actions.declare_file("lint.sh")
    ctx.actions.expand_template(
        template = ctx.file._lint_tpl,
        output = lint_sh,
        substitutions = {
            "%{CHART}": ctx.file.chart.short_path,
            "%{CHARTNAME}": ctx.attr.chart[ChartInfo].chartname,
            "%{HELM}": ctx.executable.helmbin.short_path,
        },
    )

    return DefaultInfo(
        executable = lint_sh,
        runfiles = ctx.runfiles(files = [
            ctx.executable.helmbin,
            ctx.file.chart,
        ]),
    )

helm_lint = rule(
    attrs = {
        "_lint_tpl": attr.label(
            default = Label("//helm:lint.sh.tpl"),
            allow_single_file = True,
        ),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
        "chart": attr.label(
            mandatory = True,
            allow_single_file = True,
            providers = [ChartInfo],
        ),
        "strict": attr.bool(
            default = False,
        ),
    },
    implementation = _helm_lint_impl,
    executable = True,
)
