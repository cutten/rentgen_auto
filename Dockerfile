FROM alpine:3.18

ARG XRAY_CORE_VERSION=v25.12.8
ENV SNI=dl.google.com

RUN apk add --no-cache \
    wget \
    unzip \
    build-base \
    cmake \
    libpng-dev \
    jq \
    curl

RUN wget https://github.com/fukuchi/libqrencode/archive/refs/heads/master.zip -O /tmp/libqrencode.zip

RUN unzip /tmp/libqrencode.zip -d /opt/ && rm /tmp/libqrencode.zip

WORKDIR /opt/libqrencode-master

RUN mkdir build && cd build && \
    cmake .. && \
    make && \
    make install

RUN rm -rf /opt/libqrencode-master

RUN set -e &&\
    wget https://github.com/XTLS/Xray-core/releases/download/${XRAY_CORE_VERSION}/Xray-linux-64.zip &&\
    mkdir /opt/xray &&\
    mkdir /opt/xray/config &&\
    unzip ./Xray-linux-64.zip -d /opt/xray  &&\
    rm -rf Xray-linux-64.zip

WORKDIR /opt/xray

COPY ./deployment/config/default-config.json ./default-config/config.json
COPY ./scripts ./scripts
RUN chmod -R 755 ./scripts
COPY ./entrypoint.sh .

EXPOSE 443
ENTRYPOINT [ "/bin/sh","./entrypoint.sh" ]
#ENTRYPOINT ["tail", "-f", "/dev/null"]



