---@class Gui
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
			local this_player = GetPlayer()
			if this_player then
				GlobalsSetValue("conjurer_reborn_next_refresh_hp", "0")
				local dmgComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
				if dmgComponent then
					local max_health = ComponentGetValue2(dmgComponent, "max_hp")
					ComponentSetValue2(dmgComponent, "hp", max_health)
				end
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
				index = 3
			end
			SwitchActive(MainBtns[index])
			ActiveImage = MainBtns[index].image
			ItemSwitch = false
		elseif InputIsMouseButtonJustDown(Mouse_wheel_down) then
			local index = item_index + 1
			if index > 3 then
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

UI.MiscEventFn["SettingOtherUpdate"] = function ()
	if GlobalsGetValue("conjurer_reborn_get_carrot") == "1" then
        local player = GetPlayer()
		if player then
            local x, y = EntityGetTransform(player)
            EntityLoad("mods/conjurer_reborn/files/wands/carrot/entity.xml", x, y)
			GlobalsSetValue("conjurer_reborn_get_carrot", "0")
		end
	end
end

return UI.DispatchMessage
