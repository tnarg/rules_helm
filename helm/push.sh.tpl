#!/bin/bash

export HELM_HOME=`mktemp -d`
%{HELM} init --client-only > /dev/null

export HELM_PLUGIN=`mktemp -d`
HELM_PUSH=${HELM_PLUGIN}/helm-push
mkdir -p ${HELM_PUSH}/bin
cat <<EOF > ${HELM_PUSH}/plugin.yaml
name: "push"
version: "0.0.1"
usage: "Please see https://github.com/chartmuseum/helm-push for usage"
description: "Push chart package to ChartMuseum"
command: "\$HELM_PLUGIN_DIR/bin/helmpush"
downloaders:
- command: "bin/helmpush"
  protocols:
    - "cm"
hooks:
  install: "cd \$HELM_PLUGIN_DIR; scripts/install_plugin.sh"
  update: "cd \$HELM_PLUGIN_DIR; scripts/install_plugin.sh"
EOF

cp %{HELMPUSH} ${HELM_PUSH}/bin/helmpush

%{HELM} repo add dest %{REPO} > /dev/null
%{HELM} push %{CHART} dest $@
rm -r ${HELM_PLUGIN}
rm -r ${HELM_HOME}
