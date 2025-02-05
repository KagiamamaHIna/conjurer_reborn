dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/wand_utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_helper.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")

-- TODO: Cursor handling very similar to entwand. See if they could be combined.
local function GetOrCreateCursor(x, y)
    local cursor = EntityGetWithName("conjurer_reborn_editwand_cursor")
    if cursor and cursor ~= 0 then
        return cursor
    end

    -- Offset initial load by *many pixels* from cursor position, because
    -- the engine insists on rendering it for 1 frame at the spawn position, no matter
    -- what hiding tricks we do. The positioning is immediately overtaken by
    -- InheritTransformComponent anyway.
    return EntityLoad("mods/conjurer_reborn/files/wands/editwand/re_cursor.xml", x + 1000, y + 1000)
end

local function HideCursor()
	local cursor = EntityGetWithName("conjurer_reborn_editwand_cursor")
	EntityKill(cursor)
end

local function ShowCursor(entity, x, y)
    local cursor = GetOrCreateCursor(x, y)

    if EntityGetParent(cursor) ~= entity then
        if EntityGetParent(cursor) ~= cursor then
            EntityRemoveFromParent(cursor)
        end
        EntityAddChild(entity, cursor)
    end
end

local function ScanEntity(UI, x, y)
	local entities = EntityGetInRadius(x, y, 32)

	local entity = (#entities > 1) and EntityGetClosest(x, y) or entities[1]

    if entity then
        local root = EntityGetRootEntity(entity)
        if IsValidEntity(UI, root) then
            ShowCursor(root, x, y)
            return root
        end
        -- else: get_next_entity()
    end
	-- done:) get_next_entity
	local Len = 33
	local id = nil
    for i, v in ipairs(entities) do
        local vroot = EntityGetRootEntity(v)
        if IsValidEntity(UI, vroot) then
			local ax, ay = EntityGetTransform(v)
            local alen = math.sqrt((x - ax) ^ 2 + (y - ay) ^ 2)
			if Len > alen then
                Len = alen
				id = vroot
			end
        end
    end
	if id then
		ShowCursor(id, x, y)
		return
	end
	-- Nothing found
	HideCursor()
	return nil
end

local function PhysicsEnabled(entity, enable)
	local a = EntityFirstComponent(entity, "PhysicsBodyComponent")
	local b = EntityFirstComponent(entity, "CharacterDataComponent")
	local c = EntityFirstComponent(entity, "SimplePhysicsComponent")

	if a then ComponentSetValue2(a, "is_kinematic", not enable) end
	if b then EntitySetComponentIsEnabled(entity, b, enable) end
	if c then EntitySetComponentIsEnabled(entity, c, enable) end
end

local function RemoveJoints(entity)
	local removable_components = {
		"PhysicsJointComponent", "PhysicsJoint2Component", "PhysicsJoint2MutatorComponent"
	}
	for _, comp_name in pairs(removable_components) do
		local comps = EntityGetComponentIncludingDisabled(entity, comp_name)
		if not comps then return end

		for _, comp in ipairs(comps) do
			EntityRemoveComponent(entity, comp)
		end
	end
end

local ENTITY_TO_MOVE = ENTITY_TO_MOVE or nil
local ENTITY_TO_ROTATE = ENTITY_TO_ROTATE or nil
local PREV_HOVERED_ENTITY = PREV_HOVERED_ENTITY or nil


local function MoveEntity(entity, x, y)
	EntityApplyTransform(entity, x, y)
end

local function FreezeEntity(entity)
	PhysicsSetStatic(entity, true)

	ENTITY_TO_MOVE = nil
	ENTITY_TO_ROTATE = nil
end

local function RotateEntity(entity, x, y)
	local mass = EntityGetValue(entity, "PhysicsBody2Component", "mPixelCount")

	-- This essentially resets the torque, making it turn linearly
	PhysicsSetStatic(entity, true)
	PhysicsSetStatic(entity, false)

	if mass then
		PhysicsApplyTorque(entity, mass)
		return
	end

	local entity_x, entity_y = EntityGetTransform(entity)
	local rot = math.atan2(entity_y - y, entity_x - x)

	EntitySetTransform(entity, entity_x, entity_y, rot)
end

local function m1_click_event(entity)
	ENTITY_TO_MOVE = entity
	PhysicsSetStatic(entity, false)
	PhysicsEnabled(entity, false)
	RemoveJoints(entity)
end

local function m2_click_event(entity)
	ENTITY_TO_ROTATE = entity
	PhysicsEnabled(entity, false)
	RemoveJoints(entity)
end

local function m1_release_event(entity)
	PhysicsEnabled(entity, true)
	ENTITY_TO_MOVE = nil
end

local function m2_release_event(entity)
	FreezeEntity(entity)
end

local function m1_action(entity, x, y)
	MoveEntity(entity, x, y)

	if HasClickedMouse2() then
		FreezeEntity(entity)
	end
end

local function m2_action(entity, x, y)
	RotateEntity(entity, x, y)
end

---标记实体
---@param UI Gui
---@param entity integer
---@param x number
---@param y number
local function interact_action(UI, entity, x, y)
	local target_has_changed = UI.UserData["EditWandEntityToInspectEntity"] ~= PREV_HOVERED_ENTITY
	local target_is_alive = entity and EntityGetIsAlive(entity)
	--[[
    if not target_is_alive or target_has_changed then
		GlobalsSetValue(SIGNAL_RESET_EDITWAND_GUI, "1")
	end]]

	UI.UserData["EditWandEntityToInspectEntity"] = entity

	-- Toggle indicator
	local old_indicator = EntityGetWithName("conjurer_reborn_editwand_indicator")
	if old_indicator and EntityGetIsAlive(old_indicator) and target_has_changed then
		EntityKill(old_indicator)
	end

    if target_is_alive and target_has_changed then
		EntityLoadChild(entity, "mods/conjurer_reborn/files/wands/editwand/re_selected_indicator.xml")
	end
end

---更新实体法杖的实体行为
---@param UI Gui
function EditWandUpdate(UI)
	local x, y = DEBUG_GetMouseWorld()
	local hovered_entity = ScanEntity(UI, x, y)

	local only_m1_clicked = HasClickedMouse1() and not IsHoldingMouse2() and hovered_entity
	local only_m2_clicked = HasClickedMouse2() and not IsHoldingMouse1() and hovered_entity

	local m1_action_released = not IsHoldingMouse1() and ENTITY_TO_MOVE
	local m2_action_released = not IsHoldingMouse2() and ENTITY_TO_ROTATE

	-- Click events
	if only_m1_clicked then m1_click_event(hovered_entity) end
	if only_m2_clicked then m2_click_event(hovered_entity) end

	-- Release event
	if m1_action_released then m1_release_event(ENTITY_TO_MOVE) end
	if m2_action_released then m2_release_event(ENTITY_TO_ROTATE) end

	-- Actions
	if ENTITY_TO_MOVE then m1_action(ENTITY_TO_MOVE, x, y) end
	if ENTITY_TO_ROTATE then m2_action(ENTITY_TO_ROTATE, x, y) end

	if HasClickedInteract() then interact_action(UI, hovered_entity, x, y) end


	PREV_HOVERED_ENTITY = hovered_entity
end
