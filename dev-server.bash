#!/usr/bin/env bash

shopt -s extglob
set -x

while true; do
    ls dist/!(index.js) | entr -dr \
        elm-live src/*.elm \
            --dir=./dist \
            --host=0.0.0.0 \
            "$@" \
            -- \
            --output dist/index.js
done
