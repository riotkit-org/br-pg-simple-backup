ARG POSTGRES_VERSION
ARG GO_VERSION

# ========================================
#  Collect specific version of PostgreSQL
# ========================================
FROM postgres:${POSTGRES_VERSION} as postgres

ARG POSTGRES_VERSION=${POSTGRES_VERSION}

RUN apt-get update && apt-get install python3 make bash util-linux gcc-multilib file patchelf -y

ADD . /workspace
WORKDIR /workspace

# collect binaries and libraries in .build/data directory
RUN cd /workspace && make copy_libs_and_executables POSTGRES_VERSION=${POSTGRES_VERSION}


# =============================================
#  Build application && embed PostgreSQL in it
# =============================================
FROM golang:${GO_VERSION} as builder

COPY --from=postgres /workspace /workspace
RUN apt-get update && apt-get install make -y

RUN cd /workspace && \
    make build
