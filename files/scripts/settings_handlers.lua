dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


function handle_zoom_setting()
    local zoom = CurSettingGet("zoom_level")
    if zoom == "noita" then
        -- Nothing needs overwriting
        return
    end
    local MagicNumberFormat = [[
<MagicNumbers
  VIRTUAL_RESOLUTION_X="%d"
  VIRTUAL_RESOLUTION_Y="%d"
></MagicNumbers>
]]

    -- Change the actual zoom level
    local ZOOM_LEVELS = {
        conjurer = 600,
        huge = 854,
        fullhd = 1920,
    }
    local gui = GuiCreate()
    local internal_size_w, internal_size_h = GuiGetScreenDimensions(gui)
    GuiDestroy(gui)
    local currentAspectRatio = internal_size_w / internal_size_h
    local resx = ZOOM_LEVELS[zoom]
    local resy = math.floor(resx / currentAspectRatio + 0.5) + 1
    ModTextFileSetContent("mods/conjurer_reborn/visual_magic_numbers.xml", MagicNumberFormat:format(resx, resy))
    ModMagicNumbersFileAdd("mods/conjurer_reborn/visual_magic_numbers.xml")


    -- Make the fog of war shader match the zoom level.
    --
    -- Note for `fullhd`:
    -- The zoom level breaks so much it actually doesn't even care about the shader
    -- anymore, so just make it same as the `huge` and call it a day.
    local FOW_SHADERS = {
        conjurer = "mods/conjurer_reborn/files/overrides/resolution_conjurer.vert",
        huge = "mods/conjurer_reborn/files/overrides/resolution_huge.vert",
        fullhd = "mods/conjurer_reborn/files/overrides/resolution_huge.vert",
    }
    ModTextFileSetContent(
        "data/shaders/post_final.vert",
        ModTextFileGetContent(FOW_SHADERS[zoom])
    )
end

function handle_progression_setting()
    local progression = CurSettingGet("progression")

    if not progression then
        print("Conjurer: Disabling progression logging")
        GameAddFlagRun("no_progress_flags_perk")
        GameAddFlagRun("no_progress_flags_animal")
        GameAddFlagRun("no_progress_flags_action")
    end
end
