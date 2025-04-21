dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


function damage_received(damage, message, entity_thats_responsible, is_fatal)
  if is_fatal then
    local player = GetUpdatedEntityID()

    -- Momentary blindness
    local blindness = EntityCreateNew()
    EntityAddComponent2(blindness, "GameEffectComponent", {
        effect="BLINDNESS",
        frames=120,
    })
    EntityAddChild(player, blindness)

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
end
