FROM ubuntu:xenial as build

# Build VIPSTARCOIN

RUN apt-get -y update
RUN apt-get -y install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git cmake libboost-all-dev
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get -y update
RUN apt-get -y install libdb4.8-dev libdb4.8++-dev

# enable zeromq
RUN apt-get -y install libzmq3-dev

RUN git clone https://github.com/VIPSTARCOIN/VIPSTARCOIN --recursive
WORKDIR VIPSTARCOIN
RUN git submodule update --init --recursive

# Note autogen will prompt to install some more dependencies if needed
RUN ./autogen.sh
RUN ./configure --with-pic --disable-shared --enable-cxx --disable-bench --disable-tests
RUN make -j2

COPY --from=build /VIPSTARCOIN/src/VIPSTARCOINd /bin/VIPSTARCOINd
COPY --from=build /VIPSTARCOIN/src/VIPSTARCOIN-tx /bin/VIPSTARCOIN-tx
COPY --from=build /VIPSTARCOIN/src/VIPSTARCOIN-cli /bin/VIPSTARCOIN-cli

LABEL version="1.0.0-beta"

EXPOSE 31916
EXPOSE 14889

ENTRYPOINT ["/bin/VIPSTARCOINd"]
CMD ["-help"]
