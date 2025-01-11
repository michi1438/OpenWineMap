#!/bin/bash
#rm -rf /tmp/mod_tile_src /tmp/mod_tile_build
#mkdir /tmp/mod_tile_src /tmp/mod_tile_build
#cd /tmp/mod_tile_src
#git clone --depth 1 https://github.com/openstreetmap/mod_tile.git .
#cd /tmp/mod_tile_buILD
#cmake -B . -S /tmp/mod_tile_src \
#  -DCMAKE_BUILD_TYPE:STRING=Release \
#  -DCMAKE_INSTALL_LOCALSTATEDIR:PATH=/var \
#  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
#  -DCMAKE_INSTALL_RUNSTATEDIR:PATH=/run \
#  -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
#  -DENABLE_TESTS:BOOL=ON
#cmake --build .
#ctest
#cmake --install . --strip
#
## Create /usr/share/renderd directory
#mkdir --parents /usr/share/renderd
#
## Copy files of example map
#cp -av /tmp/mod_tile_src/utils/example-map /usr/share/renderd/example-map
#
## Add configuration
#cp -av /tmp/mod_tile_src/etc/apache2/renderd-example-map.conf /etc/httpd/conf/extra/httpd-tile-renderd-example-map.conf
#printf '\n[example-map]\nURI=/tiles/renderd-example\nXML=/usr/share/renderd/example-map/mapnik.xml\n' | tee -a /etc/renderd.conf
#printf '\n[example-map-jpg]\nTYPE=jpg image/jpeg jpeg\nURI=/tiles/renderd-example-jpg\nXML=/usr/share/renderd/example-map/mapnik.xml\n' | tee -a /etc/renderd.conf
#printf '\n[example-map-png256]\nTYPE=png image/png png256\nURI=/tiles/renderd-example-png256\nXML=/usr/share/renderd/example-map/mapnik.xml\n' | tee -a /etc/renderd.conf
#printf '\n[example-map-png32]\nTYPE=png image/png png32\nURI=/tiles/renderd-example-png32\nXML=/usr/share/renderd/example-map/mapnik.xml\n' | tee -a /etc/renderd.conf
#printf '\n[example-map-webp]\nTYPE=webp image/webp webp\nURI=/tiles/renderd-example-webp\nXML=/usr/share/renderd/example-map/mapnik.xml\n' | tee -a /etc/renderd.conf
#
## Enable configuration
#printf '\nInclude conf/extra/httpd-tile.conf\n' | tee -a /etc/httpd/conf/httpd.conf
#printf '\nInclude conf/extra/httpd-tile-renderd-example-map.conf\n' | tee -a /etc/httpd/conf/httpd.conf
#
## Start services

IF [ ! -d ~/src ]; then
	mkdir ~/src
	cd ~/src
	git clone --progress https://github.com/gravitystorm/openstreetmap-carto
	cd openstreetmap-carto
	git pull --all
	git switch --detach v5.9.0
fi

carto -v

carto project.mml > mapnik.xml

httpd
renderd -f
