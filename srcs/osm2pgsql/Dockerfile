FROM alpine:3.20.3

WORKDIR /

RUN apk update && \
	apk add --no-cache cmake make g++ git nlohmann-json \
		postgresql-dev boost-dev expat-dev bzip2-dev zlib-dev \
		libpq proj-dev lua5.3-dev luajit-dev

RUN git clone https://github.com/osm2pgsql-dev/osm2pgsql.git
 
CMD ["tail", "-f"]

#EXPOSE 5432 
