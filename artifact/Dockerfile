FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Annoyingly, add-apt-repository isn't installed by default on Ubuntu Docker images.
# We install software-properties-common to obtain it.
RUN apt-get update -y && \
    apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:hvr/ghc && \
    apt-get update -y && \
    apt-get install -y cabal-install-3.2 ghc-8.8.3 \
      build-essential git autoconf python3 libgmp-dev libncurses-dev xutils-dev

ENV PATH /root/.cabal/bin:/opt/ghc/8.8.3/bin:/opt/cabal/3.2/bin:$PATH

RUN cabal v2-update && \
    cabal install alex happy --constraint='alex==3.2.5' --constraint='happy==1.19.12'

WORKDIR /root/

RUN git clone https://gitlab.haskell.org/ghc/ghc.git

WORKDIR /root/ghc/

RUN git reset --hard 59c023ba5ccb10fff62810591f20608bd73c97af && \
    git submodule update --init --recursive

RUN ./boot && \
    ./configure && \
    ./hadrian/build.sh binary-dist -j --docs=no-sphinx

ENV LYG_VER 8.11.0.20200227

RUN tar -xvf _build/bindist/ghc-${LYG_VER}-x86_64-unknown-linux.tar.xz
WORKDIR ghc-${LYG_VER}-x86_64-unknown-linux
RUN mkdir /opt/ghc/lyg && \
    ./configure --prefix=/opt/ghc/lyg && \
    make install
ENV PATH /opt/ghc/lyg/bin:$PATH

WORKDIR /root/

RUN rm -rf ghc/ghc-${LYG_VER}-x86_64-unknown-linux
