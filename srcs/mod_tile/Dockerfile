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
 apache2 \
 cron \
 dateutils \
 fonts-hanazono \
 fonts-noto-cjk \
 fonts-noto-hinted \
 fonts-noto-unhinted \
 fonts-unifont \
 gnupg2 \
 gdal-bin \
 liblua5.3-dev \
 lua5.3 \
 mapnik-utils \
 renderd \
 vim \
&& apt-get clean autoclean \
&& apt-get autoremove --yes \
&& rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN adduser --disabled-password --gecos "" $DB_USER 

# Get Noto Emoji Regular font, despite it being deprecated by Google
RUN wget https://github.com/googlefonts/noto-emoji/blob/9a5261d871451f9b5183c93483cbd68ed916b1e9/fonts/NotoEmoji-Regular.ttf?raw=true --content-disposition -P /usr/share/fonts/

# For some reason this one is missing in the default packages
RUN wget https://github.com/stamen/terrain-classic/blob/master/fonts/unifont-Medium.ttf?raw=true --content-disposition -P /usr/share/fonts/

# Install python libraries
# Configure Apache
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" >> /etc/apache2/conf-available/mod_tile.conf \
&& echo "LoadModule headers_module /usr/lib/apache2/modules/mod_headers.so" >> /etc/apache2/conf-available/mod_headers.conf \
&& a2enconf mod_tile && a2enconf mod_headers
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# leaflet
COPY leaflet-demo.html /var/www/html/index.html

# Create volume directories
RUN mkdir -p /run/renderd/ \
  &&  mkdir  -p  /data/style/  \
  &&  mkdir  -p  /var/www/htm/dist/  \
  &&  mkdir  -p  /home/$DB_USER/src/  \
  &&  chown  -R  $DB_USER:  /data/  \
  &&  chown  -R  $DB_USER:  /home/$DB_USER/src/  \
  &&  chown  -R  $DB_USER:  /run/renderd  \
  &&  mv  /var/cache/renderd/tiles/            /data/tiles/     \
  &&  chown  -R  $DB_USER: /data/tiles \
  &&  ln  -s  /data/style              /home/$DB_USER/src/openstreetmap-carto  \
  &&  ln  -s  /data/tiles              /var/cache/renderd/tiles                \
;

RUN echo '[default] \n\
URI=/tile/ \n\
TILEDIR=/var/cache/renderd/tiles \n\
XML=/home/owmuser/src/openstreetmap-carto/mapnik.xml \n\
HOST=localhost \n\
TILESIZE=256 \n\
MAXZOOM=20' >> /etc/renderd.conf \
 && sed -i 's,/usr/share/fonts/truetype,/usr/share/fonts,g' /etc/renderd.conf

RUN chmod -R 777 /home/$DB_USER/src/*
COPY mapnik.xml /
COPY mod_tile_init.sh /

COPY L.Control.Opacity.css /var/www/html/dist/
COPY L.Control.Opacity.js /var/www/html/dist/

RUN sed "s/80/8080/" -i /etc/apache2/ports.conf

WORKDIR /home/$DB_USER/src/

cmd ["bash", "/mod_tile_init.sh"]

EXPOSE 8080
