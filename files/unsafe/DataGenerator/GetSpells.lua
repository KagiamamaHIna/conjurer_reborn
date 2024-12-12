dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/SimulateAppend.lua")
dofile_once("data/scripts/gun/gun_enums.lua")

--[[
SpellTypeBG = {
	[ACTION_TYPE_PROJECTILE] = "data/ui_gfx/inventory/item_bg_projectile.png",
	[ACTION_TYPE_STATIC_PROJECTILE] = "data/ui_gfx/inventory/item_bg_static_projectile.png",
	[ACTION_TYPE_MODIFIER] = "data/ui_gfx/inventory/item_bg_modifier.png",
	[ACTION_TYPE_DRAW_MANY] = "data/ui_gfx/inventory/item_bg_draw_many.png",
	[ACTION_TYPE_MATERIAL] = "data/ui_gfx/inventory/item_bg_material.png",
	[ACTION_TYPE_OTHER] = "data/ui_gfx/inventory/item_bg_other.png",
	[ACTION_TYPE_UTILITY] = "data/ui_gfx/inventory/item_bg_utility.png",
	[ACTION_TYPE_PASSIVE] = "data/ui_gfx/inventory/item_bg_passive.png"
}
]]

---@class DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")

--先加载所有的内容
dofile_once("data/scripts/gun/gun_actions.lua")

local SpellTable = {}
local OrderedListId = {}
local EnumToListId = {}

for _,v in pairs(actions) do
    SpellTable[v.id] = v
	SpellTable[v.id].conjurer_unsafe_from_id = "?"--提前标记为?，方便后续处理，因为不能检测set文件的
    OrderedListId[#OrderedListId + 1] = v.id
    if EnumToListId[v.type] == nil then
        EnumToListId[v.type] = {}
    end
	EnumToListId[v.type][#EnumToListId[v.type]+1] = v.id
end
actions = nil

--加载原生的内容
local OriSpellLua = datawak:At("data/scripts/gun/gun_actions.lua")
loadstring(OriSpellLua)()

for _,v in pairs(actions) do
    if SpellTable[v.id] then--如果存在数据，标记为noita
		SpellTable[v.id].conjurer_unsafe_from_id = "Noita"
	end
end
actions = nil

local AppendsModToFile = GetAppendedModIdToFile(OriSpellLua, "data/scripts/gun/gun_actions.lua")

for modid,v in pairs(AppendsModToFile) do
    loadstring(v)()
    for _, perk in pairs(actions) do
		if SpellTable[perk.id] and SpellTable[perk.id].conjurer_unsafe_from_id == "?" then--如果存在数据，且为?，那么标记为模组id
			SpellTable[perk.id].conjurer_unsafe_from_id = modid
		end
    end
	actions = nil
end

local KeyToSpell = {}
for i,v in ipairs(OrderedListId)do
	KeyToSpell[v] = i
end

return {SpellTable, OrderedListId, EnumToListId, KeyToSpell}