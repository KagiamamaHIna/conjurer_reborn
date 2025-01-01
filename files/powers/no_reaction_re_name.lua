dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
local entity = EntityGetParent(GetUpdatedEntityID())
local src = GetStorageComp(entity, "conjurer_reborn_src_key", "value_string")
local new = GetStorageComp(entity, "conjurer_reborn_new_key", "value_string")

local lsrc = GameTextGetTranslatedOrNot(src)
local lnew = GameTextGetTranslatedOrNot(new)
local ItemComponent = EntityGetFirstComponentIncludingDisabled(entity, "ItemComponent")
ComponentSetValue2(ItemComponent, "ui_description", lsrc..lnew)
