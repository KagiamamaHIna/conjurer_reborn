dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

function damage_received(damage, message, entity_thats_responsible, is_fatal)
    if not is_fatal then
        return
    end
    local player = EntityObj(GetUpdatedEntityID())
    
    if GlobalsGetValue("conjurer_unsafePowerKalmaActive", "0") == "0" then
        --像老版本一样，没血了不会送回去，不过这次会回满血。还有原来我数字写的那么诡异，不过现在修了:)
        player.comp.DamageModelComponent[1].attr.wait_for_kill_flag_on_death = true
        player.comp.DamageModelComponent[1].attr.invincibility_frames = 2
        GlobalsSetValue("conjurer_reborn_next_refresh_hp", "1")
    else
        player.comp.DamageModelComponent[1].attr.wait_for_kill_flag_on_death = false
    end
end
