\set REGION bordeaux_region

DROP TABLE :REGION;

CREATE TABLE :REGION(
    id SERIAL PRIMARY KEY NOT NULL UNIQUE,
    type_of_appelation VARCHAR(64),
    appelation VARCHAR(64) NOT NULL UNIQUE,
    geom geometry(POLYGON,4326) NOT NULL UNIQUE
  );

INSERT INTO :REGION(type_of_appelation, appelation, geom)
	VALUES (
		'AOC',
		'bordeaux',
		'SRID=4326;POLYGON((2 47,1 49,1 49,2 47))');

INSERT INTO :REGION(type_of_appelation, appelation, geom)
	VALUES (
		'AOC',
		'medoc',
		'SRID=4326;POLYGON((1 48,0 47,0 47,1 48))');
