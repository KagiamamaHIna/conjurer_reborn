dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile("data/scripts/lib/utilities.lua")

---设置灵魂出窍开启状态
---@param UI Gui
---@param value boolean
function SetBinocularsActive(UI, value)
	WorldGlobalSetBool(UI, "PowerBinocularsActive", value)
end

---获得灵魂出窍开启状态
---@param UI Gui
---@return boolean
function GetBinocularsActive(UI)
	return WorldGlobalGetBool(UI, "PowerBinocularsActive", false)
end

-- Conjurer Eye
function TogglePlayerMovement(is_enabled)
	local player = GetPlayer()
	if player == nil then
		return
	end

	local CharacterPlatforming = EntityGetFirstComponentIncludingDisabled(player, "CharacterPlatformingComponent")

	EntitySetComponentIsEnabled(player, CharacterPlatforming, is_enabled)

	if not is_enabled then
		local dataComp = EntityGetFirstComponent(player, "CharacterDataComponent")
		ComponentSetValueVector2(dataComp, "mVelocity", 0, 0)
	end
end

function ToggleBinoculars(UI)
	local is_active = GetBinocularsActive(UI)

	TogglePlayerMovement(is_active)
	GameSetCameraFree(not is_active)

	SetBinocularsActive(UI, not is_active)

	local text = not is_active and "$conjurer_reborn_power_binoculars_on" or "$conjurer_reborn_power_binoculars_off"
	GamePrint(text)
end

function GetCameraControls()
	local player = GetPlayer()
	if player == nil then
		return false
	end
	return not EntityGetValue(player, "PlatformShooterPlayerComponent", "center_camera_on_this_entity")
end

-- Glass Eye
function ToggleCameraControls(UI)
	local player = GetPlayer()
	if player == nil then
		return
	end

	-- Make sure binoculars are turned off
	if GetBinocularsActive(UI) then
		-- TODO:
		-- Figure out how to make the camera stay properly when binoculars are used.
		-- Previous tries always put the camera back in player's starting position,
		-- no matter how we tried to set it manually.
		ToggleBinoculars(UI)
	end

	EntityToggleValue(player, "PlatformShooterPlayerComponent", "center_camera_on_this_entity")

	local is_active = not EntityGetValue(player, "PlatformShooterPlayerComponent", "center_camera_on_this_entity")

	local text = is_active and "$conjurer_reborn_power_glass_eye_on" or "$conjurer_reborn_power_glass_eye_off"
	GamePrint(text)
end

---计算网格视野的位置
---@return number
---@return number
function CalculateGridPosition()
	local x, y = GameGetCameraPos()
	local GRID_SIZE = 100

	-- Lock to grid
	x = x - x % GRID_SIZE
	y = y - y % GRID_SIZE

	return x, y
end

---切换网格视野
function ToggleGrid()
	local grid = EntityGetWithName("conjurer_reborn_grid_overlay")
	if grid == nil or grid == 0 then
		local x, y = CalculateGridPosition()
		EntityLoad("mods/conjurer_reborn/files/powers/re_grid_overlay.xml", x, y)
	else
		EntityKill(grid)
	end
end

function GetKalma(UI)
	return WorldGlobalGetBool(UI, "PowerKalmaActive", false)
end

function ToggleKalma(UI)
	local player = GetPlayer()
	if player == nil then
		return
	end
	local active = GetKalma(UI)
	if active then
		GamePrint("$conjurer_reborn_power_kalma_off")
	else
		GamePrint("$conjurer_reborn_power_kalma_on")
	end

	WorldGlobalSetBool(UI, "PowerKalmaActive", not active)
end

local player_speedy_defaults = {
	jump_velocity_y = -95,
	jump_velocity_x = 56,
	fly_speed_max_up = 95,
	fly_speed_max_down = 85,
	--fly_speed_change_spd=0.25,
	run_velocity = 154,
	fly_velocity_x = 52,
	velocity_min_x = -57,
	velocity_max_x = 57,
	velocity_min_y = -200,
	velocity_max_y = 350,
}

local speedy_vars = {}
for key, var in pairs(player_speedy_defaults) do
	speedy_vars[key] = var * 7
end

function GetSpeed()
	local particles = EntityGetWithName("conjurer_reborn_speed_particles")
	if particles == 0 or particles == nil then
		return false
	end
	return true
end

function ToggleSpeed()
	local player = GetPlayer()
	if player == nil then
		return
	end
	local particles = EntityGetWithName("conjurer_reborn_speed_particles")

	if particles == 0 or particles == nil then
		EntitySetValues(player, "CharacterPlatformingComponent", speedy_vars)

		local new_particles = EntityLoad("mods/conjurer_reborn/files/powers/speed_particles.xml")
		EntityAddChild(player, new_particles)

		GamePrint("$conjurer_reborn_power_viima_on")
	else
		EntitySetValues(player, "CharacterPlatformingComponent", player_speedy_defaults)

		EntityRemoveFromParent(particles)
		EntityKill(particles)

		GamePrint("$conjurer_reborn_power_viima_off")
	end
end

local WorldCurrent = "world_conjurer"

function CreateDimensionalPortal(biome, world, biome_file, scene_file)
	local BIOME_SELECTION = "conjurer_reborn_BIOME_SELECTION"
	local BIOME_SELECTION_SCENE_FILE = "conjurer_reborn_BIOME_SELECTION_FILE"
	local BIOME_SELECTION_FILE = "conjurer_reborn_BIOME_FILE"
	local WORLD_SELECTION = "conjurer_reborn_WORLD_SELECTION"
	return function()
		-- Never ever let these *not* update when creating a new portal
		biome_file = biome_file or "mods/conjurer_reborn/files/biomes/biome_map.lua"
		scene_file = scene_file or "data/biome/_pixel_scenes.xml"
		biome = biome or "conjurer"

		GlobalsSetValue(BIOME_SELECTION_FILE, biome_file)
		GlobalsSetValue(BIOME_SELECTION_SCENE_FILE, scene_file)
		GlobalsSetValue(BIOME_SELECTION, biome)
		GlobalsSetValue(WORLD_SELECTION, world)
		WorldCurrent = world
		-- Kill any existing portals
		local portal = EntityGetWithName("dimension_portal")
		EntityKill(portal)

		-- Spawn the portal
		local player = GetPlayer()
		local x, y = EntityGetTransform(player)
		EntityLoad("mods/conjurer_reborn/files/powers/dimension_portal.xml", x, y - 80)
	end
end

---以下是记忆点的一些函数和变量实现---
local function memorize_path(name)
	return "mods/conjurer_reborn/files/gfx/power_icons/waypoints/" .. name .. ".png"
end

local function memorize_key(name)
	return "conjurer_reborn_WAYPOINT_" .. name
end

local MnenomisDevices = {
	{ name = "Ahma",    image = memorize_path("ahma") },
	{ name = "Ilves",   image = memorize_path("ilves") },
	{ name = "Karhu",   image = memorize_path("karhu") },
	{ name = "Kettu",   image = memorize_path("kettu") },
	{ name = "karppa",  image = memorize_path("karppa") },
	{ name = "Naali",   image = memorize_path("naali") },
	{ name = "Norppa",  image = memorize_path("norppa") },
	{ name = "Orava",   image = memorize_path("orava") },
	{ name = "Peura",   image = memorize_path("peura") },
	{ name = "Poro",    image = memorize_path("poro") },
	{ name = "Hirvi",   image = memorize_path("hirvi") },
	{ name = "Rotta",   image = memorize_path("rotta") },
	{ name = "Rusakko", image = memorize_path("rusakko") },
	{ name = "Siili",   image = memorize_path("siili") },
	{ name = "Supi",    image = memorize_path("supi") },
	{ name = "Susi",    image = memorize_path("susi") },
}
---预处理键
for _, v in ipairs(MnenomisDevices) do
	v.name = "$conjurer_reborn_power_memorize_" .. v.name:lower()
end

LOCATION_MEMORY = {
	-- Automatically populated format:
	-- { name="kettu", image="kettu.png", x=123, y=456 }
}

local function memorize_parse_coordinates(value)
	local x, y = value:match("([^,]+);([^,]+)")
	return tonumber(x), tonumber(y)
end

for i, animal in ipairs(MnenomisDevices) do
	local key = memorize_key(animal.name)
	local value = GlobalsGetValue(key, "not_found")

	if value ~= "not_found" then
		local x, y = memorize_parse_coordinates(value)
		table.insert(LOCATION_MEMORY, {
			name = animal.name,
			image = animal.image,
			x = x,
			y = y,
		})
	end
end

local function check_duplicate(name)
	for i, animal in ipairs(LOCATION_MEMORY) do
		if name == animal.name then
			return true
		end
	end
	return false
end

local function get_random_animal()
	if #LOCATION_MEMORY == #MnenomisDevices then
		-- All animals exhausted. One shouldn't need this many waypoints?!
		return nil
	end

	local new_animal = nil
	local is_duplicate = false

	repeat
		new_animal = random_from_array(MnenomisDevices)
		is_duplicate = check_duplicate(new_animal.name)
	until (not is_duplicate)

	return new_animal
end

function SetWaypoint(x, y)
	SetRandomSeed(x,y)
	local animal = get_random_animal()

	if not animal then
		GamePrint("$conjurer_reborn_power_memorize_too_many")
		return
	end

	-- Add to table for immediate use
	table.insert(LOCATION_MEMORY, {
		name = animal.name,
		image = animal.image,
		x = x,
		y = y,
	})

	-- Add to globals for reloading upon restart
	GlobalsSetValue(
		memorize_key(animal.name),
		x .. ";" .. y
	)
	local name = GameTextGet(animal.name)
	GamePrint(GameTextGet("$conjurer_reborn_power_memorize_save", name))
end

function RemoveWaypoint(animal, index)
	table.remove(LOCATION_MEMORY, index)
	GlobalsSetValue(memorize_key(animal.name), "not_found")
end

---获取出生点坐标
---@param world string?
---@return integer
---@return integer
function GetSpawnPosition(world)
	world = world or WorldCurrent
	if world == "world_noita" then
        return 227, -85
	end

	-- For now all other worlds are just Conjurer's own.
	return tonumber(MagicNumbersGetValue("DESIGN_PLAYER_START_POS_X")), tonumber(MagicNumbersGetValue("DESIGN_PLAYER_START_POS_Y"))
end

---结束---

---改变世界关系
---@param value integer
function ChangeHappiness(value)
	local entity = GameGetWorldStateEntity()
	EntitySetValue(entity, "WorldStateComponent", "global_genome_relations_modifier", value)
end

---返回世界关系
---@return integer
function GetHappiness()
	local entity = GameGetWorldStateEntity()
	return EntityGetValue(entity, "WorldStateComponent", "global_genome_relations_modifier")
end

function GetHappinessImage()
	local love = "mods/conjurer_reborn/files/gfx/power_icons/paradise.png"
    local neutral = "mods/conjurer_reborn/files/gfx/power_icons/statusquo.png"
    local hate = "mods/conjurer_reborn/files/gfx/power_icons/war.png"

    local value = GetHappiness()
    if value <= -100 then
        return hate
    end
    if value >= 100 then
        return love
    end
	return neutral
end
