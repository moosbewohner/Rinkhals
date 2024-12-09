# docker build -t ghcr.io/jbatonnet/rinkjals/python -f build/3-python/Dockerfile .
# docker push ghcr.io/jbatonnet/rinkjals/python

FROM --platform=linux/arm/v7 arm32v7/debian:12.8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git && \
    apt install -y libjpeg-dev libsodium23 && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://www.python.org/ftp/python/3.12.7/Python-3.12.7.tgz && \
    tar -xf Python-3.12.7.tgz && \
    rm -rf Python-3.12.7.tgz && \
    cd Python-3.12.7 && \
    ./configure --enable-optimizations && \
    make -j 6 && \
    make altinstall && \
    cd && \
    rm -rf Python-3.12.7

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.12 get-pip.py

COPY ./files/2-external/usr/share/moonraker/scripts/moonraker-requirements.txt moonraker-requirements.txt 

RUN python3.12 -m pip install -r moonraker-requirements.txt && \
    python3.12 -m pip install websockets paho-mqtt aiohttp
