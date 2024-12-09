-- Synced with magic numbers. Location for respawn & tower return.
-- Note: not the same as Noita's default mountain spawn location.
CONJURER_SPAWN_X = MagicNumbersGetValue("DESIGN_PLAYER_START_POS_X")
CONJURER_SPAWN_Y = MagicNumbersGetValue("DESIGN_PLAYER_START_POS_Y")

NOITA_SPAWN_X = 227
NOITA_SPAWN_Y = -85

-- Ninepiece Backgrounds
NPBG_DEFAULT = 0
NPBG_GOLD = 1
NPBG_TAB = 2
NPBG_BLUE = 3
NPBG_BLUE_TAB = 4
NPBG_BROWN = 5
NPBG_BROWN_TAB = 6
NPBG_PURPLE = 7
NPBG_GREEN = 8
NPBG_BLACK = 9

NPBG_STYLES = {
  [NPBG_DEFAULT]="data/ui_gfx/decorations/9piece0_gray.png",
  [NPBG_GOLD]="data/ui_gfx/decorations/9piece0.png",
  [NPBG_TAB]="mods/conjurer_reborn/files/gfx/9piece_tab.png",
  [NPBG_BLUE]="mods/conjurer_reborn/files/gfx/9piece_blue.png",
  [NPBG_BLUE_TAB]="mods/conjurer_reborn/files/gfx/9piece_blue_tab.png",
  [NPBG_BROWN]="mods/conjurer_reborn/files/gfx/9piece_brown.png",
  [NPBG_BROWN_TAB]="mods/conjurer_reborn/files/gfx/9piece_brown_tab.png",
  [NPBG_BROWN_TAB]="mods/conjurer_reborn/files/gfx/9piece_brown_tab.png",
  [NPBG_PURPLE]="mods/conjurer_reborn/files/gfx/9piece_purple.png",
  [NPBG_GREEN]="mods/conjurer_reborn/files/gfx/9piece_green.png",
  [NPBG_BLACK]="mods/conjurer_reborn/files/gfx/9piece_black.png",
}


ICON_MOUSE_LEFT = "mods/conjurer_reborn/files/gfx/mouse_left.png"
ICON_MOUSE_RIGHT = "mods/conjurer_reborn/files/gfx/mouse_right.png"


COLOR_TEXT_TITLE = {red=155, green=173, blue=183}


-- TIME OF DAY
DAWN = 0.73
NOON = 0
DUSK = 0.47
MIDNIGHT = 0.6


GLOBAL_UNDEFINED = "nil"

--
-- MATWAND
--
-- NOTE: The reticle entity file has the actual default brush image defined
-- TODO: Dynamic first load?
SELECTED_BRUSH = "conjurer_reborn_SELECTED_BRUSH"
SELECTED_BRUSH_CATEGORY = "conjurer_reborn_SELECTED_BRUSH_CATEGORY"
SELECTED_MATERIAL = "conjurer_reborn_SELECTED_MATERIAL"
SELECTED_MATERIAL_ICON = "conjurer_reborn_SELECTED_MATERIAL_ICON"
SELECTED_MATERIAL_IS_PHYSICS = "conjurer_reborn_SELECTED_MATERIAL_IS_PHYSICS"
BRUSH_GRID_SIZE = "conjurer_reborn_BRUSH_GRID_SIZE"

ERASER_MODE = "conjurer_reborn_ERASER_MODE"
ERASER_MODE_ALL = "ALL"
ERASER_MODE_SELECTED = "SELECTED"
ERASER_MODE_SOLIDS = "[solid]"
ERASER_MODE_LIQUIDS = "[liquid]"
ERASER_MODE_SANDS = "[sand_ground]"
ERASER_MODE_GASES = "[gas]"
ERASER_MODE_FIRE = "[fire]"

ERASER_REPLACE = "conjurer_reborn_ERASER_REPLACE"
ERASER_SHARED_GRID = "conjurer_reborn_ERASER_SHARED_GRID"
ERASER_GRID_SIZE = "conjurer_reborn_ERASER_GRID_SIZE"
ERASER_SIZE = "conjurer_reborn_ERASER_SIZE"

ERASER_PIXEL = "mods/conjurer_reborn/files/gfx/eraser_pixel.png"
REPLACER_PIXEL = "mods/conjurer_reborn/files/gfx/replacer_pixel.png"


--
-- ENTWAND
--
SELECTED_ENTITY_INDEX = "conjurer_reborn_SELECTED_ENTITY_INDEX"
SELECTED_ENTITY_TYPE = "conjurer_reborn_SELECTED_ENTITY_TYPE"

ENTWAND_GRID_SIZE = "conjurer_reborn_ENTWAND_GRID_SIZE"
ENTWAND_ROWS = "conjurer_reborn_ENTWAND_ROWS"
ENTWAND_COLS = "conjurer_reborn_ENTWAND_COLS"

ENTWAND_HOLD_TO_SPAWN  = "conjurer_reborn_ENTWAND_HOLD_TO_SPAWN"
ENTWAND_HOLD_TO_DELETE = "conjurer_reborn_ENTWAND_HOLD_TO_DELETE"
ENTWAND_DELETE_ALL  = "conjurer_reborn_ENTWAND_DELETE_ALL"
ENTWAND_KILL_INSTEAD  = "conjurer_reborn_ENTWAND_KILL_INSTEAD"

ENTWAND_IGNORE_BACKGROUNDS  = "conjurer_reborn_IGNORE_BACKGROUNDS"
BG_NAME = "conjurer_reborn_background"

ANIMALS_SPAWN_GOLD = "conjurer_reborn_animals_spawn_gold"


--
-- EDITWAND
--
ENTITY_TO_INSPECT = "conjurer_reborn_ENTITY_TO_INSPECT"
SIGNAL_RESET_EDITWAND_GUI = "conjurer_reborn_SIGNAL_RESET_EDITWAND_GUI"
EDITWAND_SHOW_ALL_COMPS = "conjurer_reborn_EDITWAND_SHOW_ALL_COMPS"

EDITWAND_TUNE_COMPONENT_ID = "conjurer_reborn_EDITWAND_TUNE_COMPONENT_ID"
EDITWAND_TUNE_COMPONENT_FIELD = "conjurer_reborn_EDITWAND_TUNE_COMPONENT_FIELD"
EDITWAND_TUNE_COMPONENT_VALUE = "conjurer_reborn_EDITWAND_TUNE_COMPONENT_VALUE"

--
-- POWERS
--
KALMA_IS_IMMORTAL = "conjurer_reborn_IMMORTALITY"
BINOCULARS_ACTIVE = "conjurer_reborn_BINOCULARS_ACTIVE"

RAIN_ENABLED = "conjurer_reborn_RAIN_ENABLED"
RAIN_COUNT = "conjurer_reborn_RAIN_COUNT"
RAIN_WIDTH = "conjurer_reborn_RAIN_WIDTH"
RAIN_VELOCITY_MIN = "conjurer_reborn_RAIN_VELOCITY_MIN"
RAIN_VELOCITY_MAX = "conjurer_reborn_RAIN_VELOCITY_MAX"
RAIN_GRAVITY = "conjurer_reborn_RAIN_GRAVITY"
RAIN_BOUNCE = "conjurer_reborn_RAIN_BOUNCE"
RAIN_DRAW_LONG = "conjurer_reborn_RAIN_DRAW_AS_LONG"
RAIN_MATERIAL = "conjurer_reborn_RAIN_MATERIAL"
RAIN_MATERIAL_ICON = "conjurer_reborn_RAIN_MATERIAL_ICON"

WIND_OVERRIDE_ENABLED = "conjurer_reborn_WIND_OVERRIDE_ENABLED"
WIND_SPEED = "conjurer_reborn_WIND_SPEED"

FOG_AMOUNT = "conjurer_reborn_FOG_AMOUNT"
CLOUD_AMOUNT = "conjurer_reborn_CLOUD_AMOUNT"


--
-- OTHER
--
PLAYER_HAS_DIED = "conjurer_reborn_PLAYER_HAS_DIED"
FIRST_LOAD_DONE = "conjurer_reborn_FIRST_LOAD_DONE"


-- World file locations
BIOME_MAP_NOITA = "data/biome_impl/biome_map.png"
BIOME_MAP_NOITA_NG = "data/biome_impl/biome_map_newgame_plus.lua"
BIOME_MAP_CONJURER = "mods/conjurer_reborn/files/biomes/biome_map.png"
BIOME_MAP_CONJURER_GENERATED = "mods/conjurer_reborn/files/biomes/biome_map.lua"
PIXEL_SCENES_NOITA = "mods/conjurer_reborn/files/overrides/original_pixel_scenes.xml"
PIXEL_SCENES_DEFAULT = "data/biome/_pixel_scenes.xml"
PIXEL_SCENES_NOITA_NG = "data/biome/_pixel_scenes_newgame_plus.xml"

-- World selection values for Globals
BIOME_CURRENT = "conjurer_reborn_CURRENT_WORLD"
BIOME_SELECTION = "conjurer_reborn_BIOME_SELECTION"
BIOME_DESERT = "desert"
BIOME_FOREST = "forest"
BIOME_WINTER = "winter"
BIOME_WATER = "lake"
BIOME_HELL = "hell"
BIOME_NOITA = "noita"
BIOME_NOITA_NG = "noita_ng+"
BIOME_CONJURER = "conjurer"

WORLD_CURRENT = "conjurer_reborn_WORLD_CURRENT"
WORLD_SELECTION = "conjurer_reborn_WORLD_SELECTION"
WORLD_NOITA = "world_noita"
WORLD_CONJURER = "world_conjurer"

BIOME_SELECTION_SCENE_FILE = "conjurer_reborn_BIOME_SELECTION_FILE"
BIOME_SELECTION_FILE = "conjurer_reborn_BIOME_FILE"


DEFAULTS = {
  -- Matwand
  [SELECTED_BRUSH] = "4", -- 10px brush
  [SELECTED_BRUSH_CATEGORY] = "1", -- 10px brush
  [SELECTED_MATERIAL] = "soil",
  [SELECTED_MATERIAL_ICON] = "mods/conjurer_reborn/files/gfx/material_icons/soil.png",
  [SELECTED_MATERIAL_IS_PHYSICS] = "0",
  [BRUSH_GRID_SIZE] = "1",
  [ERASER_MODE] = ERASER_MODE_ALL,
  [ERASER_REPLACE] = "0",
  [ERASER_SHARED_GRID] = "1",
  [ERASER_GRID_SIZE] = "1",
  [ERASER_SIZE] = "2",
  -- Entwand
  [SELECTED_ENTITY_INDEX] = "120",  -- Sheep.
  [SELECTED_ENTITY_TYPE] = 1, -- Animals / Creatures
  [ENTWAND_GRID_SIZE] = 1,
  [ENTWAND_ROWS] = 1,
  [ENTWAND_COLS] = 1,
  [ENTWAND_HOLD_TO_SPAWN] = "0",
  [ENTWAND_HOLD_TO_DELETE] = "0",
  [ENTWAND_DELETE_ALL] = "0",
  [ENTWAND_KILL_INSTEAD] = "0",
  [ENTWAND_IGNORE_BACKGROUNDS] = "0",
  [ANIMALS_SPAWN_GOLD] = "0",
  -- Editwand
  [ENTITY_TO_INSPECT] = GLOBAL_UNDEFINED,
  [SIGNAL_RESET_EDITWAND_GUI] = "0",
  [EDITWAND_SHOW_ALL_COMPS] = "0",
  -- Powers
  [BINOCULARS_ACTIVE] = "0",
  [KALMA_IS_IMMORTAL] = "0",
  [RAIN_ENABLED] = "0",
  [RAIN_COUNT] = 10,
  [RAIN_WIDTH] = 1280,
  [RAIN_VELOCITY_MIN] = "30",
  [RAIN_VELOCITY_MAX] = "60",
  [RAIN_GRAVITY] = "10",
  [RAIN_BOUNCE] = "1",
  [RAIN_DRAW_LONG] = "1",
  [RAIN_MATERIAL] = "water",
  [RAIN_MATERIAL_ICON] = "mods/conjurer_reborn/files/gfx/material_icons/water_colorgen.png",
  [WIND_OVERRIDE_ENABLED] = "1",
  [WIND_SPEED] = "2",
  [FOG_AMOUNT] = 0,
  [CLOUD_AMOUNT] = 0,
  -- Other
  [PLAYER_HAS_DIED] = "0",
  [FIRST_LOAD_DONE] = "0",
  [WORLD_CURRENT] = WORLD_CONJURER,
  [WORLD_SELECTION] = WORLD_CONJURER,
  [BIOME_CURRENT] = BIOME_CONJURER,
  [BIOME_SELECTION] = BIOME_CONJURER,
  [BIOME_SELECTION_FILE] = BIOME_MAP_CONJURER_GENERATED,
  [BIOME_SELECTION_SCENE_FILE] = PIXEL_SCENES_DEFAULT, -- Overridden as Conjurer's
}
