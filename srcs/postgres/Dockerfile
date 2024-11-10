FROM alpine:3.20.3

WORKDIR /

RUN apk update && \
	apk add --no-cache postgis bash

COPY ./postgis_init.sh ./
COPY ./postgres_dirs.sh ./

RUN bash ./postgres_dirs.sh

USER postgres

CMD ["bash", "./postgis_init.sh"]

EXPOSE 5432 
