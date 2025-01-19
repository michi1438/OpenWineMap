#!/bin/bash

if [ ! -d /home/$DB_USER/src/openstreetmap-carto ]; then

	GIT clone --progress --single-branch --branch v5.6.x https://github.com/gravitystorm/openstreetmap-carto.git --depth 1
	cd openstreetmap-carto
	sed -i 's/, "unifont Medium", "Unifont Upper Medium"//g' style/fonts.mss
	sed -i 's/"Noto Sans Tibetan Regular",//g' style/fonts.mss
	sed -i 's/"Noto Sans Tibetan Bold",//g' style/fonts.mss
	sed -i 's/Noto Sans Syriac Eastern Regular/Noto Sans Syriac Regular/g' style/fonts.mss
	rm -rf .git

fi

mv -v /mapnik.xml /home/$DB_USER/src/openstreetmap-carto/

echo "MOD_TILE_INIT.SH: mod_tile is up!!!"

tail -f
