local GetPerks = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetPerks.lua")
local GetEnemies = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetEnemies.lua")
local GetMaterials = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetMaterials.lua")
local GetSpells = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetSpells.lua")
--local GetPickups = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetPickups.lua")
StatusTable = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetStatus.lua")
---获取法术数据
---@param id string
---@return table
function GetSpell(id)
	return GetSpells[1][id]
end

---获取材料数据
---@param id string
---@return table
function GetMaterial(id)
	return GetMaterials[1][id]
end

---获取敌人数据
---@param id string
---@return table
function GetEnemy(id)
	return GetEnemies[1][id]
end

---获取天赋数据
---@param id string
---@return table
function GetPerk(id)
	return GetPerks[1][id]
end

---返回敌人的有序列表
---@return table
function GetEnemyList()
	return GetEnemies[2]
end

---返回天赋的有序列表
---@return table
function GetPerkList()
    return GetPerks[2]
end

---返回材料的有序列表
---@return table
function GetMaterialList()
    return GetMaterials[2]
end

---返回所有法术的有序列表
---@return table
function GetSpellList()
	return GetSpells[2]
end

---从给定的枚举数中获取指定类型的有序列表
---@param number number
---@return table
function GetSpellListInEnum(number)
	return GetSpells[3][number]
end

---返回可以通过枚举获得指定类型的有序列表
---@return table
function GetSpellListEnumMap()
	return GetSpells[3]
end

---返回所有法术的所有数据
---@return table
function GetSpellData()
	return GetSpells[1]
end

---返回所有材料的所有数据
---@return table
function GetMaterialData()
	return GetMaterials[1]
end

---返回所有敌人的所有数据
---@return table
function GetEnemyData()
	return GetEnemies[1]
end

---返回所有天赋的所有数据
---@return table
function GetPerkData()
	return GetPerks[1]
end

---返回材料的分类表
---@return table
function GetMaterialTypeList()
	return GetMaterials[3]
end

---从给定的id获得对应的键
---@param key string
---@return integer
function GetEnemyIDToKey(key)
    return GetEnemies[3][key]
end

---从给定的id获得对应的键
---@param key string
---@return integer
function GetPerkIDToKey(key)
	return GetPerks[3][key]
end

---从给定的id获得对应的键
---@param key string
---@return integer
function GetSpellIDToKey(key)
	return GetSpells[4][key]
end
