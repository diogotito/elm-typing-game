#!/bin/sh

while true; do
    ls -d src/*.elm | entr -d \
        elm-live src/*.elm \
            --dir=./dist \
            -- \
            --output dist/index.js
done
