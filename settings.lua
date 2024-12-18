dofile("data/scripts/lib/mod_settings.lua")

local csv = dofile_once("mods/conjurer_reborn/files/lib/csv.lua")

local currentLang = csv(ModTextFileGetContent("mods/conjurer_reborn/files/lang/lang.csv"))
local gameLang = csv(ModTextFileGetContent("data/translations/common.csv"))
local CurrentMap = {}
for v, _ in pairs(gameLang.rowHeads) do --构建一个关联表用来查询键值
	if v ~= "" then
		local tempKey = gameLang.get("current_language", v)
		CurrentMap[tempKey] = v
	end
end
local function GetText(key) --获取文本
	if key == "" then
		return key
	end
	local GameKey
	local GameTextLangGet = GameTextGet("$current_language")
	GameKey = CurrentMap[GameTextLangGet]
	if GameKey == nil then
		GameKey = "en"
	end
	local result = currentLang.get(key, GameKey) or ""
	result = string.gsub(result, [[\n]], "\n")
	if result == nil or result == "" then
		result = currentLang.get(key, "en")
	end
	return result
end

---监听访问
---@param t table
---@param callback function
local function TableListener(t, callback)
	local function NewListener()
		local __data = {}
		local deleteList = {}
		for k, v in pairs(t) do
			__data[k] = v
			deleteList[#deleteList + 1] = k
		end
		for _, v in pairs(deleteList) do
			t[v] = nil
		end
		local result = {
			__newindex = function(table, key, value)
				local temp = callback(key, value)
				value = temp or value
				rawset(__data, key, value)
				rawset(table, key, nil)
			end,
			__index = function(table, key)
				local temp = callback(key, rawget(__data, key))
				if temp == nil then
					return rawget(__data, key)
				else
					return temp
				end
			end,
			__call = function()
				return __data
			end
		}
		return result
	end
	setmetatable(t, NewListener())
end

local function Setting(t)
	TableListener(t, function(key, value)
		if key == "ui_name" or key == "ui_description" then
			local result = GetText(value)
			return result
		end
	end)
	return t
end

local function GetTextOrKey(key)
	local result = GetText(key)
	return result or key
end

local function ValueListInit(t)
	TableListener(t, function(key, value)
		return GetTextOrKey(value)
	end)
	return t
end

local function ValueList(t)
	for k, v in pairs(t) do
		t[k] = ValueListInit(v)
	end
	return t
end


local mod_id = "conjurer_reborn"

mod_settings_version = 1
mod_settings =
{
    Setting({
		category_id = "general_settings",
		ui_name = "conjurer_reborn_setting_general",
		settings = {
			Setting({
				id = "zoom_level",
				ui_name = "conjurer_reborn_setting_zoom_level",
				ui_description = "conjurer_reborn_setting_zoom_level_desc",
				value_default = "conjurer",
				values = ValueList({
					{ "conjurer", "conjurer_reborn_setting_zoom_level_conjurer" },
					{ "noita", "conjurer_reborn_setting_zoom_level_noita" },
                    { "huge",     "conjurer_reborn_setting_zoom_level_huge" },
					{ "fullhd", "conjurer_reborn_setting_zoom_level_fullhd" },
				}),
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            }),
			Setting({
				id = "progression",
				ui_name = "conjurer_reborn_setting_progression",
				ui_description = "conjurer_reborn_setting_progression_desc",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            }),
			Setting({
				id = "click_sound",
				ui_name = "conjurer_reborn_setting_click_sound",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            }),
			Setting({
				id = "bottom_pos",
				ui_name = "conjurer_reborn_setting_bottom_pos",
				value_default = "bottom_center",
				values = ValueList({
					{ "bottom_center", "conjurer_reborn_setting_bottom_bottom_center" },
					{ "bottom_right", "conjurer_reborn_setting_bottom_bottom_right" },
				}),
				scope = MOD_SETTING_SCOPE_RUNTIME,
			})
		}
    }),
    Setting({
		category_id = "control_settings",
		ui_name = "conjurer_reborn_setting_controls",
		settings = {
			Setting({
				id = "secondary_button",
				ui_name = "conjurer_reborn_setting_secondary_button",
				ui_description = "conjurer_reborn_setting_secondary_button_desc",
				value_default = "mouse2",
                values = ValueList({
                    { "throw",  "conjurer_reborn_setting_secondary_button_throw" },
					{ "mouse2", "conjurer_reborn_setting_secondary_button_mouse2" }
				}),
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			})
		},
    }),
	Setting({
		category_id = "conjurer_other",
		ui_name = "conjurer_reborn_setting_other",
        settings = {
			Setting({
				id = "get_carrot",
				ui_name = "",
				ui_description = "",
				ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
					GuiIdPushString(gui,"conjurer_reborn_get_carrot")
                    local click = GuiButton(gui, 1, 2, 0, GetTextOrKey("conjurer_reborn_setting_get_carrot"))
                    local flag, entity = pcall(GameGetWorldStateEntity)
					local isConjurer = GameHasFlagRun("conjurer_reborn_world")
					local desc = ""
					if not flag or entity == 0 then
						desc = GetTextOrKey("conjurer_reborn_setting_get_carrot_desc_error")
                    elseif entity ~= 0 and not isConjurer then
						desc = GetTextOrKey("conjurer_reborn_setting_get_carrot_desc_no_conjurer")
					end
                    GuiTooltip(gui, GetTextOrKey("conjurer_reborn_setting_get_carrot_desc"), desc)
					if click and flag and entity ~= 0 and isConjurer then
						GlobalsSetValue("conjurer_reborn_get_carrot", "1")
					end
					GuiIdPop(gui)
				end
			})
		},
	}),
	Setting({
		category_id = "control_settings",
		ui_name = "conjurer_reborn_setting_notice",
		settings = {},
	}),
}


function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id) -- This can be used to migrate some settings between mod versions.
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
