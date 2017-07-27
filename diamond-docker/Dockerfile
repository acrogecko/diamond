FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

# Set the timezone
#
RUN echo "America/Denver" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

# Get the needed packages for the build
#
RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      git yasm curl zip make g++ python-dev net-tools ca-certificates build-essential \
      libboost-all-dev libssl-dev libcurl4-openssl-dev libdb-dev libdb++-dev \
      libgmp-dev libminiupnpc-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create the daemon user
#
ENV HOME /diamond
RUN groupadd -r diamond && useradd --no-log-init -r -s /bin/bash -m -d /diamond -g diamond diamond
RUN chown diamond:diamond -R /diamond

# Pick up the maintenance scripts
#
COPY ./src/bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Get the additional source
#
WORKDIR /diamond
RUN git clone https://github.com/DMDcoin/diamond.git app && mkdir -p app/src/obj

# Build the daemon
#
WORKDIR /diamond/app/src
RUN make -f makefile.unix USE_UPNP=- -e PIE=1 && cp diamondd /usr/local/bin

# Cleanup
#
WORKDIR /diamond
RUN rm -rf app

# Ready to run
#
EXPOSE 17771 17772
USER diamond
CMD ["dmd_oneshot"]