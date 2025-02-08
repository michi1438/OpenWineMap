#!/bin/bash

export PYTHON=/bin/python3

if [ ! -d /home/$DB_USER/src/openstreetmap-carto ]; then

	git clone --progress --single-branch --branch v5.6.x https://github.com/gravitystorm/openstreetmap-carto.git --depth 1
	cd openstreetmap-carto
	sed -i 's/, "unifont Medium", "Unifont Upper Medium"//g' style/fonts.mss
	sed -i 's/"Noto Sans Tibetan Regular",//g' style/fonts.mss
	sed -i 's/"Noto Sans Tibetan Bold",//g' style/fonts.mss
	sed -i 's/Noto Sans Syriac Eastern Regular/Noto Sans Syriac Regular/g' style/fonts.mss
	rm -rf .git

fi

if [ ! -d /.MAP/mapnik ]; then
	pushd /.MAP/
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
	JOBS=$(nproc) make
	make install
	popd
else
	cd /.MAP/mapnik/
	(
		make install
	)
fi
cp -r -v /.MAP/mapnik/deps/mapbox/polylabel/include/* /usr/include/mapbox/ 
cp -r -v /.MAP/mapnik/deps/mapbox/geometry/include/mapbox/* /usr/include/mapbox/
cp -r -v /.MAP/mapnik/deps/mapbox/geometry/include/* /usr/include/mapbox/
cp -r -v /.MAP/mapnik/deps/mapbox/variant/include/* /usr/include/

echo "MOD_TILE_INIT.SH: mapnik is built !!!"

if [ ! -f /tmp/mod_tile_build/src/renderd ]; then
	export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)
	rm -rf /tmp/mod_tile_src /tmp/mod_tile_build
	mkdir /tmp/mod_tile_src /tmp/mod_tile_build
	cd /tmp/mod_tile_src
   	(
		git clone --progress --depth 1 \
			https://github.com/openstreetmap/mod_tile.git . 
	)
	cd /tmp/mod_tile_build
	(
		cmake -B . -S /tmp/mod_tile_src \
		  -DCMAKE_BUILD_TYPE:STRING=Release \
		  -DCMAKE_INSTALL_LOCALSTATEDIR:PATH=/var \
		  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
		  -DCMAKE_INSTALL_RUNSTATEDIR:PATH=/run \
		  -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc 
		cmake --build .
		cmake --install . --strip
		echo "MOD_TILE_INIT.SH: mod_tile is up!!!"
	)
else
	cd /tmp/mod_tile_build/
	(
		cmake --install . --strip
		echo "MOD_TILE_INIT.SH: mod_tile is up!!!"
	)
fi

# Enable configuration
a2enmod tile
a2ensite 000-default

source /etc/apache2/envvars

mv -v /.ccls_host /.MAP/mapnik/.ccls
rm -rf /.MAP/mapnik/demo/test_mapnik 
mv -v /test_mapnik /.MAP/mapnik/demo/test_mapnik
cp -v /myrenderd.conf /etc/renderd.conf
chmod -R 777 /.MAP/mapnik/demo/*

pushd /.MAP/mapnik/demo/test_mapnik/
	make && ./aquitaine;
popd

rm -rf /var/cache/renderd/tiles/*

service apache2 start
renderd -f
