# syntax=docker/dockerfile:1

# Make a build env with everything we need
FROM public.ecr.aws/debian/debian:bookworm as build

ARG GIT_HASH
ARG GOOS
ARG GOARCH
ARG GOVERSION

RUN apt update && apt upgrade -y && \
    apt install -y git make jq vim

# Grab golang directly from Google
#  TODO: Can we pull this from Artifactory?
ADD https://go.dev/dl/go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz /tmp/go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz
RUN tar -C /usr/local -xzf /tmp/go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /build

# Install bom so we can build an SBOM
RUN go install sigs.k8s.io/bom/cmd/bom@latest

# Copy this repo to the WORKDIR and run make
COPY . .
RUN make build

# Capture the build artifact information in an SBOM file
RUN /root/go/bin/bom generate --format json --name evergreen --output evergreen.spdx.json . && \
    install -D -m 444 evergreen.spdx.json /var/lib/db/sbom/evergreen.spdx.json


# Create a dev container with the entire build environment
FROM build AS dev
CMD ["/bin/bash"]

# Create a dev container with the entire build environment
FROM build AS local-evergreen

ARG GOOS
ARG GOARCH

WORKDIR /build
CMD ["/bin/bash", "-c", "/build/build/start-local-evergreen.sh"]



# Production is as slim as possible
FROM public.ecr.aws/debian/debian:bookworm-slim as production
#FROM scratch as production

ARG GOOS
ARG GOARCH

WORKDIR /app
COPY --from=build /build/clients/${GOOS}_${GOARCH}/evergreen .
COPY --from=build /var/lib/db/sbom/evergreen.spdx.json /var/lib/db/sbom/evergreen.spdx.json

ENTRYPOINT ["/app/evergreen", "service", "web"]


# UI
FROM node:20-bookworm as ui

ARG GIT_HASH
ARG GOOS
ARG GOARCH
ARG GOVERSION

WORKDIR /build
RUN git clone https://github.com/evergreen-ci/spruce.git .
RUN yarn

CMD ["yarn", "run", "dev"]


