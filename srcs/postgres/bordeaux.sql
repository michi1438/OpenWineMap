UPDATE polygons SET name = REPLACE(name,'É','E'); 

\t
\x

CREATE OR REPLACE FUNCTION commune_not_found(TEXT[], TEXT[])
                     RETURNS SETOF text
AS 
$$
DECLARE
  my_array text[] := $1;
  reg_table text[] := $2;
  state text;
BEGIN
  FOREACH state IN ARRAY my_array 
  LOOP
	IF NOT EXISTS (SELECT name FROM polygons WHERE (name = state OR official_name = state) AND postal_code = ANY(reg_table) LIMIT 1) THEN --TODO add an OR full_postal_code = state
		RETURN NEXT state;
	END IF;
  END LOOP;
END;
$$
LANGUAGE plpgsql;


-- DROP TABLE IF EXISTS :AOP;
-- CREATE TABLE :AOP AS SELECT * FROM polygons WHERE name IN ARRAY communes;

-- AOP PACHERENC_DU_VIC_BILH 
\set AOP pacherenc_du_vic_bilh 

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE 1 <> 1;
\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'

\set REG_TABLE ARRAY['''32''']
\set COMMUNES ARRAY['''Maumusson-Laguian''','''Cannet''','''Viella''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * froh commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);

\set REG_TABLE ARRAY['''65''']
\set COMMUNES ARRAY['''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-Lanne''','''Soublecause''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);

\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Arricau-Bordes''','''Arrosès''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Bétracq''','''Burosse-Mendousse''','''Cadillon''','''Castetpugon''','''Castillon (canton de Lembeye)''','''Conchez-de-Béarn''','''Corbère-Abères''','''Crouseilles''','''Diusse''','''Escurès''','''Gayon''','''Lasserre''','''Lembeye''','''Mascaraàs-Haron''','''Moncaup''','''Moncla''','''Monpezat''','''Mont-Disse''','''Portet''','''Saint-Jean-Poudge''','''Séméacq-Blachon''','''Tadousse-Ussau''','''Vialer''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

INSERT INTO :AOP (name, geom, zaxis) VALUES ('the_whole_appelation', (SELECT ST_union(geom) FROM :AOP), 5); 

-- AOP TURSAN 
\set AOP tursan 

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE 1 <> 1;
\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'

\set REG_TABLE ARRAY['''40''']
\set COMMUNES ARRAY['''Aire-sur-l''''Adour''','''Arboucave''','''Aubagnan''','''Bahus-Soubiran''','''Bats-Tursan''','''Buanes''','''Castelnau-Tursan''','''Classun''','''Clèdes''','''Coudures''','''Duhort-Bachen''','''Eugénie-les-Bains''','''Eyres-Moncube''','''Fargues''','''Geaune''','''Larrivière-Saint-Savin''','''Latrille''','''Lauret''','''Mauries''','''Miramont-Sensacq''','''Montgaillard''','''Montsoué''','''Payros-Cazautets''','''Pécorade''','''Pimbo''','''Puyol-Cazalet''','''Renung''','''Saint-Agnet''','''Saint-Loubouer''','''Sarraziet''','''Sarron''','''Serres-Gaston''','''Sorbets''','''Urgons''','''Vielle-Tursan''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

\set REG_TABLE ARRAY['''32''']
\set COMMUNES ARRAY['''Ségos''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

INSERT INTO :AOP (name, geom, zaxis) VALUES ('the_whole_appelation', (SELECT ST_union(geom) FROM :AOP), 10); 

-- AOP BEARNE 
\set AOP bearne

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE 1 <> 1;
\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'

\set REG_TABLE ARRAY['''32''']
\set COMMUNES ARRAY['''Maumusson-Laguian''','''Riscle''','''Cannet''','''Viella''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);

\set REG_TABLE ARRAY['''65''']
\set COMMUNES ARRAY['''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-Lanne''','''Soublecause''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);

\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Abos''','''Arbus''','''Arricau-Bordes''','''Arrosès''','''Artiguelouve''','''Aubertin''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Baigts-de-Béarn''','''Bellocq''','''Bérenx''','''Bétracq''','''Bosdarros''','''Burosse-Mendousse''','''Cadillon''','''Cardesse''','''Carresse-Cassaber''','''Castagnède''','''Castetpugon''','''Castillon (Canton de Lembeye)''','''Conchez-de-Béarn''','''Corbère-Abères''','''Crouseilles''','''Cuqueron''','''Diusse''','''Escurès''','''Estialescq''','''Gan''','''Gayon''','''Gelos''','''Haut-de-Bosdarros''','''L''''Hôpital-d''''Orion''','''Jurançon''','''Lacommande''','''Lagor''','''Lahontan''','''Lahourcade''','''Laroin''','''Lasserre''','''Lasseube''','''Lasseubetat''','''Lespielle''','''Lucq-de-Béarn''','''Mascaraàs-Haron''','''Mazères-Lezons''','''Moncaup''','''Moncla''','''Monein''','''Monpezat''','''Mont-Disse''','''Mourenx''','''Narcastet''','''Ogenne-Camptort''','''Oraàs''','''Orthez''','''Parbayse''','''Portet''','''Puyoô''','''Ramous''','''Rontignon''','''Saint-Faust''','''Saint-Jean-Poudge''','''Salies-de-Béarn''','''Salles-Mongiscard''','''Sauvelade''','''Séméacq-Blachon''','''Taron-Sadirac-Viellenave''','''Tadousse-Ussau''','''Uzos''','''Vialer''','''Vielleségure''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

INSERT INTO :AOP (name, geom, zaxis) VALUES ('the_whole_appelation', (SELECT ST_union(geom) FROM :AOP), 15); 

-- AOP IROULEGUY
\set AOP irouleguy 

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE 1 <> 1;
\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'

\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Aincille''','''Anhaux''','''Ascarat''','''Bidarray''','''Bussunarits-Sarrasquette''','''Bustince-Iriberry''','''Irouléguy''','''Ispoure''','''Jaxu''','''Lasse''','''Lecumberry''','''Ossès''','''Saint-Etienne-de-Baïgorry''','''Saint-Jean-le-Vieux''','''Saint-Martin-d''''Arrossa''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

INSERT INTO :AOP (name, geom, zaxis) VALUES ('the_whole_appelation', (SELECT ST_union(geom) FROM :AOP), 5); 

-- AOP MADIRAN 
\set AOP madiran

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE 1 <> 1;
\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'

\set REG_TABLE ARRAY['''32''']
\set COMMUNES ARRAY['''Cannet''','''Maumusson-Laguian''','''Viella''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);

\set REG_TABLE ARRAY['''65''']
\set COMMUNES ARRAY['''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-Lanne''','''Soublecause''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);

\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Arricau-Bordes''','''Arrosès''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Bétracq''','''Burosse-Mendousse''','''Cadillon''','''Castetpugon''','''Castillon (Canton de Lembeye)''','''Conchez-de-Béarn''','''Corbère-Abères''','''Crouseilles''','''Diusse''','''Escurès''','''Gayon''','''Lasserre''','''Lembeye''','''Mascaraàs-Haron''','''Moncaup''','''Moncla''','''Monpezat''','''Mont-Disse''','''Portet''','''Saint-Jean-Poudge''','''Séméacq-Blachon''','''Tadousse-Ussau''','''Vialer''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

INSERT INTO :AOP (name, geom, zaxis) VALUES ('the_whole_appelation', (SELECT ST_union(geom) FROM :AOP), 10); 

-- AOP JURANCON 
\set AOP jurancon 

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE 1 <> 1;
\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'

\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Abos''','''Arbus''','''Artiguelouve''','''Aubertin''','''Bosdarros''','''Cardesse''','''Cuqueron''','''Estialescq''','''Gan''','''Gelos''','''Haut-de-Bosdarros''','''Jurançon''','''Lacommande''','''Lahourcade''','''Laroin''','''Lasseube''','''Lasseubetat''','''Lucq-de-Béarn''','''Mazères-Lezons''','''Monein''','''Narcastet''','''Parbayse''','''Rontignon''','''Saint-Faust''','''Uzos''']
\echo :REG_TABLE 'COMMUNES WHERE NOT FOUND:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
INSERT INTO :AOP SELECT * FROM polygons WHERE (name = ANY(:COMMUNES) OR official_name = ANY(:COMMUNES)) AND postal_code = ANY(:REG_TABLE);
\echo '\n'

INSERT INTO :AOP (name, geom, zaxis) VALUES ('the_whole_appelation', (SELECT ST_union(geom) FROM :AOP), 10); 
