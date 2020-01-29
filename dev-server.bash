#!/usr/bin/env bash

shopt -s extglob
set -x

while true; do
    ls -d src/*.elm dist/!(index.js) | entr -d \
        elm-live src/*.elm \
            --dir=./dist \
            "$@" \
            -- \
            --output dist/index.js
done
