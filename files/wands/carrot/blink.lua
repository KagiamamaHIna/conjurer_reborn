dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")


if has_clicked_m1() or is_holding_m2() then
  local x, y = DEBUG_GetMouseWorld()
  teleport_player(x, y)
end
