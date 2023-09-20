#!/usr/bin/env bash

GIT_HASH=$(git rev-parse --short HEAD)

docker buildx build --platform=linux/arm64 \
    -f build/Dockerfile \
    --build-arg GIT_HASH=${GIT_HASH} \
    --build-arg GOOS="linux" \
    --build-arg GOARCH="arm64" \
    --build-arg GOVERSION="1.20.7" \
    -t evergreen:${GIT_HASH} \
    --target production \
    .
