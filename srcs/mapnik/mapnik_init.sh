#!/bin/bash

if [ ! -d /.MAP/mapnik ]; then
	git clone https://github.com/mapnik/mapnik.git
	cd mapnik/
	git submodule update --init
	./configure	
	JOBS=4 make
	make install
fi

echo "MAPNIK_INIT.SH: mapnik is built !!!"

cd /.MAP

tail -f
