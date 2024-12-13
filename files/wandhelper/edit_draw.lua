dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/wand_utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")

-- TODO: Cursor handling very similar to entwand. See if they could be combined.
local function get_or_create_cursor(x, y)
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

local function hide_cursor()
	local cursor = EntityGetWithName("conjurer_reborn_editwand_cursor")
	EntityKill(cursor)
end

local function show_cursor(entity, x, y)
    local cursor = get_or_create_cursor(x, y)

    if EntityGetParent(cursor) ~= entity then
        if EntityGetParent(cursor) ~= cursor then
            EntityRemoveFromParent(cursor)
        end
        EntityAddChild(entity, cursor)
    end
end

local function scan_entity(x, y)
	local SCAN_RADIUS = 32
	local entities = EntityGetInRadius(x, y, SCAN_RADIUS)

	local entity = (#entities > 1) and EntityGetClosest(x, y) or entities[1]

	if entity then
		local root = EntityGetRootEntity(entity)
		if is_valid_entity(root) then
			show_cursor(root, x, y)
			return root
		end
		-- else: get_next_entity()
	end

	-- Nothing found
	hide_cursor()
	return nil
end

local function physics_enabled(entity, enable)
	local a = EntityFirstComponent(entity, "PhysicsBodyComponent")
	local b = EntityFirstComponent(entity, "CharacterDataComponent")
	local c = EntityFirstComponent(entity, "SimplePhysicsComponent")

	if a then ComponentSetValue2(a, "is_kinematic", not enable) end
	if b then EntitySetComponentIsEnabled(entity, b, enable) end
	if c then EntitySetComponentIsEnabled(entity, c, enable) end
end

local function remove_joints(entity)
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

ENTITY_TO_MOVE = ENTITY_TO_MOVE or nil
ENTITY_TO_ROTATE = ENTITY_TO_ROTATE or nil
PREV_HOVERED_ENTITY = PREV_HOVERED_ENTITY or nil


local function move_entity(entity, x, y)
	EntityApplyTransform(entity, x, y)
end

local function freeze_entity(entity)
	PhysicsSetStatic(entity, true)

	ENTITY_TO_MOVE = nil
	ENTITY_TO_ROTATE = nil
end

local function rotate_entity(entity, x, y)
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
	physics_enabled(entity, false)
	remove_joints(entity)
end

local function m2_click_event(entity)
	ENTITY_TO_ROTATE = entity
	physics_enabled(entity, false)
	remove_joints(entity)
end

local function m1_release_event(entity)
	physics_enabled(entity, true)
	ENTITY_TO_MOVE = nil
end

local function m2_release_event(entity)
	freeze_entity(entity)
end

local function m1_action(entity, x, y)
	move_entity(entity, x, y)

	if has_clicked_m2() then
		freeze_entity(entity)
	end
end

local function m2_action(entity, x, y)
	rotate_entity(entity, x, y)
end

local function interact_action(entity, x, y)
	local target_has_changed = GlobalsGetNumber(ENTITY_TO_INSPECT) ~= PREV_HOVERED_ENTITY
	local target_is_alive = entity and EntityGetIsAlive(entity)

	if not target_is_alive or target_has_changed then
		GlobalsSetValue(SIGNAL_RESET_EDITWAND_GUI, "1")
	end

	GlobalsSetValue(ENTITY_TO_INSPECT, tostring(entity))

	-- Toggle indicator
	local old_indicator = EntityGetWithName("editwand_indicator")
	if old_indicator and EntityGetIsAlive(old_indicator) and target_has_changed then
		EntityKill(old_indicator)
	end

	if target_is_alive and target_has_changed then
		local new_indicator = EntityLoad("mods/conjurer_reborn/files/wands/editwand/selected_indicator.xml", x - 1000, y - 1000)
		EntityAddChild(entity, new_indicator)
	end
end

function EditWandUpdate(UI)
	local x, y = DEBUG_GetMouseWorld()
	local hovered_entity = scan_entity(x, y)

	local only_m1_clicked = has_clicked_m1() and not is_holding_m2() and hovered_entity
	local only_m2_clicked = has_clicked_m2() and not is_holding_m1() and hovered_entity

	local m1_action_released = not is_holding_m1() and ENTITY_TO_MOVE
	local m2_action_released = not is_holding_m2() and ENTITY_TO_ROTATE

	-- Click events
	if only_m1_clicked then m1_click_event(hovered_entity) end
	if only_m2_clicked then m2_click_event(hovered_entity) end

	-- Release event
	if m1_action_released then m1_release_event(ENTITY_TO_MOVE) end
	if m2_action_released then m2_release_event(ENTITY_TO_ROTATE) end

	-- Actions
	if ENTITY_TO_MOVE then m1_action(ENTITY_TO_MOVE, x, y) end
	if ENTITY_TO_ROTATE then m2_action(ENTITY_TO_ROTATE, x, y) end

	if has_clicked_interact() then interact_action(hovered_entity, x, y) end


	PREV_HOVERED_ENTITY = hovered_entity
end
