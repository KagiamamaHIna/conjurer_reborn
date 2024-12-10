dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/SimulateAppend.lua")

---@class DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")

--先加载所有的内容
dofile_once("data/scripts/perks/perk_list.lua")

local PerkTable = {}
local OrderedListId = {}

for _,v in pairs(perk_list) do
    PerkTable[v.id] = v
	PerkTable[v.id].conjurer_unsafe_from_id = "?"--提前标记为?，方便后续处理，因为不能检测set文件的
	OrderedListId[#OrderedListId+1] = v.id
end
perk_list = nil

--加载原生的内容
local OriPerkLua = datawak:At("data/scripts/perks/perk_list.lua")
loadstring(OriPerkLua)()

for _,v in pairs(perk_list) do
    if PerkTable[v.id] then--如果存在数据，标记为noita
		PerkTable[v.id].conjurer_unsafe_from_id = "Noita"
	end
end
perk_list = nil

local AppendsModToFile = GetAppendedModIdToFile(OriPerkLua, "data/scripts/perks/perk_list.lua")

for modid,v in pairs(AppendsModToFile) do
    loadstring(v)()
    for _, perk in pairs(perk_list) do
		if PerkTable[perk.id] and PerkTable[perk.id].conjurer_unsafe_from_id == "?" then--如果存在数据，且为?，那么标记为模组id
			PerkTable[perk.id].conjurer_unsafe_from_id = modid
		end
    end
	perk_list = nil
end

local KeyToPerk = {}
for i,v in ipairs(OrderedListId)do
	KeyToPerk[v] = i
end
return {PerkTable, OrderedListId, KeyToPerk}
