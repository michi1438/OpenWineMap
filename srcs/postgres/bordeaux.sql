UPDATE polygons SET name = REPLACE(name,'É','E'); 

\t
\x

\set REGION irouleguy 
\set COMMUNE ('''Aincille''','''Anhaux''','''Ascarat''','''Bidarray''','''Bussunarits-Sarrasquette''','''Bustince-Iriberry''','''Irouléguy''','''Ispoure''','''Jaxu''','''Lasse''','''Lecumberry''','''Ossès''','''Saint-Etienne-de-Baïgorry''','''Saint-Jean-le-Vieux''','''Saint-Martin-d’Arrossa''')

DROP TABLE IF EXISTS :REGION;
SELECT name FROM polygons WHERE name IN :COMMUNE; 
CREATE TABLE :REGION AS SELECT * FROM polygons WHERE name IN :COMMUNE;

\set REGION bearne 
\set COMMUNE ('''Maumusson-Laguian''','''Riscle''','''Cannet''','''Viella''','''Castelnau-Rivière-Basse''','''Hagedet''','''Lascazères''','''Madiran''','''Saint-LanneetSoublecause''','''Abos''','''Arbus''','''Arricau-Bordes''','''Arrosès''','''Artiguelouve''','''Aubertin''','''Aubous''','''Aurions-Idernes''','''Aydie''','''Baigts-de-Béarn''','''Bellocq''','''Bérenx''','''Bétracq''','''Bosdarros''','''Burosse-Mendousse''','''Cadillon''','''Cardesse''','''Carresse''','''Castagnède''','''Castetpugon''','''Castillon(CantondeLembeye)''','''Conchez-de-Béarn''','''Corbères-Abères''','''Crouseilles''','''Cuqueron''','''Diusse''','''Escurès''','''Estialescq''','''Gan''','''Gayon''','''Gelos''','''Haut-de-Bosdarros''','''L’Hôpital-d’Orion''','''Jurançon''','''Lacommande''','''Lagor''','''Lahontan''','''Lahourcade''','''Laroin''','''Lasserre''','''Lasseube''','''Lasseubetat''','''Lembeye''','''Lespielle-Germenaud-Lannegrasse''','''Lucq-de-Béarn''','''Mascaraàs-Haron''','''Mazères-Lezons''','''Moncaup''','''Moncla''','''Monein''','''Monpezat''','''Mont-Disse''','''Mourenx''','''Narcastet''','''Ogenne-Camptort''','''Oraàs''','''Orthez''','''Parbayse''','''Portet''','''Puyoo''','''Ramous''','''Rontignon''','''Saint-Faust''','''Saint-Jean-Poudge''','''Salies-de-Béarn''','''Salles-Mongiscard''','''Sauvelade''','''Séméacq-Blachon''','''Tadon-Sadirac-Viellenave''','''Tadousse-Ussau''','''Uzos''','''Vialer''','''Vielleségure''')

DROP TABLE IF EXISTS :REGION;
EXPLAIN ANALYZE
SELECT EXISTS (SELECT name FROM polygons WHERE name NOT IN :COMMUNE); 
CREATE TABLE :REGION AS SELECT * FROM polygons WHERE name IN :COMMUNE;
