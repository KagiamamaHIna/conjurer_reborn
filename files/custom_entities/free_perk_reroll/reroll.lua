dofile_once( "data/scripts/perks/perk.lua" )

function item_pickup( entity_item, entity_who_picked, item_name )
    local pos_x, pos_y = EntityGetTransform(entity_item)
	local last = GlobalsGetValue( "TEMPLE_PERK_REROLL_COUNT", "0" )
    perk_reroll_perks(entity_item)
	GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", last)
	-- spawn a new one
	EntityKill( entity_item )
	EntityLoad( "data/entities/particles/perk_reroll.xml", pos_x, pos_y )
	EntityLoad( "mods/conjurer_reborn/files/custom_entities/free_perk_reroll/free_perk_reroll.xml", pos_x, pos_y )
end
