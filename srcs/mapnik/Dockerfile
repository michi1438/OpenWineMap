FROM michael/builder

RUN	apk add --no-cache  python3 harfbuzz-dev proj proj-dev

COPY mapnik_init.sh /
COPY .ccls_host /

WORKDIR /.MAP/
 
CMD ["bash", "/mapnik_init.sh"]
