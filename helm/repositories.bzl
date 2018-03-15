
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



def helm_tools():
    for helm_version in _helm_runtimes:
        for platform in _helm_runtimes[helm_version]:
            native.new_http_archive(
                name = "helm_runtime_%s_%s" % (platform["os"], platform["arch"]),
                build_file_content = """exports_files(["%s-%s/helm"], visibility = ["//visibility:public"])""" % (platform["os"], platform["arch"]),
                url = "https://storage.googleapis.com/kubernetes-helm/helm-v%s-%s-%s.tar.gz" % (helm_version, platform["os"], platform["arch"]),
            )

    for helm_s3_version in _helm_s3_runtimes:
        for platform in _helm_s3_runtimes[helm_s3_version]:
            native.new_http_archive(
                name = "helm_s3_runtime_%s_%s" % (platform["os"], platform["arch"]),
                build_file_content = """exports_files(["bin/helms3"], visibility = ["//visibility:public"])""",
                url = "https://github.com/hypnoglow/helm-s3/releases/download/v0.6.0/helm-s3_%s_%s_%s.tar.gz" % (helm_s3_version, platform["os"], platform["arch"]),
            )
