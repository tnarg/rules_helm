#!/bin/bash

HEAD=$(git rev-parse HEAD)

if [ -z "$(git status --porcelain)" ]; then
    echo "GIT_STATUS ${HEAD}"
else
    echo "GIT_STATUS ${HEAD}-SNAPSHOT"
fi

