load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_helm_runtimes = {
    "3.9.0": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "1484ffb0c7a608d8069470f48b88d729e88c41a1b6602f145231e8ea7b43b50a",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "7e5a2f2a6696acf278ea17401ade5c35430e2caa57f67d4aa99c607edcc08f5e",
        },
        {
            "os": "darwin",
            "arch": "arm64",
            "sha256": "22cf080ded5dd71ec15d33c13586ace9b6002e97518a76df628e67ecedd5aa70",
        },
    ]
}

_helm_s3_runtimes = {
    "0.12.0": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "701318680e90510e9ec321447bb805fc181733ceab2fb35b5291bc33cec3b2bc",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "ee61357f3c76e46c152aee399616aba22d04319424264869f7183ae264ff847b",
        },
        {
            "os": "darwin",
            "arch": "arm64",
            "sha256": "eab922353ac2f813c47e3b011aa3c22242748e3805f48e747dfbd3e20d8abf7c",
        },
    ]
}

_helm_push_runtimes = {
    "0.10.2": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "0f661c9e2ad1701c40812c398576cc55ff5a4c89c681eb98b496ab6a61c5cbf0",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "59d96d2ade0187fe726cb35e9e33ef422006ac62b14186fe6f19783d3abca91d",
        },
        {
            "os": "darwin",
            "arch": "arm64",
            "sha256": "03e861fb52eee613232b98af790c08002b6a5791d3be247fe1b5f56be2a887f9",
        },
        {
            "os": "windows",
            "arch": "amd64",
            "sha256": "25a089f98fb0d8a94f5a9d1805a3f86487ac14a3d26dd027f126e8f67b23545f",
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
