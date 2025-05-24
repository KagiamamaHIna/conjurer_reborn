dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


function damage_received(damage, message, entity_thats_responsible, is_fatal)
    if not is_fatal then
        return
    end
    local player = GetUpdatedEntityID()
    local death_x,death_y = EntityGetTransform(player)
    GlobalsSetValue("conjurer_reborn_last_death_x", tostring(death_x))
    GlobalsSetValue("conjurer_reborn_last_death_y", tostring(death_y))
    
    if ModSettingGet("conjurer_reborn.rebirth_blinded") and GlobalsGetValue("conjurer_unsafePowerBinocularsActive", "0") ~= "1" then
        -- Momentary blindness
        local blindness = EntityCreateNew()
        EntityAddComponent2(blindness, "GameEffectComponent", {
            effect = "BLINDNESS",
            frames = 120,
        })
        EntityAddChild(player, blindness)
    end


    -- Teleport to spawn
    local x, y = get_spawn_position()
    teleport_player(x, y)
    GlobalsSetValue("conjurer_reborn_next_refresh_hp", "1")
    -- Refresh health
    --[[
    local dmgComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
	if dmgComponent then
		local max_health = ComponentGetValue2(dmgComponent, "max_hp")
		ComponentSetValue2(dmgComponent, "hp", max_health)  
	end]]
    --
    GamePrintImportant("$conjurer_reborn_player_reborn1", "$conjurer_reborn_player_reborn2")
end
