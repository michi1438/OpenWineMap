\set REGION aquitaine 

DROP TABLE :REGION;

CREATE TABLE :REGION AS * FROM polygons;


UPDATE polygons SET name = REPLACE(name,'É','E'); 
