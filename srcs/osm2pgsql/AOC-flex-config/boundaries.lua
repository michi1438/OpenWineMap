-- This config example file is released into the Public Domain.

-- This is a very simple Lua config for the Flex output not intended for
-- real-world use. Use it do understand the basic principles of the
-- configuration. After reading and understanding this, have a look at
-- "geometries.lua".

-- For debugging
-- inspect = require('inspect')

-- The global variable "osm2pgsql" is used to talk to the main osm2pgsql code.
-- You can, for instance, get the version of osm2pgsql:
print('osm2pgsql version: ' .. osm2pgsql.version)

-- A place to store the SQL tables we will define shortly.
local tables = {}

-- Create a new table called "pois" with the given columns. When running in
-- "create" mode, this will do the `CREATE TABLE`, when running in "append"
-- mode, this will only declare the table for use.
--
-- This is a "node table", it can only contain data derived from nodes and will
-- contain a "node_id" column (SQL type INT8) as first column. When running in
-- "append" mode, osm2pgsql will automatically update this table using the node
-- ids.

-- A special table for restaurants to demonstrate that we can have any tables
-- with any columns we want.

-- This is an "area table", it can contain data derived from ways or relations
-- and will contain an "area_id" column. Way ids will be stored "as is" in the
-- "area_id" column, for relations the negative id will be stored. When
-- running in "append" mode, osm2pgsql will automatically update this table
-- using the way/relation ids.
tables.polygons = osm2pgsql.define_area_table('polygons', {
    { column = 'type', type = 'text' },
    { column = 'zaxis', type = 'smallint' },
    { column = 'name', type = 'text' },
    { column = 'official_name', type = 'text' },
    { column = 'postal_code', type = 'text' },
    { column = 'tags', type = 'jsonb' },
    -- The type of the `geom` column is `geometry`, because we need to store
    -- polygons AND multipolygons
    { column = 'geom', type = 'geometry', not_null = true },
})

-- Debug output: Show definition of tables
for name, dtable in pairs(tables) do
    print("\ntable '" .. name .. "':")
    print("  name='" .. dtable:name() .. "'")
--    print("  columns=" .. inspect(dtable:columns()))
end

-- Helper function to remove some of the tags we usually are not interested in.
-- Returns true if there are no tags left.
local function clean_tags(tags)
    tags.odbl = nil
    tags.created_by = nil
    tags.source = nil
    tags['source:ref'] = nil

    return next(tags) == nil
end

-- Called for every node in the input. The `object` argument contains all the
-- attributes of the node like `id`, `version`, etc. as well as all tags as a
-- Lua table (`object.tags`).
-- Called for every way in the input. The `object` argument contains the same
-- information as with nodes and additionally a boolean `is_closed` flag and
-- the list of node IDs referenced by the way (`object.nodes`).

-- Called for every relation in the input. The `object` argument contains the
-- same information as with nodes and additionally an array of members
-- (`object.members`).
function osm2pgsql.process_relation(object)
    --  Uncomment next line to look at the object data:
    --  print(inspect(object))

    if clean_tags(object.tags) then
        return
    end

    -- Store multipolygons and boundaries as polygons
    if  object.tags.type == 'boundary' 
		and object.tags.postal_code ~= nil
		and object.tags.name ~= nil then
         tables.polygons:insert({
            type = object.tags.type,
            name = object.tags.name, -- TODO change the weird character into something more general....
            official_name = object.tags.official_name,
            postal_code = string.sub(object.tags.postal_code, 1, 2),
            tags = object.tags,
            geom = object:as_multipolygon()
        })
    end
end

