dofile_once("mods/conjurer_reborn/files/wandhelper/mat_helper.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
local MatTable = GetMaterialData()
local MatTypeList = GetMaterialTypeList()

---------------------------
--		 橡皮擦API		  --
---------------------------

---让橡皮擦实体跟随鼠标
---@param UI Gui
local function EraserFollowMouse(UI)
	local eraser = EntityGetWithName("conjurer_reborn_eraser_reticle")
	if eraser then
		local grid_size
		local SharedMode = GetEraserUseBrushGrid(UI)
		if SharedMode then
			grid_size = GetBrushGridSize(UI)
		else
			grid_size = GetEraserGridSize(UI)
		end
		local mx, my = DEBUG_GetMouseWorld()
		local x, y = GridSnap(mx, my, grid_size)
		EntitySetTransform(eraser, x, y)
	end
end

local EraseListCache = {}
local EraseEntityIdList = {}
local PrevErase = false

---材料擦除
---@param UI Gui
---@param material string
local function erase(UI, material)
	local chunk_count, chunk_size, total_size = GetEraserSize(UI)
	local eraser_mode = GetEraserMode(UI)
	local eraser_replace = GetEraserUseReplacer(UI)

	local from_any_material = (eraser_mode == "ALL")
	local from_selected = (eraser_mode == "SELECTED")

	local from_material = from_selected and CellFactory_GetType(material) or 0
    local to_material = eraser_replace and material or "air"
	if MatTable[material] and MatTable[material].conjurer_unsafe_type == MatType.Box2d and eraser_replace then
		GamePrint("$conjurer_reborn_material_handle_replace_no_box2d")
		return
	end
	local reticle = EntityGetWithName("conjurer_reborn_eraser_reticle")
	local x, y = EntityGetTransform(reticle)

	-- Start from the top left corner of the reticle
	x = math.floor(x - total_size / 2) + 2
	y = math.floor(y - total_size / 2) + 2

	-- Create 5x5px rectangular erasers in a grid shape.
	-- This is done *only* because making even-sized erasers with a radius seems
	-- impossible.  Eg. no radius will allow for an exactly 10px eraser.
	-- 不要每次都新建那么多实体和组件，会严重降低性能
	if not PrevErase then
        --与循环无关变量外置提高性能
        local WashMode = GetEraserWashMode(UI)
        if WashMode then --假如是WashMode
            local vars = {
                radius = 3,
                eat_probability = 100,
                only_stain = true,
            }
            for row = 0, chunk_count - 1, 1 do
                EraseEntityIdList[row] = {}
                for col = 0, chunk_count - 1, 1 do
                    local eraser = EntityCreateNew("conjurer_reborn_eraser_entity")
                    EraseEntityIdList[row][col] = eraser
                    EntitySetTransform(eraser,
                        math.floor(x + col * chunk_size),
                        math.floor(y + row * chunk_size)
                    )

                    EntityAddComponent2(eraser, "CellEaterComponent", vars)
                end
            end
            return
        end
		--不是就来这里执行替换等操作
		local list = MatTypeList[eraser_mode]
		local toListStr
		if list then
			if EraseListCache[eraser_mode] == nil then
				EraseListCache[eraser_mode] = table.concat(list, ",")
			end
			toListStr = Cpp.SameElemListStr(#list, #to_material, to_material)
		end
		local FromListStr
        if eraser_mode == "NOT_SELECTED" then
			local _list = GetMaterialList()
			local key
            for i, v in pairs(_list) do
                if v == material then
                    key = i
                    break
                end
            end
			local d = DeepCopy(_list)
			table.remove(d, key)
			FromListStr = table.concat(d, ",")
			toListStr = Cpp.SameElemListStr(#_list - 1, #to_material, to_material)
		end

		local vars = {
			radius = 3,
			is_circle = false,
			steps_per_frame = 512,
			to_material = CellFactory_GetType(to_material),
			from_any_material = from_any_material,
			from_material = from_material,
			extinguish_fire = false,
			kill_when_finished = false
		}
		if eraser_mode == MatType.Fire then--灭火！
			vars["extinguish_fire"] = true
		end
        if list then
            vars["from_material_array"] = EraseListCache[eraser_mode]
            vars["to_material_array"] = toListStr
        end
		if eraser_mode == "NOT_SELECTED" then
            vars["from_material_array"] = FromListStr
            vars["to_material_array"] = toListStr
		end
		for row = 0, chunk_count - 1, 1 do
			EraseEntityIdList[row] = {}
			for col = 0, chunk_count - 1, 1 do
				local eraser = EntityCreateNew("conjurer_reborn_eraser_entity")
				EraseEntityIdList[row][col] = eraser
				EntitySetTransform(eraser,
					math.floor(x + col * chunk_size),
					math.floor(y + row * chunk_size)
				)

				EntityAddComponent2(eraser, "MagicConvertMaterialComponent", vars)
			end
		end
	else
		for row=0,#EraseEntityIdList do--读取缓存，设置位置
			for col=0,#EraseEntityIdList[row] do
				EntitySetTransform(EraseEntityIdList[row][col],
					math.floor(x + col * chunk_size),
					math.floor(y + row * chunk_size)
				)
			end
		end
	end
end

---执行材料擦除
---@param UI Gui
---@param material string
local function HandleErase(UI, material)
	-- Nothing fancy, *yet*.
	-- TODO: Add all the same hooks as m1 has
	erase(UI, material)
end

---材料擦除释放
local function HandleEraseRelease()
	EraseEntityIdList = {}
	local entity = EntityGetWithName("conjurer_reborn_eraser_entity")
	while entity ~= 0 do
		EntityKill(entity)
		entity = EntityGetWithName("conjurer_reborn_eraser_entity")
	end
end

---------------------------
--		  画刷API		 --
---------------------------

---让画刷实体跟随鼠标
---@param UI Gui
local function BrushFollowMouse(UI)
	local brush = EntityGetWithName("conjurer_reborn_brush_reticle")
	if brush then
		local grid_size = GetBrushGridSize(UI)
		local mx, my = DEBUG_GetMouseWorld()
		local x, y = GridSnap(mx, my, grid_size)
		EntitySetTransform(brush, x, y)
	end
end

---绘制普通材料
---@param material string
---@param brush table
local function DrawNormal(material, brush, rotation)
	local reticle = EntityGetWithName("conjurer_reborn_brush_reticle")
	local x, y = EntityGetTransform(reticle)
    local draw_vars = GetMatDrawVars(material, brush, rotation)
	draw_vars["emitter_lifetime_frames"] = 6
	EntityAddComponent2(reticle, "ParticleEmitterComponent", draw_vars)
end

---绘制扩张材料
---@param material string
---@param brush table
---@param x number
---@param y number
local function DrawGrower(material, brush, x, y, rotation)
	local filler = EntityCreateNew()
	local draw_vars = GetMatDrawVars(material, brush, rotation)

	draw_vars["image_animation_raytrace_from_center"] = true

	EntityAddComponent2(filler, "LifetimeComponent", { lifetime = 200 })
	EntityAddComponent2(filler, "ParticleEmitterComponent", draw_vars)
	EntitySetTransform(filler, x, y)
end

---绘制Box2D
---@param brush table
local function DrawBox2D(brush, rotation)
    local reticle = EntityGetWithName("conjurer_reborn_brush_reticle")
    local var = GetMatDrawVars("conjurer_reborn_construction_steel", brush, rotation)
	var["emitter_lifetime_frames"] = 6
	EntityAddComponent2(
		reticle,
		"ParticleEmitterComponent",
		var
	)
end

---绘制材料，按下的过程
---@param UI Gui
---@param matid string
---@param brush table
---@param x number
---@param y number
local function HandleDraw(UI, matid, brush, x, y, rotation)
	local is_box2d_material = MatTable[matid].conjurer_unsafe_type == MatType.Box2d
	if is_box2d_material and not brush.physics_supported then
		return GamePrint("$conjurer_reborn_material_handle_draw_no_box2d")
	end

	if brush.action then
		return brush.action(matid, brush, x, y)
	end

	if is_box2d_material then
		DrawBox2D(brush, rotation)
	elseif brush.raytrace_from_center then
		DrawGrower(matid, brush, x, y, rotation)
	else
		DrawNormal(matid, brush, rotation)
	end
end

---处理Box2D的转换
---@param material string
---@param brush table
local function ReleaseBox2D(material, brush)
	-- Conversion delay is added because our drawing logic has a short
	-- "trailing" for a few frames upon releasing mouse (on purpose).
	local seconds = 0.33
	GlobalsSetValue("conjurer_reborn_TempBox2DMaterialID", material)
	SetTimeOut(
		seconds,
		"mods/conjurer_reborn/files/wandhelper/mat_to_box2d.lua",
		"ConvertMaterial"
	)
end

---绘制材料，放开的处理
---@param matid string
---@param brush table
---@param x number
---@param y number
local function HandleRelease(matid, brush, x, y)
	local is_box2d_material = MatTable[matid].conjurer_unsafe_type == MatType.Box2d
	if is_box2d_material and not brush.physics_supported then
		return -- Do nothing, warning has already been given upon clicking.
	end

	if brush.release_action then
		return brush.release_action(matid, brush, x, y)
	end

	-- No other default release actions yet needed.
	if is_box2d_material then
		ReleaseBox2D(matid, brush)
	end
end

local horizontal = 1
local any_rotation = 3

local LastRotation = 0
local PrevDraw = false
---执行材料工具实体的操作
---@param UI Gui
function MaterialToolEntityUpdate(UI)
	BrushFollowMouse(UI)
	EraserFollowMouse(UI)

    local brush = GetActiveBrush(UI)
	
	local brushObj = EntityObj(EntityGetWithName("conjurer_reborn_brush_reticle") or 0)
    if brushObj.entity_id ~= 0 and (brush.can_rotation or brush.can_rotation_horizontal) then
		local rotationMax
		if brush.can_rotation then
            rotationMax = any_rotation
        else
			rotationMax = horizontal
		end
		if UI.UserData["BrushRotationType"] == nil then
			UI.UserData["BrushRotationType"] = 0
		end
        if InputIsKeyJustDown(Key_q) then
            if UI.UserData["BrushRotationType"] - 1 < 0 then
                UI.UserData["BrushRotationType"] = rotationMax
            else
                UI.UserData["BrushRotationType"] = UI.UserData["BrushRotationType"] - 1
            end
        elseif InputIsKeyJustDown(Key_e) then
			if UI.UserData["BrushRotationType"] + 1 > rotationMax then
                UI.UserData["BrushRotationType"] = 0
            else
                UI.UserData["BrushRotationType"] = UI.UserData["BrushRotationType"] + 1
            end
        end
        local newRotation = UI.UserData["BrushRotationType"] * 90
        if newRotation > 180 then
            newRotation = newRotation - 360
        end
        if LastRotation ~= newRotation then
            LastRotation = newRotation
			RefreshBrushSprite(UI)
			brushObj.attr.rotation = math.rad(newRotation)
        end
		--print(newRotation)
    elseif brushObj.entity_id ~= 0 and brushObj.attr.rotation ~= 0 then--没有就检查并设置为0
        RefreshBrushSprite(UI)
		brushObj.attr.rotation = 0
	end

	local holding_m1 = IsHoldingMouse1()
	local ACTION_HOLD_DRAW = not brush.click_to_use and holding_m1
	local ACTION_CLICK_DRAW = brush.click_to_use and HasClickedMouse1()
	local ACTION_RELEASE_DRAW = (holding_m1 == false and PrevDraw == true)
	local ACTION_HOLD_ERASE = IsHoldingMouse2()
	local ACTION_RELEASE_ERASE = (ACTION_HOLD_ERASE == false and PrevErase == true)
	local brush_grid_size = GetBrushGridSize(UI)

	local mx, my = DEBUG_GetMouseWorld()

	local bx, by = GridSnap(mx, my, brush_grid_size)

	local material = GetActiveMaterial(UI)
	if ACTION_HOLD_DRAW or ACTION_CLICK_DRAW then
		HandleDraw(UI, material, brush, bx, by, math.deg(brushObj.attr.rotation))
	end

	if ACTION_RELEASE_DRAW then
		HandleRelease(material, brush, bx, by)
	end

	if ACTION_HOLD_ERASE then
		HandleErase(UI, material)
	end

	if ACTION_RELEASE_ERASE then
		HandleEraseRelease()
	end

	PrevDraw = holding_m1
	PrevErase = ACTION_HOLD_ERASE
end
