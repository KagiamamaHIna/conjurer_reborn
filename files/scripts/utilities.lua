dofile_once("data/scripts/lib/utilities.lua")

dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


-- Include this file with:
-- dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")

MOD_PATH = "mods/conjurer_reborn/files/"
ICON_UNKNOWN = "mods/conjurer_reborn/files/gfx/icon_unknown.png"

local BUTTON_SETTING = ModSettingGet("conjurer_reborn.secondary_button")
local BUTTON_CHOICES = {
  throw={hold="mButtonDownThrow", click="mButtonFrameThrow"},
  mouse2={hold="mButtonDownRightClick", click="mButtonFrameRightClick"}
}

local SELECTED_BUTTON = BUTTON_CHOICES[BUTTON_SETTING]

--
---------------------------
-- General utilities
--

function capitalize_string(input)
  return input:gsub("%a", string.upper, 1)
end
function split_string(input, sep)
  sep = sep or "%s"

  local t={}
  for str in string.gmatch(input, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function get_path_basename(path)
  local parts = split_string(path, "/")
  return parts[#parts]
end

function get_entity_name_from_file(path)
  if not path or #path == 0 then
    return "anonymous entity"
  end

  local basename = get_path_basename(path)
  local sans_ext = split_string(basename, ".")[1]

  return sans_ext
end

function normalize_name(name)
  local words = split_string(name, "_")

  -- Don't capitalize everything, for now?
  --for i, word in ipairs(words) do
  --  words[i] = capitalize_string(word)
  --end

  return capitalize_string(table.concat(words, " "))
end


function round(num)
    if num >= 0 then return math.floor(num+.5)
    else return math.ceil(num-.5) end
end


function get_player()
  local players = get_players()
  if players ~= nil then
    return players[1]
  end

  -- Player is dead
  return nil
end

function shooting_is_enabled(player)
  player = player or get_player()
  if not player then return false end

  return ComponentGetIsEnabled(
    EntityGetFirstComponentIncludingDisabled(player, "GunComponent")
  )
end


function is_holding_m1(ignore_guncomponent)
  local player = get_player()
  if not player then return false end

  if not ignore_guncomponent and not shooting_is_enabled(player) then
    return false
  end

  return ComponentGetValue2(
    EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent"),
    "mButtonDownFire"
  )
end

function is_holding_m2(ignore_guncomponent)
  local player = get_player()
  if not player then return false end

  if not ignore_guncomponent and not shooting_is_enabled(player) then
    return false
  end

  return ComponentGetValue2(
    EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent"),
    SELECTED_BUTTON.hold
  )
end


function has_clicked_m1(ignore_guncomponent)
  local click_frame = EntityGetValue(
    get_player(), "ControlsComponent", "mButtonFrameFire"
  )

  if not ignore_guncomponent and not shooting_is_enabled() then
    return false
  end

  return click_frame == GameGetFrameNum()
end


function has_clicked_interact()
  local click_frame = EntityGetValue(
    get_player(), "ControlsComponent", "mButtonFrameInteract"
  )

  return click_frame == GameGetFrameNum()
end


function has_clicked_m2(ignore_guncomponent)
  local click_frame = EntityGetValue(
    get_player(), "ControlsComponent", SELECTED_BUTTON.click
  )

  if not ignore_guncomponent and not shooting_is_enabled() then
    return false
  end

  return click_frame == GameGetFrameNum()
end


function get_frames_in_air(player)
  return EntityGetValue(
    player or get_player(),
    "CharacterPlatformingComponent",
    "mFramesInAirCounter"
  )
end


function get_active_wand()
  local player = get_player()
  if not player then return nil end

  return EntityGetValue(player, "Inventory2Component", "mActiveItem")
end


function set_time_of_day(time)
  local entity = GameGetWorldStateEntity()
  edit_component(entity, "WorldStateComponent", function(comp,vars)
    vars.time = time
  end)
end


function bool_to_global(value)
  if value then
    return "1"
  end
  return "0"
end


function toggle_global(value)
  if value == "0" or not value then
    return "1"
  end
  return "0"
end


function set_weather()
  local worldState = EntityGetFirstComponentIncludingDisabled(
    GameGetWorldStateEntity(), "WorldStateComponent"
  )
  ComponentSetValue2(worldState, "intro_weather", true)
end


function entity_set_genome(entity, herd)
  local genomeComp = EntityGetFirstComponentIncludingDisabled(entity, "GenomeDataComponent")
  local herd_id = StringToHerdId(herd)

  ComponentSetValue2(genomeComp, "herd_id", herd_id)
end


function enable_physics(mats)
  -- Enables physics drawing for physics materials
  for i, mat in ipairs(mats) do
    mat.is_physics = true
  end
  return mats
end


local PI = math.pi
unitCircle = {
  ["topleft"] = 5*PI / 6,
  ["botleft"] = 9*PI / 8, -- 7*PI / 6
  ["topright"] = PI / 4,
  ["botright"] = 15*PI / 8, -- 11*PI / 6
  ["top"] = PI / 2,
  ["bot"] = 3*PI / 2,
}


function UniqueRandom()
  -- Return a generator for fetching multiple unique random numbers from a list.
  local used = {}
  local function generator(...)
    local num = Random(...)
    if used[num] then
      return generator(...)
    else
      used[num] = true
      return num
    end
  end
  return generator
end


-- Shorthands for a really common actions
function EntityGetValue(entity, component_name, attr_name)
  if entity == nil or entity == 0 then return nil end
  local comp = EntityGetFirstComponentIncludingDisabled(entity, component_name)
  if comp == 0 or comp == nil then
    return
  end
  return ComponentGetValue2(
    comp, attr_name
  )
end

function EntityFirstComponent(entity, component_name)
  -- Holy moly, should've made this alias sooner.
  return EntityGetFirstComponentIncludingDisabled(entity, component_name)
end

function EntitySetValue(entity, component_name, attr_name, value)
  if entity == nil or entity == 0 then return end

  return ComponentSetValue2(
    EntityGetFirstComponentIncludingDisabled(entity, component_name), attr_name, value
  )
end

function EntitySetValues(entity, component_name, values)
  if entity == nil or entity == 0 then return end

  local comp = EntityGetFirstComponentIncludingDisabled(entity, component_name)
  ComponentSetValues(comp, values)
end

function EntityToggleValue(entity, component_name, attr_name)
  if entity == nil or entity == 0 then return end

  local value = EntityGetValue(entity, component_name, attr_name)
  EntitySetValue(entity, component_name, attr_name, not value)
end

function ComponentToggleValue(comp, attr_name)
  local presumably_boolean = ComponentGetValue2(comp, attr_name)
  ComponentSetValue2(comp, attr_name, not presumably_boolean)
end

function ComponentSetValues(component, values)
  for key, value in pairs(values) do
    ComponentSetValue2(component, key, value)
  end
end

function GlobalsGet(key, default)
  default = default or tostring(DEFAULTS[key])

  local value = GlobalsGetValue(key, default)
  if value == GLOBAL_UNDEFINED then
    return nil
  end
  return value
end

function GlobalsToggleBool(key, default)
  GlobalsSetValue(key, toggle_global(GlobalsGetBool(key, default)))
end

function GlobalsGetBool(key, default)
  return GlobalsGet(key, default) == "1"
end

function GlobalsGetNumber(key, default)
  return tonumber(GlobalsGet(key, default))
end


function teleport_player(x, y)
  local player = get_player()
  if not player then
    return
  end

  EntitySetTransform(player, x, y)

  -- 1. Make the arrival less janky when teleporting in-air.
  --
  -- 2. If the Eye of Conjurer is active while we give the player some velocity
  -- it'll make the player float off helpless, so we disable it in that case.
  if not GlobalsGetBool(BINOCULARS_ACTIVE) then
    local dataComp = EntityGetFirstComponent(player, "CharacterDataComponent")
    local xvel, yvel = ComponentGetValue2(dataComp, "mVelocity")
    ComponentSetValue2(dataComp, "mVelocity", xvel, -65)
  end
end

function is_physical_entity(entity)
  return (
    EntityFirstComponent(entity, "PhysicsBody2Component") or
    EntityFirstComponent(entity, "PhysicsBodyComponent")
  )
end

function get_spawn_position(world)
  world = world or GlobalsGet(WORLD_CURRENT)
  if world == WORLD_NOITA then
    return NOITA_SPAWN_X, NOITA_SPAWN_Y
  end

  -- For now all other worlds are just Conjurer's own.
  return CONJURER_SPAWN_X, CONJURER_SPAWN_Y
end


---------------------------
-- PERKS
function has_perk(perk_id)
  return GameHasFlagRun("PERK_PICKED_" .. perk_id)
end


function enable_perks(player, perks)
  local x, y = EntityGetTransform(player)
  for _,name in ipairs(perks) do
    local perk = perk_spawn(x, y, name)
    if ( perk ~= nil ) then
      perk_pickup(perk, player, EntityGetName(perk), false, false)
    end
  end
end


function enable_perks_without_icons(player, perks)
  enable_perks(player, perks)

  local children = EntityGetAllChildren(player)
  for _, child in ipairs(children) do
    local icons = EntityGetComponentIncludingDisabled(child, "UIIconComponent")
    if icons then
      EntityRemoveFromParent(child)
      EntityKill(child)
    end
  end
end


---------------------------
-- ITEMS
function item_in_inventory(item)
  local full_items = EntityGetAllChildren(EntityGetWithName("inventory_full"))
  local quick_items = EntityGetAllChildren(EntityGetWithName("inventory_quick"))

  if (full_items and #full_items > 0) then
    for _, i in ipairs(full_items) do
      if i == item then return true end
    end
  end

  if (quick_items and #quick_items > 0) then
    for _, i in ipairs(quick_items) do
      if i == item then return true end
    end
  end

  return false
end


function clear_player_inventory(player, inventory)
  local items = EntityGetAllChildren(inventory)
  if (items == nil) then return end

  for _, item in ipairs(items) do
    GameKillInventoryItem(player, item)
  end
end


function give_player_items(inventory, items)
  for _, path in ipairs(items) do
    local item = EntityLoad(path)
    if item then
      EntityAddChild(inventory, item)
    else
      GamePrint("Couldn't load the item ["..path.."], something's terribly wrong!")
    end
  end
end


function create_image_spawner(z_index)
  return function(path, offset_x, offset_y)
    return function(x, y)
      -- Cursor offsets can be set very accurately for backgrounds.
      local cursor_x = 5
      local cursor_y = 10

      local bg = EntityLoad("mods/conjurer_reborn/files/custom_entities/base_bg_generated.xml", x, y)
      EntityAddComponent2(bg, "SpriteComponent", {
        image_file=path,
        z_index=z_index,
        offset_x=offset_x + cursor_x,
        offset_y=offset_y + cursor_y,
      })

      return bg
    end
  end
end


---------------------------
-- Debugging utils

-- Missing Python?
function float(var)
  return tonumber(var)
end


function debug_component(comp)
  print("--- COMPONENT DATA ---")
  print(str(ComponentGetMembers(comp)))
  print("--- END COMPONENT DATA ---")
end


function str(var)
  if type(var) == 'table' then
    local s = '{ '
    for k,v in pairs(var) do
      if type(k) ~= 'number' then
        k = '["'..k..'"] = '
      else
        k = ""
      end
      s = s .. k .. str(v) .. ','
    end
    return s .. '} '
  end
  if type(var) == 'string' then
    return tostring('"' .. var .. '"')
  end
  return tostring(var)
end


function debug_entity(e)
    local parent = EntityGetParent(e)
    local children = EntityGetAllChildren(e)
    local comps = EntityGetAllComponents(e)

    print("--- ENTITY DATA ---")
    print("Parent: ["..parent.."] " .. (EntityGetName(parent) or "nil"))

    print(" Entity: ["..str(e).."] " .. (EntityGetName(e) or "nil"))
    print("  Tags: " .. (EntityGetTags(e) or "nil"))
    if (comps ~= nil) then
      for _, comp in ipairs(comps) do
          print("  Comp: ["..comp.."] " .. (ComponentGetTypeName(comp) or "nil"))
      end
    end

    if children == nil then return end

    for _, child in ipairs(children) do
        local comps = EntityGetAllComponents(child)
        print("  Child: ["..child.."] " .. EntityGetName(child))
        for _, comp in ipairs(comps) do
            print("   Comp: ["..comp.."] " .. (ComponentGetTypeName(comp) or "nil"))
        end
    end
    print("--- END ENTITY DATA ---")
end


function Print(...)
  GamePrint(str(...))
end
