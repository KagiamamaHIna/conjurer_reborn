dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")

local Brushes = dofile_once("mods/conjurer_reborn/files/wandhelper/mat_brushes.lua")
local WorldGlobalGetNumber = Compose(tonumber, WorldGlobalGet)

local EraserModeAll = "ALL"
local EraserModeSelected = "SELECTED"
local EraserModeNotSelected = "NOT_SELECTED"
local EraserModeSolids = MatType.Solid
local EraserModeLiquids = MatType.Liquid
local EraserModePowder = MatType.Powder
local EraserModeGases = MatType.Gas
local EraserModeFire = MatType.Fire
local EraserModeBox2D = MatType.Box2d

local EraserSprites = {
	[EraserModeAll] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_erase_solids.png",
	--[EraserModeSelected] = "none, use active material",
	[EraserModeSolids] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_solid.png",
	[EraserModeLiquids] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_liquid.png",
	[EraserModePowder] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_sand.png",
	[EraserModeGases] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_gas.png",
    [EraserModeFire] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_fire.png",
	[EraserModeBox2D] = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_box2d.png"
}

local EraserPixelSprite = "mods/conjurer_reborn/files/gfx/eraser_pixel.png"
local ReplacerPixelSprite = "mods/conjurer_reborn/files/gfx/replacer_pixel.png"

---网格对齐
---@param x number
---@param y number
---@param grid_size number
---@return integer
---@return integer
function GridSnap(x, y, grid_size)
	-- Snap to given grid
	x = x - x % grid_size
	y = y - y % grid_size

	-- Center-align around the cursor
	x = x + grid_size / 2
	y = y + grid_size / 2

	-- Finally, snap to Noita's pixel grid
	return math.floor(x), math.floor(y)
end

---------------------------
--		  画刷API		 --
---------------------------

---从给定索引中找到画刷
---@param CategoryIndex integer
---@param Index integer
---@return table|nil
function GetBrushForKey(CategoryIndex, Index)
    local temp = Brushes[CategoryIndex]
    if temp == nil or temp.brushes == nil then
        return
    end
	return temp.brushes[Index]
end

---获取当前画刷
---@param UI Gui
---@return table Brushes, integer CategoryIndex, integer Index
function GetActiveBrush(UI)
	local CategoryIndex = WorldGlobalGetNumber(UI, "MatwandBrushCategoryIndex", "1")
	local Index = WorldGlobalGetNumber(UI, "MatwandBrushIndex", "4")
	return GetBrushForKey(CategoryIndex, Index), CategoryIndex, Index
end

---改变当前画刷
---@param UI Gui
---@param CategoryIndex integer
---@param Index integer
function ChangeActiveBrush(UI, CategoryIndex, Index)
	WorldGlobalSet(UI, "MatwandBrushCategoryIndex", CategoryIndex)
    WorldGlobalSet(UI, "MatwandBrushIndex", Index)
	UI.UserData["BrushRotationType"] = 0
	RefreshBrushSprite(UI)
end

---刷新画刷贴图
---@param UI Gui
function RefreshBrushSprite(UI)
	local brush = GetActiveBrush(UI)
    local brush_reticle = EntityGetWithName("conjurer_reborn_brush_reticle")

	EntitySetValues(brush_reticle, "SpriteComponent", {
		image_file = brush.reticle_file,
		offset_x = brush.offset_x,
		offset_y = brush.offset_y,
	})

	EntityRefreshSprite(brush_reticle, EntityFirstComponent(brush_reticle, "SpriteComponent"))
end

---返回画刷的GridSize
---@param UI Gui
---@return integer
function GetBrushGridSize(UI)
	return WorldGlobalGetNumber(UI, "BrushGridSize", "1")
end

---设置画刷的GridSize
---@param UI Gui
---@param value integer
function SetBrushGridSize(UI, value)
	WorldGlobalSet(UI, "BrushGridSize", value)
end

---返回Brushes，用于数据处理之类的
---@return table
function GetBrushesTable()
	return Brushes
end

---------------------------
--		 材料API		  --
---------------------------

---改变当前选择的材料id
---@param UI Gui
---@param matid string
function SetActiveMaterial(UI, matid)
	WorldGlobalSet(UI, "MatwandPickedMaterial", matid)
end

---返回当前选择的材料id
---@param UI Gui
---@return string
function GetActiveMaterial(UI)--如果材料不存在，那么就设置成默认的
    local matid = WorldGlobalGet(UI, "MatwandPickedMaterial", GetMaterialList()[1])
    if GetMaterial(matid) == nil then
		matid = GetMaterialList()[1]
		WorldGlobalSet(UI, "MatwandPickedMaterial", matid)
	end
	return matid
end

---返回当前选择的材料贴图
---@param UI Gui
---@return string
function GetActiveMaterialsImage(UI)
	return string.format("mods/conjurer_unsafe/cache/MatIcon/%s.png", GetActiveMaterial(UI))
end

---获取用于生成材料的组件数据表
---@param material string
---@param brush table
---@return table
function GetMatDrawVars(material, brush, rotation)
	rotation = math.floor(rotation or 0)
	local x_offset = 0
    local y_offset = 0
    if rotation == 90 then--角度修正
        x_offset = x_offset + 1
	elseif rotation == -180 then
        x_offset = x_offset + 1
        y_offset = y_offset + 1
	elseif rotation == -91 then
		y_offset = y_offset + 1
    end
	return {
		emitted_material_name = material,
		image_animation_file = brush.brush_file,

		create_real_particles = true,
		emitter_lifetime_frames = 200,--定时清除
		render_on_grid = true,
		fade_based_on_lifetime = true,
		cosmetic_force_create = false,
		emission_interval_min_frames = 1,
		emission_interval_max_frames = 1,
		emit_cosmetic_particles = false,
		image_animation_speed = 2,
		image_animation_loop = false,
		image_animation_raytrace_from_center = false,
		collide_with_gas_and_fire = false,
		set_magic_creation = true,
		is_emitting = true,
        image_animation_use_entity_rotation = true,
        x_pos_offset_min = y_offset,--反着填是nolla的问题！！！
		y_pos_offset_min = x_offset,
        x_pos_offset_max = y_offset,
        y_pos_offset_max = x_offset,
	}
end

---------------------------
--		 橡皮擦API		  --
---------------------------

---返回当前橡皮擦模式
---@param UI Gui
---@return string
function GetEraserMode(UI)
	return WorldGlobalGet(UI, "EraserMode", EraserModeAll)
end

---设置当前橡皮擦模式
---@param UI Gui
---@param Mode string
function SetEraserMode(UI, Mode)
	WorldGlobalSet(UI, "EraserMode",Mode)
end

---返回橡皮擦的GridSize
---@param UI Gui
---@return number
function GetEraserGridSize(UI)
	return WorldGlobalGetNumber(UI, "EraserGridSize", "1")
end

---设置橡皮擦的GridSize
---@param UI Gui
---@param value number
function SetEraserGridSize(UI, value)
	WorldGlobalSet(UI, "EraserGridSize", value)
end

---返回是否共享画刷的网格对齐
---@param UI Gui
---@return boolean
function GetEraserUseBrushGrid(UI)
	return WorldGlobalGetBool(UI, "BrushAndEraserSharedGRID", true)
end

---设置 是否共享画刷的网格对齐
---@param UI Gui
---@param enable boolean
function SetEraserUseBrushGrid(UI, enable)
	WorldGlobalSetBool(UI, "BrushAndEraserSharedGRID", enable)
end

---返回橡皮擦的 覆盖模式 是否启用
---@param UI Gui
---@return boolean
function GetEraserUseReplacer(UI)
	return WorldGlobalGetBool(UI, "MatwandEraserReplace", false)
end

---设置橡皮擦的 覆盖模式 是否启用
---@param UI Gui
---@param enable boolean
function SetEraserUseReplacer(UI, enable)
    local status = GetEraserUseReplacer(UI)
	if status == enable then
		return
	end
    WorldGlobalSetBool(UI, "MatwandEraserReplace", enable)
	RefreshEraserReticleSprite(UI)
end

---返回橡皮擦的 擦洗模式 是否启用
---@param UI Gui
---@return boolean
function GetEraserWashMode(UI)
	return WorldGlobalGetBool(UI, "EraserWashMode", false)
end

---设置橡皮擦的 擦洗模式 是否启用
---@param UI Gui
---@param value boolean
function SetEraserWashMode(UI, value)
	WorldGlobalSetBool(UI, "EraserWashMode", value)
end

---返回当前选择的橡皮擦贴图
---@param UI Gui
function GetActiveEraserImage(UI)
	local current_eraser = GetEraserMode(UI)
    if current_eraser == EraserModeSelected then
        return GetActiveMaterialsImage(UI), "mods/conjurer_reborn/files/gfx/matwand_icons/9piece_selected_mat.png"
    end
	if current_eraser == EraserModeNotSelected then
		return GetActiveMaterialsImage(UI), "mods/conjurer_reborn/files/gfx/matwand_icons/9piece_not_selected_mat.png"
	end
	return EraserSprites[current_eraser]
end

---获得橡皮擦工具范围大小等参数
---@param UI Gui
---@return number
---@return number
---@return number
function GetEraserSize(UI)
	-- Eraser sizes with chunk_count multiplier:
	-- 1: 5px
	-- 2: 10px
	-- 3: 15px
	-- ...

	local chunk_size = 5
	local chunk_count = WorldGlobalGetNumber(UI, "MatwandEraserChunkCount", "2")
	local total_size = chunk_count * chunk_size
	return chunk_count, chunk_size, total_size
end

---设置橡皮擦工具的大小
---@param UI Gui
---@param value number
function SetEraserSize(UI, value)
    local count = GetEraserSize(UI)
	if count == value then
		return
	end
    WorldGlobalSet(UI, "MatwandEraserChunkCount", value)
	RefreshEraserReticleSprite(UI)
end

---刷新橡皮擦实体贴图
---@param UI Gui
function RefreshEraserReticleSprite(UI)
	local chunk_count, _, total_size = GetEraserSize(UI)
	local reticle = EntityGetWithName("conjurer_reborn_eraser_reticle")

	local corners = {
		{ -- Topleft
			math.floor(total_size / 2),
			math.floor(total_size / 2)
		},
		{ -- Topright
			math.floor(-total_size / 2) + 1,
			math.floor(total_size / 2)
		},
		{ -- Bottomleft
			math.floor(total_size / 2),
			math.floor(-total_size / 2) + 1
		},
		{ -- Bottomright
			math.floor(-total_size / 2) + 1,
			math.floor(-total_size / 2) + 1
		},
	}

	local replace = GetEraserUseReplacer(UI)
	local image = replace and ReplacerPixelSprite or EraserPixelSprite

	for i, SpriteComponent in ipairs(EntityGetComponent(reticle, "SpriteComponent")) do
		-- The odd sizes (15, 25, ...) require their own offset
		local offset = chunk_count % 2

		local corner = corners[i]
		ComponentSetValue2(SpriteComponent, "offset_x", corner[1] + offset)
		ComponentSetValue2(SpriteComponent, "offset_y", corner[2] + offset)
		ComponentSetValue2(SpriteComponent, "image_file", image)

		EntityRefreshSprite(reticle, SpriteComponent)
	end
end

---根据类型返回一个对应的贴图路径
---@param key string
---@return string
function GetEraserSprites(key)
	return EraserSprites[key]
end
