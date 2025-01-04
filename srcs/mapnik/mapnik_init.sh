#!/bin/bash

if [ ! -d /.MAP/mapnik ]; then
	git config --global http.version HTTP/1.1
	git config --global http.postBuffer 524288000
	git config --global http.lowSpeedLimit 0
	git config --global http.lowSpeedTime 999999
	git config --global core.compression 0

	git clone --depth 1 --progress https://github.com/mapnik/mapnik.git
	git fetch --unshallow
	git pull
	cd mapnik/
	git submodule update --init
	./configure	 DEMO=True
	JOBS=10 make
	make install
else
	cd /.MAP/mapnik/
	make install
fi

mv -v /.ccls_host /.MAP/mapnik/.ccls
rm -rf /.MAP/mapnik/demo/test_mapnik 
mv -v /test_mapnik /.MAP/mapnik/demo/test_mapnik
chmod -R 777 /.MAP/mapnik/demo/*

echo "MAPNIK_INIT.SH: mapnik is built !!!"

tail -f
