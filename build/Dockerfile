# docker build -t ghcr.io/jbatonnet/rinkjals/build -f build/Dockerfile build
# docker push ghcr.io/jbatonnet/rinkjals/build

FROM debian:12.8

RUN apt update && \
    apt install -y git wget jq rclone zip && \
    rm -rf /var/lib/apt/lists/*
