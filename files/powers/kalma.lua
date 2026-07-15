dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")
---Returns the value of a mod setting. 'id' should normally be in the format 'mod_name.setting_id'. Cache the returned value in your lua context if possible.
---@param id string
---@param def any
---@return boolean|number|string|nil
function SettingGet(id, def)
    local result = ModSettingGet("conjurer_unsafe.r_" .. id)
    if result == nil then
        return def
    end
    return result
end
local entity_id = GetUpdatedEntityID()
local player_id = EntityGetParent(entity_id)
if player_id == nil or player_id == 0 then
    return
end
local player = EntityObj(player_id)

if player.comp.DamageModelComponent and SettingGet("kalma_protection_all", true) then
    player.comp.DamageModelComponent[1].attr.invincibility_frames = 2
end
local entity = EntityObj(entity_id)
local effectMap = {
    PROTECTION_POLYMORPH = SettingGet("kalma_protection_polymorph", true),
    STUN_PROTECTION_ELECTRICITY = SettingGet("kalma_protection_shock_stun", false),
    STUN_PROTECTION_FREEZE = SettingGet("kalma_protection_freeze_stun", false),
    BREATH_UNDERWATER = SettingGet("kalma_protection_breath", false),
    KNOCKBACK_IMMUNITY = SettingGet("kalma_protection_knockback", false),
    PROTECTION_FOOD_POISONING = SettingGet("kalma_food_poisoning", false)
}

for _, v in ipairs(entity.comp_all.GameEffectComponent or {}) do
    if effectMap[v.attr.effect] ~= nil then
        v:SetEnable(effectMap[v.attr.effect])
        effectMap[v.attr.effect] = nil
    end
end
for name,_ in pairs(effectMap)do
    entity.NewComp.GameEffectComponent {
        effect = name,
        frames = -1
    }
end
