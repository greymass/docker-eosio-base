FROM ubuntu:20.04 as build-stage

# install build deps
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  autotools-dev \
  build-essential \
  bzip2 \
  ca-certificates \
  clang \
  cmake \
  curl \
  doxygen \
  git \
  gnupg \
  graphviz \
  libbz2-dev \
  libcurl4-gnutls-dev \
  libgmp3-dev \
  libpq-dev \
  libssl-dev \
  libtool \
  libusb-1.0-0-dev \
  llvm-7-dev \
  lsb-release \
  make \
  patch \
  pkg-config \
  python2.7 \
  python2.7-dev \
  python3 \
  python3-dev \
  ruby \
  sudo \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# setup build time variables
ARG EOSIO_VERSION=v2.1.0
ARG EOSIO_REPOSITORY=https://github.com/EOSIO/eos.git
ARG EOSIO_BUILD=Release

# build and install eosio
WORKDIR /tmp
RUN git clone --branch $EOSIO_VERSION --depth 1 $EOSIO_REPOSITORY . \
  && git submodule update --init --recursive
RUN ./scripts/eosio_build.sh -y -o $EOSIO_BUILD -i /eosio
RUN ./scripts/eosio_install.sh

# runtime image
FROM ubuntu:20.04

# runtime deps
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
  libcurl3-gnutls \
  libpq5 \
  libtinfo5 \
  libusb-1.0-0 \
  && rm -rf /var/lib/apt/lists/*

# copy eosio install
COPY --from=build-stage /eosio /eosio

# setup runtime env
ARG EOSIO_VERSION=v2.1.0
ENV EOSIO_VERSION=$EOSIO_VERSION
ENV PATH="/eosio/bin:${PATH}"
