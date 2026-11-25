ARG NIM_VERSION=2.2.14
ARG UBUNTU_VERSION=24.04

FROM nimlang/nim:${NIM_VERSION} AS builder

ARG MOSDEPTH_VERSION=0.3.15
ARG MOSDEPTH_SHA256=7fc4bacd5cd1fecad76c93f08921e32efaad2ebabccd7a65e6f4fdf9095ea08e

WORKDIR /src

# Download the release source, verify its checksum, and build
RUN curl -fsSL -o mosdepth.tar.gz \
        https://github.com/brentp/mosdepth/archive/refs/tags/v${MOSDEPTH_VERSION}.tar.gz && \
    echo "${MOSDEPTH_SHA256}  mosdepth.tar.gz" | sha256sum -c - && \
    tar -xzf mosdepth.tar.gz --strip-components=1 && \
    nimble build -y -d:release && \
    install -m 0755 mosdepth /usr/local/bin/mosdepth

FROM ubuntu:${UBUNTU_VERSION} AS final

# mosdepth dlopens the unversioned libhts.so at runtime, which only
# libhts-dev provides; link it to the runtime library instead
RUN apt-get update && \
    apt-get install -y --no-install-recommends libhts3t64 && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s libhts.so.3 /usr/lib/$(uname -m)-linux-gnu/libhts.so

COPY --from=builder /usr/local/bin/mosdepth /usr/local/bin/mosdepth

# Add a new user/group called bldocker
RUN groupadd -g 500001 bldocker && \
    useradd -m -r -u 500001 -g bldocker bldocker

# Change the default user to bldocker from root
USER bldocker

LABEL maintainer="Yash Patel <ypatel@sbpdiscovery.org>" \
      org.opencontainers.image.source=https://github.com/TheBoutrosLab/docker-mosdepth \
      org.opencontainers.image.description="Dockerfile for mosdepth"
