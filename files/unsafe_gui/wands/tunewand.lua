dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/tune_helper.lua")

---@type function|nil
local ActiveTunewandFn

---@param fn function
local function ToggleActiveOverlay(fn)
	ActiveTunewandFn = (ActiveTunewandFn ~= fn) and fn or nil
end

local function DrawActiveTunewandFn(UI)
	if ActiveTunewandFn then
		ActiveTunewandFn(UI)
	end
end

local TuneWandSpriteBG = "mods/conjurer_reborn/files/gfx/9piece_light.png"

local SpeChar = string.byte('@')

local ThisRunTextInputInit = false
local ActivelySwitch = false
local HoverID
local LastKeyword
---绘制状态选择栏
---@param UI Gui
local function StatusPicker(UI)
    local X = 30
    local Y = 64

    UI.NextZDeep(0)
    local _, textH = UI.TextDimensions("$conjurer_reborn_tunewand_status_effect")
    UI.Text(X + 2, Y - textH - 4 - 2,"$conjurer_reborn_tunewand_status_effect")

	UI.NextZDeep(0)
    local list, return_keyword = SearchInputBox(UI, "TunewandSearch", HasStatusEntityList, X + 30, Y + 205, 102.5, 0, false,
        function(item, keyword)
			keyword = keyword:lower()
            local Name = GetNameOrKey(item.ui_name) --搜索状态本地化名字
            if Name == "" then
                Name = item.id
            end
			local lowerName = Name:lower()
            --默认分数是0，分数最低下限也是0，那么第一次获取分数可以不用判断直接赋值
			--减少分支优化
			local score = Cpp.AbsPartialPinyinRatio(lowerName,keyword)

			local lowerId = item.id:lower()
            local newScore = Cpp.AbsPartialPinyinRatio(lowerId, keyword)--搜索状态id
            if newScore > score then
                score = newScore
            end
			local function GetEnName()
				return CSV.get(string.sub(item.ui_name,2), "en")
			end
			local flag, EnName = pcall(GetEnName)
			if flag and EnName then--判断英文原名
                newScore = Cpp.AbsPartialPinyinRatio(EnName:lower(), keyword)
				if newScore > score then
					score = newScore
				end
			end

            if string.byte(keyword, 1, 1) == SpeChar then --搜索模组id/模组名字
                local modId = item.conjurer_unsafe_from_id or "?"
                local lowerModId = modId:lower()
                newScore = Cpp.AbsPartialPinyinRatio(lowerModId, string.sub(keyword, 2):lower())
                if newScore > score then
                    score = newScore
                end
                local modName = ModIdToName(modId) --获取模组名字
                if modName then                    --对模组名字判空
                    newScore = Cpp.AbsPartialPinyinRatio(modName:lower(), string.sub(keyword, 2):lower())
                    if newScore > score then
                        score = newScore
                    end
                end
            end
			return score
        end)
    return_keyword = return_keyword or ""
    local PageId = "StatusPickerPage"
    if return_keyword ~= "" then
        PageId = PageId .. "Searched"
    end
    if return_keyword ~= "" and LastKeyword ~= return_keyword then
        LastKeyword = return_keyword
        UI.UserData["PageGridIndex" .. PageId] = 1
    elseif return_keyword == "" and LastKeyword then
        LastKeyword = nil
    end
    
    local entity = GetPlayerObj()

    local hasHover = false
    PageGrid(UI,PageId,list,X,Y,160,200,9,10,TuneWandSpriteBG,
        function(input)--回调执行表格操作
            UI.NextZDeep(1)
            local left, right = UI.ImageButton("TunewandStatusPicker" .. input.id, 0, 0, StatusIconTable[input.id])
            
            if entity then
                local CTRL = InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL)
                if left and CTRL then
                    EntityAddStains(entity, input.id)
                elseif left then
                    local amount = tonumber(UI.GetInputText("StatusEffectDurationInput")) or 16
                    amount = amount * 100
                    EntityAddEffect(entity, input.id, amount)
                end
                if right and CTRL then
                    entity:RemoveStainEffect(input.id)
                elseif right then
                    entity:RemoveIngestionEffect(input.id)
                end
            end


            local Info = UI.WidgetInfoTable()
            hasHover = Info.hovered or hasHover
            if Info.hovered and HoverID ~= input.id then--及时切换
                HoverID = input.id
                UI.UserData["StatusPickerDrawIndex"] = nil
                UI.UserData["StatusPickerDrawCount"] = nil
                ActivelySwitch = false
            end
            local ThisIndex
            if #StatusTable[input.id] > 1 and Info.hovered then--暂时切换显示机制
                if UI.UserData["StatusPickerDrawIndex"] == nil then
                    UI.UserData["StatusPickerDrawIndex"] = 1
                end

                ThisIndex = UI.UserData["StatusPickerDrawIndex"]
                if ThisIndex > #StatusTable[input.id] then--越界处理
                    ThisIndex = 1
                    UI.UserData["StatusPickerDrawIndex"] = 1
                elseif ThisIndex <= 0 then
                    ThisIndex = #StatusTable[input.id]
                    UI.UserData["StatusPickerDrawIndex"] = ThisIndex
                end

                local LArrow = InputIsKeyJustDown(Key_LEFT)
                local RArrow = InputIsKeyJustDown(Key_RIGHT)

                if LArrow or RArrow then
                    ActivelySwitch = true--后面和前面都有自动清理环节
                end

                if not ActivelySwitch then--自动切换
                    if UI.UserData["StatusPickerDrawCount"] == nil then
                        UI.UserData["StatusPickerDrawCount"] = 1
                    else
                        UI.UserData["StatusPickerDrawCount"] = UI.UserData["StatusPickerDrawCount"] + 1
                    end
    
                    if UI.UserData["StatusPickerDrawCount"] >= 75 then
                        UI.UserData["StatusPickerDrawCount"] = 1
                        UI.UserData["StatusPickerDrawIndex"] = UI.UserData["StatusPickerDrawIndex"] + 1
                    end
                else--主动切换
                    if LArrow then
                        UI.UserData["StatusPickerDrawIndex"] = UI.UserData["StatusPickerDrawIndex"] - 1
                    elseif RArrow then
                        UI.UserData["StatusPickerDrawIndex"] = UI.UserData["StatusPickerDrawIndex"] + 1
                    end
                end

            else
                ThisIndex = 1
            end
            local effect = StatusTable[input.id][ThisIndex]

            UI.BetterTooltipsNoCenter(function()
                UI.Text(0, 0, GetNameOrKey(effect.ui_name))

                UI.VerticalSpacing(1)
                UI.NextColor(127, 127, 127, 255)--id
                UI.Text(0, 0, string.format("%s - %d", effect.id, effect.conjurer_reborn_status_num_id))
                
                if StatusIconTable[input.id] == "mods/conjurer_reborn/files/gfx/unknown_status.png" then--隐藏的状态效果
                    UI.VerticalSpacing(1)
                    UI.NextColor(169, 169, 169, 255)
                    UI.Text(0, 0, "$conjurer_reborn_tunewand_hidden_status_effect")
                end

                if effect.is_harmful then
                    UI.VerticalSpacing(1)
                    UI.NextColor(255, 48, 48, 255)
                    UI.Text(0, 0, "$conjurer_reborn_tunewand_harmful_status_effect")
                end

                UI.VerticalSpacing(1)--描述
                UI.Text(0, 0, GetNameOrKey(effect.ui_description))

                if #StatusTable[effect.id] > 1 then--时长栏
                    UI.VerticalSpacing(1)
                    UI.BeginHorizontal(0, 0, true)
                    local thisTable = StatusTable[effect.id]
                    for i=1,#thisTable do
                        local RoundStr
                        local a_min = (thisTable[i].min_threshold_normalized or 0) * 60
                        if i == 1 then
                            local b_min = (thisTable[i + 1].min_threshold_normalized or 0) * 60
                            RoundStr = string.format("[0s, %ds)", b_min)
                        elseif i == #thisTable then
                            RoundStr = string.format("[%ds, +∞]", a_min)
                        else
                            local b_min = (thisTable[i + 1].min_threshold_normalized or 0) * 60
                            RoundStr = string.format("[%ds, %ds)", a_min, b_min)
                        end
                        
                        if i == ThisIndex then--当前选中的改变颜色
                            UI.NextColor(127, 127, 255, 255)
                        end
                        UI.Text(0, 0, RoundStr)
                        UI.HorizontalSpacing(1)
                    end
                    UI.LayoutEnd()
                end
                if effect.extra_status_00 then--额外状态效果支持
                    local ExtraStatus = StatusTable[effect.extra_status_00][1]
                    UI.BeginHorizontal(0, 0, true)
                    UI.Text(0, 0, "$conjurer_reborn_tunewand_extra_status_effect")
                    local ExtraInfo = UI.WidgetInfoTable()
                    UI.HorizontalSpacing(1)

                    UI.NextOption(GUI_OPTION.Layout_NoLayouting)
                    local extraw = GuiGetImageDimensions(UI.gui, StatusIconTable[effect.extra_status_00])
                    UI.Image("ExtraStatusImage", ExtraInfo.x + ExtraInfo.width, ExtraInfo.y - 2, StatusIconTable[effect.extra_status_00])

                    UI.HorizontalSpacing(1)
                    UI.Text(extraw - 5, 0, ExtraStatus.ui_name)
                    UI.HorizontalSpacing(1)

                    UI.NextColor(127, 127, 127, 255)
                    UI.Text(0, 0, string.format("(%s - %d)", effect.extra_status_00, ExtraStatus.conjurer_reborn_status_num_id))
                    UI.LayoutEnd()
                end

                local modName
                if effect.conjurer_unsafe_from_id ~= "Noita" then
                    modName = ModIdToName(effect.conjurer_unsafe_from_id) or "?"
                else
                    modName = "Noita"
                end
                UI.VerticalSpacing(2)
                UI.NextColor(72, 209, 204, 255)
                UI.Text(0, 0, modName)
            end, UI.GetZDeep() - 1000, 10, 3)
        end
    )
    if not hasHover then --不需要时清空
        UI.UserData["StatusPickerDrawIndex"] = nil
        UI.UserData["StatusPickerDrawCount"] = nil
        HoverID = nil
        ActivelySwitch = false
    end

    UI.NextZDeep(0)
    local _, textH = UI.TextDimensions("$conjurer_reborn_tunewand_status_effect_options")
    UI.Text(X + 175, Y - textH - 4 - 2,"$conjurer_reborn_tunewand_status_effect_options")

    UI.BeginVertical(X + 173, Y - 1, true, 2,2)
    GuiBeginAutoBox(UI.gui) --框住用的自动盒子
    
    UI.BeginHorizontal(0, 0, true)
    UI.NextZDeep(0)
    UI.Text(0, 0, "$conjurer_reborn_tunewand_status_effect_duration")
    UI.HorizontalSpacing(2)
    UI.NextZDeep(0)
    local inputNumStr = UI.TextInput("StatusEffectDurationInput", 0, 0, 80, -1, "16", "-0123456789")
    local inputInfo = UI.WidgetInfoTable()
    UI.GuiTooltip("$conjurer_reborn_tunewand_status_effect_duration_desc")
    if inputInfo.right_clicked then
        UI.TextInputRestore("StatusEffectDurationInput")
    end
    local inputNum = tonumber(inputNumStr)
    if inputNum == nil and not inputInfo.hovered then
        UI.TextInputRestore("StatusEffectDurationInput")
        inputNum = tonumber(UI.GetInputText("StatusEffectDurationInput"))
    end
    if inputNum then
        UI.NextZDeep(0)
        UI.NextColor(255, 222, 173, 255)
        UI.Text(-4,0,NumToWithSignStr(inputNum) .. "s")
    end
    UI.LayoutEnd()

    UI.NextZDeep(0)
    if UI.TextBtn("RemoveAllIngestStatus", 0, 0, "$conjurer_reborn_tunewand_remove_all_status_effect_ingest") then
        if entity then
            RemoveAllIngest(entity)
        end
    end

    UI.NextZDeep(0)
    if UI.TextBtn("RemoveAllStainStatus", 0,0,"$conjurer_reborn_tunewand_remove_all_status_effect_stain") then
        if entity then
            RemoveAllStain(entity)
        end
    end

    UI.NextZDeep(0)
    if UI.TextBtn("RemoveIngestSize", 0,0,"$conjurer_reborn_tunewand_remove_ingest_size") then
        if entity then
            SetZeroIngestSize(entity)
        end
    end

    local SetIngestFlag = ConjurerCheckbox(UI, "SetIngestCheckbox", 0,0,"$conjurer_reborn_tunewand_set_ingest_size",nil,false)
    if SetIngestFlag then
        UI.VerticalSpacing(2)
        UI.BeginHorizontal(0, 0, true)
        UI.NextZDeep(0)
        UI.Text(0, 0, "$conjurer_reborn_tunewand_set_ingest_size_input")
        UI.NextZDeep(0)

        UI.HorizontalSpacing(2)

        local NumStr = UI.TextInput("SetIngestSizeInput", 0, 0, 80, -1, "0", "0123456789")

        local SetIngestSizeInputInfo = UI.WidgetInfoTable()
        if SetIngestSizeInputInfo.right_clicked then
            UI.TextInputRestore("SetIngestSizeInput")
        end
        if not SetIngestSizeInputInfo.hovered then
            UI.SetInputText("SetIngestSizeInput", tostring(tonumber(NumStr) or 0))
        end

        if not ThisRunTextInputInit then
            UI.SetInputText("SetIngestSizeInput", WorldGlobalGet(UI, "GlobalSetIngestSizeInput", "0"))
            ThisRunTextInputInit = true
        else
            WorldGlobalSet(UI, "GlobalSetIngestSizeInput", UI.GetInputText("SetIngestSizeInput"))
        end

        UI.LayoutEnd()
    end


	UI.NextZDeep(-10)
    GuiEndAutoBoxNinePiece(UI.gui, 1, 90, 0, false, 0, TuneWandSpriteBG, TuneWandSpriteBG)
    local ButtonsBoxInfo = UI.WidgetInfoTable()
    InputBlockEasy(UI, "TunewandStatusButtons阻止框", ButtonsBoxInfo)

    UI.LayoutEnd()
end

local OrbList = {}
for i=0,11 do
    OrbList[#OrbList+1] = i
end
OrbList[#OrbList + 1] = 13

---玩家编辑器
---@param UI Gui
local function PlayerEditer(UI)
    local X = 30
    local Y = 64
    local player = GetPlayerObj()
    UI.NextZDeep(0)
    local _, textH = UI.TextDimensions("$conjurer_reborn_tunewand_player_edit")
    UI.Text(X + 2, Y - textH - 4 - 2,"$conjurer_reborn_tunewand_player_edit")

    UI.BeginVertical(X + 1, Y - 1, true, 2,2)
    GuiBeginAutoBox(UI.gui) --框住用的自动盒子

    if player.comp.DamageModelComponent then
        local DamageModelComp = player.comp.DamageModelComponent[1]
        local PlayerHPInputBox = {
            {
                text = "$conjurer_reborn_tunewand_hp",
                id = "PlayerHPEditor",
                w = 140,
                l = -1,
                thisNum = tostring(DamageModelComp.attr.hp * 25),
                defNum = tostring(DamageModelComp.attr.max_hp * 25),
                allowed_characters = "0123456789e.+-",
                action = function (input_num)
                    DamageModelComp.attr.hp = input_num / 25
                end
            },
            {
                text = "$conjurer_reborn_tunewand_max_hp",
                id = "PlayerMaxHPEditor",
                w = 140,
                l = -1,
                thisNum = tostring(DamageModelComp.attr.max_hp * 25),
                defNum = "100",
                allowed_characters = "0123456789e.+-",
                action = function (input_num)
                    DamageModelComp.attr.max_hp = input_num / 25
                end
            }
        }
        local PlayerHPTextOffset = 0
        for _,v in ipairs(PlayerHPInputBox) do--布局偏移计算
            local width = UI.TextDimensions(v.text)
            if width > PlayerHPTextOffset then
                PlayerHPTextOffset = width
            end
        end
        PlayerHPTextOffset = PlayerHPTextOffset + 2
        for _, v in ipairs(PlayerHPInputBox) do
            UI.BeginHorizontal(0, 0, true)
            UI.NextZDeep(0)
            UI.Text(0, 0, v.text)
            UI.HorizontalSpacing(2)
            UI.NextZDeep(0)
            local LastHoverKey = "Last" .. v.id .. "Hover"
            local ThisInitKey = v.id .. "Init"
            local defStr = "100"
            if not UI.UserData[ThisInitKey] then--初始化，防止重置玩家血量
                defStr = v.thisNum
                UI.UserData[ThisInitKey] = true
            else
                if not UI.UserData[LastHoverKey] then
                    UI.SetInputText(v.id, v.thisNum)
                end
            end
            local thisTextWidth = UI.TextDimensions(v.text)
            UI.TextInput(v.id, PlayerHPTextOffset - thisTextWidth, 0, v.w, v.l, defStr, v.allowed_characters)
            local thisInfo = UI.WidgetInfoTable()
            UI.UserData[LastHoverKey] = thisInfo.hovered
            if thisInfo.right_clicked then
                UI.SetInputText(v.id, v.defNum)
            end
            local NewStr = UI.GetInputText(v.id)
            local NewNum = tonumber(NewStr)
            if NewStr == "" then--如果什么输入都没有，重置成0
                NewNum = 0
            end
            if NewNum then
                v.action(NewNum)
            elseif NewNum == nil and not thisInfo.hovered then
                UI.SetInputText(v.id, v.defNum)
            end
            UI.LayoutEnd()
        end
    else
        UI.BeginHorizontal(0, 0, true)
        UI.NextZDeep(0)
        UI.Text(0, 0, "$conjurer_reborn_tunewand_hp")
        UI.HorizontalSpacing(2)
        UI.NextZDeep(0)
        UI.NextColor(127, 127, 127, 255)
        UI.Text(0,0,"$conjurer_reborn_tunewand_n_a")
        UI.LayoutEnd()
    end

    UI.BeginHorizontal(0, 0, true)
    UI.NextZDeep(0)
    UI.Text(0, 0, "$conjurer_reborn_tunewand_gold")

    UI.HorizontalSpacing(2)
    if player.comp.WalletComponent then
        UI.NextZDeep(0)
        local money = player.comp.WalletComponent[1].attr.money
        local GoldInitKey = "GoldInputInit"
        local defGold = "0"
        if UI.UserData[GoldInitKey] == nil then
            defGold = tostring(money)
            UI.UserData[GoldInitKey] = true
        end
        if not UI.UserData["LastGoldInputHover"] and UI.UserData[GoldInitKey] then
            UI.SetInputText("PlayerGoldEditorInput", tostring(money))
        end
        local moneyStr = UI.TextInput("PlayerGoldEditorInput", 0, 0, 85, -1, defGold, "0123456789")

        local GoldInputInfo = UI.WidgetInfoTable()
        if GoldInputInfo.right_clicked then
            UI.SetInputText("PlayerGoldEditorInput", defGold)
            moneyStr = "0"
        end
        UI.UserData["LastGoldInputHover"] = GoldInputInfo.hovered
        local newMoney = tonumber(moneyStr) or 0 --设置或重置为0
        newMoney = math.min(newMoney, Int32Max)--上界检查
        player.comp.WalletComponent[1].attr.money = newMoney
        if player.comp.InventoryGuiComponent then
            player.comp.InventoryGuiComponent[1].attr.wallet_money_target = newMoney
            if newMoney < Int32Max then--上界检查，如果试图改成更小的自动关闭无限钱
                player.comp.WalletComponent[1].attr.mHasReachedInf = false
            end
        end
        
        UI.LayoutEnd()
        UI.UserData["InfGoldEditerStatus"] = player.comp.WalletComponent[1].attr.mHasReachedInf
        local enable,click = ConjurerCheckboxNoSave(UI, "InfGoldEditer", 0, 0, "$conjurer_reborn_tunewand_inf_gold",nil,false)
        if click then
            player.comp.WalletComponent[1].attr.mHasReachedInf = enable
        end
    else
        UI.NextZDeep(0)
        UI.NextColor(127, 127, 127, 255)
        UI.Text(0,0,"$conjurer_reborn_tunewand_n_a")
        UI.LayoutEnd()
    end

    if player.comp.CharacterDataComponent then--无限飞行
        UI.VerticalSpacing(2)
        local CharacterDataComponent = player.comp.CharacterDataComponent[1]
        UI.UserData["InfFlyEditerStatus"] = not CharacterDataComponent.attr.flying_needs_recharge
        local enable,click = ConjurerCheckboxNoSave(UI, "InfFlyEditer", 0, 0, "$conjurer_reborn_tunewand_inf_fly",nil,true)
        if click then
            CharacterDataComponent.attr.flying_needs_recharge = not enable
        end
    end

    UI.VerticalSpacing(2)
    UI.NextZDeep(0)
    local RemovePerkClick = UI.TextBtn("IMPLRemovePerks",0,0,"$conjurer_reborn_tunewand_remove_all_perks")
    local RemovePerkInfo = UI.WidgetInfoTable()
    if not RemovePerkInfo.hovered then--经典的确认实现（
        UI.UserData["RemovePerkConfirm"] = false
    end
    local RemovePerkTooltip = "$conjurer_reborn_tunewand_remove_all_perks_desc"
    if UI.UserData["RemovePerkConfirm"] then
        RemovePerkTooltip = "$conjurer_reborn_reset_IKnowWhatImDoing"
    end
    if RemovePerkClick then
        if UI.UserData["RemovePerkConfirm"] then
            UI.UserData["RemovePerkConfirm"] = false
            IMPL_remove_all_perks(player.entity_id)
        else
            UI.UserData["RemovePerkConfirm"] = true
        end
    end
    UI.GuiTooltip(RemovePerkTooltip)

    UI.VerticalSpacing(2)
    UI.NextZDeep(0)
    UI.Text(0, 0, "$conjurer_reborn_tunewand_orb")

    UI.BeginHorizontal(0, 0, true)
    local WorldModes = {
        {
            id = "WestOrbMode",
            text = "$conjurer_reborn_tunewand_west",
            key = "west"
        },
        {
            id = "OverworldOrbMode",
            text = "$conjurer_reborn_tunewand_overworld",
            key = "over"
        },
        {
            id = "EastOrbMode",
            text = "$conjurer_reborn_tunewand_east",
            key = "east"
        }
    }

    local OrbMode = UI.UserData["OrbWorldMode"]
    if OrbMode == nil then
        OrbMode = "over"
        UI.UserData["OrbWorldMode"] = OrbMode
    end

    for _,v in ipairs(WorldModes) do
        UI.NextZDeep(0)
        UI.HorizontalSpacing(1)
        if OrbMode == v.key then
            UI.NextColor(127, 127, 255, 255)
        end
        if UI.TextBtn(v.id, 0,0,v.text) then
            UI.UserData["OrbWorldMode"] = v.key
        end
    end
    UI.LayoutEnd()

    UI.BeginHorizontal(0,0,true)
    local toOrbId
    if OrbMode == "west" then
        toOrbId = ToWestOrbID
    elseif OrbMode == "east" then
        toOrbId = ToEastOrbID
    else
        toOrbId = function(...)
            return ...
        end
    end
    local ThisGUIOrbs = {}
    local FoundOrbTable = GetCurrentOrbTable()
    for IdIndex, i in ipairs(OrbList) do
        if IdIndex == 7 then
            UI.LayoutEnd()
            UI.BeginHorizontal(0,0,true)
        end
        local Orbid = toOrbId(i)
        ThisGUIOrbs[#ThisGUIOrbs+1] = Orbid
        UI.NextZDeep(0)
        if FoundOrbTable[Orbid] then
            UI.NextColor(127, 127, 255, 255)
        end
        local left, right = UI.TextBtn(("OrbPicker%d"):format(Orbid), 0, 0, ("[%.2d]"):format(Orbid))
        UI.GuiTooltip("$conjurer_reborn_tunewand_orb_choose_desc")
        if FoundOrbTable[Orbid] == nil and left then
            AddOrb(Orbid)
            OrbSound()
        end
        if right then
            RemoveOrb(Orbid)
            ClickSound()
        end
    end
    UI.LayoutEnd()
    UI.BeginHorizontal(0, 0, true)
    UI.NextZDeep(0)
    if UI.TextBtn("OrbSelectAll", 0, 0, "$conjurer_reborn_tunewand_select_all") then
        AddOrbFromList(ThisGUIOrbs)
        OrbSound()
    end
    UI.HorizontalSpacing(1)
    UI.NextZDeep(0)
    if UI.TextBtn("OrbSelectNone",0,0, "$conjurer_reborn_tunewand_select_none") then
        RemoveOrbFromList(ThisGUIOrbs)
    end

    UI.LayoutEnd()


    UI.NextZDeep(-10)
    GuiEndAutoBoxNinePiece(UI.gui, 1, 110, 0, false, 0, TuneWandSpriteBG, TuneWandSpriteBG)
    local ButtonsBoxInfo = UI.WidgetInfoTable()
    InputBlockEasy(UI, "TunewandEditorButtons阻止框", ButtonsBoxInfo)

    UI.LayoutEnd()
end

local MainTuneBtns = {
    {
        id = "tune_status_effect_picker",
        name = "$conjurer_reborn_tunewand_status_effect_picker",
        image = "mods/conjurer_reborn/files/gfx/tunewand_icons/status_effect_icon.png",
        action = function ()
            ToggleActiveOverlay(StatusPicker)
        end,
    },
    {
        id = "tune_player_edit_options",
        name = "$conjurer_reborn_tunewand_player_edit",
        image = "mods/conjurer_reborn/files/gfx/tunewand_icons/player_edit.png",
        action = function()
            ToggleActiveOverlay(PlayerEditer)
        end,
    },
}

---绘制左边的主按钮
---@param UI Gui
local function TunewandButtons(UI)
    UI.BeginVertical(7, 65, true, 2,2)
	GuiBeginAutoBox(UI.gui)--框住用的自动盒子
    for _, v in ipairs(MainTuneBtns) do
        UI.NextZDeep(0)
        local left = UI.ImageButton(v.id, 0, 0, v.image)
        UI.GuiTooltip(v.name)
        if left then
			ClickSound()
            v.action()
        end
    end
	UI.NextZDeep(-10)
    GuiEndAutoBoxNinePiece(UI.gui, 1, 0, 0, false, 0, TuneWandSpriteBG, TuneWandSpriteBG)

    local ButtonsBoxInfo = UI.WidgetInfoTable()
    InputBlockEasy(UI, "TunewandButtons阻止框", ButtonsBoxInfo)
    
    UI.LayoutEnd()
end

---绘制Matwand的GUI
---@param UI Gui
function DrawTuneWandGui(UI)
    if GetPlayer() == nil or GameIsInventoryOpen() then
		return
	end
    TunewandButtons(UI)
    DrawActiveTunewandFn(UI)
end
