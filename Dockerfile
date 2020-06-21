FROM alpine:3.9
MAINTAINER Juvenal A. Silva Jr. <juvenal.silva.jr@gmail.com>

ENV VERSION 2.3.7
ENV PAR2 0.8.0

# Create user and group for SABnzbd.
RUN addgroup -S -g 666 sabnzbd \
    && adduser -S -u 666 -G sabnzbd -h /home/sabnzbd -s /bin/sh sabnzbd

# This is SABnzbd basic install with requirements
RUN apk add --no-cache ca-certificates openssl python py-pip py-six py-cryptography libgomp \
                       py-enum34 py-cffi py-openssl py-cheetah shadow unzip unrar p7zip \
                       build-base automake autoconf python-dev \
    && cd /tmp \
    && wget -O- https://github.com/Parchive/par2cmdline/archive/v$PAR2.tar.gz | tar -zx \
    && cd par2cmdline-$PAR2 \
    && aclocal \
    && automake --add-missing \
    && autoconf \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && cd .. \
    && rm -rf par2cmdline-$PAR2 \
    && pip --no-cache-dir install --upgrade sabyenc requests \
    && apk del build-base automake autoconf python-dev \
    && cd /opt \
    && wget -O- https://github.com/sabnzbd/sabnzbd/archive/$VERSION.tar.gz | tar -zx \
    && mv sabnzbd-$VERSION sabnzbd \
    && mkdir -p /mnt/data \
    && mkdir -p /mnt/data/watch \
    && mkdir -p /mnt/downloads

# Add SABnzbd init script.
COPY entrypoint.sh /home/sabnzbd/entrypoint.sh
RUN chmod 755 /home/sabnzbd/entrypoint.sh

VOLUME ["/mnt/data", "/mnt/data/watch", "/mnt/downloads"]

EXPOSE 8080

WORKDIR /home/sabnzbd

CMD ["./entrypoint.sh"]
