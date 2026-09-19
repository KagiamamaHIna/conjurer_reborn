CurSettingDisableLoad = true
dofile_once("mods/conjurer_reborn/files/lib/CurSetting.lua")
---@module 'input'
InputFrame = dofile_once("mods/conjurer_reborn/files/lib/input.lua")
local entity = GetUpdatedEntityID()

function CustomKeyName(setting, ...)
	local names = {}
	for _,key in ipairs({...})do
    	local name = GameTextGetTranslatedOrNot(InputFrame.get_input_name(CurSettingGet(key)))
		names[#names+1] = name
	end
    return GameTextGet(setting, unpack(names))
end

local desc = CustomKeyName("$conjurer_reborn_tp_carrot_desc", "tp_carrot_blink", "tp_carrot_hold", "tp_carrot_hold_shift")
local ItemComponent = EntityGetFirstComponentIncludingDisabled(entity, "ItemComponent")
ComponentSetValue2(ItemComponent, "ui_description", desc)
