local HasEntwand = EntityGetWithName("conjurer_reborn_spawner_reticle")
if HasEntwand == 0 or HasEntwand == nil then
    EntityKill(GetUpdatedEntityID())
	return
end

dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

VisualEntity = EntityObj(GetUpdatedEntityID())
local deg, comp = GetStorageComp(VisualEntity.entity_id, "deg", "value_float")
if comp == nil then
    AddSetStorageComp(VisualEntity.entity_id, "deg", 0, "value_float")
    deg = 0
end

local ratio = tonumber(GlobalsGetValue("conjurer_unsafeEntWandScanRadius", "32")) or 32
local x, y = DEBUG_GetMouseWorld()

VisualEntity.attr.x = x + math.cos(math.rad(deg)) * ratio
VisualEntity.attr.y = y + math.sin(math.rad(deg)) * ratio

deg = deg + 0.2
if deg >= 360 then
	deg = 0
end
SetStorageComp(VisualEntity.entity_id, "deg", deg, "value_float")
