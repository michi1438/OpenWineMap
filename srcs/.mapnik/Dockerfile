FROM michael/builder

RUN	apk add --no-cache  python3 harfbuzz-dev proj proj-dev

COPY mapnik_init.sh /
COPY test_mapnik/ /test_mapnik/
COPY .ccls_host /

WORKDIR /.MAP/mapnik/demo/test_mapnik
 
CMD ["bash", "/mapnik_init.sh"]
