FROM debian:stable-slim
ENV VERSION=5.0.6

# Services
EXPOSE 6666
# Plaintext
EXPOSE 6667
# SSL/TLS
EXPOSE 6697

WORKDIR /data

RUN apt -qq update \
    && apt -yqq install  build-essential curl libssl-dev ca-certificates libcurl4-openssl-dev zlib1g sudo python3 \
    && apt clean \
    && useradd -r -d /data unrealircd && chown unrealircd:unrealircd /data \
    && sudo -u unrealircd curl -sSL https://www.unrealircd.org/downloads/unrealircd-${VERSION}.tar.gz \
    | sudo -u unrealircd tar xz  \
    && cd unrealircd-${VERSION}  \
    && sudo -u unrealircd ./Config \
      --with-showlistmodes \
      --with-listen=5 \
      --with-nick-history=2000 \
      --with-sendq=3000000 \
      --with-bufferpool=18 \
      --with-permissions=0600 \
      --with-fd-setsize=1024 \
      --enable-dynamic-linking  \
    && sudo -u unrealircd make -j $( grep -ic 'processor' /proc/cpuinfo)  \
    && sudo -u unrealircd make install \
    && cd /data  \
    && rm -rvf unrealircd-${VERSION}  \
    && apt -yqq remove --purge build-essential libcurl4-openssl-dev \
    && chmod +x /data/unrealircd/unrealircd

USER unrealircd
ENTRYPOINT /data/unrealircd/bin/unrealircd -F
