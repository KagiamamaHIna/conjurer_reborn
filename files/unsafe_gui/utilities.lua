dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")

function ClickSound()
	GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
end

function ItemSound()
	GamePlaySound("data/audio/Desktop/ui.bank", "ui/item_switch_places", GameGetCameraPos())
end

---@param key string
---@return string
function GetNameOrKey(key)
	if key == nil then
		return ""
	end
	local name = GameTextGetTranslatedOrNot(key)
    if name == "" then
        name = string.sub(key, 2)
    end
	return name
end

local Globaldefault = "__conjurer_reborn_is_not_has_any_value___yes_i_am_sajo_yukimi_p"

---从当前世界的全局获取值或从UserData缓存的获取
---@param UI Gui
---@param key string
---@param default string? default = ""
---@return string
function WorldGlobalGet(UI, key, default)
	default = Default(default, "")
	if UI.UserData["__WorldGlobalCache"] == nil then
		UI.UserData["__WorldGlobalCache"] = {}
	end
	if UI.UserData["__WorldGlobalCache"][key] == nil then
		local value = GlobalsGetValue(ModID .. key, Globaldefault)
		if value == Globaldefault then
			GlobalsSetValue(ModID .. key, default)
			value = default
		end
		UI.UserData["__WorldGlobalCache"][key] = value
	end
	return UI.UserData["__WorldGlobalCache"][key]
end

---设置当前世界的全局变量
---@param UI Gui
---@param key string
function WorldGlobalSet(UI, key, value)
	if UI.UserData["__WorldGlobalCache"] == nil then
		UI.UserData["__WorldGlobalCache"] = {}
	end
	value = tostring(value)
	GlobalsSetValue(ModID .. key, value)
	UI.UserData["__WorldGlobalCache"][key] = value
end

---从当前世界的全局获取值或从UserData缓存的获取
---@param UI Gui
---@param key string
---@param default boolean? default = false
---@return boolean
function WorldGlobalGetBool(UI, key, default)
	default = Default(default, false)
	local defaultStr
	if default then
		defaultStr = "1"
	else
		defaultStr = "2"
	end
	local text = WorldGlobalGet(UI, key, defaultStr)
	local result
	if text == "1" then
		result = true
	elseif text == "0" then
		result = false
	end
	return result
end

---设置当前世界的全局变量
---@param UI Gui
---@param key string
---@param value boolean
function WorldGlobalSetBool(UI, key, value)
	if UI.UserData["__WorldGlobalCache"] == nil then
		UI.UserData["__WorldGlobalCache"] = {}
	end
	local InputText = "0"
	if value then
		InputText = "1"
	end
	GlobalsSetValue(ModID .. key, InputText)
	UI.UserData["__WorldGlobalCache"][key] = InputText
end

---带向上取整和方向键减少增加功能的滑条
---@param UI Gui
---@param id string
---@param x number
---@param y number
---@param text string
---@param value_min number
---@param value_max number
---@param value_default number
---@param width number
---@param value_formatting string?
---@return number
function EasyCeilSlider(UI, id, x, y, text, value_min, value_max, value_default, width, value_formatting)
	value_formatting = Default(value_formatting, "")
	local value = UI.Slider(id, x, y, text, value_min, value_max, value_default, 1, value_formatting, width)
	local _, _, hover = UI.WidgetInfo()
	local result = math.ceil(value)
	UI.SetSliderValue(id, result)
	local SliderFrKey = id .. "SliderFr"
	if hover then
		local function MoveSlider()
			local left = InputIsKeyDown(Key_KP_MINUS) or InputIsKeyDown(Key_LEFT) or InputIsKeyDown(Key_MINUS)
			local right = InputIsKeyDown(Key_KP_PLUS) or InputIsKeyDown(Key_RIGHT) or InputIsKeyDown(Key_EQUALS)
			local num = 1
			if left then
				UI.SetSliderValue(id, value - num)
			elseif right then
				UI.SetSliderValue(id, value + num)
			end
		end
		local hasPush = InputIsKeyDown(Key_KP_MINUS) or InputIsKeyDown(Key_LEFT) or InputIsKeyDown(Key_MINUS)
			or InputIsKeyDown(Key_KP_PLUS) or InputIsKeyDown(Key_RIGHT) or InputIsKeyDown(Key_EQUALS)
		if hasPush then
			if UI.UserData[SliderFrKey] == nil then --如果在悬浮，就分配一个帧检测时间
				UI.UserData[SliderFrKey] = 30
			else
				if UI.UserData[SliderFrKey] == 30 then
					MoveSlider()
				end
				if UI.UserData[SliderFrKey] ~= 0 then
					UI.UserData[SliderFrKey] = UI.UserData[SliderFrKey] - 1
				else --如果到了0
					MoveSlider()
				end
			end
		else
			UI.UserData[SliderFrKey] = 30
		end
	else
		UI.UserData[SliderFrKey] = nil
	end
	return UI.GetSliderValue(id)
end

---可以提前设置保存值的带向上取整的滑条
---@param UI Gui
---@param id string
---@param x number
---@param y number
---@param text string
---@param value_min number
---@param value_max number
---@param value_default number
---@param width number
---@param savedValue number?
---@param value_formatting string?
---@return number
function EasySlider(UI, id, x, y, text, value_min, value_max, value_default, width, savedValue, value_formatting)
	value_formatting = Default(value_formatting, "")
	local flag = false
	if UI.GetSliderValue(id) == nil then
		flag = true
	end
	EasyCeilSlider(UI, id, x, y, text, value_min, value_max, value_default, width, value_formatting)
	if flag and savedValue then
		UI.SetSliderValue(id, savedValue)
	end
	return UI.GetSliderValue(id)
end

---相同(左边)文本宽度的滑条
---@param UI Gui
---@param id string
---@param Align number
---@param x number
---@param y number
---@param text string
---@param value_min number
---@param value_max number
---@param value_default number
---@param width number
---@param tooltip string?
---@param savedValue number?
---@return number
function SameWidthSlider(UI, id, Align, x, y, text, value_min, value_max, value_default, width, tooltip, savedValue, isDecimals, format)
	format = format or ""
	UI.BeginHorizontal(0, 0, true)
    UI.NextZDeep(0)
	text = GameTextGet(text)
    local left = UI.TextBtn(id .. "TextBtn", 0, 0, text)
    if left then
        UI.SetSliderValue(id, value_min)
    end
    local _, _, hover, tx, ty, textWitdh = UI.WidgetInfo()
	local number
	local numberStr
	if isDecimals then
        number = UI.GetSliderValue(id) or 0
		numberStr = tostring(number)
    else
		number = math.ceil(UI.GetSliderValue(id) or 0)
		if number and number < 0 then
			numberStr = tostring(number - 1)
		end
	end
	if format then
		numberStr = format
	end
    if hover then

        UI.NextOption(GUI_OPTION.Layout_NoLayouting)
        UI.NextZDeep(0)
        UI.Text(tx + textWitdh + width + 6 + Align - textWitdh, ty + 1, numberStr)
		if tooltip then
			UI.BetterTooltipsNoCenter(function()--强制绘制悬浮窗
				UI.Text(0,0,tooltip)
			end, -3000, 8, nil, nil, nil, true, nil, nil, true)
		end
	end
    UI.NextZDeep(0)
	local result
    if isDecimals then
		local flag = false
		if UI.GetSliderValue(id) == nil then
			flag = true
		end
        result = UI.Slider(id, x + Align - textWitdh, y + 1, "", value_min, value_max, value_default, 0.01, format, width)
		if flag and savedValue then
			UI.SetSliderValue(id, savedValue)
		end
	else
		result = EasySlider(UI, id, x + Align - textWitdh, y+1, "", value_min, value_max, value_default, width, savedValue)
	end
	if tooltip then
		UI.GuiTooltip(tooltip)
	end
    GuiAnimateBegin(UI.gui)--帮助滑条能完整的显示文本
	GuiAnimateAlphaFadeIn(UI.gui, UI.NewID(id.."ANI"), 0, 0, false)
    UI.Text(0, 0, numberStr)
    GuiAnimateEnd(UI.gui)
    UI.LayoutEnd()
	return result
end

---Conjurer风格的Checkbox
---@param UI Gui
---@param id string
---@param x number
---@param y number
---@param text string
---@param zdeep integer?
---@param default boolean?
---@return boolean enable, boolean click
function ConjurerCheckbox(UI, id, x, y, text, zdeep, default)
	zdeep = Default(zdeep, 0)
	default = Default(default, false)
	local StatusKey = id .. "Status"
	local Status = WorldGlobalGetBool(UI, StatusKey, default)
	local CheckboxImg = "mods/conjurer_reborn/files/gfx/checkbox_empty.png"
	if Status then
		CheckboxImg = "mods/conjurer_reborn/files/gfx/checkbox_full.png"
	end
	UI.BeginHorizontal(x, y, true, 0, 0)
	UI.NextZDeep(zdeep)
	local _, height = GuiGetTextDimensions(UI.gui, text)
	local _, ImgHeight = GuiGetImageDimensions(UI.gui, CheckboxImg)
	UI.Image(id .. "CheckBoxImage", 0, height / 2 - ImgHeight / 2, CheckboxImg)
	UI.NextZDeep(zdeep)
	local left = UI.TextBtn(id, 3, 0, text)
	if left then
		WorldGlobalSetBool(UI, StatusKey, not Status)
	end
	UI.LayoutEnd()
	return WorldGlobalGetBool(UI, StatusKey), left
end

---获取开启状态，第二个是全局变量是否初始化
---@param id string
---@return boolean status, boolean init
function GetConjurerCheckBoxStatus(id)
    local StatusKey = "conjurer_unsafe".. id .. "Status"
	local result = GlobalsGetValue(StatusKey, Globaldefault)
	if result == Globaldefault then
		return false, false
	end
	return result == "1", true
end

---Conjurer风格的Checkbox，不持久性保存数据
---@param UI Gui
---@param id string
---@param x number
---@param y number
---@param text string
---@param zdeep integer?
---@param default boolean?
---@return boolean enable, boolean click
function ConjurerCheckboxNoSave(UI, id, x, y, text, zdeep, default)
	zdeep = Default(zdeep, 0)
	default = Default(default, false)
	local StatusKey = id .. "Status"
	local Status = UI.UserData[StatusKey]
	if Status == nil then
		Status = default
		UI.UserData[StatusKey] = default
	end
	local CheckboxImg = "mods/conjurer_reborn/files/gfx/checkbox_empty.png"
	if Status then
		CheckboxImg = "mods/conjurer_reborn/files/gfx/checkbox_full.png"
	end
	UI.BeginHorizontal(x, y, true, 0, 0)
	UI.NextZDeep(zdeep)
	local _, height = GuiGetTextDimensions(UI.gui, text)
	local _, ImgHeight = GuiGetImageDimensions(UI.gui, CheckboxImg)
	UI.Image(id .. "CheckBoxImage", 0, height / 2 - ImgHeight / 2, CheckboxImg)
	UI.NextZDeep(zdeep)
	local left = UI.TextBtn(id, 3, 0, text)
	if left then
		UI.UserData[StatusKey] = not Status
	end
	UI.LayoutEnd()
	return UI.UserData[StatusKey], left
end

local BUTTON_SETTING = ModSettingGet("conjurer_reborn.secondary_button")
local BUTTON_CHOICES = {
	throw = { hold = "mButtonDownThrow", click = "mButtonFrameThrow" },
	mouse2 = { hold = "mButtonDownRightClick", click = "mButtonFrameRightClick" }
}

local SELECTED_BUTTON = BUTTON_CHOICES[BUTTON_SETTING]

---来源于原版conjurer
---@param player integer?
---@return boolean
function ShootingIsEnabled(player)
	player = player or GetPlayer()
	if not player then return false end

	return ComponentGetIsEnabled(EntityGetFirstComponentIncludingDisabled(player, "GunComponent"))
end

---来源于原版conjurer
---@param ignore_guncomponent boolean?
---@return boolean
function IsHoldingMouse1(ignore_guncomponent)
	local player = GetPlayer()
	if not player then return false end

	if not ignore_guncomponent and not ShootingIsEnabled(player) then
		return false
	end

	return ComponentGetValue2(
		EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent"),
		"mButtonDownFire"
	)
end

---来源于原版conjurer
---@param ignore_guncomponent boolean?
---@return boolean
function IsHoldingMouse2(ignore_guncomponent)
	local player = GetPlayer()
	if not player then return false end

	if not ignore_guncomponent and not ShootingIsEnabled(player) then
		return false
	end

	return ComponentGetValue2(
		EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent"),
		SELECTED_BUTTON.hold
	)
end

---来源于原版conjurer
---@param entity integer
---@param component_name string
function EntityFirstComponent(entity, component_name)
	-- Holy moly, should've made this alias sooner.
	return EntityGetFirstComponentIncludingDisabled(entity, component_name)
end

---来源于原版conjurer
---@param component integer
---@param values table
function ComponentSetValues(component, values)
	for key, value in pairs(values) do
		ComponentSetValue2(component, key, value)
	end
end

---来源于原版conjurer
---@param entity integer
---@param component_name string
---@param values any
function EntitySetValues(entity, component_name, values)
	if entity == nil or entity == 0 then return end

    local comp = EntityGetFirstComponentIncludingDisabled(entity, component_name)
	if comp == nil or comp == 0 then
		return nil
	end
	ComponentSetValues(comp, values)
end

---来源于原版conjurer
---@param entity integer
---@param component_name string
---@param attr_name string
---@param value any
function EntitySetValue(entity, component_name, attr_name, value)
	if entity == nil or entity == 0 then return end

	return ComponentSetValue2(EntityGetFirstComponentIncludingDisabled(entity, component_name), attr_name, value)
end

-- Shorthands for a really common actions
---来源于原版conjurer
---@param entity integer
---@param component_name string
---@param attr_name string
---@return any
function EntityGetValue(entity, component_name, attr_name)
	if entity == nil or entity == 0 then return nil end
    local comp = EntityGetFirstComponentIncludingDisabled(entity, component_name)
	if comp == nil or comp == 0 then
		return nil
	end
	return ComponentGetValue2(comp, attr_name)
end

---来源于原版conjurer
---@param entity integer
---@param component_name string
---@param attr_name string
function EntityToggleValue(entity, component_name, attr_name)
	if entity == nil or entity == 0 then return end

	local value = EntityGetValue(entity, component_name, attr_name)
	EntitySetValue(entity, component_name, attr_name, not value)
end

---来源于原版conjurer
---@param ignore_guncomponent boolean?
---@return boolean
function HasClickedMouse1(ignore_guncomponent)
	local click_frame = EntityGetValue(
		GetPlayer(), "ControlsComponent", "mButtonFrameFire"
	)

	if not ignore_guncomponent and not ShootingIsEnabled() then
		return false
	end

	return click_frame == GameGetFrameNum()
end

---来源于原版conjurer
---@return boolean
function HasClickedInteract()
	local click_frame = EntityGetValue(
		GetPlayer(), "ControlsComponent", "mButtonFrameInteract"
	)

	return click_frame == GameGetFrameNum()
end

---来源于原版conjurer
---@param ignore_guncomponent boolean?
---@return boolean
function HasClickedMouse2(ignore_guncomponent)
	local click_frame = EntityGetValue(
		GetPlayer(), "ControlsComponent", SELECTED_BUTTON.click
	)

	if not ignore_guncomponent and not ShootingIsEnabled() then
		return false
	end

	return click_frame == GameGetFrameNum()
end

---页面表格框
---@param UI Gui
---@param id string
---@param items table
---@param x number
---@param y number
---@param width integer
---@param height integer
---@param row integer
---@param column integer
---@param sprite string
---@param BtnCallBack function
function PageGrid(UI, id, items, x, y, width, height, row, column, sprite, BtnCallBack)
	local PageMaxBtn = row * column --单页面下最多按钮数
	local itemLen = #items
	local NoItems = false
	local PageSize = math.ceil(itemLen / PageMaxBtn) --所有页面数
	if PageSize == 0 then
		NoItems = true
		PageSize = 1
	end
	local PageIndexKey = "PageGridIndex" .. id
	local PageIndex = UI.UserData[PageIndexKey] --页面索引

	if PageIndex == nil then
		PageIndex = 1
		UI.UserData[PageIndexKey] = 1
	end

	if PageIndex < 1 then
		PageIndex = PageSize
		UI.UserData[PageIndexKey] = PageSize
	elseif PageIndex > PageSize then
		PageIndex = 1
		UI.UserData[PageIndexKey] = 1
	end

	--计算起始和终止范围
	local StartIndex = PageMaxBtn * (PageIndex - 1) + 1
	local EndIndex = math.min(PageMaxBtn * PageIndex, itemLen) --防止越界
	UI.ScrollContainer(id, x, y, width, height)
	UI.AddAnywhereItem(id, function()
		if NoItems then --没有项目绘制文本
			UI.NextZDeep(0)
			UI.Text(0, 0, GameTextGet("$conjurer_reborn_page_grid_no_items"))
		else
			local Count = 1
			UI.BeginHorizontal(0, 0, true)
			for i = StartIndex, EndIndex do --根据给定范围遍历
				if Count > row then
					Count = 1
					UI.LayoutEnd()
					UI.BeginHorizontal(0, 0, true)
				end
				Count = Count + 1
				BtnCallBack(items[i], i)
			end
			UI.LayoutEnd()
		end
	end)

	UI.DrawScrollContainer(id, true, true, sprite, nil, nil, -100)
	--下面是绘制两个按钮和文本
	local ScrollHeight = UI.GetScrollHeight(id)
	local ScrollWidth = UI.GetScrollWidth(id)
	local LeftBtnId = id .. "PageLeftBtn"
	local RightBtnId = id .. "PageRightBtn"
	UI.ScrollContainer(LeftBtnId, x + 2, y + ScrollHeight - 17, 0, 0)
	--绘制两个按钮和文本
	local mx, my = InputGetMousePosOnScreen()
	mx = mx / UI.GetScale()
	my = my / UI.GetScale()
	local LeftBtnHover = UI.GetScrollHover(LeftBtnId, true)
	UI.AddAnywhereItem(LeftBtnId, function()
		if LeftBtnHover then
			UI.NextColor(255, 165, 0, 255)
		end
		if LeftBtnHover and InputIsMouseButtonJustDown(Mouse_left) then
			ClickSound()
			if InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL) then
				UI.UserData[PageIndexKey] = 1
			else
				UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] - 1
			end
		end
		UI.NextZDeep(2)
		UI.Text(0, 0, "<", 1, "data/fonts/font_pixel.xml")
	end)
	UI.DrawScrollContainer(LeftBtnId, false, true, sprite, nil, nil, -99)

	UI.ScrollContainer(RightBtnId, ScrollWidth + x - 12, y + ScrollHeight - 17, 0, 0)
	local RightBtnHover = UI.GetScrollHover(RightBtnId, true)
	UI.AddAnywhereItem(RightBtnId, function()
		if RightBtnHover then
			UI.NextColor(255, 165, 0, 255)
			InputIsMouseButtonJustDown(Mouse_left)
		end
		if RightBtnHover and InputIsMouseButtonJustDown(Mouse_left) then
			ClickSound()
			if InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL) then
				UI.UserData[PageIndexKey] = PageSize
			else
				UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] + 1
			end
		end
		UI.NextZDeep(2)
		UI.Text(0, 0, ">", 1, "data/fonts/font_pixel.xml")
	end)
	UI.DrawScrollContainer(RightBtnId, false, true, sprite, nil, nil, -99)
	local GridHover = UI.GetScrollHover(id, true)
	if GridHover then
		if InputIsMouseButtonJustDown(Mouse_wheel_up) then
			UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] - 1
		elseif InputIsMouseButtonJustDown(Mouse_wheel_down) then
			UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] + 1
		end
	end
	--绘制页面数的文本控件
	UI.NextZDeep(2)
	local pageText = string.format("%d/%d", PageIndex, PageSize)
	local pageTextWidth = UI.TextDimensions(pageText, nil, nil, "data/fonts/font_pixel.xml")
	UI.Text(ScrollWidth / 2 + x - pageTextWidth / 2, y + ScrollHeight - 13, pageText, 1, "data/fonts/font_pixel.xml")
end

---垂直翻页框
---@param UI Gui
---@param id string
---@param items table
---@param x number
---@param y number
---@param width number
---@param height number
---@param ColumnMax integer
---@param sprite string
---@param BtnCallBack function
function VerticalPage(UI, id, items, x, y, width, height, ColumnMax, sprite, BtnCallBack)
	local itemLen = #items
	if itemLen == 0 then --没元素不渲染
		return
	end
	local PageSize = math.ceil(itemLen / ColumnMax) --所有页面数

	local PageIndexKey = "VerticalPageIndex" .. id
	local PageIndex = UI.UserData[PageIndexKey] --页面索引

	if PageIndex == nil then
		PageIndex = 1
		UI.UserData[PageIndexKey] = 1
	end

	if PageIndex < 1 then
		PageIndex = PageSize
		UI.UserData[PageIndexKey] = PageSize
	elseif PageIndex > PageSize then
		PageIndex = 1
		UI.UserData[PageIndexKey] = 1
	end
	--计算起始和终止范围
	local StartIndex = ColumnMax * (PageIndex - 1) + 1
	local EndIndex = math.min(ColumnMax * PageIndex, itemLen) --防止越界

	UI.ScrollContainer(id, x, y, width, height, 1)
	local YText = 0
	UI.AddAnywhereItem(id, function()
		GuiAnimateBegin(UI.gui)
		GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("VerticalPageAlpha0" .. id), 0, 0, false)
		UI.Text(0, 0, "<", 1, "mods/conjurer_reborn/files/font/VerticalPageFont.xml")
		UI.VerticalSpacing(6)
		GuiAnimateEnd(UI.gui)

		for i = StartIndex, EndIndex do
			BtnCallBack(items[i], i)
			UI.VerticalSpacing(2)
		end
		--绘制页面数的文本控件
		local ScrollWidth = UI.GetScrollWidth(id)
		local PageTextScale = 0.7
		GuiAnimateBegin(UI.gui) --腾出空间并计算y轴
		GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("VerticalPageDownTextAlpha0" .. id), 0, 0, false)
		local pageText = string.format("%d/%d", PageIndex, PageSize)
		UI.Text(0, 0, pageText, PageTextScale, "data/fonts/font_pixel.xml")
		local _, _, _, PageTextX, PageTextY = UI.WidgetInfo()
		YText = PageTextY
		UI.VerticalSpacing(6)
		UI.Text(0, 0, "<", 1, "mods/conjurer_reborn/files/font/VerticalPageFont.xml")
		GuiAnimateEnd(UI.gui)
		local pageTextWidth = UI.TextDimensions(pageText, nil, PageTextScale, "data/fonts/font_pixel.xml")
		UI.NextOption(GUI_OPTION.Layout_NoLayouting) --让文本绝对定位
		UI.NextZDeep(2)
		UI.Text(ScrollWidth / 2 + PageTextX - pageTextWidth / 2 + 1.5, PageTextY, pageText, PageTextScale, "data/fonts/font_pixel.xml")
	end)

	UI.DrawScrollContainer(id, true, true, sprite, nil, nil, -100)
	local ScrollWidth = UI.GetScrollWidth(id)
	local LeftBtnId = id .. "VerticalPageLeftBtn"
	local RightBtnId = id .. "VerticalPageRightBtn"
	UI.ScrollContainer(LeftBtnId, x, y, ScrollWidth - 4, 0)
	--绘制两个按钮和文本
	local mx, my = InputGetMousePosOnScreen()
	mx = mx / UI.GetScale()
	my = my / UI.GetScale()
	local LeftBtnHover = UI.GetScrollHover(LeftBtnId, true)
	UI.AddAnywhereItem(LeftBtnId, function()
		GuiAnimateBegin(UI.gui)
		GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("VerticalPageLeftAlpha0" .. id), 0, 0, false)
		UI.Text(0, 0, "<", 1, "mods/conjurer_reborn/files/font/VerticalPageFont.xml")
		GuiAnimateEnd(UI.gui)
		if LeftBtnHover then
			UI.NextColor(255, 165, 0, 255)
		end
		if LeftBtnHover and InputIsMouseButtonJustDown(Mouse_left) then
			ClickSound()
			if InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL) then
				UI.UserData[PageIndexKey] = 1
			else
				UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] - 1
			end
		end
		UI.NextZDeep(2)
		UI.NextOption(GUI_OPTION.Layout_NoLayouting)
		UI.Text(x + (ScrollWidth - 4) / 2 - 0.5, y + 1, "<", 1, "mods/conjurer_reborn/files/font/VerticalPageFont.xml")
	end)
	UI.DrawScrollContainer(LeftBtnId, true, true, sprite, nil, nil, -99)

	UI.ScrollContainer(RightBtnId, x, YText + 13, ScrollWidth - 4, 0)
	local RightBtnHover = UI.GetScrollHover(RightBtnId, true)
	UI.AddAnywhereItem(RightBtnId, function()
		GuiAnimateBegin(UI.gui)
		GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("VerticalPageRightAlpha0" .. id), 0, 0, false)
		UI.Text(0, 0, ">", 1, "mods/conjurer_reborn/files/font/VerticalPageFont.xml")
		GuiAnimateEnd(UI.gui)
		if RightBtnHover then
			UI.NextColor(255, 165, 0, 255)
		end
		if RightBtnHover and InputIsMouseButtonJustDown(Mouse_left) then
			ClickSound()
			if InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL) then
				UI.UserData[PageIndexKey] = 1
			else
				UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] + 1
			end
		end
		UI.NextZDeep(2)
		UI.NextOption(GUI_OPTION.Layout_NoLayouting)
		UI.Text(x + (ScrollWidth - 4) / 2 - 0.5, YText + 13, ">", 1, "mods/conjurer_reborn/files/font/VerticalPageFont.xml")
	end)
	UI.DrawScrollContainer(RightBtnId, true, true, sprite, nil, nil, -99)

	--滚轮翻页
	local GridHover = UI.GetScrollHover(id, true)
	if GridHover then
		if InputIsMouseButtonJustDown(Mouse_wheel_up) then
			UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] - 1
		elseif InputIsMouseButtonJustDown(Mouse_wheel_down) then
			UI.UserData[PageIndexKey] = UI.UserData[PageIndexKey] + 1
		end
	end
end
