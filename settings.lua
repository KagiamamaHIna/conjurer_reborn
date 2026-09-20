---@param i18n table<string, table<string,string>>
---@return fun(setting:table):table Setting
---@return fun(values:string[][]):table ValueList
---@return fun(key:string):value:string GetTextOrKey
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
		game_print_gui_error = "In-game print GUI error",
        vertical_page_column_max = "Favorite Bar Single Column Size",
        vertical_page_column_max_desc = "How many items can be displayed in one column?",
        bottom_hidden_btn_pos = "Bottom hidden button position",
        bottom_hidden_btn_pos_left = "Left",
        bottom_hidden_btn_pos_right = "Right",
        unsafe = "Unsafe Setting",
        unsafe_load_conjurer = "Unsafe automatically loads Conjurer in non-gamemode",
        unsafe_load_conjurer_desc = "No need to manually enable Conjurer Reborn\nSimply enable Unsafe to use it",
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
		pinyin_matching = "Pinyin Matching",
        pinyin_matching_desc = "A setting intended for Chinese users.",
		pinyin_keyboard_switch = "Keybind Selection: ",
		pinyin_keyboard_switch_desc =
            MT {
                "Choose a keybind that fits your habits!",
                "I guess if you're a non-Chinese speaker,",
				"you're only reading this out of curiosity, right?"
            },
        pinyin_quanpin = "Quanpin",
        pinyin_daqian = "DaQian Zhuyin",
        pinyin_xiaohe = "XiaoHe Shuangpin",
        pinyin_ziranma = "Ziranma Shuangpin",
        pinyin_sougou = "Sougou Shuangpin",
        pinyin_zhineng_abc = "Zhineng ABC Shuangpin",
        pinyin_guobiao = "Guobiao Shuangpin",
        pinyin_microsoft = "Microsoft Shuangpin",
        pinyin_pinyinpp = "Pinyin++ Shuangpin",
        pinyin_ziguang = "Ziguang Shuangpin",
		pinyin_fuzzy_phonetics = "Fuzzy Phonetics",
        pinyin_fuzzy_phonetics_desc = "This causes the match engine to treat two specific phonemes as the same.",
		pinyin_first = "First-Letter Matching",
        pinyin_zh_eq_z = "zh = z",
        pinyin_sh_eq_s = "sh = s",
        pinyin_ch_eq_c = "ch = c",
        pinyin_ang_eq_an = "ang = an",
		pinyiin_eng_eq_en = "eng = en",
        pinyiin_v_eq_u = "v = u",
        quick_switch = "quick switch",
        matwand = "Staff of Material Mastery:",
        draw_material = "draw material",
        erase_material = "erase material",
        quick_eyedropper = "quick eyedropper",
        left_brush = "left-rotate brush",
        right_brush = "right-rotate brush",
        quick_enable_fe = "toggle falling sand",
        material_overwrite = "material overwrite",
        angle_snap = "angle snap",
        constrain_proportion = "constrain proportion",
        entwand = "Staff of Illusions:",
        spawn_entity = "spawn entity",
        delete_entity = "delete entity",
        quick_select_entity = "quick select entity",
        remove_add_progress = "remove/add progress",
        quick_scan_preview = "quick scan preview",
        editwand = "Chaos Claw:",
        left_click_behavior = "left-click behavior",
        right_click_behavior = "right-click behavior",
        interact = "interact",
        tunewand = "Heart of Tune:",
        other_controls = "Ohter:",
        carrot_controls = "Porgand:",
        tp_carrot_blink = "blink tp",
        tp_carrot_hold = "hold tp",
        tp_carrot_hold_shift = "hold shift",
        glass_eye = "conscious eye",
        post_fx = "post fx",
        binoculars = "conjurer eye",
        fullbright = "all-seeing eye",
        grid_display = "gridular monocle",
        viima = "viima's howl",
        exit_polymorph = "exit polymorph",
        player_respawn = "player respawn"
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
                "!     2. 巫师塔的背景贴图",
				"\\"
            },
        general = "常规",
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
        controls = "按键控制",
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
		game_print_gui_error = "游戏内打印GUI错误",
        vertical_page_column_max = "收藏栏单列大小",
        vertical_page_column_max_desc = "一列可以显示多少个？",
        bottom_hidden_btn_pos = "底部隐藏按钮位置",
        bottom_hidden_btn_pos_left = "左",
        bottom_hidden_btn_pos_right = "右",
        unsafe = "不安全设置",
        unsafe_load_conjurer = "Unsafe主动以非游戏模式加载Conjurer",
        unsafe_load_conjurer_desc = "无需启用Conjurer Reborn\n只要启用unsafe即可使用",
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
        pinyin_matching = "拼音匹配",
        pinyin_matching_desc = "为中文使用者准备的设置",
        pinyin_keyboard_switch = "键位选择：",
        pinyin_keyboard_switch_desc = "根据你的使用习惯选择一个键位！",
        pinyin_quanpin = "全拼",
        pinyin_daqian = "大千注音",
        pinyin_xiaohe = "小鹤双拼",
        pinyin_ziranma = "自然码双拼",
        pinyin_sougou = "搜狗双拼",
        pinyin_zhineng_abc = "智能ABC双拼",
        pinyin_guobiao = "国标双拼",
        pinyin_microsoft = "微软双拼",
        pinyin_pinyinpp = "拼音++双拼",
        pinyin_ziguang = "紫光双拼",
        pinyin_fuzzy_phonetics = "模糊音",
        pinyin_fuzzy_phonetics_desc = "这将让匹配引擎将特定两种音韵视为同一种",
		pinyin_first = "首字母匹配",
        pinyin_zh_eq_z = "zh = z",
        pinyin_sh_eq_s = "sh = s",
        pinyin_ch_eq_c = "ch = c",
        pinyin_ang_eq_an = "ang = an",
		pinyiin_eng_eq_en = "eng = en",
        pinyiin_v_eq_u = "v = u",
        quick_switch = "快捷切换",
        matwand = "材料魔杖：",
        draw_material = "绘制材料",
        erase_material = "擦除材料",
        quick_eyedropper = "快捷吸管工具",
        left_brush = "左转画刷",
        right_brush = "右转画刷",
        quick_enable_fe = "开关落沙模拟",
        material_overwrite = "材料覆盖",
        angle_snap = "角度吸附",
        constrain_proportion = "限制比例",
        entwand = "幻象魔杖：",
        spawn_entity = "生成实体",
        delete_entity = "删除实体",
        quick_select_entity = "快捷选中实体",
        remove_add_progress = "删除/增加进展",
        quick_scan_preview = "快捷扫描预览",
        editwand = "混沌之爪：",
        left_click_behavior = "左键行为",
        right_click_behavior = "右键行为",
        interact = "互动",
        tunewand = "调谐之心：",
        other_controls = "其他：",
        carrot_controls = "胡萝卜：",
        tp_carrot_blink = "点击传送",
        tp_carrot_hold = "长按传送",
        tp_carrot_hold_shift = "长按切换",
        glass_eye = "固定视觉",
        post_fx = "后期特效",
        binoculars = "灵魂出窍",
        fullbright = "全视之眼",
        grid_display = "网格视野",
        viima = "凌风而行",
        exit_polymorph = "退出变形",
        player_respawn = "玩家复活"
	}
}
local Setting, ValueList, GetTextOrKey = i18nLib(i18n)
local function GetClacKeyOffset(...)
    local list = { ... }
    return function(gui)
        local offset = 0
        for _, v in ipairs(list) do
            local w = GuiGetTextDimensions(gui, GetTextOrKey(v))
            if w > offset then
                offset = w
            end
        end
        return offset
    end
end

dofile("data/scripts/lib/mod_settings.lua")
local InputFrame = {} local keycodes = {} setfenv(loadfile("data/scripts/debug/keycodes.lua"), keycodes)() function InputFrame.get_any_input() for k, v in pairs(keycodes) do if k:find("^Mouse_") then if InputIsMouseButtonJustDown(v) then return k end elseif k:find("^Key_") then if InputIsKeyJustDown(v) then return k end elseif k:find("^JOY_BUTTON_") then for i = 0, 3 do if InputIsJoystickButtonJustDown(i, v) then return k end end end end end function InputFrame.check_mouse_btn(input) if input ~= "Mouse_left" and input ~= "Mouse_right" then return true end local player = EntityGetWithTag("player_unit")[1] player = player or EntityGetWithTag("polymorphed_player")[1] if player == nil then return true end local ControlsComponent = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent") if ControlsComponent == nil then return true end local enabled = ComponentGetValue2(ControlsComponent, "enabled") if not enabled then return true end local key = input == "Mouse_left" and "mButtonDownLeftClick" or "mButtonDownRightClick" local Click = ComponentGetValue2(ControlsComponent, key) return Click end function InputFrame.read_input(input) if input == "unbound" then return false end if input:find("^Mouse_") then return InputIsMouseButtonDown(keycodes[input]) elseif input:find("^Key_") then return InputIsKeyDown(keycodes[input]) elseif input:find("^JOY_BUTTON_") then for i = 0, 3 do if InputIsJoystickButtonDown(i, keycodes[input]) then return true end end return false end end function InputFrame.read_input_cmb(input) return InputFrame.read_input(input) and InputFrame.check_mouse_btn(input) end function InputFrame.read_input_down(input) if input == "unbound" then return false end if input:find("^Mouse_") then return InputIsMouseButtonJustDown(keycodes[input]) elseif input:find("^Key_") then return InputIsKeyJustDown(keycodes[input]) elseif input:find("^JOY_BUTTON_") then for i = 0, 3 do if InputIsJoystickButtonJustDown(i, keycodes[input]) then return true end end return false end end function InputFrame.read_input_down_cmb(input) return InputFrame.read_input_down(input) and InputFrame.check_mouse_btn(input) end function InputFrame.read_input_up(input) if input == "unbound" then return false end if input:find("^Mouse_") then return InputIsMouseButtonJustUp(keycodes[input]) elseif input:find("^Key_") then return InputIsKeyJustUp(keycodes[input]) elseif input:find("^JOY_BUTTON_") then for i = 0, 3 do if InputIsJoystickButtonDown(i, keycodes[input]) then return false end end return true end end function InputFrame.read_input_up_cmb(input) return InputFrame.read_input_up(input) and InputFrame.check_mouse_btn(input) end local names = { Mouse_left = "$input_mouseleft", Mouse_right = "$input_mouseright", Mouse_middle = "$input_mousemiddle", Mouse_wheel_up = "$input_mousewheelup", Mouse_wheel_down = "$input_mousewheeldown", Mouse_x1 = "$input_mousebutton4", Mouse_x2 = "$input_mousebutton5", Key_a = "A", Key_b = "B", Key_c = "C", Key_d = "D", Key_e = "E", Key_f = "F", Key_g = "G", Key_h = "H", Key_i = "I", Key_j = "J", Key_k = "K", Key_l = "L", Key_m = "M", Key_n = "N", Key_o = "O", Key_p = "P", Key_q = "Q", Key_r = "R", Key_s = "S", Key_t = "T", Key_u = "U", Key_v = "V", Key_w = "W", Key_x = "X", Key_y = "Y", Key_z = "Z", Key_1 = "1", Key_2 = "2", Key_3 = "3", Key_4 = "4", Key_5 = "5", Key_6 = "6", Key_7 = "7", Key_8 = "8", Key_9 = "9", Key_0 = "0", Key_RETURN = "Return", Key_ESCAPE = "Escape", Key_BACKSPACE = "Backspace", Key_TAB = "$input_tab", Key_SPACE = "$input_space", Key_MINUS = "-", Key_EQUALS = "=", Key_LEFTBRACKET = "[", Key_RIGHTBRACKET = "]", Key_BACKSLASH = "\\", Key_NONUSHASH = "#", Key_SEMICOLON = ";", Key_APOSTROPHE = "'", Key_GRAVE = "`", Key_COMMA = ",", Key_PERIOD = ".", Key_SLASH = "/", Key_CAPSLOCK = "CapsLock", Key_F1 = "F1", Key_F2 = "F2", Key_F3 = "F3", Key_F4 = "F4", Key_F5 = "F5", Key_F6 = "F6", Key_F7 = "F7", Key_F8 = "F8", Key_F9 = "F9", Key_F10 = "F10", Key_F11 = "F11", Key_F12 = "F12", Key_PRINTSCREEN = "PrintScreen", Key_SCROLLLOCK = "ScrollLock", Key_PAUSE = "Pause", Key_INSERT = "Insert", Key_HOME = "Home", Key_PAGEUP = "PageUp", Key_DELETE = "Delete", Key_END = "End", Key_PAGEDOWN = "PageDown", Key_RIGHT = "Right", Key_LEFT = "Left", Key_DOWN = "Down", Key_UP = "Up", Key_NUMLOCKCLEAR = "Numlock", Key_KP_DIVIDE = "Keypad /", Key_KP_MULTIPLY = "Keypad *", Key_KP_MINUS = "Keypad -", Key_KP_PLUS = "Keypad +", Key_KP_ENTER = "Keypad Enter", Key_KP_1 = "Keypad 1", Key_KP_2 = "Keypad 2", Key_KP_3 = "Keypad 3", Key_KP_4 = "Keypad 4", Key_KP_5 = "Keypad 5", Key_KP_6 = "Keypad 6", Key_KP_7 = "Keypad 7", Key_KP_8 = "Keypad 8", Key_KP_9 = "Keypad 9", Key_KP_0 = "Keypad 0", Key_KP_PERIOD = "Keypad .", Key_APPLICATION = "Menu", Key_POWER = "Power", Key_KP_EQUALS = "Keypad =", Key_F13 = "F13", Key_F14 = "F14", Key_F15 = "F15", Key_F16 = "F16", Key_F17 = "F17", Key_F18 = "F18", Key_F19 = "F19", Key_F20 = "F20", Key_F21 = "F21", Key_F22 = "F22", Key_F23 = "F23", Key_F24 = "F24", Key_EXECUTE = "Execute", Key_HELP = "Help", Key_MENU = "Menu", Key_SELECT = "Select", Key_STOP = "Stop", Key_AGAIN = "Again", Key_UNDO = "Undo", Key_CUT = "Cut", Key_COPY = "Copy", Key_PASTE = "Paste", Key_FIND = "Find", Key_MUTE = "Mute", Key_VOLUMEUP = "VolumeUp", Key_VOLUMEDOWN = "VolumeDown", Key_KP_COMMA = "Keypad ,", Key_KP_EQUALSAS400 = "Keypad = (AS400)", Key_ALTERASE = "AltErase", Key_SYSREQ = "SysReq", Key_CANCEL = "Cancel", Key_CLEAR = "Clear", Key_PRIOR = "Prior", Key_RETURN2 = "Return", Key_SEPARATOR = "Separator", Key_OUT = "Out", Key_OPER = "Oper", Key_CLEARAGAIN = "Clear / Again", Key_CRSEL = "CrSel", Key_EXSEL = "ExSel", Key_KP_00 = "Keypad 00", Key_KP_000 = "Keypad 000", Key_THOUSANDSSEPARATOR = "ThousandsSeparator", Key_DECIMALSEPARATOR = "DecimalSeparator", Key_CURRENCYUNIT = "CurrencyUnit", Key_CURRENCYSUBUNIT = "CurrencySubUnit", Key_KP_LEFTPAREN = "Keypad (", Key_KP_RIGHTPAREN = "Keypad )", Key_KP_LEFTBRACE = "Keypad {", Key_KP_RIGHTBRACE = "Keypad }", Key_KP_TAB = "Keypad Tab", Key_KP_BACKSPACE = "Keypad Backspace", Key_KP_A = "Keypad A", Key_KP_B = "Keypad B", Key_KP_C = "Keypad C", Key_KP_D = "Keypad D", Key_KP_E = "Keypad E", Key_KP_F = "Keypad F", Key_KP_XOR = "Keypad XOR", Key_KP_POWER = "Keypad ^", Key_KP_PERCENT = "Keypad %", Key_KP_LESS = "Keypad <", Key_KP_GREATER = "Keypad >", Key_KP_AMPERSAND = "Keypad &", Key_KP_DBLAMPERSAND = "Keypad &&", Key_KP_VERTICALBAR = "Keypad |", Key_KP_DBLVERTICALBAR = "Keypad ||", Key_KP_COLON = "Keypad :", Key_KP_HASH = "Keypad #", Key_KP_SPACE = "Keypad Space", Key_KP_AT = "Keypad @", Key_KP_EXCLAM = "Keypad !", Key_KP_MEMSTORE = "Keypad MemStore", Key_KP_MEMRECALL = "Keypad MemRecall", Key_KP_MEMCLEAR = "Keypad MemClear", Key_KP_MEMADD = "Keypad MemAdd", Key_KP_MEMSUBTRACT = "Keypad MemSubtract", Key_KP_MEMMULTIPLY = "Keypad MemMultiply", Key_KP_MEMDIVIDE = "Keypad MemDivide", Key_KP_PLUSMINUS = "Keypad +/-", Key_KP_CLEAR = "Keypad Clear", Key_KP_CLEARENTRY = "Keypad ClearEntry", Key_KP_BINARY = "Keypad Binary", Key_KP_OCTAL = "Keypad Octal", Key_KP_DECIMAL = "Keypad Decimal", Key_KP_HEXADECIMAL = "Keypad Hexadecimal", Key_LCTRL = "Left Ctrl", Key_LSHIFT = "$input_leftshift", Key_LALT = "Left Alt", Key_LGUI = "Left Windows", Key_RCTRL = "Right Ctrl", Key_RSHIFT = "$input_rightshift", Key_RALT = "Right Alt", Key_RGUI = "Right Windows", Key_MODE = "ModeSwitch", Key_AUDIONEXT = "AudioNext", Key_AUDIOPREV = "AudioPrev", Key_AUDIOSTOP = "AudioStop", Key_AUDIOPLAY = "AudioPlay", Key_AUDIOMUTE = "AudioMute", Key_MEDIASELECT = "MediaSelect", Key_WWW = "WWW", Key_MAIL = "Mail", Key_CALCULATOR = "Calculator", Key_COMPUTER = "Computer", Key_AC_SEARCH = "AC Search", Key_AC_HOME = "AC Home", Key_AC_BACK = "AC Back", Key_AC_FORWARD = "AC Forward", Key_AC_STOP = "AC Stop", Key_AC_REFRESH = "AC Refresh", Key_AC_BOOKMARKS = "AC Bookmarks", Key_BRIGHTNESSDOWN = "BrightnessDown", Key_BRIGHTNESSUP = "BrightnessUp", Key_DISPLAYSWITCH = "DisplaySwitch", Key_KBDILLUMTOGGLE = "KBDIllumToggle", Key_KBDILLUMDOWN = "KBDIllumDown", Key_KBDILLUMUP = "KBDIllumUp", Key_EJECT = "Eject", Key_SLEEP = "Sleep", Key_APP1 = "App1", Key_APP2 = "App2", JOY_BUTTON_ANALOG_00_MOVED = "$input_xboxbutton_analog_00", JOY_BUTTON_ANALOG_01_MOVED = "$input_xboxbutton_analog_01", JOY_BUTTON_ANALOG_02_MOVED = "$input_xboxbutton_analog_02", JOY_BUTTON_ANALOG_03_MOVED = "$input_xboxbutton_analog_03", JOY_BUTTON_ANALOG_04_MOVED = "$input_xboxbutton_analog_04", JOY_BUTTON_ANALOG_05_MOVED = "$input_xboxbutton_analog_05", JOY_BUTTON_ANALOG_06_MOVED = "$input_xboxbutton_analog_06", JOY_BUTTON_ANALOG_07_MOVED = "$input_xboxbutton_analog_07", JOY_BUTTON_ANALOG_08_MOVED = "$input_xboxbutton_analog_08", JOY_BUTTON_ANALOG_09_MOVED = "$input_xboxbutton_analog_09", JOY_BUTTON_DPAD_UP = "$input_xboxbutton_dpad_up", JOY_BUTTON_DPAD_DOWN = "$input_xboxbutton_dpad_down", JOY_BUTTON_DPAD_LEFT = "$input_xboxbutton_dpad_left", JOY_BUTTON_DPAD_RIGHT = "$input_xboxbutton_dpad_right", JOY_BUTTON_START = "$input_xboxbutton_start", JOY_BUTTON_BACK = "$input_xboxbutton_back", JOY_BUTTON_LEFT_THUMB = "$input_xboxbutton_left_thumb", JOY_BUTTON_RIGHT_THUMB = "$input_xboxbutton_right_thumb", JOY_BUTTON_LEFT_SHOULDER = "$input_xboxbutton_left_shoulder", JOY_BUTTON_RIGHT_SHOULDER = "$input_xboxbutton_right_shoulder", JOY_BUTTON_LEFT_STICK_MOVED = "$input_xboxbutton_left_stick_moved", JOY_BUTTON_RIGHT_STICK_MOVED = "$input_xboxbutton_right_stick_moved", JOY_BUTTON_0 = "$input_xboxbutton_a", JOY_BUTTON_1 = "$input_xboxbutton_b", JOY_BUTTON_2 = "$input_xboxbutton_x", JOY_BUTTON_3 = "$input_xboxbutton_y", JOY_BUTTON_4 = "$input_xboxbutton_4", JOY_BUTTON_5 = "$input_xboxbutton_5", JOY_BUTTON_6 = "$input_xboxbutton_6", JOY_BUTTON_7 = "$input_xboxbutton_7", JOY_BUTTON_8 = "$input_xboxbutton_8", JOY_BUTTON_9 = "$input_xboxbutton_9", JOY_BUTTON_10 = "$input_xboxbutton_10", JOY_BUTTON_11 = "$input_xboxbutton_11", JOY_BUTTON_12 = "$input_xboxbutton_12", JOY_BUTTON_13 = "$input_xboxbutton_13", JOY_BUTTON_14 = "$input_xboxbutton_14", JOY_BUTTON_15 = "$input_xboxbutton_15", JOY_BUTTON_LEFT_STICK_LEFT = "$input_xboxbutton_left_stick_left", JOY_BUTTON_LEFT_STICK_RIGHT = "$input_xboxbutton_left_stick_right", JOY_BUTTON_LEFT_STICK_UP = "$input_xboxbutton_left_stick_up", JOY_BUTTON_LEFT_STICK_DOWN = "$input_xboxbutton_left_stick_down", JOY_BUTTON_RIGHT_STICK_LEFT = "$input_xboxbutton_right_stick_left", JOY_BUTTON_RIGHT_STICK_RIGHT = "$input_xboxbutton_right_stick_right", JOY_BUTTON_RIGHT_STICK_UP = "$input_xboxbutton_right_stick_up", JOY_BUTTON_RIGHT_STICK_DOWN = "$input_xboxbutton_right_stick_down", JOY_BUTTON_ANALOG_00_DOWN = "$input_xboxbutton_analog_00", JOY_BUTTON_ANALOG_01_DOWN = "$input_xboxbutton_analog_01", JOY_BUTTON_ANALOG_02_DOWN = "$input_xboxbutton_analog_02", JOY_BUTTON_ANALOG_03_DOWN = "$input_xboxbutton_analog_03", JOY_BUTTON_ANALOG_04_DOWN = "$input_xboxbutton_analog_04", JOY_BUTTON_ANALOG_05_DOWN = "$input_xboxbutton_analog_05", JOY_BUTTON_ANALOG_06_DOWN = "$input_xboxbutton_analog_06", JOY_BUTTON_ANALOG_07_DOWN = "$input_xboxbutton_analog_07", JOY_BUTTON_ANALOG_08_DOWN = "$input_xboxbutton_analog_08", JOY_BUTTON_ANALOG_09_DOWN = "$input_xboxbutton_analog_09", } function InputFrame.get_input_name(input) if input == "unbound" then return "$menuoptions_configurecontrols_action_unbound" end local name = names[input] if name ~= nil then if name:find("^%$") then name = GameTextGet(name) end return name:upper() end return "$menuoptions_configurecontrols_keyname_unknown" end local detect_key = {} local disable_button = {} function InputFrame.mod_setting_input(mod_id, gui, in_main_menu, im_id, setting) GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine) GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawSemiTransparent) local uioffset = mod_setting_group_x_offset local offset = mod_setting_group_x_offset + GuiGetTextDimensions(gui, setting.ui_name) + 10 if setting.custom_offset then offset = mod_setting_group_x_offset + setting.custom_offset(gui) + 10 local w = GuiGetTextDimensions(gui, setting.ui_name) uioffset = mod_setting_group_x_offset + setting.custom_offset(gui) - w end GuiText(gui, uioffset, 0, setting.ui_name) local text if detect_key[setting.id] then text = "$menuoptions_configurecontrols_pressakey" GuiIdPush(gui, im_id) local textw = GuiGetTextDimensions(gui, "$menuoptions_configurecontrols_pressakey") GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine) local unbound = "[" .. GameTextGet("$menuoptions_configurecontrols_action_unbound") .. "]" local clicked = GuiButton(gui, 1, offset + textw + 10, 0, unbound) local _, _, hover = GuiGetPreviousWidgetInfo(gui) if clicked then detect_key[setting.id] = false ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), "unbound", false) end GuiIdPop(gui) local input = InputFrame.get_any_input() if input ~= nil and not hover then detect_key[setting.id] = false if input == "Mouse_left" or input == "Mouse_right" or input == "JOY_BUTTON_0" or input == "JOY_BUTTON_1" then disable_button[setting.id] = true end ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), input, false) end else text = InputFrame.get_input_name(ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))) end if disable_button[setting.id] and (InputFrame.read_input_up("Mouse_left") or InputFrame.read_input_down("Mouse_right") or InputFrame.read_input_down("JOY_BUTTON_0") or InputFrame.read_input_down("JOY_BUTTON_1")) then disable_button[setting.id] = false GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive) GuiOptionsAddForNextWidget(gui, GUI_OPTION.ForceFocusable) end local clicked, right_clicked = GuiButton(gui, im_id, offset, 0, text) if clicked then detect_key[setting.id] = true elseif right_clicked then ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), setting.value_default, false) end mod_setting_tooltip(mod_id, gui, in_main_menu, setting) end

local mod_id = "conjurer_reborn"
local conjurer_reborn_reset_matwand_fav_confirm = false
local conjurer_reborn_reset_entwand_fav_confirm = false

local mod_id_prefix = mod_id .. "."

local KeyboardList = {
    {
        name = "pinyin_quanpin",
		SettingKey = "QUANPIN"
    },
    {
        name = "pinyin_daqian",
		SettingKey = "DAQIAN"
    },
	{
        name = "pinyin_xiaohe",
		SettingKey = "XIAOHE"
    },
	{
        name = "pinyin_ziranma",
		SettingKey = "ZIRANMA"
    },
	{
        name = "pinyin_sougou",
		SettingKey = "SOUGOU"
    },
	{
        name = "pinyin_zhineng_abc",
		SettingKey = "ZHINENG_ABC"
    },
	{
        name = "pinyin_guobiao",
		SettingKey = "GUOBIAO"
    },
	{
        name = "pinyin_microsoft",
		SettingKey = "MICROSOFT"
    },
	{
        name = "pinyin_pinyinpp",
		SettingKey = "PINYINPP"
    },
	{
        name = "pinyin_ziguang",
		SettingKey = "ZIGUANG"
    },
}

local function DrawKeyboardItem(gui)
	local key = mod_id_prefix .. "keyboard_switch"
	local keyboard = ModSettingGet(key)
    if keyboard == nil then
        ModSettingSet(key, "QUANPIN")
        keyboard = "QUANPIN"
    end
    for _, v in ipairs(KeyboardList) do
		local offset = mod_setting_group_x_offset  + 4
        GuiIdPushString(gui, v.name)

        if keyboard == v.SettingKey then
            GuiColorSetForNextWidget(gui, 0x33 / 255, 0x67 / 255, 0xD1 / 255, 1)
			offset = mod_setting_group_x_offset + 8
		end
        if GuiButton(gui, 0, offset, 0, GetTextOrKey(v.name)) and keyboard ~= v.SettingKey then
            ModSettingSet(key, v.SettingKey)
			local flag, entity = pcall(GameGetWorldStateEntity)
            local isConjurer = GameHasFlagRun("conjurer_reborn_world")
			if entity ~= 0 and isConjurer then--处在conjurer世界
                ModTextFileSetContent("mods/conjurer_reborn/is_refresh_keyboard.txt", "1")
				ModTextFileSetContent("mods/conjurer_reborn/is_refresh_pinin.txt", "1")
			end
		end
		
        if v.desc ~= nil then
            GuiTooltip(gui, GetTextOrKey(v.desc), "")
        end

        GuiIdPop(gui)
    end
end

local FuzzyPhonetics = {
    {
		name = "pinyin_first",
		SettingKey = "first_letter",
		value_default = true,
	},
	{
        name = "pinyin_zh_eq_z",
        SettingKey = "zh_eq_z",
		value_default = true,
    },
	{
        name = "pinyin_sh_eq_s",
        SettingKey = "sh_eq_s",
		value_default = true,
    },
	{
        name = "pinyin_ch_eq_c",
        SettingKey = "ch_eq_c",
		value_default = true,
    },
	{
        name = "pinyin_ang_eq_an",
        SettingKey = "ang_eq_an",
		value_default = true,
    },
	{
        name = "pinyiin_eng_eq_en",
        SettingKey = "eng_eq_en",
		value_default = true,
    },
	{
        name = "pinyiin_v_eq_u",
        SettingKey = "v_eq_u",
		value_default = true,
    },
}

local function DrawFuzzyPhoneticsItem(gui)
	local offset = mod_setting_group_x_offset + 4
	for _, v in ipairs(FuzzyPhonetics) do
        GuiIdPushString(gui, v.name)
		local key = mod_id_prefix .. v.SettingKey
		local value = ModSettingGet(key)
		if value == nil then
            value = v.value_default
			ModSettingSet(key, value)
		end
        local text = GetTextOrKey(v.name) .. ": " .. GameTextGet(value and "$option_on" or "$option_off")
        if GuiButton(gui, 0, offset, 0, text) then
            ModSettingSet(key, not value)
            local flag, entity = pcall(GameGetWorldStateEntity)
            local isConjurer = GameHasFlagRun("conjurer_reborn_world")
            if entity ~= 0 and isConjurer then --处在conjurer世界
                ModTextFileSetContent("mods/conjurer_reborn/is_refresh_pinin.txt", "1")
            end
        end
        GuiIdPop(gui)
    end
end
local function Keybind(...)
    local list = {...}
    local keys = {}
    for _, t in ipairs(list) do
        for _, v in ipairs(t.settings) do
            keys[#keys + 1] = v.ui_name
        end
    end
    local clac = GetClacKeyOffset(unpack(keys))
    local result = {}
    for _, t in ipairs(list) do
        local newlist = {}
        for _, v in ipairs(t.settings) do
            v.custom_offset = clac
            v.scope = MOD_SETTING_SCOPE_RUNTIME
            v.ui_fn = InputFrame.mod_setting_input
            newlist[#newlist + 1] = Setting(v)
        end
        t.settings = newlist
        result[#result + 1] = Setting(t)
    end
    local id_prefix = mod_id  .. "."
    local function parseSetting(settings)
        for _, s in pairs(settings) do
            if s.id ~= nil then
                local key =  id_prefix .. s.id
                if s.value_default ~= nil then
                    ModSettingSet(key, s.value_default)
                    ModSettingSetNextValue(key, s.value_default, false)
                end
            elseif s.settings ~= nil then
                parseSetting(s.settings)
            end
        end
    end
    result[#result + 1] = Setting {
        id = "reset_" .. (result[1].category_id or "keybind_def"),
		ui_name = "",
		ui_description = "",
        ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
            local offset = mod_setting_group_x_offset + clac(gui) + 12
            local click = GuiButton(gui, im_id, offset, 0, "$menuoptions_configurecontrols_reset_all")
            if click then
                parseSetting(result)
            end
        end
    }
    return result
end

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
				scope = MOD_SETTING_SCOPE_RUNTIME,
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
		foldable = true,
		_folded = true,
        settings = Keybind({
            category_id = "matwand_controls",
            ui_name = "matwand",
            settings = {
                {
				    id = "mat_quick_switch",
				    ui_name = "quick_switch",
				    value_default = "unbound",
			    },
                {
			        id = "draw_material",
			        ui_name = "draw_material",
                    value_default = "Mouse_left",
			    },
			    {
			        id = "erase_material",
			        ui_name = "erase_material",
                    value_default = "Mouse_right",
                },
			    {
			        id = "quick_eyedropper",
			        ui_name = "quick_eyedropper",
				    value_default = "Mouse_middle",
                },
			    {
			        id = "left_brush",
			        ui_name = "left_brush",
			        value_default = "Key_q",
                },
		        {
			        id = "right_brush",
				    ui_name = "right_brush",
                    value_default = "Key_e",
                },
                {
				    id = "angle_snap",
				    ui_name = "angle_snap",
				    value_default = "Key_LSHIFT",
                },
                {
				    id = "constrain_proportion",
				    ui_name = "constrain_proportion",
				    value_default = "Key_LSHIFT",
			    },
                {
				    id = "material_overwrite",
				    ui_name = "material_overwrite",
				    value_default = "unbound",
			    },
                {
				    id = "quick_enable_fe",
				    ui_name = "quick_enable_fe",
				    value_default = "unbound",
                },
            }
        },
        {
            category_id = "entwand_controls",
            ui_name = "entwand",
            settings = {
                {
				    id = "ent_quick_switch",
				    ui_name = "quick_switch",
				    value_default = "unbound",
			    },
                {
				    id = "spawn_entity",
				    ui_name = "spawn_entity",
                    value_default = "Mouse_left",
			    },
			    {
				    id = "delete_entity",
				    ui_name = "delete_entity",
                    value_default = "Mouse_right",
                },
			    {
				    id = "remove_add_progress",
				    ui_name = "remove_add_progress",
                    value_default = "Mouse_middle",
                },
			    {
				    id = "quick_select_entity",
				    ui_name = "quick_select_entity",
                    value_default = "Mouse_middle",
                },
                {
				    id = "quick_scan_preview",
				    ui_name = "quick_scan_preview",
                    value_default = "unbound",
                },
            }
        },
        {
            category_id = "editwand_controls",
            ui_name = "editwand",
            settings = {
                {
				    id = "edit_quick_switch",
				    ui_name = "quick_switch",
				    value_default = "unbound",
                },
                {
				    id = "edit_m1",
				    ui_name = "left_click_behavior",
				    value_default = "Mouse_left",
                },
                {
				    id = "edit_m2",
				    ui_name = "right_click_behavior",
				    value_default = "Mouse_right",
                },
                {
				    id = "edit_interact",
				    ui_name = "interact",
				    value_default = "Key_e",
			    },
            }
        },
        {
            category_id = "tunewand_controls",
            ui_name = "tunewand",
            settings = {
                {
				    id = "tune_quick_switch",
				    ui_name = "quick_switch",
				    value_default = "unbound",
			    },
            }
        },
        {
            category_id = "carrot_controls",
            ui_name = "carrot_controls",
            settings = {
                {
				    id = "tp_carrot_blink",
				    ui_name = "tp_carrot_blink",
				    value_default = "Mouse_left",
                },
                {
				    id = "tp_carrot_hold",
				    ui_name = "tp_carrot_hold",
				    value_default = "Mouse_right",
                },
                {
				    id = "tp_carrot_hold_shift",
				    ui_name = "tp_carrot_hold_shift",
				    value_default = "Key_LSHIFT",
			    },
            }
        },
        {
            category_id = "other_controls",
            ui_name = "other_controls",
            settings = {
                {
				    id = "exit_polymorph",
				    ui_name = "exit_polymorph",
				    value_default = "Key_q",
                },
                {
				    id = "player_respawn",
				    ui_name = "player_respawn",
				    value_default = "Key_RETURN",
                },
                {
				    id = "glass_eye",
				    ui_name = "glass_eye",
				    value_default = "unbound",
                },
                {
				    id = "post_fx",
				    ui_name = "post_fx",
				    value_default = "unbound",
                },
                {
				    id = "binoculars",
				    ui_name = "binoculars",
				    value_default = "unbound",
                },
                {
				    id = "fullbright",
				    ui_name = "fullbright",
				    value_default = "unbound",
                },
                {
				    id = "grid_display",
				    ui_name = "grid_display",
				    value_default = "unbound",
                },
                {
				    id = "viima",
				    ui_name = "viima",
				    value_default = "unbound",
                },
            }
        })
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
                    local click = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, GetTextOrKey("reset_matwand_fav"))
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
				end
            },
			Setting{
				id = "reset_entwand_fav",
				ui_name = "",
				ui_description = "",
				ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                    local click = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, GetTextOrKey("reset_entwand_fav"))
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
		category_id = "pinyin_settings",
        ui_name = "pinyin_matching",
        ui_description = "pinyin_matching_desc",
		foldable = true,
		_folded = true,
        settings = {
            Setting {
				ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                    GuiIdPushString(gui, "conjurer_reborn_pinyin_keyboard_switch")
                    
                    GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawSemiTransparent)
					GuiText(gui, mod_setting_group_x_offset, 0, GetTextOrKey("pinyin_keyboard_switch"))
					GuiTooltip(gui, GetTextOrKey("pinyin_keyboard_switch_desc"), "")

					DrawKeyboardItem(gui)

					GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawSemiTransparent)
					GuiText(gui, mod_setting_group_x_offset, 0, GetTextOrKey("pinyin_fuzzy_phonetics"))
                    GuiTooltip(gui, GetTextOrKey("pinyin_fuzzy_phonetics_desc"), "")
					
					DrawFuzzyPhoneticsItem(gui)

					GuiIdPop(gui)
				end
			}
		},
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
