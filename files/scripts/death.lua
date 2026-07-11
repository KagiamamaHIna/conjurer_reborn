dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")
dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

---可以同时设置相机和玩家位置的函数
---@param x number?
---@param y number?
function SetCameraPlayerXY(x, y)
    local player = GetPlayerObj()
    if player == nil then
        return
    end
    x = x and x or player.attr.x
    y = y and y or player.attr.y
    player.attr.x = x
    player.attr.y = y
    local pspc = player.comp.PlatformShooterPlayerComponent
    if pspc then
        local SrcPos = pspc[1].attr.mSmoothedCameraPosition
        local Desired = pspc[1].attr.mDesiredCameraPos
        local xOffset = Desired.x - SrcPos.x
        local yOffset = Desired.y - SrcPos.y
        pspc[1].set_attrs = {
            mSmoothedCameraPosition = { x = x, y = y },
            mDesiredCameraPos = {x = x + xOffset, y = y + yOffset}
        }
    end
end

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
    
    if CurSettingGet("rebirth_blinded") and GlobalsGetValue("conjurer_unsafePowerBinocularsActive", "0") ~= "1" then
        -- Momentary blindness
        player:NewChild().NewComp.GameEffectComponent {
            effect = "BLINDNESS",
            frames = 120,
        }
    end


    -- Teleport to spawn
    local x, y = get_spawn_position()
    SetCameraPlayerXY(x, y)
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
