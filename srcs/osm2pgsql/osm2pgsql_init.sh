#!/bin/bash

if [ ! -d ./osm2pgsql ]; then
	git clone https://github.com/osm2pgsql-dev/osm2pgsql.git /.PBF/osm2pgsql
	cd osm2pgsql/; mkdir build/ && cd build/;
	cmake ../
	make
	make install
fi

echo "alias osm2pgsql=\"/.PBF/osm2pgsql/build/osm2pgsql --output=flex -S /boundaries.lua -W -d $DB_NAME -H $DB_HOST -U $DB_USER\"" > /root/.bashrc

cd /.PBF

echo "OSM2PGSQL_INIT.SH: osm2pgsql is built !!!"

tail -f
