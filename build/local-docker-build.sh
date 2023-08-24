#!/usr/bin/env bash

GIT_HASH=$(git rev-parse --short HEAD)

docker buildx build --platform=linux/arm64 \
    --build-arg GIT_HASH="${GIT_HASH}" \
    --build-arg GOOS="linux" \
    --build-arg GOARCH="arm64" \
    --build-arg GOVERSION="1.20.7" \
    --label "git-${GIT_HASH}" \
    --tag evergreen-dev:latest \
    --tag evergreen-dev:${GIT_HASH} \
    --target dev \
    -f build/Dockerfile \
    .

docker buildx build --platform=linux/arm64 \
    --build-arg GIT_HASH="${GIT_HASH}" \
    --build-arg GOOS="linux" \
    --build-arg GOARCH="arm64" \
    --build-arg GOVERSION="1.20.7" \
    --label "git-${GIT_HASH}" \
    --tag evergreen:latest \
    --tag evergreen:${GIT_HASH} \
    --target production \
    -f build/Dockerfile \
    .
