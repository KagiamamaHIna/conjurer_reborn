---@type Gui
local UI = dofile("mods/conjurer_reborn/files/unsafe/gui.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/SearchForList.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")

CSV = ParseCSV(ModTextFileGetContent("data/translations/common.csv"))

--GUI加载
dofile_once("mods/conjurer_reborn/files/unsafe_gui/wands/matwand.lua")  --材料法杖
dofile_once("mods/conjurer_reborn/files/unsafe_gui/wands/entwand.lua")  --实体法杖
dofile_once("mods/conjurer_reborn/files/unsafe_gui/wands/editwand.lua") --编辑法杖
dofile_once("mods/conjurer_reborn/files/unsafe_gui/wands/tunewand.lua") --编辑法杖
dofile_once("mods/conjurer_reborn/files/unsafe_gui/bottom.lua")         --底部按钮

---@type table|nil
local ActiveTable

---@param t table
local function ToggleActiveOverlay(t)
	if ActiveTable then
		ActiveTable.release()
	end
	ActiveTable = (ActiveTable ~= t) and t or nil
	if ActiveTable then
		ActiveTable.active()
	end
end

local function SwitchActive(t)
	if t and t ~= ActiveTable then
		if ActiveTable then
			ActiveTable.release()
		end
		ActiveTable = t
		ActiveTable.active()
	end
end

local BtnX = 20
local BtnY = 7.5

local ActiveImage

local MainBtns = {
	{
		name = "$conjurer_reborn_wand_matwand",
		desc = "$conjurer_reborn_wand_matwand_desc",
		id = "MatWandBtn",
		image = "mods/conjurer_reborn/files/wands/matwand/matwand.png",
		action = DrawMatWandGui,
		active = function()
			EnabledBrushes(UI, true)
		end,
		release = function()
			EnabledBrushes(UI, false)
		end,
		index = 1
	},
	{
		name = "$conjurer_reborn_wand_entwand",
		desc = "$conjurer_reborn_wand_entwand_desc",
		id = "EntWandBtn",
		image = "mods/conjurer_reborn/files/wands/entwand/entwand.png",
		action = DrawEntWandGui,
		active = function()
			EnabledReticle(UI, true)
		end,
		release = function()
			EnabledReticle(UI, false)
			local cursor = EntityGetWithName("conjurer_reborn_entwand_cursor") --删除光标标记实体
			if cursor and cursor ~= 0 then
				EntityKill(cursor)
			end
		end,
		index = 2
	},
	{
		name = "$conjurer_reborn_wand_editwand",
		desc = "$conjurer_reborn_wand_editwand_desc",
		id = "EditWandBtn",
		image = "mods/conjurer_reborn/files/wands/editwand/editwand.png",
		action = DrawEditWandGui,
		active = function()
			local entity = UI.UserData["EditWandEntityToInspectEntity"]
			if entity and EntityGetIsAlive(entity) then
				EntityLoadChild(entity, "mods/conjurer_reborn/files/wands/editwand/re_selected_indicator.xml")
			end
		end,
		release = function()
			local cursor = EntityGetWithName("conjurer_reborn_editwand_cursor") --删除光标标记实体
			if cursor and cursor ~= 0 then
				EntityKill(cursor)
			end
			local indicator = EntityGetWithName("conjurer_reborn_editwand_indicator")
			if indicator and indicator ~= 0 then
				EntityKill(indicator)
			end
		end,
		index = 3
    },
	{
		name = "$conjurer_reborn_wand_tunewand",
		desc = "$conjurer_reborn_wand_tunewand_desc",
		id = "TuneWandBtn",
		image = "mods/conjurer_reborn/files/wands/tunewand/tunewand.png",
		action = DrawTuneWandGui,
		active = function()

		end,
		release = function()
		end,
		index = 4
	}
}

UI.OnceCallOnExecute(function() --尝试移除
	for _, v in pairs(MainBtns) do
		v.release()
	end
end)

local ItemSwitch = false

local function RefreshSwitchWand()
	local CurrentActive = GetActiveItem()
	if ItemSwitch and ActiveTable and CurrentActive ~= -1 then --最后决定切换等操作
		ItemSwitch = false
		ActiveTable.release()
		ActiveTable = nil
	end
end

UI.MainTickFn["Main"] = function()
	UI.OnceCallOnExecute(function ()
		UI.UserData["HasInputBoxHover"] = nil
	end)
	if UI.UserData["EditWandEntityToInspectEntity"] == nil then --每帧尝试移除一次
		local indicator = EntityGetWithName("conjurer_reborn_editwand_indicator")
		if indicator and indicator ~= 0 then
			EntityKill(indicator)
		end
	end

	local player = GetPlayer()
	if player == nil then
		return
	end
	if GlobalsGetValue("conjurer_reborn_next_refresh_hp", "0") == "1" then --全局变量通知大法（
		UI.OnceCallOnExecute(function()--回满血用的
			local this_player = GetPlayerObj()
			if this_player and this_player.comp.DamageModelComponent then
                GlobalsSetValue("conjurer_reborn_next_refresh_hp", "0")
				this_player.comp.DamageModelComponent[1].attr.hp = this_player.comp.DamageModelComponent[1].attr.max_hp
			end
		end)
	end
    BottomBtnDraw(UI) --底部功能按钮绘制
    --因为有些功能必须更新
    --所以提前到这里来调用
	--但是内部关于具体的按钮项则是会根据玩家打开背包阻止渲染

	if ActiveTable then--魔杖对应的实体的一些操作
		ActiveTable.action(UI)
		local item = GetActiveItem()
		if item ~= -1 and not ItemSwitch then
			GlobalsSetValue("conjurer_reborn_active_item", tostring(item))
			SetActiveItem(-1)
			ItemSwitch = true
		end
		if item == -1 then
			ItemSwitch = true
		end
		local wand = EntityGetWithName("conjurer_reborn_wand_entity")
		if wand == nil or wand == 0 then
			wand = EntityLoadChild(player, "mods/conjurer_reborn/files/wands/wand.xml")
			local pos_x, pos_y = EntityGetTransform(player)
			EntityLoad("data/entities/particles/poof_blue.xml", pos_x, pos_y)
		end
		local comp = EntityGetFirstComponent(wand, "SpriteComponent")
		local CompSprite = ComponentGetValue2(comp, "image_file")
		if CompSprite ~= ActiveImage then
			local pos_x, pos_y = EntityGetTransform(wand)
			ComponentSetValue2(comp, "image_file", ActiveImage)
			EntityRefreshSprite(wand, comp)
			EntityLoad("data/entities/particles/poof_blue.xml", pos_x, pos_y)
		end
	else
		local wand = EntityGetWithName("conjurer_reborn_wand_entity") --关闭时这个实体也应该关闭
		if wand and wand ~= 0 then
			local pos_x, pos_y = EntityGetTransform(wand)
			EntityKill(wand)
			EntityLoad("data/entities/particles/poof_blue.xml", pos_x, pos_y)
		end
		local item = GetActiveItem()
		if item == -1 then --重置手持物品
			local temp = tonumber(GlobalsGetValue("conjurer_reborn_active_item", "0"))
			ItemSwitch = false
			local inv = EntityGetWithName("inventory_quick")
			local IsChild = false
			for _, child in pairs(EntityGetAllChildren(inv) or {}) do --不是背包中的就不要设置了
				if child == temp then
					IsChild = true
					break
				end
			end
			if IsChild and EntityGetIsAlive(temp) and temp ~= "-1" then
				SetActiveItem(temp)
			else --刷新手持物
				SetActiveItem(0)
			end
		end
	end

	if GameIsInventoryOpen() then --下面只是按钮绘制
		RefreshSwitchWand()
		return
	end

	local shift = InputIsKeyDown(Key_LSHIFT) or InputIsKeyDown(Key_RSHIFT)
	if shift and InputIsKeyJustDown(Key_1) and not UI.UserData["HasInputBoxHover"] then --shift+数字键快捷键切换
		SwitchActive(MainBtns[1])
		ActiveImage = MainBtns[1].image
		ItemSwitch = false
	elseif shift and InputIsKeyJustDown(Key_2) and not UI.UserData["HasInputBoxHover"] then
		SwitchActive(MainBtns[2])
		ActiveImage = MainBtns[2].image
		ItemSwitch = false
	elseif shift and InputIsKeyJustDown(Key_3) and not UI.UserData["HasInputBoxHover"] then
		SwitchActive(MainBtns[3])
		ActiveImage = MainBtns[3].image
        ItemSwitch = false
	elseif shift and InputIsKeyJustDown(Key_4) and not UI.UserData["HasInputBoxHover"] then
		SwitchActive(MainBtns[4])
		ActiveImage = MainBtns[4].image
		ItemSwitch = false
	end

	local inventory2 = EntityGetFirstComponent(player, "Inventory2Component") --滚轮切换
	if inventory2 and shift and (InputIsMouseButtonJustDown(Mouse_wheel_up) or InputIsMouseButtonJustDown(Mouse_wheel_down)) then
		local item_index = 0
		if ActiveTable then
			item_index = ActiveTable.index
		end
		if InputIsMouseButtonJustDown(Mouse_wheel_up) then
			local index = item_index - 1
			if index < 1 then
				index = 4
			end
			SwitchActive(MainBtns[index])
			ActiveImage = MainBtns[index].image
			ItemSwitch = false
		elseif InputIsMouseButtonJustDown(Mouse_wheel_down) then
			local index = item_index + 1
			if index > 4 then
				index = 1
			end
			SwitchActive(MainBtns[index])
			ActiveImage = MainBtns[index].image
			ItemSwitch = false
		end
	end

	for i = 1, #MainBtns do
		if ActiveTable ~= MainBtns[i] then --未激活是半透明的
			UI.NextOption(GUI_OPTION.DrawSemiTransparent)
		end
		UI.NextZDeep(0)
		local left = UI.EasyMoveImgBtn(MainBtns[i].id, BtnX + 20 * (i - 1), BtnY, MainBtns[i].image)
		UI.BetterTooltipsNoCenter(function()
			UI.Text(0, 0, MainBtns[i].name)
			UI.VerticalSpacing(2)
			UI.Text(0, 0, MainBtns[i].desc)
			UI.VerticalSpacing(2)
			UI.Text(0, 0, GameTextGet("$conjurer_reborn_wand_switch", tostring(i)))
		end, -3000, 10)

		if left then
			ClickSound()
			ToggleActiveOverlay(MainBtns[i])
			ActiveImage = MainBtns[i].image
		end
	end

	RefreshSwitchWand()
end

UI.MiscEventFn["WeatherLoop"] = function()
	local WorldGlobalGetNumber = Compose(tonumber, WorldGlobalGet)
    if WorldGlobalGetBool(UI, "GlobalRainCont", false) then
        local RainCount = WorldGlobalGetNumber(UI, "RainDropletsSliderSave", "10")
        local RainWidth = WorldGlobalGetNumber(UI, "RainExtraWidthSave", "1280")
        local Mat = WorldGlobalGet(UI, "RainContMat", "water")
        local VelocityMin = WorldGlobalGetNumber(UI, "RainVelocityMinSave", "30")
        local VelocityMax = WorldGlobalGetNumber(UI, "RainVelocityMaxSave", "60")
        local Gravity = WorldGlobalGetNumber(UI, "RainGravitySliderSave", "10")
        local bounce, bflag = GetConjurerCheckBoxStatus("RainBouncyDroplet")
        if not bflag then
            bounce = true
        end
        local long, lflag = GetConjurerCheckBoxStatus("RainLongDroplets")
		if not lflag then
			long = true
		end
        GameEmitRainParticles(RainCount, RainWidth, Mat, VelocityMin, VelocityMax, Gravity, bounce, long)
	end
	if GetConjurerCheckBoxStatus("WeatherWindCont") then
		local value_multiplier = 100
		-- Wind control
        local wind = UI.GetSliderValue("WeatherWindSlider")
		if wind == nil then
			wind = tonumber(WorldGlobalGet(UI, "WeatherWindSliderSave", "0"))
		end
		SetWorldValue("wind_speed", wind)
		
		-- Fog control
        local fog = UI.GetSliderValue("WeatheFogSlider")
        if fog == nil then
            fog = tonumber(WorldGlobalGet(UI, "WeatherCloudsSliderSave", "0"))
        end
		fog = fog / value_multiplier
		SetWorldValue("fog", fog)
		SetWorldValue("fog_target", fog)
		SetWorldValue("fog_target_extra", fog)

		-- Cloud control
		-- [sic] "Rain" variables, from the docs:
		-- "should be called clouds, controls amount of cloud cover in the sky"
        local clouds = UI.GetSliderValue("WeatherCloudsSlider")
        if clouds == nil then
            clouds = tonumber(WorldGlobalGet(UI, "WeatheFogSliderSave", "0"))
        end
        clouds = clouds / value_multiplier
        SetWorldValue("rain", clouds)
		SetWorldValue("rain_target_extra", clouds)
	end
end

local Int64Max = 2^63-1
UI.MiscEventFn["SettingOtherUpdate"] = function ()
    local player = GetPlayerObj()
    if GlobalsGetValue("conjurer_reborn_get_carrot") == "1" and player then
        local x, y = player:GetTransform()
        EntityLoad("mods/conjurer_reborn/files/wands/carrot/entity.xml", x, y)
        GlobalsSetValue("conjurer_reborn_get_carrot", "0")
    end
	
    if GetConjurerCheckBoxStatus("SetIngestCheckbox") and player and player.comp_all.IngestionComponent then
		local IngestNumStr = WorldGlobalGet(UI, "GlobalSetIngestSizeInput", "0")
        local IngestNum = tonumber(IngestNumStr) or 0
        IngestNum = IngestNum / 100
		IngestNum = math.min(IngestNum, Int64Max)
        for _, v in ipairs(player.comp_all.IngestionComponent or {}) do
			local IngestMax = v.attr.ingestion_capacity
			v.attr.ingestion_size = IngestNum * IngestMax
		end
	end
end

local CessationMessage = false
UI.MiscEventFn["CESSATION"] = function ()
    local player_id = EntityGetWithTag("polymorphed_cessation")[1]
	local player = GetPlayer()
    if player_id == nil or player then--有玩家的时候也退出
        CessationMessage = false
        return
    end
	if not CessationMessage then
		GamePrintImportant("$conjurer_reborn_exit_cessation")
	end
    CessationMessage = true
	if not InputIsKeyDown(Key_q) then
		return
	end
	for _,vid in ipairs(EntityGetWithTag("polymorphed_cessation") or {})do
		local player = EntityObj(vid)
		for _,v in ipairs(player:GetAllChildObj() or {})do
			for _,c in ipairs(v.comp_all.GameEffectComponent or {})do
				if c.attr.effect == "POLYMORPH_CESSATION" then
					c.attr.frames = 1
				end
			end
		end
	end
end

local PolymorphMessage = false
UI.MiscEventFn["POLYMORPH"] = function()
	if not ModSettingGet("conjurer_reborn.disable_inf_chaos_poly") then
		SetWorldValue("player_polymorph_random_count", 0)
	end
    local player_id = EntityGetWithTag("polymorphed_player")[1]
    if player_id == nil then
        PolymorphMessage = false
        return
    end
    if not PolymorphMessage then
        local player = EntityObj(player_id)
        player:AddComp("LuaComponent", {
			script_damage_received="mods/conjurer_reborn/files/scripts/poly_death.lua",
        })
		for _,v in ipairs(player.comp_all.DamageModelComponent)do
			v.attr.wait_for_kill_flag_on_death = true
		end
        GamePrintImportant("$conjurer_reborn_exit_poly")
    end
	PolymorphMessage = true
    if not InputIsKeyDown(Key_q) then
        return
    end
    local player = EntityObj(player_id)
	for _,v in ipairs(player:GetAllChildObj() or {})do
        for _, c in ipairs(v.comp_all.GameEffectComponent or {}) do
			local effect = c.attr.effect
			if effect == "POLYMORPH" or effect == "POLYMORPH_RANDOM" or effect == "POLYMORPH_UNSTABLE" then
				c.attr.frames = 1
			end
		end
	end
end

UI.TickEventFn["PolyDeath"] = function()
    if GlobalsGetValue("conjurer_reborn_poly_death", "0") == "0" then
        return
    end
    local player = GetPlayerObj()
    if player == nil then
        return
    end
	
	if ModSettingGet("conjurer_reborn.rebirth_blinded") then
		player:AddChild(EntityObjCreateNew():AddComp("GameEffectComponent",  {
			effect="BLINDNESS",
			frames=120,
		}))
	end

	player:AddChild(EntityObjCreateNew():AddComp("GameEffectComponent",  {
        effect="PROTECTION_POLYMORPH",
        frames=60,
    }))

    local x, y = GetSpawnPosition()
    player.attr.x = x
    player.attr.y = y
    GamePrintImportant("$conjurer_reborn_player_reborn1", "$conjurer_reborn_player_reborn2")
	GlobalsSetValue("conjurer_reborn_poly_death", "0")
end

local MagrinSize = 10
local ImageScale = 0.75
UI.TickEventFn["WaypointInMap"] = function ()
	local x, y = UI.GetScreenPosition(GameGetCameraPos())
    for _, v in ipairs(LOCATION_MEMORY) do
		if v.next ~= 0 then
			local IW,IH = GuiGetImageDimensions(UI.gui, v.image, ImageScale)
			local vx, vy = UI.GetScreenPosition(v.x, v.y)
	
			local len
			local player = GetPlayerObj()
			if player then
				len = math.sqrt((player.attr.x - v.x) ^ 2 + (player.attr.y - v.y) ^ 2)--相距距离
			end
			local hIW = IW / 2
			local hIH = IH / 2
			vx = vx - hIW
			if vx < MagrinSize - hIW then
				vx = MagrinSize - hIW
			elseif vx > UI.ScreenWidth - MagrinSize - hIW then
				vx = UI.ScreenWidth - MagrinSize - hIW
			end
			
			vy = vy - hIH
			local srcVY = vy
			if vy < MagrinSize - hIH then
				vy = MagrinSize - hIH
			elseif vy > UI.ScreenHeight - MagrinSize - hIH then
				vy = UI.ScreenHeight - MagrinSize - hIH
			end
			UI.NextZDeep(-10000)
			UI.Image("OnScreen" .. v.name, vx, vy, v.image, 0.75, ImageScale)
			local Info = UI.WidgetInfoTable()
			if len then
				local lenStr = string.format("%0.f", len)
				local TextW, TextH = UI.TextDimensions(lenStr, ImageScale, 2, "data/fonts/font_pixel.xml")
				local LenY = Info.y + IH
                if srcVY > UI.ScreenHeight - MagrinSize - hIH - TextH then
                    LenY = Info.y - IH / 2
                end
				local TextXOffset = 0
                if Info.x + TextW > UI.ScreenWidth then
					TextXOffset = UI.ScreenWidth - (Info.x + TextW)
                end
				local finalX = Info.x + TextXOffset
				UI.NextZDeep(-10000)
				UI.Text(finalX, LenY, lenStr, ImageScale, "data/fonts/font_pixel.xml")
			end
		end
	end
end

return UI.DispatchMessage
