FROM michael/builder

RUN apk add --no-cache nlohmann-json postgresql-dev \
		expat-dev bzip2-dev zlib-dev \
		libpq proj-dev lua5.3-dev luajit-dev

COPY osm2pgsql_init.sh /

WORKDIR /.PBF/
 
CMD ["bash", "/osm2pgsql_init.sh"]
