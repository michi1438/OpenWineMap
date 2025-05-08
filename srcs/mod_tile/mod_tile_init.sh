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

	git clone --single-branch --branch "v4.0.4" --depth 1 --progress https://github.com/mapnik/mapnik.git
	cd mapnik/
	git fetch --unshallow
	git pull
	git submodule update --init
	./configure	 DEMO=True
	JOBS=$(nproc --ignore=2) make
	JOBS=$(nproc --ignore=2) make install
	popd
else
	cd /.MAP/mapnik/
	(
		JOBS=$(nproc --ignore=2) make install
	)
fi
cp -r -v /.MAP/mapnik/deps/mapbox/polylabel/include/* /usr/include/mapbox/ 
cp -r -v /.MAP/mapnik/deps/mapbox/geometry/include/mapbox/* /usr/include/mapbox/
cp -r -v /.MAP/mapnik/deps/mapbox/geometry/include/* /usr/include/mapbox/
cp -r -v /.MAP/mapnik/deps/mapbox/variant/include/* /usr/include/

echo "MOD_TILE_INIT.SH: mapnik is built !!!"

if [ ! -f /tmp/mod_tile_build/src/renderd ]; then
	rm -rf /tmp/mod_tile_src /tmp/mod_tile_build
	mkdir /tmp/mod_tile_src /tmp/mod_tile_build
	cd /tmp/mod_tile_src
   	(
		git clone --progress --depth 1 \
			https://github.com/openstreetmap/mod_tile.git . 
		sed -i 's/100$/10000/' includes/render_config.h
	)
	cd /tmp/mod_tile_build
	(
		CMAKE_BUILD_PARALLEL_LEVEL=$(nproc --ignore=2) cmake -B . -S /tmp/mod_tile_src \
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

diff -x *.o -x *.png -x *.out /test_mapnik /.MAP/mapnik/demo/test_mapnik
if [ ! $? -eq 0 ]; then
	rm -rf /.MAP/mapnik/demo/test_mapnik 
	mv -v /test_mapnik /.MAP/mapnik/demo/test_mapnik
else
	echo "MOD_TILE_INIT.SH: using the previous test_mapnik dir no change were spoted!!!"
	echo
fi


mv -v /.ccls_host /.MAP/mapnik/.ccls
mv -v /leaflet-demo.html /var/www/html/index.html
cp -v /myrenderd.conf /etc/renderd.conf
chmod -R 777 /.MAP/mapnik/demo/*

sed -i "s/<NUM_THREADS>/$(nproc --ignore=2)/" /etc/renderd.conf

sed -i 's/.*ScriptAlias \/cgi-bin\/ \/usr\/lib\/cgi-bin\/.*/\t\tScriptAlias \/cgi-bin\/ \/var\/www\/cgi-bin\//' /etc/apache2/conf-available/serve-cgi-bin.conf 
sed -i 's/.*<Directory "\/usr\/lib\/cgi-bin">.*/\t\t<Directory "\/var\/www\/cgi-bin\/">/' /etc/apache2/conf-available/serve-cgi-bin.conf
sed -i 's/ -MultiViews +SymLinksIfOwnerMatch//' /etc/apache2/conf-available/serve-cgi-bin.conf
sed -i '/Require all granted/d' /etc/apache2/conf-available/serve-cgi-bin.conf  

sed -i "s/<DB_NAME>/$DB_NAME/" /etc/apache2/sites-available/000-default.conf
sed -i "s/<DB_USER>/$DB_USER/" /etc/apache2/sites-available/000-default.conf
sed -i "s/<DB_USER_PW>/$DB_USER_PW/" /etc/apache2/sites-available/000-default.conf
sed -i "s/<DB_HOST>/$DB_HOST/" /etc/apache2/sites-available/000-default.conf
sed -i "s/<DB_PORT>/$DB_PORT/" /etc/apache2/sites-available/000-default.conf

printf "#########     Adding capaility to run CGI-scripts #################\n
ServerName localhost\n
ScriptAlias /cgi-bin/ /var/www/cgi-bin/\n
Options +ExecCGI\n
AddHandler cgi-script .cgi .pl .py\n" >> /etc/apache2/apache2.conf

cd /home/$DB_USER/db_connect/
(
	mv -v /def_aop/cgi_hook.py /var/www/cgi-bin/
	mv -v /def_aop/* ./
	python3 def_appelations.py #> def_appelation.out
	python3 lay_renderd.py
)

cd /.MAP/mapnik/demo/test_mapnik/
(
	mkdir -v /home/$DB_USER/src/openstreetmap-carto/highlighted/
	python3 iter_mapnik.py
)

pushd /home/$DB_USER/db_connect/
	python3 lay_highlights.py
popd

# Enable configuration
a2enmod tile
a2enmod cgi 
a2enmod env 
a2ensite 000-default

source /etc/apache2/envvars

echo
echo Testing no internet no rendering, no server
tail -f

echo
echo Starting APACHE2
apache2 -E apache2_startup.log; cat /etc/apache2/apache2_startup.log | grep warn 

echo
echo Starting RENDERD
renderd -f > /var/log/renderd_output.log  #TODO filter output to not get all maps ouputed maybe with awk...
