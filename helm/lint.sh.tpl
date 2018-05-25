#!/bin/bash

set -e
CHART=$(readlink %{CHART})
HELM=$(readlink %{HELM})
export TMPDIR=$(mktemp -d)
pushd ${TMPDIR}
tar xfz ${CHART}
$HELM lint %{CHARTNAME} $@
popd
rm -r ${TMPDIR}
