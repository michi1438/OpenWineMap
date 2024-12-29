#!/bin/bash

if [ ! -d /.MAP/mapnik ]; then
	git clone https://github.com/mapnik/mapnik.git
	cd mapnik/
	git submodule update --init
	./configure	 DEMO=True
	JOBS=10 make
	make install
fi

mv /.ccls_host /.MAP/mapnik/.ccls
chmod -R 777 /.MAP/mapnik/demo/c++/*

echo "MAPNIK_INIT.SH: mapnik is built !!!"

cd /.MAP

tail -f
