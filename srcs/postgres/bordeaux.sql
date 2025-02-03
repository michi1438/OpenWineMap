UPDATE polygons SET name = REPLACE(name,'É','E'); 

\t
\x

CREATE OR REPLACE FUNCTION commune_not_found(TEXT[])
                     RETURNS SETOF text
AS 
$$
DECLARE
  my_array text[] := $1;
  state text;
BEGIN
  FOREACH state IN ARRAY my_array 
  LOOP
	IF NOT EXISTS (SELECT name FROM polygons where name = state LIMIT 1) THEN
		RETURN NEXT state;
	END IF;
  END LOOP;
END;
$$
LANGUAGE plpgsql;


-- DROP TABLE IF EXISTS :REGION;
-- CREATE TABLE :REGION AS SELECT * FROM polygons WHERE name IN ARRAY communes;

\set REGION bearne 
\set COMMUNES ARRAY['''Maumusson-Laguian''','''Riscle''','''Cannet''','''Viella''','''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-LanneetSoublecause''','''Abos''','''Arbus''','''Arricau-Bordes''','''Arrosès''','''Artiguelouve''','''Aubertin''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Baigts-de-Béarn''','''Bellocq''','''Bérenx''','''Bétracq''','''Bosdarros''','''Burosse-Mendousse''','''Cadillon''','''Cardesse''','''Carresse''','''Castagnède''','''Castetpugon''','''Castillon(CantondeLembeye)''','''Conchez-de-Béarn''','''Corbères-Abères''','''Crouseilles''','''Cuqueron''','''Diusse''','''Escurès''','''Estialescq''','''Gan''','''Gayon''','''Gelos''','''Haut-de-Bosdarros''','''L’Hôpital-d’Orion''','''Jurançon''','''Lacommande''','''Lagor''','''Lahontan''','''Lahourcade''','''Laroin''','''Lasserre''','''Lasseube''','''Lasseubetat''','''Lembeye''','''Lespielle-Germenaud-Lannegrasse''','''Lucq-de-Béarn''','''Mascaraàs-Haron''','''Mazères-Lezons''','''Moncaup''','''Moncla''','''Monein''','''Monpezat''','''Mont-Disse''','''Mourenx''','''Narcastet''','''Ogenne-Camptort''','''Oraàs''','''Orthez''','''Parbayse''','''Portet''','''Puyoo''','''Ramous''','''Rontignon''','''Saint-Faust''','''Saint-Jean-Poudge''','''Salies-de-Béarn''','''Salles-Mongiscard''','''Sauvelade''','''Séméacq-Blachon''','''Tadon-Sadirac-Viellenave''','''Tadousse-Ussau''','''Uzos''','''Vialer''','''Vielleségure''']

\echo '\nALL COMMUNES WHERE FOUND EXEPT:'
SELECT * from commune_not_found(:COMMUNES);
\echo '\n'

DROP TABLE IF EXISTS :REGION;
CREATE TABLE :REGION AS SELECT * FROM polygons WHERE name = ANY(:COMMUNES);



\set REGION irouleguy 
\set COMMUNES ARRAY['''Aincille''','''Anhaux''','''Ascarat''','''Bidarray''','''Bussunarits-Sarrasquette''','''Bustince-Iriberry''','''Irouléguy''','''Ispoure''','''Jaxu''','''Lasse''','''Lecumberry''','''Ossès''','''Saint-Etienne-de-Baïgorry''','''Saint-Jean-le-Vieux''','''Saint-Martin-d''''Arrossa''']

\echo '\nALL COMMUNES WHERE FOUND EXEPT:'
SELECT * from commune_not_found(:COMMUNES);
\echo '\n'

DROP TABLE IF EXISTS :REGION;
CREATE TABLE :REGION AS SELECT * FROM polygons WHERE name = ANY(:COMMUNES);
