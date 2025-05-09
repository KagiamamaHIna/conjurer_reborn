dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

-- Toggle breathing, according to are we using the carrot or not.
-- Always reset breath when changing carrot in/out.
function enabled_changed(entity, is_enabled)
    local player = GetPlayerObj()
    if player == nil then
        return
    end
    for _,v in ipairs(player.comp.DamageModelComponent or {}) do
        v.attr.air_needed = not is_enabled
        v.attr.air_in_lungs = 7
    end
end
