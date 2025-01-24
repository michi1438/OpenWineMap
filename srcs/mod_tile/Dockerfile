FROM ubuntu:22.04 AS compiler-common
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DB_USER owmuser
ENV G_MESSAGES_DEBUG=all

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
 ca-certificates gnupg lsb-release locales \
 wget curl \
 git-core unzip unrar \
&& locale-gen $LANG && update-locale LANG=$LANG \
&& apt-get update && apt-get -y upgrade

RUN mkdir -p /home/$DB_USER/src \

###########################################################################################################

FROM compiler-common AS final

# Based on
# https://switch2osm.org/serving-tiles/manually-building-a-tile-server-18-04-lts/
ENV DEBIAN_FRONTEND=noninteractive
ENV AUTOVACUUM=on
ENV UPDATES=disabled
ENV REPLICATION_URL=https://planet.openstreetmap.org/replication/hour/
ENV MAX_INTERVAL_SECONDS=3600
ENV PG_VERSION 15

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Get packages
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
 make \
 cmake \
 apache2 \
 apache2-dev \
 libiniparser-dev \
 dateutils \
 libboost-all-dev \
 g++ \
 libpq-dev \
 gnupg2 \
 libgdal-dev\
 liblua5.3-dev \
 libharfbuzz-dev \
 pkg-config \
 lua5.3 \
 python3 \
 vim \
 proj-bin \
 libproj-dev \
 libcairo2-dev \
&& apt-get clean autoclean \
&& apt-get autoremove --yes \
&& rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN adduser --disabled-password --gecos "" $DB_USER 

# Install python libraries
# Configure Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# leaflet
COPY leaflet-demo.html /var/www/html/index.html

# Create volume directories
RUN mkdir -p /run/renderd/ \
  &&  mkdir  -p  /data/style/  \
  &&  mkdir  -p  /var/www/htm/dist/  \
  &&  mkdir  -p  /.MAP \
  &&  mkdir  -p  /home/$DB_USER/src/  \
  &&  chown  -R  $DB_USER:  /data/  \
  &&  chown  -R  $DB_USER:  /home/$DB_USER/src/  \
  &&  chown  -R  $DB_USER:  /run/renderd  \
  &&  ln  -s  /data/style              /home/$DB_USER/src/openstreetmap-carto  \
;

RUN chmod -R 777 /home/$DB_USER/src/*
COPY mapnik.xml /
COPY mod_tile_init.sh /

COPY .ccls_host /
COPY myrenderd.conf /myrenderd.conf
COPY test_mapnik/ /test_mapnik/
COPY L.Control.Opacity.css /var/www/html/dist/
COPY L.Control.Opacity.js /var/www/html/dist/

RUN sed "s/80/8080/" -i /etc/apache2/ports.conf

WORKDIR /home/$DB_USER/src/

cmd ["bash", "/mod_tile_init.sh"]

EXPOSE 8080
