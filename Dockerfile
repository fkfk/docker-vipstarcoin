FROM ubuntu:xenial as build

# Build VIPSTARCOIN

RUN set -x \
 && apt-get -y update \
 && apt-get -y install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git cmake libboost-all-dev libzmq3-dev software-properties-common \
 && add-apt-repository ppa:bitcoin/bitcoin \
 && apt-get -y update \
 && apt-get -y install libdb4.8-dev libdb4.8++-dev

RUN mkdir /tmp/build
WORKDIR /tmp/build
RUN git clone https://github.com/VIPSTARCOIN/VIPSTARCOIN-bitcore --recursive
WORKDIR /tmp/build/VIPSTARCOIN-bitcore
RUN git submodule update --init --recursive

# Note autogen will prompt to install some more dependencies if needed
RUN set -x \
 && chmod 755 ./autogen.sh \
 && ./autogen.sh
RUN ./configure --with-pic --disable-shared --enable-cxx --disable-bench --disable-tests -without-gui
RUN make

COPY --from=build /tmp/build/VIPSTARCOIN-bitcore/src/VIPSTARCOINd /bin/VIPSTARCOINd
COPY --from=build /tmp/build/VIPSTARCOIN-bitcore/src/VIPSTARCOIN-tx /bin/VIPSTARCOIN-tx
COPY --from=build /tmp/build/VIPSTARCOIN-bitcore/src/VIPSTARCOIN-cli /bin/VIPSTARCOIN-cli

LABEL version="1.0.0-beta"

EXPOSE 31916
EXPOSE 14889

ENTRYPOINT ["/bin/VIPSTARCOINd"]
CMD ["-help"]
