dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

local entity = EntityObj(GetUpdatedEntityID()):GetParent()
if entity.comp.StatusEffectDataComponent == nil then
    return
end
dofile_once("data/scripts/status_effects/status_list.lua")

local HasStatus = {}
for _,v in ipairs(status_effects) do
    if HasStatus[v.id] == nil then
        HasStatus[v.id] = true
        entity:RemoveStainEffect(v.id, 1)
    end
end
