#!/usr/bin/env bash

docker buildx build --platform=linux/arm64 \
    --build-arg GIT_HASH="$(git rev-parse --short HEAD)" \
    --build-arg GOOS="linux" \
    --build-arg GOARCH="arm64" \
    --build-arg GOVERSION="1.20.7" \
    -t evergreen:dev \
    --target dev \
    .
