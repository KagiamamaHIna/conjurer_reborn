--dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")

table.insert( actions,
{
  id                = "MATWAND",
  name              = "Stone of the Elements",
  description       = "Control the elements themselves",
  sprite            = "mods/conjurer_reborn/files/" .. "wands/matwand/spell.png",
  type              = ACTION_TYPE_PROJECTILE,
  spawn_level       = "",
  spawn_probability = "",
  price             = 100000,
  mana              = 0,
  hide_from_conjurer  = true,
  action = function()
    -- Could we make some sparks fly here? Some eartherly lights?
  end,
})

table.insert( actions,
{
  id                = "ENTWAND",
  name              = "Illusion Shard",
  description       = "Conjure the most convincing illusions",
  sprite            = "mods/conjurer_reborn/files/" .. "wands/entwand/spell.png",
  type              = ACTION_TYPE_PROJECTILE,
  spawn_level       = "",
  spawn_probability = "",
  price             = 100000,
  mana              = 0,
  hide_from_conjurer  = true,
  action = function()
    -- Could we make some sparks fly here? Some eartherly lights?
  end,
})

table.insert( actions,
{
  id                = "EDITWAND",
  name              = "CHAOS CLAW",
  description       = "Twist & corrupt the core of any entity",
  sprite            = "mods/conjurer_reborn/files/" .. "wands/editwand/spell.png",
  type              = ACTION_TYPE_PROJECTILE,
  spawn_level       = "",
  spawn_probability = "",
  price             = 100000,
  mana              = 0,
  hide_from_conjurer  = true,
  action = function()
    -- Could we make some sparks fly here? Some eartherly lights?
  end,
})
