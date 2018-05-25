#!/bin/bash

set -e
export _VARS=$(cat volatile-status.txt | awk '{printf "%s=%s ", $1, $2}')
export _CHART_VERSION=$(env -i $_VARS bash -c 'echo %{CHART_VERSION}')
export TMPDIR=`mktemp -d`
export ARCHIVE="$TMPDIR/%{CHART_NAME}-${_CHART_VERSION}.tgz"
cp %{CHART} ${ARCHIVE}
%{HELM} lint %{ARGS} ${ARCHIVE} $@
rm -r ${TMPDIR}
