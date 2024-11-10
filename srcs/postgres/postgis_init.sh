#!/bin/bash

bash
cd
mkdir /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data
initdb -D /var/lib/postgresql/data

sed -i '/.*replication.*all.*/d' /var/lib/postgresql/data/pg_hba.conf 
sed -i '/^#.*/d' /var/lib/postgresql/data/pg_hba.conf 
sed -i 's/127\.0\.0\.1\/32/172\.28\.0\.0\/16/' /var/lib/postgresql/data/pg_hba.conf
sed -i '/^$/d' /var/lib/postgresql/data/pg_hba.conf
sed -i 's/trust/scram-sha-256/' /var/lib/postgresql/data/pg_hba.conf

pg_ctl start -D /var/lib/postgresql/data
createuser $DB_USER
createdb --encoding=UTF8 --owner=$DB_USER $DB_NAME

psql --username=postgres --dbname=$DB_NAME -c "CREATE EXTENSION postgis;"
psql --username=postgres --dbname=$DB_NAME -c "CREATE EXTENSION postgis_topology;"

tail -f
