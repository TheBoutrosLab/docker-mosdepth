ARG MINIFORGE_VERSION=24.9.2-0
ARG UBUNTU_VERSION=24.04

FROM condaforge/mambaforge:${MINIFORGE_VERSION} AS builder

# Use mamba to install tools and dependencies into /usr/local
ARG TOOL_VERSION=X.X.X
RUN mamba create -qy -p /usr/local \
    -c bioconda \
    -c conda-forge \
    tool_name==${TOOL_VERSION}

# Deploy the target tools into a base image
FROM ubuntu:${UBUNTU_VERSION} AS final
COPY --from=builder /usr/local /usr/local

# Add a new user/group called bldocker
RUN groupadd -g 500001 bldocker && \
    useradd -r -u 500001 -g bldocker bldocker

# Change the default user to bldocker from root
USER bldocker

LABEL   maintainer="Your Name <YourName@sbpdiscovery.org>" \
        org.opencontainers.image.source=https://github.com/TheBoutrosLab/<REPO>
