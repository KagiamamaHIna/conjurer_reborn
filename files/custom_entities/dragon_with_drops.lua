dofile_once("data/scripts/lib/utilities.lua")
local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )
local eid = EntityLoad( "data/entities/animals/boss_dragon.xml", pos_x, pos_y )

EntityAddComponent( eid, "LuaComponent", 
{ 
    script_death = "data/scripts/animals/boss_dragon_death.lua",
    execute_every_n_frame = "-1",
} )

EntityKill( entity_id )
