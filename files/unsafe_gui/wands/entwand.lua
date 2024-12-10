dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_helper.lua")
dofile_once("data/scripts/gun/gun_enums.lua")

local EntWandSpriteBG = "mods/conjurer_reborn/files/gfx/9piece_blue.png"
local EntWandSpriteTab = "mods/conjurer_reborn/files/gfx/9piece_blue_tab.png"

---@type function|nil
local ActiveEntwandFn = nil

---@param fn function
local function ToggleActiveOverlay(fn)
	ActiveEntwandFn = (ActiveEntwandFn ~= fn) and fn or nil
end

local function DrawActiveEntwandFn(UI)
	if ActiveEntwandFn then
		ActiveEntwandFn(UI)
	end
end

---@param key string
---@return string
local function GetEntNameOrKey(key)
	if key == nil then
		return ""
	end
	local name = GameTextGetTranslatedOrNot(key)
    if name == "" then
        name = string.sub(key, 2)
    end
	return name
end

local SpeChar = string.byte('@')

local function FromIdSearch(keyword, id)
	local score = 0
    if string.byte(keyword, 1, 1) == SpeChar then --搜索模组id/模组名字
        local modId = id or "?"
        local lowerModId = modId:lower()
        local newScore = Cpp.AbsPartialPinyinRatio(lowerModId, string.sub(keyword, 2):lower())
        if newScore > score then
            score = newScore
        end
        local modName = ModIdToName(modId) --获取模组名字
        if modName then              --对模组名字判空
            newScore = Cpp.AbsPartialPinyinRatio(modName:lower(), string.sub(keyword, 2):lower())
            if newScore > score then
                score = newScore
            end
        end
    end
	return score
end

---绘制敌人的悬浮窗文本
---@param UI Gui
---@param id string
---@param isNoDraw boolean?
local function EnemyTooltipText(UI, id, isNoDraw, MainFn)
	local enemy = GetEnemy(id)
    local name = GetEntNameOrKey(enemy.name)
    local shift = InputIsKeyDown(Key_RSHIFT) or InputIsKeyDown(Key_LSHIFT)
	local FileIKey = "EntWandEnemyFileIndex"..id
	if UI.UserData[FileIKey] == nil then
		UI.UserData[FileIKey] = 1
	end
	if MainFn then
		MainFn()
	end
    UI.Text(0, 0, name)           --本地化名称显示
	
    UI.NextColor(127, 127, 127, 255) --id显示
    UI.Text(0, 0, id)
    
	if enemy.herd_id then
		UI.NextColor(127, 127, 255, 255)
		UI.Text(0, 0, enemy.herd_id)--阵营显示
	end
	
    UI.VerticalSpacing(3)
    if shift and #enemy.files > 1 then
        for i, v in ipairs(enemy.files) do
			local file = v:gsub("data/entities/",".../",1)
			UI.BeginHorizontal(0,0,true,0,0)
            UI.Text(0, 0, file)
            local _, _, hover = UI.WidgetInfo()
            if hover and not isNoDraw and UI.UserData[FileIKey] ~= i then
                UI.UserData[FileIKey] = i
				ItemSound()
            end
            if UI.UserData[FileIKey] == i then
                local img = "mods/conjurer_reborn/files/gfx/checkbox_full.png"
				local _, height = GuiGetTextDimensions(UI.gui, file)
                local _, ImgHeight = GuiGetImageDimensions(UI.gui, img)
				UI.Image(id .. "EnemySelectIcon", 3, height / 2 - ImgHeight / 2-1, img)
            end
            UI.LayoutEnd()
			UI.VerticalSpacing(1)
        end
    else
		local file = enemy.files[UI.UserData[FileIKey]]:gsub("data/entities/",".../",1)
		UI.Text(0,0,GameTextGet("$conjurer_reborn_entwand_enemy_list_active",file))
		UI.VerticalSpacing(1)
		if #enemy.files == 1 then
			UI.NextColor(127, 127, 127, 255)
			UI.Text(0, 0, "$conjurer_reborn_entwand_enemy_list_desc_only")
        else
			UI.Text(0, 0, "$conjurer_reborn_entwand_enemy_list_desc")
		end
    end
	
	UI.VerticalSpacing(3)
	UI.NextColor(72, 209, 204, 255)
	local modName
	if enemy.from_id ~= "Noita" then
		modName = ModIdToName(enemy.from_id) or "?"
	else
		modName = "Noita"
	end
	UI.Text(0,0,modName)
end

local ActiveHoverEnemy = nil
local IsMain = false--这两个is参数用于判断主函数还是选择器的悬浮窗，确保不会发现窗口重叠问题
local IsPicker = false
local ActiveHoverX = 0
local ActiveHoverY = 0
---绘制敌人的悬浮窗
---@param UI Gui
---@param id string
local function EnemyTooltip(UI, id, MainFn)
    local _, _, hover, x, y = UI.WidgetInfo()
	if IsMain and MainFn == nil or IsPicker and MainFn ~= nil then
		return
	end
    local shift = InputIsKeyDown(Key_RSHIFT) or InputIsKeyDown(Key_LSHIFT)
    if hover and ActiveHoverEnemy == nil and shift then
		if MainFn then
            IsMain = true
        else
			IsPicker = true
		end
        ActiveHoverEnemy = id
        ActiveHoverX = x
		ActiveHoverY = y
    elseif ActiveHoverEnemy and not shift then
        ActiveHoverEnemy = nil
		IsMain = false
		IsPicker = false
    end
    if ActiveHoverEnemy and ActiveHoverEnemy == id then
        UI.BetterTooltipsNoCenter(function(isNoDraw)
            EnemyTooltipText(UI, id, isNoDraw, MainFn)
        end, UI.GetZDeep() - 10, 10, 3, nil, nil, true, ActiveHoverX, ActiveHoverY)
    else
		UI.BetterTooltipsNoCenter(function (isNoDraw)
			EnemyTooltipText(UI, id, isNoDraw, MainFn)
		end, UI.GetZDeep() - 10, 10, 3)
	end
end

---输入类型枚举量获得其对应的法术类型字符串
---@param type integer
---@return string
function SpellTypeEnumToStr(type)
	local TypeTable = {
		[ACTION_TYPE_PROJECTILE] = GameTextGetTranslatedOrNot("$inventory_actiontype_projectile"),
		[ACTION_TYPE_STATIC_PROJECTILE] = GameTextGetTranslatedOrNot("$inventory_actiontype_staticprojectile"),
		[ACTION_TYPE_MODIFIER] = GameTextGetTranslatedOrNot("$inventory_actiontype_modifier"),
		[ACTION_TYPE_DRAW_MANY] = GameTextGetTranslatedOrNot("$inventory_actiontype_drawmany"),
		[ACTION_TYPE_MATERIAL] = GameTextGetTranslatedOrNot("$inventory_actiontype_material"),
		[ACTION_TYPE_OTHER] = GameTextGetTranslatedOrNot("$inventory_actiontype_other"),
		[ACTION_TYPE_UTILITY] = GameTextGetTranslatedOrNot("$inventory_actiontype_utility"),
		[ACTION_TYPE_PASSIVE] = GameTextGetTranslatedOrNot("$inventory_actiontype_passive")
	}
    local result = TypeTable[type]
	if result ~= nil then
		return result
	end
	return "unknown"
end

---绘制法术的悬浮窗文本
---@param UI Gui
---@param id string
local function SpellTooltipText(UI, id)
    local spell = GetSpell(id)
    local name = GetEntNameOrKey(spell.name)
    UI.Text(0, 0, name)           --本地化名称显示
	
	UI.NextColor(127, 127, 127, 255) --id显示
    UI.Text(0, 0, id)

	local desc = GetEntNameOrKey(spell.description)
	UI.Text(0, 0, desc)--描述

    UI.NextColor(127, 127, 255, 255)--法术类型
    UI.Text(0, 0, SpellTypeEnumToStr(spell.type))
	
	UI.VerticalSpacing(3)
	UI.NextColor(72, 209, 204, 255)--所属模组
	local modName
	if spell.conjurer_unsafe_from_id ~= "Noita" then
		modName = ModIdToName(spell.conjurer_unsafe_from_id) or "?"
	else
		modName = "Noita"
	end
	UI.Text(0,0,modName)
end

---绘制天赋的悬浮窗文本
---@param UI Gui
---@param id string
local function PerkTooltipText(UI, id)
    local perk = GetPerk(id)
	local name = GetEntNameOrKey(perk.ui_name)
    UI.Text(0, 0, name)           --本地化名称显示
	
	UI.NextColor(127, 127, 127, 255) --id显示
    UI.Text(0, 0, id)

    local desc = GetEntNameOrKey(perk.ui_description)
    UI.Text(0, 0, desc) --描述显示
	
	UI.VerticalSpacing(3)
	UI.NextColor(72, 209, 204, 255)--所属模组
	local modName
	if perk.conjurer_unsafe_from_id ~= "Noita" then
		modName = ModIdToName(perk.conjurer_unsafe_from_id) or "?"
	else
		modName = "Noita"
	end
	UI.Text(0,0,modName)
end

---绘制实体选择框
---@param UI Gui
local function EntPicker(UI)
    local X = 30
    local Y = 58
	local refresh = false
    --渲染选择格
	if UI.UserData["EntWandPageSwitchIndex"] == nil then
		UI.UserData["EntWandPageSwitchIndex"] = 1
	end
    local SwitchIndex = UI.UserData["EntWandPageSwitchIndex"]
	UI.BeginHorizontal(X + 4, Y - 11, true, 4)
    for k, v in pairs(ALL_ENTITIES) do
		local thiskey = "EntWandPageTap" .. v.name
		GuiBeginAutoBox(UI.gui)--框住用的自动盒子
		local ThisIcon = v.icon_off
        local ThisBG = EntWandSpriteBG
        if SwitchIndex == k then
            ThisIcon = v.icon
			ThisBG = EntWandSpriteTab
        end
        UI.NextZDeep(1)
		local left = UI.ImageButton(thiskey .. "Btn",0,0, ThisIcon)
        if left then
            ClickSound()
            UI.UserData["EntWandPageSwitchIndex"] = k
            SwitchIndex = k
            refresh = true
        end
		UI.BetterTooltipsNoCenter(function ()
            UI.Text(0, 0, v.name)
			UI.VerticalSpacing(2)
			if v.desc then
				UI.Text(0, 0, v.desc)
			end
        end, UI.GetZDeep() - 10, 10, 3)

		UI.NextZDeep(0)
        GuiEndAutoBoxNinePiece(UI.gui, 0, 0, 0, false, 0, ThisBG)
	end
    UI.LayoutEnd()

    local list = ALL_ENTITIES[SwitchIndex].entities
	local return_keyword = ""
    local PageId = "EntWandPage" .. ALL_ENTITIES[SwitchIndex].name
	UI.NextZDeep(0)
    list, return_keyword = SearchInputBox(UI, "EntwandSearch", list, X + 30, Y + 215, 102.5, 0, refresh,
		function (item, keyword)
			local score
			keyword = keyword:lower()
            if ALL_ENTITIES[SwitchIndex].Type == EntityType.Enemy then
                local enemy = GetEnemy(item)
                local lowerName = GetEntNameOrKey(enemy.name):lower()
                score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
				local newScore = Cpp.AbsPartialPinyinRatio(item:lower(), keyword)--搜索id
                if newScore > score then
                    score = newScore
                end
                newScore = FromIdSearch(keyword, enemy.from_id)--搜索模组
				if newScore > score then
                    score = newScore
                end
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Perk then
                local perk = GetPerk(item)
                local lowerName = GetEntNameOrKey(perk.ui_name):lower()
                score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
				local newScore = Cpp.AbsPartialPinyinRatio(item:lower(), keyword)--搜索id
                if newScore > score then
                    score = newScore
                end
				newScore = FromIdSearch(keyword, perk.conjurer_unsafe_from_id)
				if newScore > score then
                    score = newScore
                end
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Spell then
                local spell = GetSpell(item)
				local lowerName = GetEntNameOrKey(spell.name):lower()--搜索名字
                score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
				local newScore = Cpp.AbsPartialPinyinRatio(item:lower(), keyword)--搜索id
                if newScore > score then
                    score = newScore
                end
				newScore = FromIdSearch(keyword, spell.conjurer_unsafe_from_id)
				if newScore > score then
                    score = newScore
                end
            else
                local lowerName = GetEntNameOrKey(item.name):lower()
				score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
			end
			return score
        end)
	if return_keyword ~= "" then
        PageId = PageId .. "Searched"
		UI.UserData["PageGridIndex"..PageId] = 1
	end
	PageGrid(UI, PageId,list,X,Y+10,160,200,9,10,EntWandSpriteBG,
		function(item, index)--回调执行表格操作
			UI.NextZDeep(0)
			local left
            if ALL_ENTITIES[SwitchIndex].Type == EntityType.Enemy then
                local enemy = GetEnemy(item)
                left = UI.ImageButton("EntIconEnemy" .. enemy.name .. index, 0, 0, enemy.png)
                EnemyTooltip(UI, item)
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Perk then
                local perk = GetPerk(item)
                left = UI.ImageButton("EntIconPerk" .. perk.id .. index, 0, 0, perk.perk_icon)
                UI.BetterTooltipsNoCenter(function()
                    PerkTooltipText(UI, item)
                end, UI.GetZDeep() - 10, 10, 3)
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Spell then
                local spell = GetSpell(item)
                left = UI.ImageButton("EntIconSpell" .. spell.id .. index, 0, 0, spell.sprite)
                UI.BetterTooltipsNoCenter(function()
                    SpellTooltipText(UI, item)
                end, UI.GetZDeep() - 10, 10, 3)
            else
                left = UI.ImageButton("EntIconOther" .. item.name .. index, 0, 0, item.image)
                UI.GuiTooltip(GetEntNameOrKey(item.name))
            end
			if left then
				SetActiveEntity(UI,SwitchIndex,index)
			end
        end
	)
end

local MainEntBtns = {
    {
		id = "entwand_entity_picker",
		name = "$conjurer_reborn_entwand_entity_picker",
        image_func = function(UI)
            return GetActiveEntityImg(UI)
		end,
        action = function()
			ToggleActiveOverlay(EntPicker)
		end,
        desc = function(UI)
            local item, index = GetActiveEntity(UI)
            local type = ALL_ENTITIES[index].Type
            if type == EntityType.Enemy then
                return
            elseif type == EntityType.Spell then
				SpellTooltipText(UI, item)
            elseif type == EntityType.Perk then
				PerkTooltipText(UI, item)
			else--都不符合
				UI.Text(0,0, item.name)
			end
		end
    },
	{
		id = "entwand_options",
		name = "$conjurer_reborn_entwand_options",
        image_func = function(UI)
			return "mods/conjurer_reborn/files/gfx/entwand_icons/icon_entity_staff_options.png"
		end,
        action = function()

		end,
        desc = function(UI)
			UI.Text(0,0,"$conjurer_reborn_entwand_options_desc")
		end
	},
    {
		id = "entwand_kill_entity",
		name = "$conjurer_reborn_entwand_kill_ent",
		image_func = function (UI)
			return "mods/conjurer_reborn/files/gfx/entwand_icons/icon_delete_entity.png"
		end,
        action = function()

		end,
        desc = function(UI)
			UI.Text(0,0,"$conjurer_reborn_entwand_kill_ent_desc")
		end
	},
}

---绘制左边的主按钮
---@param UI Gui
local function EntwandButtons(UI)
    UI.BeginVertical(7, 65, true, 2,2)
	GuiBeginAutoBox(UI.gui)--框住用的自动盒子
    for k, v in ipairs(MainEntBtns) do
        UI.NextZDeep(0)
        local left = UI.ImageButton(v.id, 0, 0, v.image_func(UI))
        if left then
            ClickSound()
            v.action()
        end
		if k == 1 then
            local item, index = GetActiveEntity(UI)
			if ALL_ENTITIES[index].Type == EntityType.Enemy then
				EnemyTooltip(UI,item,function ()
					UI.Text(0, 0, GameTextGet(v.name))--文本间隔
					UI.VerticalSpacing(3)
				end)
            else
				UI.BetterTooltipsNoCenter(function()
					UI.Text(0, 0, GameTextGet(v.name))--文本间隔
					UI.VerticalSpacing(3)
					v.desc(UI)
				end, UI.GetZDeep() - 10, 10, 3)
			end
        else
			UI.BetterTooltipsNoCenter(function()
				UI.Text(0, 0, GameTextGet(v.name))--文本间隔
				UI.VerticalSpacing(3)
				v.desc(UI)
			end, UI.GetZDeep() - 10, 10, 3)
		end
    end
	UI.NextZDeep(-10)
    GuiEndAutoBoxNinePiece(UI.gui, 1, 0, 0, false, 0, EntWandSpriteBG, EntWandSpriteBG)
    UI.ImageButton("MatPickerFavIcon", 2.5, 2, "mods/conjurer_reborn/files/gfx/fav_icon.png")
	UI.GuiTooltip("$conjurer_reborn_entwand_fav")
	UI.LayoutEnd()
end

---绘制Entwand的GUI
---@param UI Gui
function DrawEntWandGui(UI)
    EntwandButtons(UI)
	
	DrawActiveEntwandFn(UI)
end
