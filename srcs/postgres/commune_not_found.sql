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
