dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/SimulateAppend.lua")
local sandbox = dofile_once("mods/conjurer_reborn/files/lib/SandBox.lua")
---@type DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")

--先加载所有的内容
local fn, env = sandbox(function ()
	dofile("data/scripts/perks/perk_list.lua")
end)
pcall(fn)
--会用到的全局变量
_GLOBAL_INDEX_TABLES[#_GLOBAL_INDEX_TABLES+1] = env

local PerkTable = {}
local OrderedListId = {}

for _, v in pairs(env.perk_list) do
    PerkTable[v.id] = v
    PerkTable[v.id].conjurer_unsafe_from_id = "?" --提前标记为?，方便后续处理，因为不能检测set文件的
    OrderedListId[#OrderedListId + 1] = v.id
end

--加载原生的内容
local OriPerkLua = datawak:At("data/scripts/perks/perk_list.lua")
local fn,env = sandbox(loadstring(OriPerkLua))
fn()
for _,v in pairs(env.perk_list) do
    if PerkTable[v.id] then--如果存在数据，标记为noita
		PerkTable[v.id].conjurer_unsafe_from_id = "Noita"
	end
end

local AppendsModToFile = GetAppendedModIdToFile(OriPerkLua, "data/scripts/perks/perk_list.lua")

for modid,v in pairs(AppendsModToFile) do
    local fn, env = sandbox(loadstring(v))
	fn()
    for _, perk in pairs(env.perk_list) do
		if PerkTable[perk.id] and PerkTable[perk.id].conjurer_unsafe_from_id == "?" then--如果存在数据，且为?，那么标记为模组id
			PerkTable[perk.id].conjurer_unsafe_from_id = modid
		end
    end
end

local KeyToPerk = {}
for i,v in ipairs(OrderedListId)do
	KeyToPerk[v] = i
end
return {PerkTable, OrderedListId, KeyToPerk}
