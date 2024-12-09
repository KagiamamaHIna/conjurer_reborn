dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/scripts/enums.lua")


HAPPINESS_LOVE = 500
HAPPINESS_NEUTRAL = 0
HAPPINESS_HATE = -500
ACTIVE_HAPPINESS_LEVEL = HAPPINESS_NEUTRAL


function change_happiness(value)
  local entity = GameGetWorldStateEntity()
  EntitySetValue(entity, "WorldStateComponent", "global_genome_relations_modifier", value)

  ACTIVE_HAPPINESS_LEVEL=value
end


function get_happiness_icon(value)
  local icons = {
    [HAPPINESS_LOVE]="mods/conjurer_reborn/files/gfx/power_icons/paradise.png",
    [HAPPINESS_NEUTRAL]="mods/conjurer_reborn/files/gfx/power_icons/statusquo.png",
    [HAPPINESS_HATE]="mods/conjurer_reborn/files/gfx/power_icons/war.png",
  }

  return icons[value]
end
