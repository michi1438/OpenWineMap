FROM ubuntu:22.04 AS compiler-common
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ARG DB_USER
ARG G_MESSAGES_DEBUG=all

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
 ca-certificates gnupg lsb-release locales \
 git-core \
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

#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
 libharfbuzz-dev \
 pkg-config \
 python3 \
 vim \
 proj-bin \
 libproj-dev \
 libcairo2-dev \
 python3-psycopg2 \
&& apt-get clean autoclean \
&& apt-get autoremove --yes \
&& rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN adduser --disabled-password --gecos "" $DB_USER 

# Install python libraries
# Configure  Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# leaflet
COPY leaflet-demo.html /
COPY tech_sheet/base_tech_sheet.html /base_tech_sheet.html

# Create volume directories
RUN mkdir  -p /run/renderd/ \
  && mkdir -p /data/style/  \
  && mkdir -p /var/www/htm/dist/  \
  && mkdir -p /var/www/cgi-bin/  \
  && mkdir -p /home/$DB_USER/db_connect/  \
  && mkdir -p /.MAP \
  && mkdir -p /home/$DB_USER/src/  \
  && mkdir -p /var/cache/renderd/tiles/  \
  && mkdir -p /data/styler /home/$DB_USER/src/openstreetmap-carto \
  && chown -R $DB_USER:  /var/www/  \
  && chown -R $DB_USER:  /data/  \
  && chown -R $DB_USER:  /home/$DB_USER/src/  \
  && chown -R $DB_USER:  /home/$DB_USER/db_connect/  \
  && chown -R $DB_USER:  /run/renderd ;


RUN chmod -R 777 /home/$DB_USER/src/*
COPY mod_tile_init.sh /

COPY myrenderd.conf /myrenderd.conf
COPY test_mapnik/ /test_mapnik/
COPY import_for_leaflet/* /var/www/html/dist/
COPY def_aop/ /def_aop/

RUN chmod -R 777 /def_aop/

RUN sed "s/80/8080/" -i /etc/apache2/ports.conf

cmd ["bash", "/mod_tile_init.sh"]

EXPOSE 8080
