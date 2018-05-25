#!/bin/bash

set -e
export TMPDIR=`mktemp -d`
export ARCHIVE="$TMPDIR/%{CHART_NAME}-%{CHART_VERSION}.tgz"
cp %{CHART} ${ARCHIVE}
%{HELM} lint ${ARCHIVE} $@
rm -r ${TMPDIR}
