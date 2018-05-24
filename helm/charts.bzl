
def _helm_package_impl(ctx):
    #print(ctx.var)
    #interpolated_version = ctx.attr.version.format(ctx.var)
    #print(interpolated_version)

    cmd = " ".join([
        ctx.executable.helmbin.path,
        "package",
        "--debug",
        "--save=false",
        "--version=$_CHART_VERSION",
        "--destination=%s" % ctx.outputs.package.dirname,
    ])
    ctx.action(
        inputs = ctx.files.srcs + ctx.files.helmbin + [ctx.version_file],
        outputs = [ctx.outputs.package],
        command = """
set -ex
export _CHART_VERSION=$(env -i $(cat %s | awk '{printf "%%s=%%s ", $1, $2}') bash -c 'echo %s')
TMP=`mktemp -d`
CHART=$TMP/%s
cp -r %s $CHART
%s $CHART
mv %s/%s-$_CHART_VERSION.tgz %s
ls -la $CHART
rm -r $TMP
""" % (ctx.version_file.path, ctx.attr.version, ctx.attr.chartname, ctx.label.package, cmd, ctx.outputs.package.dirname, ctx.attr.chartname, ctx.outputs.package.path),
    )

helm_package = rule(
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "chartname": attr.string(
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            single_file = True,
            allow_files = True,
            cfg = "host",
        ),
    },
    outputs = {"package": "%{chartname}.tgz"},
    implementation = _helm_package_impl,
    executable = False,
)

def _helm_s3_push_impl(ctx):
    ctx.template_action(
        template = ctx.file._s3_push_tpl,
        output = ctx.outputs.push,
        substitutions = {
            "%{CHART}": ctx.file.chart.short_path,
            "%{REPO}": ctx.attr.repo,
            "%{AWS_REGION}": ctx.attr.aws_region,
            "%{HELM}": ctx.executable.helmbin.short_path,
            "%{HELMS3}": ctx.executable.helms3bin.short_path,
        },
        executable = True,
    )

    return DefaultInfo(
        executable = ctx.outputs.push,
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
            single_file = True,
            allow_files = True,
        ),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            single_file = True,
            allow_files = True,
            cfg = "host",
        ),
        "helms3bin": attr.label(
            default = Label("//helm:helm_s3_runtime"),
            executable = True,
            single_file = True,
            allow_files = True,
            cfg = "host",
        ),
        "chart": attr.label(
            mandatory = True,
            single_file = True,
        ),
        "repo": attr.string(
            mandatory = True,
        ),
        "aws_region": attr.string(
            mandatory = True,
        ),
    },
    outputs = {"push": "s3-push.sh"},
    implementation = _helm_s3_push_impl,
    executable = True,
)

def _helm_push_impl(ctx):
    ctx.template_action(
        template = ctx.file._push_tpl,
        output = ctx.outputs.push,
        substitutions = {
            "%{CHART}": ctx.file.chart.short_path,
            "%{REPO}": ctx.attr.repo,
            "%{HELM}": ctx.executable.helmbin.short_path,
            "%{HELMPUSH}": ctx.executable.helmpushbin.short_path,
        },
        executable = True,
    )

    return DefaultInfo(
        executable = ctx.outputs.push,
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
            single_file = True,
            allow_files = True,
        ),
        "helmbin": attr.label(
            default = Label("//helm:helm_runtime"),
            executable = True,
            single_file = True,
            allow_files = True,
            cfg = "host",
        ),
        "helmpushbin": attr.label(
            default = Label("//helm:helm_push_runtime"),
            executable = True,
            single_file = True,
            allow_files = True,
            cfg = "host",
        ),
        "chart": attr.label(
            mandatory = True,
            single_file = True,
        ),
        "repo": attr.string(
            mandatory = True,
        ),
    },
    outputs = {"push": "push.sh"},
    implementation = _helm_push_impl,
    executable = True,
)
