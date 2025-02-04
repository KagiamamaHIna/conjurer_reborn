dofile_once("mods/conjurer_reborn/files/wandhelper/ent_helper.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_reticle_entity.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/wand_utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("data/scripts/perks/perk.lua")

local EnemyTable = GetEnemyData()

local HOVERED_ENTITY = nil

---光标跟随
---@param UI Gui
---@param x number
---@param y number
local function SpawnerReticleFollowMouse(UI, x, y)
	local reticle = EntityGetWithName("conjurer_reborn_spawner_reticle")
	if reticle then
		local grid_size = GetEntWandGridSize(UI)
		x = x - x % grid_size
		y = y - y % grid_size
		EntitySetTransform(reticle, math.floor(x + GetReticleOffset(UI)), math.floor(y + GetReticleOffset(UI)))
	end
end

---创建或获取标记光标（标记在实体上的
---@param x number
---@param y number
---@return integer id
local function GetOrCreateCursor(x, y)
	local cursor = EntityGetWithName("conjurer_reborn_entwand_cursor")
	if cursor and cursor ~= 0 then
		return cursor
	end

	-- Offset initial load by *many pixels* from cursor position, because
	-- the engine insists on rendering it for 1 frame at the spawn position, no matter
	-- what hiding tricks we do. The positioning is immediately overtaken by
	-- InheritTransformComponent anyway.
	return EntityLoad("mods/conjurer_reborn/files/wands/entwand/re_cursor.xml", x + 1000, y + 1000)
end

---隐藏标记光标
local function HideCursor()
    local cursor = EntityGetWithName("conjurer_reborn_entwand_cursor")
	if cursor and cursor ~= 0 then
		EntityKill(cursor)
	end
end

---显示标记光标
---@param entity integer
---@param x number
---@param y number
local function ShowCursor(entity, x, y)
	local cursor = GetOrCreateCursor(x, y)

	if EntityGetParent(cursor) ~= entity then
		if EntityGetParent(cursor) ~= cursor then
			EntityRemoveFromParent(cursor)
		end
		EntityAddChild(entity, cursor)
	end
end

---判断范围内实体是否符合条件，符合就显示标记光标
---@param UI Gui
---@param x number
---@param y number
local function ScanEntity(UI, x, y)
	local ratio = GetScanRadius(UI)
	local entities = EntityGetInRadius(x, y, ratio)

	local entity = (#entities > 1) and EntityGetClosest(x, y) or entities[1]
    if entity then
        local root = EntityGetRootEntity(entity)
        if IsValidEntity(UI, root) then
            ShowCursor(root, x, y)
            HOVERED_ENTITY = root
            return
        end
        -- else: get_next_entity()
    end
    -- done:) get_next_entity
	local Len = ratio + 1
	local id = nil
    for i, v in ipairs(entities) do
        local vroot = EntityGetRootEntity(v)
        if IsValidEntity(UI, vroot) then
			local ax, ay = EntityGetTransform(v)
            local alen = math.abs(math.sqrt((x - ax) ^ 2 + (y - ay) ^ 2))
			if Len > alen then
                Len = alen
				id = vroot
			end
        end
    end
	if id then
		ShowCursor(id, x, y)
		HOVERED_ENTITY = id
		return
	end
	-- Nothing found
	HideCursor()
	HOVERED_ENTITY = nil
end

---删除实体
---@param UI Gui
local function DeleteEntity(UI)
    if HOVERED_ENTITY == nil then
        return
    end
	
    if GetEntWandKillInstead(UI) then
		EntityTrueKillOrDelete(HOVERED_ENTITY)
		HOVERED_ENTITY = nil
		return
	end

	EntityKill(HOVERED_ENTITY)
	HOVERED_ENTITY = nil
end

---给定坐标，删除小范围内的实体
---@param UI Gui
---@param x number
---@param y number
local function DeleteAll(UI, x, y)
	local entities = EntityGetInRadius(x, y, GetScanRadius(UI))
	for i, entity in ipairs(entities) do
		local root = EntityGetRootEntity(entity)
        if IsValidEntity(UI, root) then
            if GetEntWandKillInstead(UI) then
				EntityTrueKillOrDelete(root)
			else
				EntityKill(root)
			end
		end
	end
end

---根据当前获得的实体选择生成实体
---@param UI Gui
local function SpawnEntity(UI)
	local rows = GetEntWandRows(UI)
	local cols =  GetEntWandCols(UI)
	local grid_size =  GetEntWandGridSize(UI)
	local reticle = EntityGetWithName("conjurer_reborn_spawner_reticle")
	local reticle_x, reticle_y = EntityGetTransform(reticle)

	local entity_selection, c_index = GetActiveEntity(UI)
    if ALL_ENTITIES[c_index].Type == EntityType.Enemy then --判断类型，根据类型构造参数表
        local key = GetEnemyFileIndex(UI, entity_selection)
        entity_selection = { path = EnemyTable[entity_selection].files[key] }
    elseif ALL_ENTITIES[c_index].Type == EntityType.Spell then
        local spellid = entity_selection
        entity_selection = { spawn_func = function(x, y) return CreateItemActionEntity(spellid, x, y) end }
    elseif ALL_ENTITIES[c_index].Type == EntityType.Perk then
        local perkid = entity_selection
        entity_selection = { spawn_func = function(x, y) return perk_spawn(x, y, perkid) end }
    end
	
	-- Centering grid around the mouse & match it with the brush grid
	local centerize_offset_x = (cols - cols % 2) * grid_size / 2
	local centerize_offset_y = (rows - rows % 2) * grid_size / 2

	for row = 0, rows - 1 do
		local grid_offset_y = reticle_y - row * grid_size
		local y = math.floor(grid_offset_y - GetReticleOffset(UI) + centerize_offset_y)

		for col = 0, cols - 1 do
			local grid_offset_x = reticle_x - col * grid_size
			local x = math.floor(grid_offset_x - GetReticleOffset(UI) + centerize_offset_x)

			-- Manual spawn function always overrides simple spawn-by-path
			local entity = (
				entity_selection.spawn_func and entity_selection.spawn_func(x, y) or EntityLoad(entity_selection.path, x, y)
			)

			-- Per-entity post-processing
			if entity_selection.post_processor then
				entity_selection.post_processor(entity, x, y)
			end

			-- Global level post-processors, for every entity
			PostprocessEntity(entity)
		end
	end
end

---执行实体法杖的光标操作
---@param UI Gui
function EntEntityUpdate(UI)
	local x, y = DEBUG_GetMouseWorld()
	ScanEntity(UI, x, y)
	SpawnerReticleFollowMouse(UI, x, y)


	local spawn_function = GetEntWandHoldSpawn(UI) and IsHoldingMouse1 or HasClickedMouse1
	if spawn_function() then
		SpawnEntity(UI)
	end


	local delete_function = GetEntWandHoldDelete(UI) and IsHoldingMouse2 or HasClickedMouse2
	if delete_function() then
		if GetEntWandDeleteAll(UI) then
			DeleteAll(UI, x, y)
		else
			DeleteEntity(UI)
		end
	end
end
