#!/bin/bash

bash
cd

CHECK=$(cat /var/lib/postgresql/data/pg_hba.conf | wc -l)
if [ "${CHECK}" != "3" ]
then
	echo "INITS THE DB"
	mkdir /var/lib/postgresql/data
	chmod 700 /var/lib/postgresql/data
	initdb -D /var/lib/postgresql/data

	sed -i '/.*replication.*all.*/d' /var/lib/postgresql/data/pg_hba.conf 
	sed -i '/^#.*/d' /var/lib/postgresql/data/pg_hba.conf 
	sed -i 's/127\.0\.0\.1\/32/172\.28\.0\.0\/16/' /var/lib/postgresql/data/pg_hba.conf
	sed -i '/^$/d' /var/lib/postgresql/data/pg_hba.conf

	pg_ctl start -D /var/lib/postgresql/data -o "-p 10"
	psql -p 10 -c "CREATE USER $DB_USER WITH PASSWORD '$DB_USER_PW';"
	createdb -p 10 --encoding=UTF8 --owner=$DB_USER $DB_NAME

	psql -p 10 --username=postgres --dbname=$DB_NAME -c "CREATE EXTENSION postgis;"
	psql -p 10 --username=postgres --dbname=$DB_NAME -c "CREATE EXTENSION postgis_topology;"
	psql -p 10 --username=postgres --dbname=$DB_NAME -f /indexes.sql

	#should also modify the postgresql.conf with sed as per 3.5 of <https://osm2pgsql.org/doc/manual-v1.html#tuning-the-postgresql-server>

	pg_ctl stop -D /var/lib/postgresql/data

	sed -i 's/trust/scram-sha-256/' /var/lib/postgresql/data/pg_hba.conf
fi

postgres -D /var/lib/postgresql/data -i
