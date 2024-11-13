FROM alpine:3.20.3

WORKDIR /

COPY mapnik_init.sh /

RUN apk update && \
	apk add --no-cache bash vim g++ make git python3 \
		boost-dev harfbuzz-dev libpq-dev

WORKDIR /.MAP/

 
CMD ["bash", "/mapnik_init.sh"]

#EXPOSE 5432 
