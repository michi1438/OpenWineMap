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
	IF NOT EXISTS (SELECT name FROM polygons WHERE name = state AND postal_code = ANY(reg_table) LIMIT 1) THEN
		RETURN NEXT state;
	END IF;
  END LOOP;
END;
$$
LANGUAGE plpgsql;


-- DROP TABLE IF EXISTS :AOP;
-- CREATE TABLE :AOP AS SELECT * FROM polygons WHERE name IN ARRAY communes;

-- AOP BEARNE 
\set AOP bearne 
\set REG_TABLE ARRAY['''64''','''32''','''65''']
\set COMMUNES ARRAY['''Maumusson-Laguian''','''Riscle''','''Cannet''','''Viella''','''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-Lanne''','''Soublecause''','''Abos''','''Arbus''','''Arricau-Bordes''','''Arrosès''','''Artiguelouve''','''Aubertin''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Baigts-de-Béarn''','''Bellocq''','''Bérenx''','''Bétracq''','''Bosdarros''','''Burosse-Mendousse''','''Cadillon''','''Cardesse''','''Carresse-Cassaber''','''Castagnède''','''Castetpugon''','''Lembeye''','''Conchez-de-Béarn''','''Corbère-Abères''','''Crouseilles''','''Cuqueron''','''Diusse''','''Escurès''','''Estialescq''','''Gan''','''Gayon''','''Gelos''','''Haut-de-Bosdarros''','''L''''Hôpital-d''''Orion''','''Jurançon''','''Lacommande''','''Lagor''','''Lahontan''','''Lahourcade''','''Laroin''','''Lasserre''','''Lasseube''','''Lasseubetat''','''Lembeye''','''Lespielle''','''Lucq-de-Béarn''','''Mascaraàs-Haron''','''Mazères-Lezons''','''Moncaup''','''Moncla''','''Monein''','''Monpezat''','''Mont-Disse''','''Mourenx''','''Narcastet''','''Ogenne-Camptort''','''Oraàs''','''Orthez''','''Parbayse''','''Portet''','''Puyoô''','''Ramous''','''Rontignon''','''Saint-Faust''','''Saint-Jean-Poudge''','''Salies-de-Béarn''','''Salles-Mongiscard''','''Sauvelade''','''Séméacq-Blachon''','''Tadon-Sadirac-Viellenave''','''Tadousse-Ussau''','''Uzos''','''Vialer''','''Vielleségure''']

\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'
SELECT * from commune_not_found(:COMMUNES, :REG_TABLE);
\echo '\n'

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE name = ANY(:COMMUNES) AND postal_code = ANY(:REG_TABLE); -- TODO also get the indexes and the column options...

-- AOP IROULEGUY
\set AOP irouleguy 
\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Aincille''','''Anhaux''','''Ascarat''','''Bidarray''','''Bussunarits-Sarrasquette''','''Bustince-Iriberry''','''Irouléguy''','''Ispoure''','''Jaxu''','''Lasse''','''Lecumberry''','''Ossès''','''Saint-Etienne-de-Baïgorry''','''Saint-Jean-le-Vieux''','''Saint-Martin-d''''Arrossa''']

\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'
SELECT * from commune_not_found(:COMMUNES);
\echo '\n'

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE name = ANY(:COMMUNES);

-- AOP MADIRAN 
\set AOP madiran
\set REG_TABLE ARRAY['''64''','''32''','''65''']
\set COMMUNES ARRAY['''Cannet''','''Maumusson-Laguian''','''Viella''','''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-Lanne''','''Soublecause''','''Arricau-Bordes''','''Arrosès''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Bétracq''','''Burosse-Mendousse''','''Cadillon''','''Castetpugon''','''Lembeye''','''Conchez-de-Béarn''','''Corbère-Abères''','''Crouseilles''','''Diusse''','''Escurès''','''Gayon''','''Lasserre''','''Lembeye''','''Mascaraàs-Haron''','''Moncaup''','''Moncla''','''Monpezat''','''Mont-Disse''','''Portet''','''Saint-Jean-Poudge''','''Séméacq-Blachon''','''Tadousse-Ussau''','''Vialer''']

\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'
SELECT * from commune_not_found(:COMMUNES);
\echo '\n'

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE name = ANY(:COMMUNES);

-- AOP JURANCON 
\set AOP jurancon 
\set REG_TABLE ARRAY['''64''']
\set COMMUNES ARRAY['''Abos''','''Arbus''','''Artiguelouve''','''Au-bertin''','''Bosdarros''','''Cardesse''','''Cuqueron''','''Estialesq''','''Gan''','''Gelos''','''Haut-de-Bosdarros''','''Jurançon''','''Lacom-mande''','''Lahourcade''','''Laroin''','''Lasseube''','''Lasseubétat''','''Lucq-de-Béarn''','''Mazères-Lezons''','''Monein''','''Nar-castet''','''Parbayse''','''Rontignon''','''Saint-FaustetUzos''']

\echo '\nIN APPELATION' :AOP
\echo 'ALL COMMUNES WHERE FOUND EXEPT:'
SELECT * from commune_not_found(:COMMUNES);
\echo '\n'

DROP TABLE IF EXISTS :AOP;
CREATE TABLE :AOP AS SELECT * FROM polygons WHERE name = ANY(:COMMUNES);
