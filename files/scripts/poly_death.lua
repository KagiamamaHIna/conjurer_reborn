dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

function damage_received(damage, message, entity_thats_responsible, is_fatal)--检测变形后玩家是否死亡
    if not is_fatal then
        return
    end
    local player = EntityObj(GetUpdatedEntityID())
    player.comp.DamageModelComponent[1].attr.wait_for_kill_flag_on_death = true --不要真的死了
    
    for _, v in ipairs(player:GetAllChildObj() or {}) do
        for _, c in ipairs(v.comp_all.GameEffectComponent or {}) do
            local effect = c.attr.effect
            if effect == "POLYMORPH" or effect == "POLYMORPH_RANDOM" or effect == "POLYMORPH_UNSTABLE" then
                c.attr.frames = 1
            end
        end
    end
    for _, v in ipairs(player.comp_all.DamageModelComponent) do --回满血并关闭
        v.attr.hp = v.attr.max_hp
        v.enable = false
    end
    local death_x,death_y = player:GetTransform()
    GlobalsSetValue("conjurer_reborn_last_death_x", tostring(death_x))
    GlobalsSetValue("conjurer_reborn_last_death_y", tostring(death_y))

    GlobalsSetValue("conjurer_reborn_poly_death", "1")
end
