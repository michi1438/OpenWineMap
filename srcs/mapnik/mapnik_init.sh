#!/bin/bash

if [ ! -f ./mapnik ]; then

	git clone https://github.com/mapnik/mapnik.git
	cd mapnik/
	./configure	
	JOBS=4 make
	make install
fi

echo "MAPNIK_INIT.SH: mapnik is built !!!"

cd /.MAP

tail -f
