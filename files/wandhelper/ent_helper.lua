dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_list.lua")
local WorldGlobalGetNumber = Compose(tonumber, WorldGlobalGet)

SCAN_RADIUS = 32
RETICLE_NAME = "conjurer_reborn_spawner_reticle"

-- This is a fun little hack to keep the entity scanning still working & efficient.
-- Simply set the reticle entity outside the scanning range, and offset all sprites
-- & spawn points accordingly.
RETICLE_OFFSET = SCAN_RADIUS + 5

---从给定索引中找到实体
---@param CategoryIndex integer
---@param Index integer
---@return table|string|nil
function GetEntityForKey(CategoryIndex, Index)
    local temp = ALL_ENTITIES[CategoryIndex]
    if temp == nil or temp.entities == nil then
        return
    end
	return temp.entities[Index]
end

---设置当前活动的实体
---@param UI Gui
---@param CategoryIndex integer
---@param Index integer
function SetActiveEntity(UI, CategoryIndex, Index)
    local temp = ALL_ENTITIES[CategoryIndex]
    if temp == nil or temp.entities == nil then
        return
    end
	WorldGlobalSet(UI, "EntwandEntityCategoryIndex", CategoryIndex)
    if temp.Type == EntityType.Enemy then
        local id = temp.entities[Index]
        WorldGlobalSet(UI, "EntwandEntityIndex", id)
        return
    elseif temp.Type == EntityType.Perk then
		local id = temp.entities[Index]
        WorldGlobalSet(UI, "EntwandEntityIndex", id)
        return
    elseif temp.Type == EntityType.Spell then
		local id = temp.entities[Index]
        WorldGlobalSet(UI, "EntwandEntityIndex", id)
        return
    end
	WorldGlobalSet(UI, "EntwandEntityIndex", Index)
end

---获取当前实体
---@param UI Gui
---@return table|string Entity, integer CategoryIndex, integer Index
function GetActiveEntity(UI)
    local CategoryIndex = WorldGlobalGetNumber(UI, "EntwandEntityCategoryIndex", "1")
	local type = ALL_ENTITIES[CategoryIndex].Type
	local Index
	if type == EntityType.Enemy then
        local temp = WorldGlobalGet(UI, "EntwandEntityIndex", "sheep")
        Index = GetEnemyIDToKey(temp)
    elseif type == EntityType.Spell then
		local temp = WorldGlobalGet(UI, "EntwandEntityIndex", "BOMB")
		Index = GetSpellIDToKey(temp)
	elseif type == EntityType.Perk then
        local temp = WorldGlobalGet(UI, "EntwandEntityIndex", "CRITICAL_HIT")
		Index = GetPerkIDToKey(temp)
    else--都不符合
		Index = WorldGlobalGetNumber(UI, "EntwandEntityIndex", "1")
	end
	return GetEntityForKey(CategoryIndex, Index),CategoryIndex,Index
end

---获取当前实体的图片
---@param UI Gui
---@return string
function GetActiveEntityImg(UI)
    local v, CategoryIndex = GetActiveEntity(UI)
    local type = ALL_ENTITIES[CategoryIndex].Type
	local result
    if type == EntityType.Enemy then
        result = GetEnemy(v).png
    elseif type == EntityType.Perk then
		result = GetPerk(v).perk_icon
    elseif type == EntityType.Spell then
		result = GetSpell(v).sprite
    else --都不符合
        result = v.image
    end
	return result
end

---给定一个敌人id，返回其文件索引
---@param UI Gui
---@param id string
---@return integer
function GetEnemyFileIndex(UI, id)
	return UI.UserData["EntWandEnemyFileIndex"..id]
end
