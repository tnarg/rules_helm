load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_helm_runtimes = {
    "2.12.0": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "9f96a6e4fc52b5df906da381532cc2eb2f3f57cc203ccaec2b11cf5dc26a7dfc",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "2b7e4fb460d7c641be1b90aad38a882462f88fd47975cc91aa17600ab5152590",
        },
    ]
}

_helm_s3_runtimes = {
    "0.8.0": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "100e702ac23b24bf906ed5568d277f1b3e66be734cd4184ef0970bf8fa02fe18",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "cc3b91564e739caa40843ffbb0eaf672d1fb1a01a376371cea1bb19dc70beb89",
        },
    ]
}

_helm_push_runtimes = {
    "0.7.1": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "dd9b5167a44cd37b722e61e854380fd6a8bd0cd0724e022a274c120cf7097f0e",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "f410c87720bdb7033aaad4ea6262ff25dde8acd755b22567117a03668ed9557b",
        },
        {
            "os": "windows",
            "arch": "amd64",
            "sha256": "a8dc9b7e5f4feb361b62dae727840378dcec7398748fb75614521642221b19de",
        }
    ]
}

def helm_tools():
    for helm_version in _helm_runtimes:
        for platform in _helm_runtimes[helm_version]:
            http_archive(
                name = "helm_runtime_%s_%s" % (platform["os"], platform["arch"]),
                build_file_content = """exports_files(["%s-%s/helm"], visibility = ["//visibility:public"])""" % (platform["os"], platform["arch"]),
                url = "https://storage.googleapis.com/kubernetes-helm/helm-v%s-%s-%s.tar.gz" % (helm_version, platform["os"], platform["arch"]),
            )

    for helm_s3_version in _helm_s3_runtimes:
        for platform in _helm_s3_runtimes[helm_s3_version]:
            http_archive(
                name = "helm_s3_runtime_%s_%s" % (platform["os"], platform["arch"]),
                build_file_content = """exports_files(["bin/helms3"], visibility = ["//visibility:public"])""",
                url = "https://github.com/hypnoglow/helm-s3/releases/download/v%s/helm-s3_%s_%s_%s.tar.gz" % (helm_s3_version, helm_s3_version, platform["os"], platform["arch"]),
            )

    for helm_push_version in _helm_push_runtimes:
        for platform in _helm_push_runtimes[helm_push_version]:
            http_archive(
                name = "helm_push_runtime_%s_%s" % (platform["os"], platform["arch"]),
                build_file_content = """exports_files(["bin/helmpush"], visibility = ["//visibility:public"])""",
                url = "https://github.com/chartmuseum/helm-push/releases/download/v%s/helm-push_%s_%s_%s.tar.gz" % (helm_push_version, helm_push_version, platform["os"], platform["arch"]),
            )
