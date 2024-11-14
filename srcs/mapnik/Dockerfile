FROM michael/builder

RUN	apk add --no-cache  python3 harfbuzz-dev 

COPY mapnik_init.sh /

WORKDIR /.MAP/
 
CMD ["bash", "/mapnik_init.sh"]
