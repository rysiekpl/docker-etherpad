FROM debian:jessie
MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>

ENV DEBIAN_FRONTEND noninteractive
ENV ETHERPAD_VERSION 1.5.7

# install the required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        git-core \
        curl \
        python \
        libssl-dev \
        pkg-config \
        build-essential \
        ca-certificates \
        npm \
        tidy \
        abiword \
        --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# yeah, we need that because bin/installDeps.sh looks for node
# and debian has nodejs
RUN ln -s /usr/bin/nodejs /usr/bin/node

# yay, clone the repo!
RUN git clone -b "release/$ETHERPAD_VERSION" --single-branch https://github.com/ether/etherpad-lite.git /opt/etherpad && \
    rm -rf /opt/etherpad/.git

# make it sane, security-wise
RUN groupadd -r etherpad && \
    useradd -d /opt/etherpad -r -g `getent group etherpad | cut -d: -f3` etherpad && \
    mkdir -p /opt/etherpad/config && \
    chown -R etherpad:etherpad /opt/etherpad && \
    ln -s /opt/etherpad/config/settings.json /opt/etherpad/settings.json

# install the deps
RUN cd /opt/etherpad/ && \
    chown -R etherpad:etherpad ./ && \
    chmod ug+x start && \
    bin/installDeps.sh &&
    npm install ep_ldapauth

# entrypoint script
COPY start.sh /opt/etherpad/start
    
# expose, volume
EXPOSE 9001
VOLUME ['/opt/etherpad/config/'] # config

# user, workdir
WORKDIR "/opt/etherpad"

# command
CMD ["/opt/etherpad/start"]