dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


function handle_zoom_setting()
  local zoom = ModSettingGet("conjurer_reborn.zoom_level")
  if zoom == "noita" then
    -- Nothing needs overwriting
    return
  end

  -- Change the actual zoom level
  local ZOOM_LEVELS = {
    conjurer="mods/conjurer_reborn/files/overrides/resolution_conjurer.xml",
    huge="mods/conjurer_reborn/files/overrides/resolution_huge.xml",
    fullhd="mods/conjurer_reborn/files/overrides/resolution_fullhd.xml",
  }
    local text = ModTextFileGetContent(ZOOM_LEVELS[zoom])
    if text == "" or nil then
		print("Zoom Error! file no found:",ZOOM_LEVELS[zoom])
		return
	end
  ModMagicNumbersFileAdd(ZOOM_LEVELS[zoom])


  -- Make the fog of war shader match the zoom level.
  --
  -- Note for `fullhd`:
  -- The zoom level breaks so much it actually doesn't even care about the shader
  -- anymore, so just make it same as the `huge` and call it a day.
  local FOW_SHADERS = {
    conjurer="mods/conjurer_reborn/files/overrides/resolution_conjurer.vert",
    huge="mods/conjurer_reborn/files/overrides/resolution_huge.vert",
    fullhd="mods/conjurer_reborn/files/overrides/resolution_huge.vert",
  }
  ModTextFileSetContent(
    "data/shaders/post_final.vert",
    ModTextFileGetContent(FOW_SHADERS[zoom])
  )
end


function handle_progression_setting()
  local progression = ModSettingGet("conjurer_reborn.progression")

  if not progression then
    print("Conjurer: Disabling progression logging")
    GameAddFlagRun("no_progress_flags_perk")
    GameAddFlagRun("no_progress_flags_animal")
    GameAddFlagRun("no_progress_flags_action")
  end
end
