dofile_once("data/scripts/lib/utilities.lua")

dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wands/entwand/helpers.lua")


function enabled_changed(entity, is_enabled)
  if is_enabled then
    change_spawner_reticle()
    return
  end

  local reticle = EntityGetWithName(RETICLE_NAME)
  if reticle then EntityKill(reticle) end
end
