# docker build -t ghcr.io/jbatonnet/rinkjals/buildroot -f build/1-buildroot/Dockerfile build/1-buildroot
# docker push ghcr.io/jbatonnet/rinkjals/buildroot

# docker run --rm -it -v .\build\buildroot:/config -v .\build\target:/output ghcr.io/jbatonnet/rinkjals/buildroot
# docker run --rm -it -v .\build\buildroot:/config -v .\build\target:/output ghcr.io/jbatonnet/rinkjals/buildroot ./edit-config.sh
# docker run --rm -it -v .\build\buildroot:/config -v .\build\target:/output ghcr.io/jbatonnet/rinkjals/buildroot ./build-target.sh

FROM debian:12.8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y build-essential bash bc binutils build-essential bzip2 cpio g++ gcc git gzip locales libncurses5-dev libdevmapper-dev libsystemd-dev make mercurial whois patch perl python3 rsync sed tar vim unzip wget bison flex libssl-dev libfdt-dev file && \
    rm -rf /var/lib/apt/lists/*

# Sometimes Buildroot need proper locale, e.g. when using a toolchain based on glibc
RUN locale-gen en_US.utf8

WORKDIR /buildroot
RUN git clone https://gitlab.com/buildroot.org/buildroot.git --depth=1 --branch=2024.08.x /buildroot

COPY *.sh /buildroot
RUN chmod +x /buildroot/*.sh

# Configuration redirect
RUN mkdir /config
RUN ln -s /config/.config .config
VOLUME /config

# Download cache redirect
RUN mkdir /cache
RUN ln -s /cache dl
VOLUME /cache

# Output redirect
RUN mkdir /output
# RUN ln -s /output output
ENV O=/output

#VOLUME /buildroot/output

ENV FORCE_UNSAFE_CONFIGURE=1
