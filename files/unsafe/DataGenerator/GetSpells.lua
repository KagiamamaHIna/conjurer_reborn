dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/SimulateAppend.lua")
dofile_once("data/scripts/gun/gun_enums.lua")
local sandbox = dofile_once("mods/conjurer_reborn/files/lib/SandBox.lua")
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

---@type DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")

--先加载所有的内容，sandbox专门防止全局变量污染
local fn, env = sandbox(function ()
	dofile("data/scripts/gun/gun_actions.lua")
end)
pcall(fn)

local SpellTable = {}
local OrderedListId = {}
local EnumToListId = {}

for _, v in pairs(env.actions) do
	if v.id == nil or v.type == nil then
		goto continue
	end
    SpellTable[v.id] = v
	SpellTable[v.id].conjurer_unsafe_from_id = "?"--提前标记为?，方便后续处理，因为不能检测set文件的
    OrderedListId[#OrderedListId + 1] = v.id
    if EnumToListId[v.type] == nil then
        EnumToListId[v.type] = {}
    end
    EnumToListId[v.type][#EnumToListId[v.type] + 1] = v.id
	::continue::
end

--加载原生的内容
local OriSpellLua = datawak:At("data/scripts/gun/gun_actions.lua")
local fn,env = sandbox(loadstring(OriSpellLua))
pcall(fn)
for _, v in pairs(env.actions or {}) do
	if v.id == nil or v.type == nil then
		goto continue
	end
    if SpellTable[v.id] then --如果存在数据，标记为noita
        SpellTable[v.id].conjurer_unsafe_from_id = "Noita"
    end
	::continue::
end
actions = nil

local AppendsModToFile = GetAppendedModIdToFile(OriSpellLua, "data/scripts/gun/gun_actions.lua")

for modid,v in pairs(AppendsModToFile) do
    local fn = loadstring(v)--防止出问题？
    if fn then
		fn,env = sandbox(fn)
        pcall(fn)
        for _, spell in pairs(env.actions or {}) do
			if v.id == nil or v.type == nil then
				goto continue
			end
            if SpellTable[spell.id] and SpellTable[spell.id].conjurer_unsafe_from_id == "?" then --如果存在数据，且为?，那么标记为模组id
                SpellTable[spell.id].conjurer_unsafe_from_id = modid
            end
			::continue::
		end
		actions = nil
	end
end

local KeyToSpell = {}
for i,v in ipairs(OrderedListId)do
	KeyToSpell[v] = i
end

return {SpellTable, OrderedListId, EnumToListId, KeyToSpell}
