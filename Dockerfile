FROM debian:stable-slim
ARG VERSION=5.0.2

# Services
EXPOSE 6666
# Plaintext
EXPOSE 6667
# SSL/TLS
EXPOSE 6697
RUN apt-get update && \
	apt-get install -y build-essential curl libssl-dev ca-certificates libcurl4-openssl-dev zlib1g sudo python3 && \
	apt-get clean

RUN mkdir /data && useradd -r -d /data unrealircd && chown unrealircd:unrealircd /data
RUN cd /data && sudo -u unrealircd curl -s --location https://www.unrealircd.org/unrealircd4/unrealircd-$VERSION.tar.gz | sudo -u unrealircd tar xz && \
	cd unrealircd-$VERSION && \
	sudo -u unrealircd ./Config \
      --with-showlistmodes \
      --with-listen=5 \
      --with-nick-history=2000 \
      --with-sendq=3000000 \
      --with-bufferpool=18 \
      --with-permissions=0600 \
      --with-fd-setsize=1024 \
      --enable-dynamic-linking && \
    sudo -u unrealircd make && \
    sudo -u unrealircd make install && \
	cd /data && \
	rm -rf unrealircd-$VERSION && \
	chmod +x /data/unrealircd/unrealircd

USER unrealircd
ENTRYPOINT /data/unrealircd/bin/unrealircd -F
