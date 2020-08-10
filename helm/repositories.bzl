load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_helm_runtimes = {
    "2.8.2": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "614b5ac79de4336b37c9b26d528c6f2b94ee6ccacb94b0f4b8d9583a8dd122d3",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "a0a8cf462080b2bc391f38b7cf617618b189cdef9f071c06fa0068c2418cc413",
        },
    ]
}

_helm_s3_runtimes = {
    "0.6.0": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "9bc83ca57a5e06a6ec92015504aff3b8a394f8642d2ca0433cdb886de1ecdb4e",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "0357d07a6ae27bbe3fbc934e167dc8e5f76bae83a6982277122797f4eca43b72",
        },
    ]
}

_helm_push_runtimes = {
    "0.4.0": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "e0102fc8411c00b9008457a75cd4830f2e23a0415c6fa29b78b6c551d4febc07",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "bc581049e27b5aca6929109b0404f5e793274cfae0573d0f3531d0ffbd717f6e",
        },
        {
            "os": "windows",
            "arch": "amd64",
            "sha256": "0aa1e7ae2aca375cbd13d44c01c899408d557345d814ac876a4065a3d0a5b9ff",
        }
    ]
}


def helm_tools(helm_runtimes=_helm_runtimes, helm_s3_runtimes=_helm_s3_runtimes, helm_push_runtimes=_helm_push_runtimes):
    for helm_version in helm_runtimes:
        for platform in helm_runtimes[helm_version]:
            http_archive(
                name="helm_runtime_%s_%s" % (platform["os"], platform["arch"]),
                build_file_content="""exports_files(["%s-%s/helm"], visibility = ["//visibility:public"])""" % (
                    platform["os"], platform["arch"]),
                url="https://storage.googleapis.com/kubernetes-helm/helm-v%s-%s-%s.tar.gz" % (
                    helm_version, platform["os"], platform["arch"]),
            )

    for helm_s3_version in helm_s3_runtimes:
        for platform in helm_s3_runtimes[helm_s3_version]:
            http_archive(
                name="helm_s3_runtime_%s_%s" % (
                    platform["os"], platform["arch"]),
                build_file_content="""exports_files(["bin/helms3"], visibility = ["//visibility:public"])""",
                url="https://github.com/hypnoglow/helm-s3/releases/download/v%s/helm-s3_%s_%s_%s.tar.gz" % (
                    helm_s3_version, helm_s3_version, platform["os"], platform["arch"]),
            )

    for helm_push_version in helm_push_runtimes:
        for platform in helm_push_runtimes[helm_push_version]:
            http_archive(
                name="helm_push_runtime_%s_%s" % (
                    platform["os"], platform["arch"]),
                build_file_content="""exports_files(["bin/helmpush"], visibility = ["//visibility:public"])""",
                url="https://github.com/chartmuseum/helm-push/releases/download/v%s/helm-push_%s_%s_%s.tar.gz" % (
                    helm_push_version, helm_push_version, platform["os"], platform["arch"]),
            )
