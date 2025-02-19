FROM michael/simple

COPY ./postgis_init.sh ./
COPY ./postgres_dirs.sh ./

RUN apk add --no-cache postgresql postgis postgresql-contrib

COPY commune_not_found.sql /
RUN bash ./postgres_dirs.sh

USER postgres

CMD ["bash", "./postgis_init.sh"]

EXPOSE 5432 
