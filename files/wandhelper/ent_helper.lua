dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_list.lua")
dofile_once("mods/conjurer_reborn/files/overrides/drop_money_fn.lua")
local WorldGlobalGetNumber = Compose(tonumber, WorldGlobalGet)

---@param UI Gui
---@return integer
function GetScanRadius(UI)
	return WorldGlobalGetNumber(UI, "EntWandScanRadius", "32")
end

---@param UI Gui
---@return boolean
function GetScanPreview(UI)
	return WorldGlobalGetBool(UI, "EntWandScanPreview", false)
end

---@param UI Gui
---@param value boolean
function SetScanPreview(UI, value)
	local last = GetScanPreview(UI)
	if last ~= value then
    	WorldGlobalSetBool(UI, "EntWandScanPreview", value)
		ChangeSpawnerReticle(UI)
	end
end

---@param UI Gui
---@param value number
function SetScanRadius(UI, value)
    local last = GetScanRadius(UI)
	if last ~= value then
		WorldGlobalSet(UI, "EntWandScanRadius", value)
		if GetScanPreview(UI) then
			ChangeSpawnerReticle(UI)
		end
	end
end

-- This is a fun little hack to keep the entity scanning still working & efficient.
-- Simply set the reticle entity outside the scanning range, and offset all sprites
-- & spawn points accordingly.

---@param UI Gui
---@return integer
function GetReticleOffset(UI)
	return 37
end

---判断entwand的准星实体是否生成，如果没生成，根据给定坐标生成，都会返回实体id
---@param x number? x = 0
---@param y number? y = 0
---@return number
function GetOrCreateReticle(x, y)
	x = Default(x, 0)
	y = Default(y, 0)
	local reticle = EntityGetWithName("conjurer_reborn_spawner_reticle")
	if reticle and reticle ~= 0 then
		return reticle
	end
	local result = EntityCreateNew("conjurer_reborn_spawner_reticle")
	EntitySetTransform(result, x, y)
	EntityAddComponent2(result, "StreamingKeepAliveComponent", {})
	return result
end

---返回实体法杖的生成行数
---@param UI Gui
---@return integer
function GetEntWandRows(UI)
	return WorldGlobalGetNumber(UI, "EntWandRows", "1")
end

---设置实体法杖的生成行数
---@param UI Gui
---@param value integer
function SetEntWandRows(UI, value)
    local last = GetEntWandRows(UI)
	if last ~= value then
		WorldGlobalSet(UI, "EntWandRows", value)
		ChangeSpawnerReticle(UI)
	end
end

---返回实体法杖的生成列数
---@param UI Gui
---@return integer
function GetEntWandCols(UI)
	return WorldGlobalGetNumber(UI, "EntWandCols", "1")
end

---设置实体法杖的生成列数
---@param UI Gui
---@param value integer
function SetEntWandCols(UI, value)
    local last = GetEntWandCols(UI)
	if last ~= value then
		WorldGlobalSet(UI, "EntWandCols", value)
		ChangeSpawnerReticle(UI)
	end
end

---返回实体法杖的的GridSize
---@param UI Gui
---@return integer
function GetEntWandGridSize(UI)
	return WorldGlobalGetNumber(UI, "EntWandGridSize", "1")
end

---设置实体法杖的的GridSize
---@param UI Gui
---@param value integer
function SetEntWandGridSize(UI, value)
	local last = GetEntWandGridSize(UI)
	if last ~= value then
        WorldGlobalSet(UI, "EntWandGridSize", value)
		ChangeSpawnerReticle(UI)
	end
end

---返回实体法杖是否是按下一直生成
---@param UI Gui
---@return boolean
function GetEntWandHoldSpawn(UI)
	return WorldGlobalGetBool(UI, "EntWandHoldSpawn", false)
end

---设置实体法杖是否是按下一直生成
---@param UI Gui
---@param value boolean
function SetEntWandHoldSpawn(UI, value)
	WorldGlobalSetBool(UI, "EntWandHoldSpawn", value)
end

---返回实体法杖是否是按下一直删除
---@param UI Gui
---@return boolean
function GetEntWandHoldDelete(UI)
	return WorldGlobalGetBool(UI, "EntWandHoldDelete", false)
end

---设置实体法杖是否是按下一直删除
---@param UI Gui
---@param value boolean
function SetEntWandHoldDelete(UI, value)
	WorldGlobalSetBool(UI, "EntWandHoldDelete", value)
end

---获取实体法杖是否是杀死而非删除
---@param UI Gui
---@return boolean
function GetEntWandKillInstead(UI)
	return WorldGlobalGetBool(UI, "EntWandKillInstead", false)
end

---设置实体法杖是否是杀死而非删除
---@param UI Gui
---@param value boolean
function SetEntWandKillInstead(UI, value)
	WorldGlobalSetBool(UI, "EntWandKillInstead", value)
end

---返回实体法杖是否删除小部分范围内的所有敌人
---@param UI Gui
---@return boolean
function GetEntWandDeleteAll(UI)
	return WorldGlobalGetBool(UI, "EntWandDeleteAll", false)
end

---设置实体法杖是否删除小部分范围内的所有敌人
---@param UI Gui
---@param value boolean
function SetEntWandDeleteAll(UI, value)
	WorldGlobalSetBool(UI, "EntWandDeleteAll", value)
end

---返回实体法杖是否忽略背景和前景
---@param UI Gui
---@return boolean
function GetEntWandIgnoreBG(UI)
	return WorldGlobalGetBool(UI, "EntWandIgnoreBG", false)
end

---设置实体法杖是否忽略背景和前景
---@param UI Gui
---@param value boolean
function SetEntWandIgnoreBG(UI, value)
	WorldGlobalSetBool(UI, "EntWandIgnoreBG", value)
end

---改变会生成实体法杖的准星实体
---@param UI Gui
function ChangeSpawnerReticle(UI)
	local rows = GetEntWandRows(UI)
	local cols = GetEntWandCols(UI)
	local grid_size = GetEntWandGridSize(UI)
	local reticle = GetOrCreateReticle()
	
	if GetScanPreview(UI) then
		local LastVisualEntitys = {}
		if EntityGetWithName("conjurer_reborn_del_all_visual") ~= 0 then
			for _,v in ipairs(EntityGetAllChildren(reticle) or {})do
				if EntityGetName(v) == "conjurer_reborn_del_all_visual" then
					LastVisualEntitys[#LastVisualEntitys+1] = v
				end
			end
		end
		local Circumference = 2 * math.pi * GetScanRadius(UI)
		local VisualMax = math.floor(Circumference / 6)
        if VisualMax ~= #LastVisualEntitys then
            for _, v in ipairs(LastVisualEntitys) do
                EntityKill(v)
            end
            local DefDeg = 360 / VisualMax
            for i = 1, VisualMax do
                local VisualEntity = EntityObjCreateNew("conjurer_reborn_del_all_visual")
                EntityAddChild(reticle, VisualEntity.entity_id)
                VisualEntity:AddComp("SpriteComponent", {
                    image_file = "mods/conjurer_reborn/files/gfx/eraser_pixel.png",
                    additive = true,
                    emissive = true,
                    z_index = 80
                })
                    :AddComp("LuaComponent", {
                        execute_every_n_frame = 1,
                        script_source_file = "mods/conjurer_reborn/files/wands/entwand/del_all_visual_move.lua"
                    })
                AddSetStorageComp(VisualEntity.entity_id, "deg", (i - 1) * DefDeg, "value_float")
            end
        end
    elseif EntityGetWithName("conjurer_reborn_del_all_visual") ~= 0 then
		for _,v in ipairs(EntityGetAllChildren(reticle) or {})do
			if EntityGetName(v) == "conjurer_reborn_del_all_visual" then
				EntityKill(v)
			end
		end
	end

	-- Destroy all existing SpriteComponents from the reticle
	local sprites = EntityGetComponentIncludingDisabled(reticle, "SpriteComponent")
	for i, SpriteComponent in ipairs(sprites or {}) do
		EntityRemoveComponent(reticle, SpriteComponent)
	end

	-- Populate entity with new spritecomponents
	local function vars(x, y)
		local sprite_offset = 1

		-- Centering grid around the mouse & match it with the brush grid
		local center_x_offset = (cols - cols % 2) * grid_size / 2
		local center_y_offset = (rows - rows % 2) * grid_size / 2

		return {
			image_file = "mods/conjurer_reborn/files/gfx/spawner_pixel.png",
			offset_x = x + GetReticleOffset(UI) + sprite_offset - center_x_offset,
			offset_y = y + GetReticleOffset(UI) + sprite_offset - center_y_offset,
			alpha = 0.5,
			additive = false,
			emissive = false,
			z_index = 80,
		}
	end

	for row = 0, rows - 1 do
		local y = row * grid_size

		for col = 0, cols - 1 do
			local x = col * grid_size
			EntityAddComponent2(reticle, "SpriteComponent", vars(x, y))
		end
	end
end

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
	else --都不符合
		Index = WorldGlobalGetNumber(UI, "EntwandEntityIndex", "1")
	end
	return GetEntityForKey(CategoryIndex, Index), CategoryIndex, Index
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
	return UI.UserData["EntWandEnemyFileIndex" .. id] or 1--没有就默认1
end
