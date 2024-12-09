dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/custom_entities/door/door.lua")

function electricity_receiver_switched(is_electrified)
  -- TODO: This keeps flipping every `active_time_frames`.
  -- Figure out something to make this smooth.
  local door = GetUpdatedEntityID()

  toggle_background(door)
  toggle_body(door)
end
