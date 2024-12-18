dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_helper.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_reticle_entity.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_draw.lua")
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

local SpeChar = string.byte('@')

---简化的id搜索流程
---@param keyword string
---@param id string
---@return number
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
    local name = GetNameOrKey(enemy.name)
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
	local HasHover = false
    UI.VerticalSpacing(3)
    if shift and #enemy.files > 1 then
        for i, v in ipairs(enemy.files) do
			local file = v:gsub("data/entities/",".../",1)
			UI.BeginHorizontal(0,0,true,0,0)
            UI.Text(0, 0, file)
            local _, _, hover = UI.WidgetInfo()
			HasHover = hover or HasHover

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
        UI.Text(0, 0, GameTextGet("$conjurer_reborn_entwand_enemy_list_active", file))
        local _, _, hover = UI.WidgetInfo()
        HasHover = hover or HasHover
		
		UI.VerticalSpacing(1)
		if #enemy.files == 1 then
			UI.NextColor(127, 127, 127, 255)
			UI.Text(0, 0, "$conjurer_reborn_entwand_enemy_list_desc_only")
        else
			UI.Text(0, 0, "$conjurer_reborn_entwand_enemy_list_desc")
		end
    end
	if HasHover then--如果悬浮到文件文本，自动切换选择的实体
		local Active,cindex = GetActiveEntity(UI)
		if Active ~= id or ALL_ENTITIES[cindex].Type ~= EntityType.Enemy then--第二个是防重名情况
			local true_index = ALL_ENTITIES[1].conjurer_reborn_index_table[id]
			SetActiveEntity(UI, 1, true_index)
			ClickSound()
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

local HasActive = false
local ActiveHoverX = 0
local ActiveHoverY = 0
---绘制敌人的悬浮窗
---@param UI Gui
---@param id string
---@param index integer 多例实现用
---@param MainFn function? 给主函数开放的特别函数，用于在前面加上选择实体的文本
local function EnemyTooltip(UI, id, index, MainFn)
    local _, _, hover, x, y = UI.WidgetInfo()
    local ActiveKey = "EntWandActiveHoverEnemy" .. tostring(index)--多例实现，通过索引区分不同的情况
    local thisActive = UI.UserData[ActiveKey]
	if HasActive and thisActive == nil then
		return
	end
    local shift = InputIsKeyDown(Key_RSHIFT) or InputIsKeyDown(Key_LSHIFT)
	if not shift and thisActive then
		UI.UserData[ActiveKey] = nil--清空状态
        HasActive = false
		if not hover then--非悬浮状态下少渲染一帧，提升观感，悬浮状态下不禁止渲染悬浮窗，为了连贯性
			return
		end
	end
    if hover and thisActive == nil and shift then
        UI.UserData[ActiveKey] = true
        HasActive = true
        ActiveHoverX = x
		ActiveHoverY = y
    end
    if thisActive then--固定悬浮窗的调用
        UI.BetterTooltipsNoCenter(function(isNoDraw)
            EnemyTooltipText(UI, id, isNoDraw, MainFn)
        end, UI.GetZDeep() - 1000, 10, 3, nil, nil, true, ActiveHoverX, ActiveHoverY)
    else
		UI.BetterTooltipsNoCenter(function (isNoDraw)
			EnemyTooltipText(UI, id, isNoDraw, MainFn)
		end, UI.GetZDeep() - 1000, 10, 3)
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
    local name = GetNameOrKey(spell.name)
    UI.Text(0, 0, name)           --本地化名称显示
	
	UI.NextColor(127, 127, 127, 255) --id显示
    UI.Text(0, 0, id)

	local desc = GetNameOrKey(spell.description)
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
	local name = GetNameOrKey(perk.ui_name)
    UI.Text(0, 0, name)           --本地化名称显示
	
	UI.NextColor(127, 127, 127, 255) --id显示
    UI.Text(0, 0, id)

    local desc = GetNameOrKey(perk.ui_description)
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

local favItems
local favStr = ModSettingGet(ModID .. "EntWandFav")
if favStr == nil then
	favItems = {}
else
	local str = loadstring(favStr)
	if str ~= nil then
		favItems = str()
	else
		favItems = {}
	end
end

local function SavedFavToSetting()
	ModSettingSet(ModID.."EntWandFav", "return {"..SerializeTable(favItems).."}")
end

---增加收藏
---@param type string
---@param c_index integer
---@param ItemOrIndex string|integer
local function AddFav(type, c_index, ItemOrIndex)
	local temp = {
        Type = type,
        c_index = c_index,
        item = ItemOrIndex,
    }
	if type == EntityType.Other then
		temp.name = ALL_ENTITIES[c_index].entities[ItemOrIndex].name
	end
	table.insert(favItems, temp)
	SavedFavToSetting()
end

---绘制收藏格
---@param UI Gui
local function DrawFav(UI)
    local OnceRemove = false
	local NoHasItem = false
	local count = -0x7FFFFFFF
    VerticalPage(UI, "EntWandFavVerticalPage", favItems, 6, 138, 0, 0, 9, EntWandSpriteBG, function(value, index)
		UI.NextZDeep(0)
        local left
		local right
		if value.Type == EntityType.Enemy then
            local enemy = GetEnemy(value.item)
			if enemy == nil then
				NoHasItem = true
            else
				left, right = UI.ImageButton("FavEntIconEnemy" .. enemy.name .. index, 0, 0, enemy.png)
				EnemyTooltip(UI, value.item, count)
			end
		elseif value.Type == EntityType.Perk then
            local perk = GetPerk(value.item)
			if perk == nil then
                NoHasItem = true
            else
				left, right = UI.ImageButton("FavEntIconPerk" .. perk.id .. index, 0, 0, perk.perk_icon)
				UI.BetterTooltipsNoCenter(function()
					PerkTooltipText(UI, value.item)
				end, UI.GetZDeep() - 1000, 10, 3)
			end
		elseif value.Type == EntityType.Spell then
            local spell = GetSpell(value.item)
			if spell == nil then
				NoHasItem = true
            else
				left, right = UI.ImageButton("FavEntIconSpell" .. spell.id .. index, 0, 0, spell.sprite)
				UI.BetterTooltipsNoCenter(function()
					SpellTooltipText(UI, value.item)
				end, UI.GetZDeep() - 1000, 10, 3)
			end
        else
            local item = ALL_ENTITIES[value.c_index].entities[value.item]
			if item.name ~= value.name then
				NoHasItem = true
            else
				left, right = UI.ImageButton("FavEntIconOther" .. item.name .. index, 0, 0, item.image)
				UI.GuiTooltip(GetNameOrKey(item.name))
			end
		end
        if left then
			ClickSound()
			if value.Type ~= EntityType.Other then
				local true_index = ALL_ENTITIES[value.c_index].conjurer_reborn_index_table[value.item]
                SetActiveEntity(UI, value.c_index, true_index)
            else
				SetActiveEntity(UI, value.c_index, value.item)
			end
		end
        count = count + 1
		if right then
			ClickSound()
		end
		if (right or NoHasItem) and not OnceRemove then--异步执行删除
			OnceRemove = true
			UI.OnceCallOnExecute(function ()
                table.remove(favItems, index)
				SavedFavToSetting()
            end)
		end
	end)
end

local LastKeyword
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
        end, UI.GetZDeep() - 1000, 10, 3)

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
                local lowerName = GetNameOrKey(enemy.name):lower()
                score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
				local newScore = Cpp.AbsPartialPinyinRatio(item:lower(), keyword)--搜索id
                if newScore > score then
                    score = newScore
                end
                local EnName = CSV.get(string.sub(enemy.name, 2), "en")
				if EnName then
					local EnLowerName = EnName:lower()
					newScore = Cpp.AbsPartialPinyinRatio(EnLowerName, keyword)
                    if newScore > score then
                        score = newScore
                    end
                    EnLowerName = Cpp.FinnishToEnLower(EnLowerName)
					newScore = Cpp.AbsPartialPinyinRatio(EnLowerName, keyword)
                    if newScore > score then
                        score = newScore
                    end
				end
                newScore = FromIdSearch(keyword, enemy.from_id)--搜索模组
				if newScore > score then
                    score = newScore
                end
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Perk then
                local perk = GetPerk(item)
                local lowerName = GetNameOrKey(perk.ui_name):lower()
                score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
				local newScore = Cpp.AbsPartialPinyinRatio(item:lower(), keyword)--搜索id
                if newScore > score then
                    score = newScore
                end
				local EnName = CSV.get(string.sub(perk.ui_name, 2), "en")
				if EnName then
					newScore = Cpp.AbsPartialPinyinRatio(EnName:lower(), keyword)
					if newScore > score then
						score = newScore
					end
				end
				newScore = FromIdSearch(keyword, perk.conjurer_unsafe_from_id)
				if newScore > score then
                    score = newScore
                end
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Spell then
                local spell = GetSpell(item)
				local lowerName = GetNameOrKey(spell.name):lower()--搜索名字
                score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
				local newScore = Cpp.AbsPartialPinyinRatio(item:lower(), keyword)--搜索id
                if newScore > score then
                    score = newScore
                end
				local EnName = CSV.get(string.sub(spell.name, 2), "en")
				if EnName then
					newScore = Cpp.AbsPartialPinyinRatio(EnName:lower(), keyword)
					if newScore > score then
						score = newScore
					end
				end
				newScore = FromIdSearch(keyword, spell.conjurer_unsafe_from_id)
				if newScore > score then
                    score = newScore
                end
            else
                local lowerName = GetNameOrKey(item.name):lower()
				score = Cpp.AbsPartialPinyinRatio(lowerName, keyword)
			end
			return score
        end)
	if return_keyword ~= "" then
		PageId = PageId .. "Searched"
	end
    if return_keyword ~= "" and LastKeyword ~= return_keyword then
        LastKeyword = return_keyword
        UI.UserData["PageGridIndex" .. PageId] = 1
    elseif return_keyword == "" and LastKeyword then
        LastKeyword = nil
    end
	PageGrid(UI, PageId,list,X,Y+10,160,200,9,10,EntWandSpriteBG,
		function(item, index)--回调执行表格操作
			UI.NextZDeep(0)
			local left, right
            if ALL_ENTITIES[SwitchIndex].Type == EntityType.Enemy then
                local enemy = GetEnemy(item)
                left, right = UI.ImageButton("EntIconEnemy" .. enemy.name .. index, 0, 0, enemy.png)
                EnemyTooltip(UI, item, index)
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Perk then
                local perk = GetPerk(item)
                left, right = UI.ImageButton("EntIconPerk" .. perk.id .. index, 0, 0, perk.perk_icon)
                UI.BetterTooltipsNoCenter(function()
                    PerkTooltipText(UI, item)
                end, UI.GetZDeep() - 1000, 10, 3)
            elseif ALL_ENTITIES[SwitchIndex].Type == EntityType.Spell then
                local spell = GetSpell(item)
                left, right = UI.ImageButton("EntIconSpell" .. spell.id .. index, 0, 0, spell.sprite)
                UI.BetterTooltipsNoCenter(function()
                    SpellTooltipText(UI, item)
                end, UI.GetZDeep() - 1000, 10, 3)
            else
                left, right = UI.ImageButton("EntIconOther" .. item.name .. index, 0, 0, item.image)
                UI.GuiTooltip(GetNameOrKey(item.name))
            end
            if left then
                local true_index = ALL_ENTITIES[SwitchIndex].conjurer_reborn_index_table[item]
                SetActiveEntity(UI, SwitchIndex, true_index)
            end
            if right then
                if ALL_ENTITIES[SwitchIndex].Type == EntityType.Other then
                    local true_index = ALL_ENTITIES[SwitchIndex].conjurer_reborn_index_table[item]
                    AddFav(ALL_ENTITIES[SwitchIndex].Type, SwitchIndex, true_index)
                else
                    AddFav(ALL_ENTITIES[SwitchIndex].Type, SwitchIndex, item)
                end
				ClickSound()
			end
        end
	)
end

---特化的，可以对齐的滑条
---@param UI Gui
---@param id string
---@param x number
---@param y number
---@param text string
---@param value_min number
---@param value_max number
---@param value_default number
---@param width number
---@param savedValue number
---@return number
local function EntSlider(UI, id, x, y, text, value_min, value_max, value_default, width, savedValue)
	local Align = 0--对齐位置
	local desc = text.."_desc"--特化的，都满足这么个条件，所以可以少传参数
    ---因为是特化的，所以我们在这里计算最大对齐宽度
    local BigestWidth = GuiGetTextDimensions(UI.gui, GameTextGet("$conjurer_reborn_entwand_options_row"))
    local new = GuiGetTextDimensions(UI.gui, GameTextGet("$conjurer_reborn_entwand_options_col"))
    if new > BigestWidth then
        BigestWidth = new
    end
    new = GuiGetTextDimensions(UI.gui, GameTextGet("$conjurer_reborn_entwand_options_grid"))
    if new > BigestWidth then
        BigestWidth = new
    end
	Align = BigestWidth + 2
    return SameWidthSlider(UI, id, Align, x, y, text, value_min, value_max, value_default, width, desc, savedValue)
end

---实体法杖设置选项
---@param UI Gui
local function EntOptions(UI)
	local X = 30
    local Y = 66
	
	UI.NextZDeep(0)
	UI.Text(X + 2, Y-19, GameTextGet("$conjurer_reborn_entwand_options_head"))
    UI.ScrollContainer("EntOptionsBox", X, Y - 2, 0, 0, 2, 2) --自动宽高
    UI.AddAnywhereItem("EntOptionsBox", function()
        UI.NextZDeep(0)
		UI.NextColor(155, 173, 183, 255)
        UI.Text(0, 0, "$conjurer_reborn_entwand_options_spawning")
		
		UI.VerticalSpacing(2)
        local HoldingFlag, HoldingClick = ConjurerCheckbox(UI, "EntWandHoldingSpawn", 0, 0, "$conjurer_reborn_entwand_options_holding")
		UI.GuiTooltip("$conjurer_reborn_entwand_options_holding_desc")
        if HoldingClick then
            SetEntWandHoldSpawn(UI, HoldingFlag)
        end
		UI.VerticalSpacing(2)
		
		local RowValue = EntSlider(UI, "EntWandRowSlider",0,0,"$conjurer_reborn_entwand_options_row",1,50,1,100,GetEntWandRows(UI))
        SetEntWandRows(UI, RowValue)

		UI.VerticalSpacing(1)
		local ColValue = EntSlider(UI, "EntWandColSlider",0,0,"$conjurer_reborn_entwand_options_col",1,50,1,100,GetEntWandCols(UI))
        SetEntWandCols(UI, ColValue)

		UI.VerticalSpacing(1)
		local GridValue = EntSlider(UI, "EntWandGridSlider",0,0,"$conjurer_reborn_entwand_options_grid",1,50,1,100,GetEntWandGridSize(UI))
        SetEntWandGridSize(UI, GridValue)

		UI.VerticalSpacing(6)
		UI.NextZDeep(0)
		UI.NextColor(155, 173, 183, 255)
        UI.Text(0, 0, "$conjurer_reborn_entwand_options_deleting")
        UI.VerticalSpacing(2)
		
		UI.VerticalSpacing(2)
        local KillFlag, KillClick = ConjurerCheckbox(UI, "EntWandKill", 0, 0, "$conjurer_reborn_entwand_options_kill")
		UI.GuiTooltip("$conjurer_reborn_entwand_options_kill_desc")
        if KillClick then
            SetEntWandKillInstead(UI, KillFlag)
        end

		UI.VerticalSpacing(2)
        local HoldDeleteFlag, HoldDeleteClick = ConjurerCheckbox(UI, "EntWandHoldDelete", 0, 0, "$conjurer_reborn_entwand_options_holding_delete")
		UI.GuiTooltip("$conjurer_reborn_entwand_options_holding_delete_desc")
        if HoldDeleteClick then
            SetEntWandHoldDelete(UI, HoldDeleteFlag)
        end

		UI.VerticalSpacing(2)
        local DeleteMultipleFlag, DeleteMultipleClick = ConjurerCheckbox(UI, "EntWandDeleteMultiple", 0, 0, "$conjurer_reborn_entwand_options_delete_multiple")
		UI.GuiTooltip("$conjurer_reborn_entwand_options_delete_multiple_desc")
        if DeleteMultipleClick then
            SetEntWandDeleteAll(UI, DeleteMultipleFlag)
        end

		UI.VerticalSpacing(2)
        local NotDeBGFGFlag, NotDeBGFGClick = ConjurerCheckbox(UI, "EntWandNotDeBGFG", 0, 0, "$conjurer_reborn_entwand_options_not_delete_bg_fg")
		UI.GuiTooltip("$conjurer_reborn_entwand_options_not_delete_bg_fg_desc")
        if NotDeBGFGClick then
            SetEntWandIgnoreBG(UI, NotDeBGFGFlag)
        end

		UI.VerticalSpacing(6)
		UI.NextZDeep(0)
		UI.NextColor(155, 173, 183, 255)
        UI.Text(0, 0, "$conjurer_reborn_entwand_options_other")
        UI.VerticalSpacing(2)

		UI.VerticalSpacing(2)
        local GoldFlag, GoldClick = ConjurerCheckbox(UI, "EntWandGoldDrop", 0, 0, "$conjurer_reborn_entwand_options_gold_drop")
		UI.GuiTooltip("$conjurer_reborn_entwand_options_gold_drop_desc")
        if GoldClick then
            SetDropGold(GoldFlag)
        end
    end)
	
	UI.DrawScrollContainer("EntOptionsBox", false, true, EntWandSpriteBG)
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
			ToggleActiveOverlay(EntOptions)
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
        action = function()--不执行，纯属提示

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
				EnemyTooltip(UI,item, -1,function ()
					UI.Text(0, 0, v.name)--文本间隔
					UI.VerticalSpacing(3)
				end)
            else
				UI.BetterTooltipsNoCenter(function()
					UI.Text(0, 0, v.name)--文本间隔
					UI.VerticalSpacing(3)
					v.desc(UI)
				end, UI.GetZDeep() - 1000, 10, 3)
			end
        else
			UI.BetterTooltipsNoCenter(function()
				UI.Text(0, 0, v.name)--文本间隔
				UI.VerticalSpacing(3)
				v.desc(UI)
			end, UI.GetZDeep() - 1000, 10, 3)
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
	EnabledReticle(UI, true)
    EntEntityUpdate(UI)
	if GetPlayer() == nil or GameIsInventoryOpen() then
		return
	end
    EntwandButtons(UI)
	DrawFav(UI)
	DrawActiveEntwandFn(UI)
end
