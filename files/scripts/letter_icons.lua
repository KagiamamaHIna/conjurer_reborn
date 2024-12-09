LETTERS = {
  a="mods/conjurer_reborn/files/gfx/letter_icons/1.png",
  b="mods/conjurer_reborn/files/gfx/letter_icons/2.png",
  c="mods/conjurer_reborn/files/gfx/letter_icons/3.png",
  d="mods/conjurer_reborn/files/gfx/letter_icons/4.png",
  e="mods/conjurer_reborn/files/gfx/letter_icons/5.png",
  f="mods/conjurer_reborn/files/gfx/letter_icons/6.png",
  g="mods/conjurer_reborn/files/gfx/letter_icons/7.png",
  h="mods/conjurer_reborn/files/gfx/letter_icons/8.png",
  i="mods/conjurer_reborn/files/gfx/letter_icons/9.png",
  j="mods/conjurer_reborn/files/gfx/letter_icons/10.png",
  k="mods/conjurer_reborn/files/gfx/letter_icons/11.png",
  l="mods/conjurer_reborn/files/gfx/letter_icons/12.png",
  m="mods/conjurer_reborn/files/gfx/letter_icons/13.png",
  n="mods/conjurer_reborn/files/gfx/letter_icons/14.png",
  o="mods/conjurer_reborn/files/gfx/letter_icons/15.png",
  p="mods/conjurer_reborn/files/gfx/letter_icons/16.png",
  q="mods/conjurer_reborn/files/gfx/letter_icons/17.png",
  r="mods/conjurer_reborn/files/gfx/letter_icons/18.png",
  s="mods/conjurer_reborn/files/gfx/letter_icons/19.png",
  t="mods/conjurer_reborn/files/gfx/letter_icons/20.png",
  u="mods/conjurer_reborn/files/gfx/letter_icons/21.png",
  v="mods/conjurer_reborn/files/gfx/letter_icons/22.png",
  w="mods/conjurer_reborn/files/gfx/letter_icons/23.png",
  x="mods/conjurer_reborn/files/gfx/letter_icons/24.png",
  y="mods/conjurer_reborn/files/gfx/letter_icons/25.png",
  z="mods/conjurer_reborn/files/gfx/letter_icons/26.png",
  å="mods/conjurer_reborn/files/gfx/letter_icons/27.png",
  ä="mods/conjurer_reborn/files/gfx/letter_icons/28.png",
  ö="mods/conjurer_reborn/files/gfx/letter_icons/29.png",
}

local DEFAULT_UNKNOWN = "ö"

function get_letter_icon(name)
  name = name or DEFAULT_UNKNOWN
  local first_character = name:sub(1, 1)
  local path = LETTERS[string.lower(first_character)]

  if not path then
    -- Oudot tapaukset menee ö-mappiin
    path = LETTERS[DEFAULT_UNKNOWN]
  end

  return path
end
