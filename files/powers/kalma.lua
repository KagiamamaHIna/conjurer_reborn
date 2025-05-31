dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")
local entity_id = EntityGetParent(GetUpdatedEntityID())
if entity_id == nil or entity_id == 0 then
    return
end
local entity = EntityObj(entity_id)
if entity.comp.DamageModelComponent == nil then
    return
end
entity.comp.DamageModelComponent[1].attr.invincibility_frames = 2
