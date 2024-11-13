FROM alpine:3.20.3

WORKDIR /

COPY osm2pgsql_init.sh /

RUN apk update && \
	apk add --no-cache vim bash cmake make g++ git nlohmann-json \
		postgresql-dev boost-dev expat-dev bzip2-dev zlib-dev \
		libpq proj-dev lua5.3-dev luajit-dev


RUN mkdir build

WORKDIR /.PBF/
 
CMD ["bash", "/osm2pgsql_init.sh"]

#EXPOSE 5432 
