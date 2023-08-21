
# Make a build env with everything we need
FROM debian:bookworm as build

ENV GOVER="1.20.7"
ENV GOOS="linux"
ENV GOARCH="arm64"


RUN apt update && apt upgrade -y && \
    apt install -y git make

ADD https://go.dev/dl/go${GOVER}.${GOOS}-${GOARCH}.tar.gz /tmp/go${GOVER}.${GOOS}-${GOARCH}.tar.gz
RUN tar -C /usr/local -xzf /tmp/go${GOVER}.${GOOS}-${GOARCH}.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /build

# Install bom so we can build an SBOM
RUN go install sigs.k8s.io/bom/cmd/bom@latest

COPY . /build
RUN make

# Capture the build artifact information in an SBOM file
RUN /root/go/bin/bom generate --format json --name evergreen --output evergreen.spdx.json . && \
    install -D -m 444 evergreen.spdx.json /var/lib/db/sbom/evergreen.spdx.json


# Make the runtime environment
FROM debian:bookworm-slim as runtime

ENV GOOS="linux"
ENV GOARCH="arm64"

WORKDIR /app
COPY --from=build /build/clients/${GOOS}_${GOARCH}/evergreen .
COPY --from=build /var/lib/db/sbom/evergreen.spdx.json /var/lib/db/sbom/evergreen.spdx.json

CMD ["/app/evergreen", "service", "web"]
