---@param i18n table<string, table<string,string>>
---@return fun(setting:table):table Setting
---@return fun(values:string[][]):table ValueList
---@return fun(key:string):string GetTextOrKey
local i18nLib = function(i18n) local function csv(str) local cellDatas = {} local rowHeads = {} local cellArrangement = {} local result local tempKey = nil local set = function(row, column, value) if column == 1 then cellDatas[value] = {} table.insert(cellArrangement, value) tempKey = value end table.insert(cellDatas[tempKey], value) if row == 1 then rowHeads[value] = column end end result = { rowHeads = rowHeads, cellDatas = cellDatas, cellArrangement = cellArrangement, get = function(row, column) column = rowHeads[column] row = cellDatas[row] if column and row then local result = row[column] if string.byte(result, 1, 1) == 34 and string.byte(result, #result, #result) == 34 then return string.sub(result, 2, string.len(result) - 1) end return result else return nil end end, tostring = function() local cache = {} local newRowHeads = {} for v, k in pairs(rowHeads) do newRowHeads[k] = v end local rowHeadSize = #newRowHeads for i = 1, rowHeadSize do if newRowHeads[i] ~= "" then table.insert(cache, newRowHeads[i]) end if i ~= rowHeadSize then table.insert(cache, ",") end end local cellSize = #cellArrangement for i = 1, cellSize do local key = cellArrangement[i] local value = cellDatas[key] local size = #value for v_i, vstr in pairs(value) do if vstr ~= "" then table.insert(cache, vstr) end if v_i ~= size then table.insert(cache, ",") end end if i ~= cellSize then table.insert(cache, "\n") end end return table.concat(cache) end } local state_quotationMark = false local usub = string.sub local codepoint = string.byte local StartPos = 1 local charNum = 0 local posRow = 1 local posColumn = 1 local i = 1 while i <= #str do charNum = codepoint(str, i, i) if state_quotationMark then state_quotationMark = (charNum ~= 34) if charNum == 92 then i = i + 1 end else if charNum == 34 then state_quotationMark = true elseif charNum == 44 then set(posRow, posColumn, usub(str, StartPos, i - 1)) StartPos = i + 1 posColumn = posColumn + 1 elseif charNum == 10 then if (codepoint(str, i - 1, i - 1) ~= 10) then set(posRow, posColumn, usub(str, StartPos, i - 1)) StartPos = i + 1 posRow = posRow + 1 posColumn = 1 end end end i = i + 1 end set(posRow, posColumn, usub(str, StartPos, #str - 1)) return result end local function i18nGet(key, lang) local current = i18n[lang] if current == nil or current[key] == nil then local result = i18n["en"][key] if result == nil then return key end return result end return current[key] end local CurrentMap = {} local gameLang = csv(ModTextFileGetContent("data/translations/common.csv")) local function LoadLang() CurrentMap = {} gameLang = csv(ModTextFileGetContent("data/translations/common.csv")) for v, _ in pairs(gameLang.rowHeads) do if v ~= "" then local flag, tempKey = pcall(gameLang.get, "current_language", v) if flag and tempKey ~= nil and tempKey ~= "" then CurrentMap[tempKey] = v end end end end LoadLang() local inGame = false local function GetText(key) if key == "" then return key end local GameKey local GameTextLangGet = GameTextGet("$current_language") local flag, entity = pcall(GameGetWorldStateEntity) if entity and entity ~= 0 and not inGame then LoadLang() inGame = true end GameKey = CurrentMap[GameTextLangGet] if GameKey == nil then GameKey = "en" end return i18nGet(key, GameKey) or "" end local function TableListener(t, callback) local function NewListener() local __data = {} local deleteList = {} for k, v in pairs(t) do __data[k] = v deleteList[#deleteList + 1] = k end for _, v in pairs(deleteList) do t[v] = nil end local result = { __newindex = function(table, key, value) local temp = callback(key, value) value = temp or value rawset(__data, key, value) rawset(table, key, nil) end, __index = function(table, key) local temp = callback(key, rawget(__data, key)) if temp == nil then return rawget(__data, key) else return temp end end, __call = function() return __data end } return result end setmetatable(t, NewListener()) end local function GetTextOrKey(key) return GetText(key) or key end local function ValueListInit(t) TableListener(t, function(key, value) if key == 1 then return value end return GetTextOrKey(value) end) return t end local function ValueList(t) for k, v in pairs(t) do t[k] = ValueListInit(v) end return t end local function Setting(t) TableListener(t, function(key, value) if key == "ui_name" or key == "ui_description" or key == "value_display_formatting" then local result = GetText(value) return result end end) return t end return Setting, ValueList, GetTextOrKey end
---Multiline text
---@param list string[]
---@return string
local function MT(list)
	return table.concat(list, "\n")
end

local i18n = {
    ["en"] = {
        notice =
            MT {
                ",",
                "!   NOTICE!",
                "!",
                "!   If you experience problems using [Restart with enabled mods active]",
                "!   it is advised to rather just [Save & Quit] and [Continue].",
                "!",
                "!   Quick restart is known to mess up at least the following:",
                "!     1. Selected zoom level",
                "!     2. The tower background",
                "!     3. Custom Staff GUI",
				"`"
            },
        general = "General",
        zoom_level = "Zoom level",
        zoom_level_desc =
		    MT {
                "How much do you want to see? Heavily affects performance.",
                "WARNING:",
                "Big resolutions are glitchy, and probably not useful for anything but screenshots.",
            },
        zoom_level_noita = "Noita (1x Noita)",
        zoom_level_conjurer = "Conjurer (1.5x Noita)",
        zoom_level_huge = "Big (2x Noita)",
        zoom_level_fullhd = "Full HD (4.5x Noita)",
        progression = "Global progression",
		progression_desc =
		    MT {
                "Do you want to enable global Noita progression?",
                "WARNING:",
                "When this is enabled spawning any creatures, spells or perks will count towards",
                "your global progress screen, which can ruin a lot of the fun. Be absolutely sure",
                "before enabling this. [Reset all progress] is the only undo there is.",
            },
        controls = "Controls",
        secondary_button = "Secondary button scheme",
		secondary_button_desc =
			MT {
                "Which button do you want to use for erasing/removing action?",
				"Useful if your mouse2 is taken by something else specific, or you're using a controller.",
            },
        secondary_button_throw = "Throw",
        secondary_button_mouse2 = "Mouse2",
        bottom_pos = "Bottom button position",
        bottom_bottom_center = "Bottom Center",
        bottom_bottom_right = "Bottom Right",
        bottom_bottom_left = "Bottom Left (Not recommended)",
        bottom_no_display = "No Display",
        click_sound = "Button click sound",
        other = "Other",
        quick_mat_display = "Display material info when selecting material quickly",
        split_search_text = "Match All Keywords",
        split_search_text_tip = "Search multiple keywords separated by spaces (AND logic).",
		mat_img_regen_every_time = "Re-generate material image every time",
        reset_matwand_fav = "Reset material favorite",
        reset_matwand_fav_desc = "Reset the favorite of the Staff of Material Mastery",
        reset_entwand_fav = "Reset entity favorite",
        reset_entwand_fav_desc = "Reset the favorite of the Staff of Illusions",
        reset_IKnowWhatImDoing = "This action cannot be undone, click again to confirm",
        inf_chaos_poly = "Potential Permanent Chaotic Polymorphine",
        inf_chaos_poly_desc = "Note: This cannot salvage player affected by Permanent Chaotic Polymorphine",
        rebirth_blinded = "Blinded effect after rebirth",
		game_print_gui_error = "In-game print GUI error",
        vertical_page_column_max = "Favorite Bar Single Column Size",
        vertical_page_column_max_desc = "How many items can be displayed in one column?",
        bottom_hidden_btn_pos = "Bottom hidden button position",
        bottom_hidden_btn_pos_left = "Left",
        bottom_hidden_btn_pos_right = "Right",
        unsafe = "Unsafe Setting",
        unsafe_load_conjurer = "Unsafe automatically loads Conjurer in non-gamemode",
        unsafe_load_conjurer_desc = "No need to manually enable Conjurer Reborn\nSimply enabling Unsafe is enough",
		unsafe_brush = "Advanced Brush",
        unsafe_brush_desc =
            MT {
				"Provides an improved drawing experience.",
				"Disabling this reverts to the legacy drawing feature.",
				"Noita updates may break this feature, in which case you can disable it for now."
            },
        unsafe_brush_create_light = "Glow effect for new materials",
		unsafe_brush_create_light_desc =
            MT {
				"Like this effect?",
				"You can now toggle it in the Advanced Brush!"
            },
        visuals_and_audio = "Visuals & Audio",
        tooltip_animation = "Tooltip animation",
        kalma_inversion = "Kalma's Call Inversion",
    },
    ["zh-cn"] = {
		notice =
            MT {
                "/",
				"!   注意事项！",
				"!",
				"!   如果你在使用[以已启用模组生效的状态重新启动](快捷重启)时遇到问题",
				"!   那么建议使用[保存并退出]然后[继续]的方法避免问题",
				"!",
				"!   须知，快捷重启可能会导致以下功能出现问题：",
				"!     1. 选定的缩放级别",
				"!     2. 背景贴图",
				"!     3. 自定义的GUI",
				"\\"
            },
        general = "主要",
        zoom_level = "缩放级别",
        zoom_level_desc =
		    MT {
                "你想要看多大？",
				"警告：",
				"太大的分辨率有一些问题，它们可能除了截图之外没有什么用",
            },
        zoom_level_huge = "大 (2x Noita)",
        zoom_level_fullhd = "全高清 (4.5x Noita)",
        progression = "全局进展",
		progression_desc =
		    MT {
                "你想要影响你当前游戏的进展吗？",
				"警告：",
				"启用此功能后，任何法术，生物，天赋的使用都将计入你的全局进展中，",
				"这可能会破坏很多乐趣。请三思而后行。",
				"[重置所有进展]是唯一的撤销办法"
            },
        controls = "控制",
        secondary_button = "辅助按键方案",
		secondary_button_desc =
			MT {
                "如果你的鼠标右键被其他特定操作占用了，",
				"或者你使用的是其他控制器设备，那么你想要哪个键进行擦除/删除操作？",
            },
        secondary_button_throw = "投掷键",
        secondary_button_mouse2 = "鼠标右键",
        bottom_pos = "底部按钮位置",
        bottom_bottom_center = "底部中心",
        bottom_bottom_right = "右下角",
        bottom_bottom_left = "左下角(不推荐)",
        bottom_no_display = "不显示",
        click_sound = "按钮点击音效",
        other = "其他",
        quick_mat_display = "快捷选中材料时显示材料数据",
        split_search_text = "匹配所有关键词",
        split_search_text_tip = "按空格分隔多词进行“与”逻辑搜索。",
		mat_img_regen_every_time = "每次都重新生成材料贴图",
        reset_matwand_fav = "重置材料收藏",
        reset_matwand_fav_desc = "重置材料法杖的收藏",
        reset_entwand_fav = "重置实体收藏",
        reset_entwand_fav_desc = "重置幻象魔杖的收藏",
        reset_IKnowWhatImDoing = "此操作不可撤销，再点击一次确认",
        inf_chaos_poly = "潜在的永久混沌变形",
        inf_chaos_poly_desc = "注意：这无法挽回已经被永久混沌变形的玩家",
        rebirth_blinded = "重生后的致盲效果",
		game_print_gui_error = "游戏内打印GUI错误",
        vertical_page_column_max = "收藏栏单列大小",
        vertical_page_column_max_desc = "一列可以显示多少个？",
        bottom_hidden_btn_pos = "底部隐藏按钮位置",
        bottom_hidden_btn_pos_left = "左",
        bottom_hidden_btn_pos_right = "右",
        unsafe = "不安全设置",
        unsafe_load_conjurer = "Unsafe主动以非游戏模式加载Conjurer",
        unsafe_load_conjurer_desc = "无需启用Conjurer Reborn\n只要启用unsafe即可",
		unsafe_brush = "高级画刷",
        unsafe_brush_desc =
            MT {
				"可以提供更好的绘制体验。",
				"关闭则使用旧版绘制功能。",
				"Noita更新可能会破坏这个功能，此时可以先关闭。"
            },
        unsafe_brush_create_light = "新建材料的发光特效",
		unsafe_brush_create_light_desc =
            MT {
				"喜欢这个特效吗？",
				"高级画刷可以开关此功能了！"
            },
        visuals_and_audio = "视觉与音效",
        tooltip_animation = "悬浮窗动画",
        kalma_inversion = "死亡之兆反转",
	}
}
local Setting, ValueList, GetTextOrKey = i18nLib(i18n)
dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "conjurer_reborn"
local conjurer_reborn_reset_matwand_fav_confirm = false
local conjurer_reborn_reset_entwand_fav_confirm = false

mod_settings_version = 1
mod_settings =
{
    Setting{
		category_id = "general_settings",
		ui_name = "general",
		settings = {
			Setting{
				id = "zoom_level",
				ui_name = "zoom_level",
				ui_description = "zoom_level_desc",
				value_default = "conjurer",
				values = ValueList{
					{ "conjurer", "zoom_level_conjurer" },
					{ "noita", "zoom_level_noita" },
                    { "huge",     "zoom_level_huge" },
					{ "fullhd", "zoom_level_fullhd" },
				},
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
			Setting{
				id = "progression",
				ui_name = "progression",
				ui_description = "progression_desc",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
			Setting{
				id = "split_search_text2",
                ui_name = "split_search_text",
				ui_description = "split_search_text_tip",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "disable_inf_chaos_poly",
				ui_name = "inf_chaos_poly",
				ui_description = "inf_chaos_poly_desc",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "kalma_inversion",
				ui_name = "kalma_inversion",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
		}
    },
	Setting{
		category_id = "visuals_and_audio",
		ui_name = "visuals_and_audio",
        settings = {
			Setting{
				id = "tooltip_animation",
				ui_name = "tooltip_animation",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "click_sound",
				ui_name = "click_sound",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "bottom_pos",
				ui_name = "bottom_pos",
				value_default = "bottom_center",
				values = ValueList{
					{ "bottom_center", "bottom_bottom_center" },
                    { "bottom_right",  "bottom_bottom_right" },
                    { "bottom_left",   "bottom_bottom_left" },
					{ "no_display", "bottom_no_display" },
				},
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "bottom_hidden_pos",
				ui_name = "bottom_hidden_btn_pos",
				value_default = "left",
				values = ValueList{
					{ "left", "bottom_hidden_btn_pos_left" },
                    { "right",  "bottom_hidden_btn_pos_right" },
				},
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "rebirth_blinded",
				ui_name = "rebirth_blinded",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "quick_display_mat",
				ui_name = "quick_mat_display",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
		},
    },
    Setting{
		category_id = "control_settings",
		ui_name = "controls",
		settings = {
			Setting{
				id = "secondary_button",
				ui_name = "secondary_button",
				ui_description = "secondary_button_desc",
				value_default = "mouse2",
                values = ValueList{
                    { "throw",  "secondary_button_throw" },
					{ "mouse2", "secondary_button_mouse2" }
				},
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
			}
		},
    },
	Setting{
		category_id = "conjurer_other",
		ui_name = "other",
        settings = {
			Setting{
				id = "game_print_gui_error",
				ui_name = "game_print_gui_error",
				ui_description = "",
                value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "vertical_page_column_max",
				ui_name = "vertical_page_column_max",
				ui_description = "vertical_page_column_max_desc",
				value_default = 9,
				value_min = 1,
				value_max = 18,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "reset_matwand_fav",
				ui_name = "",
				ui_description = "",
				ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
					GuiIdPushString(gui,"conjurer_reborn_reset_matwand_fav")
                    local click = GuiButton(gui, 1, 2, 0, GetTextOrKey("reset_matwand_fav"))
                    local _, _, hover = GuiGetPreviousWidgetInfo(gui)
					--放开悬浮时重置
                    if not hover and conjurer_reborn_reset_matwand_fav_confirm then
                        conjurer_reborn_reset_matwand_fav_confirm = false
                    end
					
					local flag, entity = pcall(GameGetWorldStateEntity)
					local isConjurer = GameHasFlagRun("conjurer_reborn_world")

					--点击检测和确定
                    if click and not conjurer_reborn_reset_matwand_fav_confirm then
                        conjurer_reborn_reset_matwand_fav_confirm = true
                    elseif click and conjurer_reborn_reset_matwand_fav_confirm then
                        conjurer_reborn_reset_matwand_fav_confirm = false
                        ModSettingSet("conjurer_unsafeMatPickerFav", "return {}")
						if flag and entity ~= 0 and isConjurer then--符合条件下全局变量通知刷新
							GlobalsSetValue("conjurer_reborn_reset_matwand_fav_refresh", "1")
						end
                    end
					
					if conjurer_reborn_reset_matwand_fav_confirm then
						GuiTooltip(gui, GetTextOrKey("reset_IKnowWhatImDoing"), "")
                    else
						GuiTooltip(gui, GetTextOrKey("reset_matwand_fav_desc"), "")
					end

					GuiIdPop(gui)
				end
            },
			Setting{
				id = "reset_entwand_fav",
				ui_name = "",
				ui_description = "",
				ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
					GuiIdPushString(gui,"conjurer_reborn_reset_entwand_fav")
                    local click = GuiButton(gui, 1, 2, 0, GetTextOrKey("reset_entwand_fav"))
                    local _, _, hover = GuiGetPreviousWidgetInfo(gui)
					--放开悬浮时重置
                    if not hover and conjurer_reborn_reset_entwand_fav_confirm then
                        conjurer_reborn_reset_entwand_fav_confirm = false
                    end
					
					local flag, entity = pcall(GameGetWorldStateEntity)
					local isConjurer = GameHasFlagRun("conjurer_reborn_world")

					--点击检测和确定
                    if click and not conjurer_reborn_reset_entwand_fav_confirm then
                        conjurer_reborn_reset_entwand_fav_confirm = true
                    elseif click and conjurer_reborn_reset_entwand_fav_confirm then
                        conjurer_reborn_reset_entwand_fav_confirm = false
                        ModSettingSet("conjurer_unsafeEntWandFav", "return {}")
						if flag and entity ~= 0 and isConjurer then--符合条件下全局变量通知刷新
							GlobalsSetValue("conjurer_reborn_reset_entwand_fav_refresh", "1")
						end
                    end
					
					if conjurer_reborn_reset_entwand_fav_confirm then
						GuiTooltip(gui, GetTextOrKey("reset_IKnowWhatImDoing"), "")
                    else
						GuiTooltip(gui, GetTextOrKey("reset_entwand_fav_desc"), "")
					end

					GuiIdPop(gui)
				end
			}
        },
    },
	Setting{
		category_id = "unsafe_settings",
		ui_name = "unsafe",
		settings = {
			Setting{
				id = "unsafe_load_conjurer",
				ui_name = "unsafe_load_conjurer",
				ui_description = "unsafe_load_conjurer_desc",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
			Setting{
				id = "regen_mat_img_every_time",
                ui_name = "mat_img_regen_every_time",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
			Setting{
				id = "unsafe_brush",
				ui_name = "unsafe_brush",
				ui_description = "unsafe_brush_desc",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
			Setting{
				id = "unsafe_brush_create_light",
				ui_name = "unsafe_brush_create_light",
				ui_description = "unsafe_brush_create_light_desc",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
            },
		}
    },
		
	Setting{
		category_id = "control_settings",
		ui_name = "notice",
		settings = {},
    },
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
