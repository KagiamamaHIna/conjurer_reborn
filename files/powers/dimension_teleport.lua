dofile_once("data/scripts/newgame_plus.lua")

dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


-- Teleport player to spawn locations only when changing between Noita's
-- and our Conjurer's own worlds, not just different biomes.
function teleport_if_necessary(destination_world)
  local current_world = GlobalsGet(WORLD_CURRENT)

  if current_world ~= destination_world then
    local x, y = get_spawn_position(destination_world)
    print("TELEPORTING PLAYER TO " .. tostring(x) .. ", " .. tostring(y))
    teleport_player(x, y)
  end
end

function collision_trigger(entity)
  if IsPlayer(entity) then
    local destination_biome = GlobalsGet(BIOME_SELECTION)
    local destination_world = GlobalsGet(WORLD_SELECTION)

    local biome_file = GlobalsGet(BIOME_SELECTION_FILE)
    local scene_file = GlobalsGet(BIOME_SELECTION_SCENE_FILE)
    if destination_biome == "noita_ng+" then
      SessionNumbersSetValue("NEW_GAME_PLUS_COUNT", GlobalsGetValue("conjurer_reborn_next_ngplus_level", "0"))
    else
      SessionNumbersSetValue("NEW_GAME_PLUS_COUNT", "0")
    end
    print("Loading world files:")
    print(biome_file)
    print(scene_file)

    teleport_if_necessary(destination_world)

    -- Mimic a "real" seeds that base worlds get. Something between 8 and 10 digits
    local GlobalSeed = GlobalsGetValue("conjurer_reborn_power_world_seed", "")
    local seed
    if GlobalSeed == "" then --没有就随机化
      seed = Random(0, 0x7FFFFFFE)
    else
      local tempSeed = tonumber(GlobalSeed)
      if tempSeed then
        seed = tempSeed
      else --如果真的没有的话，就随机吧
        seed = Random(0, 0x7FFFFFFE)
      end
    end
    SetWorldSeed(seed)
    local seedStr = tostring(seed)

    GamePrint(GameTextGet("$log_worldseed", seedStr))

    -- Override all our own fun stuff with things necessary for loading NG+
    if destination_biome == BIOME_NOITA_NG then
      GameClearOrbsFoundThisRun()

      do_newgame_plus()
      GlobalsSetValue(BIOME_CURRENT, destination_biome)
      return
    end

    -- Actually change the map
    BiomeMapLoad_KeepPlayer(biome_file, scene_file)

    -- Update current location
    GlobalsSetValue(BIOME_CURRENT, destination_biome)
    GlobalsSetValue(WORLD_CURRENT, destination_world)
    
    GlobalsSetValue("conjurer_reborn_last_death_x", "nan")
    GlobalsSetValue("conjurer_reborn_last_death_y", "nan")
    --[[
    -- Fix a case where you couldn't draw after a teleport, before swapping wands.
    if EntityGetName(get_active_wand()) == "matwand" then
      create_brush()
    end]]
    return
  end

  -- Kill any non-player colliding entities
  EntityConvertToMaterial(entity, "plasma_fading_bright")
  EntityKill(entity)
end
