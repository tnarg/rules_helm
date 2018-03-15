
def _helm_package_impl(ctx):
    cmd = " ".join([
        ctx.executable.helmbin.path,
        "package",
        "--debug",
        "--save=false",
        "--version=%s" % ctx.attr.version,
        "--destination=%s" % ctx.outputs.package.dirname,
    ])
    ctx.action(
        inputs = ctx.files.srcs + ctx.files.helmbin,
        outputs = [ctx.outputs.package],
        command = "/bin/bash -c 'set -e; TMP=`mktemp -d`; CHART=$TMP/%s; cp -r %s $CHART; %s $CHART; rm -r $TMP'" % (ctx.attr.chartname, ctx.label.package, cmd),
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
    outputs = {"package": "%{chartname}-%{version}.tgz"},
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
