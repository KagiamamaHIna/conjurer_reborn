dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")
dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

function damage_received(damage, message, entity_thats_responsible, is_fatal)
    if not is_fatal then
        return
    end
    local player = EntityObj(GetUpdatedEntityID())
    player.comp.DamageModelComponent[1].attr.wait_for_kill_flag_on_death = true--不要真的死了
    
    if GlobalsGetValue("conjurer_unsafePowerKalmaActive", "0") == "0" then
        --像老版本一样，没血了不会送回去，不过这次会回满血。还有原来我数字写的那么诡异，不过现在修了:)
        GlobalsSetValue("conjurer_reborn_next_refresh_hp", "1")
        player.comp.DamageModelComponent[1].attr.invincibility_frames = 2
        return
    end
    local death_x,death_y = player:GetTransform()
    GlobalsSetValue("conjurer_reborn_last_death_x", tostring(death_x))
    GlobalsSetValue("conjurer_reborn_last_death_y", tostring(death_y))
    
    if ModSettingGet("conjurer_reborn.rebirth_blinded") and GlobalsGetValue("conjurer_unsafePowerBinocularsActive", "0") ~= "1" then
        -- Momentary blindness
        player:NewChild().NewComp.GameEffectComponent {
            effect = "BLINDNESS",
            frames = 120,
        }
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
