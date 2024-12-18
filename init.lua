local SrcCsv = ModTextFileGetContent("data/translations/common.csv")--设置新语言文件
local AddCsv = ModTextFileGetContent("mods/conjurer_reborn/files/lang/lang.csv")
ModTextFileSetContent("data/translations/common.csv", SrcCsv .. AddCsv)

ModMaterialsFileAdd("mods/conjurer_reborn/files/overrides/materials.xml")
ModLuaFileAppend("data/scripts/items/drop_money.lua", "mods/conjurer_reborn/files/overrides/drop_money.lua")

dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")
dofile_once("mods/conjurer_reborn/files/scripts/settings_handlers.lua")
dofile_once("mods/conjurer_reborn/files/scripts/world_handlers.lua")

-- Settings handlers
handle_zoom_setting()

-- World overrides
replace_biome_map()
append_custom_biomes()
replace_pixel_scenes()


function handle_inventory(player)
  local ITEMS_QUICK = {
    "data/entities/items/starting_wand_rng.xml",
    "data/entities/items/starting_bomb_wand_rng.xml",
    "mods/conjurer_reborn/files/wands/carrot/entity.xml",
  }
  local ITEMS_FULL = {
  }

  local inv_quick = EntityGetWithName("inventory_quick")
  local inv_full = EntityGetWithName("inventory_full")

  clear_player_inventory(player, inv_quick)
  give_player_items(inv_quick, ITEMS_QUICK)
  give_player_items(inv_full, ITEMS_FULL)
end


function player_overrides(player)
  -- Camera follow sucks hard when building stuff
  EntitySetValue(player, "PlatformShooterPlayerComponent", "move_camera_with_aim", false)

  -- Endless flight
  EntitySetValue(player, "CharacterDataComponent", "flying_needs_recharge", false)

  -- Never die
  EntitySetValue(player, "DamageModelComponent", "wait_for_kill_flag_on_death", true)
  EntityAddComponent(player, "LuaComponent", {
    script_damage_received="mods/conjurer_reborn/files/scripts/death.lua",
  })
end


function OnPlayerSpawned(player)
  GameAddFlagRun("conjurer_reborn_world")
  handle_progression_setting()

  if not GlobalsGetBool(FIRST_LOAD_DONE) or GlobalsGetBool(PLAYER_HAS_DIED) then
    handle_inventory(player)
    player_overrides(player)

    -- Always start on noon
    set_time_of_day(NOON)

    GlobalsSetValue(FIRST_LOAD_DONE, "1")
    GlobalsSetValue(PLAYER_HAS_DIED, "0")
  end
end


function OnPlayerDied(player)
  GlobalsToggleBool(PLAYER_HAS_DIED)
  GlobalsSetValue("conjurer_unsafePowerKalmaActive", "0")--让游戏给玩家在下次开启时添加无敌和防变形
  GamePrintImportant(
    "$conjurer_reborn_player_died1",
    "$conjurer_reborn_player_died2"
  )
end

if not ModIsEnabled("conjurer_unsafe") then
	local count = 0
    function OnWorldPostUpdate()
		if count == 0 then
			GamePrint("$conjurer_reborn_unsafe_no_found1")
			GamePrint(GameTextGet("$conjurer_reborn_unsafe_no_found2","It's not public yet :("))
        elseif count >= 120 then
			count = -1
		end
		count = count + 1
	end
end
