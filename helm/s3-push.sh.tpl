#!/bin/bash

export AWS_REGION=%{AWS_REGION}
export HELM_HOME=`mktemp -d`
%{HELM} init --client-only > /dev/null

export HELM_PLUGIN=`mktemp -d`
HELM_S3=${HELM_PLUGIN}/helm-s3
mkdir -p ${HELM_S3}/bin
cat <<EOF > ${HELM_S3}/plugin.yaml
name: "s3"
version: "0.0.1"
usage: "The plugin allows to use s3 protocol to upload, fetch charts and to work with repositories."
description: |-
  Provides AWS S3 protocol support.
  https://github.com/hypnoglow/helm-s3
command: "\$HELM_PLUGIN_DIR/bin/helms3"
downloaders:
- command: "bin/helms3"
  protocols:
    - "s3"
hooks:
  install: "cd \$HELM_PLUGIN_DIR; make install"
  update: "cd \$HELM_PLUGIN_DIR; make install"
EOF

cp %{HELMS3} ${HELM_S3}/bin/helms3

%{HELM} repo add dest %{REPO} > /dev/null
%{HELM} s3 push %{CHART} dest $@
rm -r ${HELM_PLUGIN}
rm -r ${HELM_HOME}
