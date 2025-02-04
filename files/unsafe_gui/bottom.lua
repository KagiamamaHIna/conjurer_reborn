dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/bottom_helper.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/powers/change_herd.lua")

local WorldGlobalGetNumber = Compose(tonumber, WorldGlobalGet)

local BottomBoxX
local BottomBoxY = -100

local SpriteBG = "data/ui_gfx/decorations/9piece0.png"

---@type function|nil
local ActiveFn
local ActiveValue

---@param t function
local function ToggleActiveOverlay(t, v)
	if ActiveFn ~= t then
        ActiveFn = t
		ActiveValue = v
    else
		ActiveFn = nil
		ActiveValue = nil
	end
end

local function DrawActiveFn(UI)
	if ActiveFn then
		ActiveFn(UI, ActiveValue)
	end
end

---绘制维度旅行菜单
---@param UI Gui
local function RenderWorldMenu(UI)
	local conjurer_dimensions = {
		{
			name = "$conjurer_reborn_power_dim_tasamaa",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/flat.png",
			action = CreateDimensionalPortal("conjurer", "world_conjurer",
				"mods/conjurer_reborn/files/biomes/biome_map.png"),
		},
		{
			name = "$conjurer_reborn_power_dim_kukkulat",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/grass.png",
			action = CreateDimensionalPortal("forest", "world_conjurer",
				"mods/conjurer_reborn/files/biomes/biome_map_green.png"),
		},
		{
			name = "$conjurer_reborn_power_dim_aavikko",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/sand.png",
			action = CreateDimensionalPortal("desert", "world_conjurer",
				"mods/conjurer_reborn/files/biomes/biome_map.lua"),
		},
		{
			name = "$conjurer_reborn_power_dim_lumi",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/snow.png",
			action = CreateDimensionalPortal("winter", "world_conjurer",
				"mods/conjurer_reborn/files/biomes/biome_map.lua"),
		},
		{
			name = "$conjurer_reborn_power_dim_markameri",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/water.png",
			action = CreateDimensionalPortal("lake", "world_conjurer", "mods/conjurer_reborn/files/biomes/biome_map.lua"),
		},
		{
			name = "$conjurer_reborn_power_dim_pahamaa",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/hell.png",
			action = CreateDimensionalPortal("hell", "world_conjurer",
				"mods/conjurer_reborn/files/biomes/biome_map_hellscape.png"),
		},
	}
	local noita_worlds = {
		{
			name = "$conjurer_reborn_power_dim_peculiar_ountainside",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/noita.png",
			action = CreateDimensionalPortal("noita", "world_noita", "data/biome_impl/biome_map.png",
				"mods/conjurer_reborn/files/overrides/original_pixel_scenes.xml")
		},
		{
			name = "$conjurer_reborn_power_dim_ng_plus",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/noita_ng.png",
			action = CreateDimensionalPortal("noita_ng+", "world_noita", "data/biome_impl/biome_map_newgame_plus.lua",
				"data/biome/_pixel_scenes_newgame_plus.xml"),
		},
		{
			-- Yeah, I think that should be descriptive enough.
			name = "???????",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/noita_metapeli.png",
			action = CreateDimensionalPortal("noita", "world_noita", "data/scripts/biomes/biome_map_gen.lua", ""),
		},
		{
			name = "$conjurer_reborn_power_dim_takalands_niilo",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/noita_niilo.png",
			action = CreateDimensionalPortal("noita", "world_noita", "data/biome_impl/biome_map_niilo.png",
				"mods/conjurer_reborn/files/overrides/original_pixel_scenes.xml"),
		},
		{
			name = "$conjurer_reborn_power_dim_bostrom_simulation",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/noita_trailer.png",
			action = CreateDimensionalPortal("noita", "world_noita", "data/biome_impl/biome_map_trailer.png", ""),
		},
		{
			name = "$conjurer_reborn_power_dim_endworld_hillplains",
			image = "mods/conjurer_reborn/files/gfx/power_icons/worlds/noita_end.png",
			action = CreateDimensionalPortal("noita", "world_noita", "data/biome_impl/biome_map_the_end.png", ""),
		},
	}
	local x = BottomBoxX + 2
	UI.BeginHorizontal(x, BottomBoxY - 22, true, 1)
	for _, v in ipairs(noita_worlds) do
		GuiBeginAutoBox(UI.gui)
		UI.NextZDeep(0)
		if UI.ImageButton(v.name, 0, 0, v.image) then
            v.action()
			ClickSound()
		end
		local tip = GameTextGetTranslatedOrNot(v.name):gsub([[']], [["]]) --单引号转义成双引号
		UI.GuiTooltip(tip)
		UI.NextZDeep(-1000)
		GuiEndAutoBoxNinePiece(UI.gui, -2, 0, 0, false, 0, "mods/conjurer_reborn/files/gfx/9piece_black.png")
	end
	UI.LayoutEnd()
	UI.BeginHorizontal(x, BottomBoxY - 42, true, 1)
	for _, v in ipairs(conjurer_dimensions) do
		GuiBeginAutoBox(UI.gui)
		UI.NextZDeep(0)
		if UI.ImageButton(v.name, 0, 0, v.image) then
            v.action()
			ClickSound()
		end
		UI.GuiTooltip(v.name)
		UI.NextZDeep(-1000)
		GuiEndAutoBoxNinePiece(UI.gui, -2, 0, 0, false, 0, "mods/conjurer_reborn/files/gfx/9piece_black.png")
	end
    UI.LayoutEnd()
    UI.NextZDeep(0)
    local TextHeight = UI.GetTextInputHeight()--用于实现正确的偏移输入框布局和居中
	local InputY = BottomBoxY - TextHeight - 45
    local str = UI.TextInput("PowerWorldSeedGet", x + 2, InputY, 80, -1, "", "0123456789")
    local InputInfo = UI.WidgetInfoTable()
    UI.GuiTooltip("$conjurer_reborn_power_world_seed_input")
	local seedNum = tonumber(str)
	if seedNum == nil and not InputInfo.hovered then
		UI.TextInputRestore("PowerWorldSeedGet")
    elseif seedNum and seedNum > 0x7FFFFFFF and not InputInfo.hovered then
		UI.SetInputText("PowerWorldSeedGet", tostring(0x7FFFFFFF))
	end
    if InputInfo.right_clicked then
        UI.TextInputRestore("PowerWorldSeedGet")
    end
    local roll = "mods/conjurer_reborn/files/gfx/power_icons/world_seed_roll.png"
    local rollHeight = GuiGetImageDimensions(UI.gui, roll, 1)
	UI.NextZDeep(0)
    if UI.ImageButton("PowerWorldSeedRoll", x + 80 + 5, InputY + TextHeight*0.5 - rollHeight*0.5, roll) then
        local cx, cy = GameGetCameraPos()
        if UI.UserData["PowerWorldSeedRollClick"] == nil then
            UI.UserData["PowerWorldSeedRollClick"] = 0
        elseif UI.UserData["PowerWorldSeedRollClick"] > 0x7FFFFFFF then
            UI.UserData["PowerWorldSeedRollClick"] = 1
        end
        UI.UserData["PowerWorldSeedRollClick"] = UI.UserData["PowerWorldSeedRollClick"] + 1
        SetRandomSeed(cx, UI.UserData["PowerWorldSeedRollClick"])
        UI.SetInputText("PowerWorldSeedGet", tostring(Random(0, 0x7FFFFFFE)))
        ClickSound()
    end
    UI.BetterTooltips(function ()
        UI.Text(0, 0, "$conjurer_reborn_power_world_seed_roll")
	end,nil,nil,25)
    if not InputInfo.hovered then
        GlobalsSetValue("conjurer_reborn_power_world_seed", UI.GetInputText("PowerWorldSeedGet") or "")
    end
	if InputInfo.hovered and (InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL)) and InputIsKeyJustDown(Key_v) then
		local Clipboard = tonumber(Cpp.GetClipboard())
		if Clipboard and Clipboard > 0 then
			UI.SetInputText("PowerWorldSeedGet", UI.GetInputText("PowerWorldSeedGet")..tostring(math.floor(Clipboard)))
		end
	end
end

---绘制传送点菜单
---@param UI Gui
local function RenderTeleportMenu(UI)
	local teleport_buttons = {
		{
			name = "$conjurer_reborn_power_memorize_return",
			image = "mods/conjurer_reborn/files/gfx/power_icons/tower.png",
			action = function()
				local x, y = GetSpawnPosition()
				local player = GetPlayer()
				if player == nil then
					return
				end
				EntitySetTransform(player, x, y)
			end,
		},
		{
			name = "$conjurer_reborn_power_memorize_set_location",
			desc = "$conjurer_reborn_power_memorize_set_location_desc",
			image = "mods/conjurer_reborn/files/gfx/power_icons/plus.png",
			action = function()
				local player = GetPlayer()
				if player == nil then
					return
				end
				local x, y = EntityGetTransform(player)
				SetWaypoint(x, y)
			end,
		},
	}

	local x = BottomBoxX + 1
	GuiBeginAutoBox(UI.gui)
	UI.BeginHorizontal(x, BottomBoxY - 23, true, 1)
	for _, v in ipairs(teleport_buttons) do
		UI.NextZDeep(0)
		if UI.ImageButton("Teleport" .. v.name, 0, 0, v.image) then
            v.action(UI)
			ClickSound()
		end
		local tip = GameTextGet(v.name)
		if v.desc then
			tip = tip .. "\n" .. GameTextGet(v.desc)
		end
		UI.GuiTooltip(tip)
	end
	UI.LayoutEnd()
	UI.NextZDeep(-1000)
	GuiEndAutoBoxNinePiece(UI.gui, -1, 0, 0, false, 0, "mods/conjurer_reborn/files/gfx/9piece_purple.png", "mods/conjurer_reborn/files/gfx/9piece_purple.png")
	local Info = UI.WidgetInfoTable()
    InputBlockEasy(UI, "BottomTeleport阻挡框", Info)

	UI.BeginHorizontal(Info.draw_x + Info.draw_width + 4, BottomBoxY - 23, true, 1)

	for k, v in ipairs(LOCATION_MEMORY) do
		if k == 9 then --往上排
			UI.LayoutEnd()
			UI.BeginHorizontal(Info.draw_x + Info.draw_width + 4, BottomBoxY - 43, true, 1)
		end
		GuiBeginAutoBox(UI.gui)
		UI.NextZDeep(0)
		local left, right = UI.ImageButton("TeleportMemory" .. v.name, 0, 0, v.image)
        if left then
			ClickSound()
			local player = GetPlayer()
			if player then
				EntitySetTransform(player, v.x, v.y)
			end
		end
		if right then
			RemoveWaypoint(v, k)
		end
		local tip = GameTextGet("$conjurer_reborn_power_memorize_tip", GameTextGet(v.name), string.format("%.2f", v.x),
			string.format("%.2f", v.y))

		UI.GuiTooltip(tip)
		UI.NextZDeep(-1000)
		GuiEndAutoBoxNinePiece(UI.gui, -2, 0, 0, false, 0, "mods/conjurer_reborn/files/gfx/9piece_purple.png")
	end
	UI.LayoutEnd()
end

---绘制世界倾向菜单
---@param UI Gui
local function RenderHappinessMenu(UI)
	local relation_buttons = {
		{
			name = "$conjurer_reborn_power_happiness_level_hate",
			desc = "$conjurer_reborn_power_happiness_level_hate_desc",
			image = "mods/conjurer_reborn/files/gfx/power_icons/war.png",
			action = function()
				GamePrint("$conjurer_reborn_power_happiness_level_hate_print")
				ChangeHappiness(-100)
			end,
		},
		{
			name = "$conjurer_reborn_power_happiness_level_neutral",
			desc = "$conjurer_reborn_power_happiness_level_neutral_desc",
			image = "mods/conjurer_reborn/files/gfx/power_icons/statusquo.png",
			action = function()
				GamePrint("$conjurer_reborn_power_happiness_level_neutral_print")
				ChangeHappiness(0)
			end,
		},
		{
			name = "$conjurer_reborn_power_happiness_level_love",
			desc = "$conjurer_reborn_power_happiness_level_love_desc",
			image = "mods/conjurer_reborn/files/gfx/power_icons/paradise.png",
			action = function()
				GamePrint("$conjurer_reborn_power_happiness_level_love_print")
				ChangeHappiness(100)
			end,
		},
	}

	local x = BottomBoxX + 55.5
	UI.BeginHorizontal(x, BottomBoxY - 23, true, 1)
	GuiBeginAutoBox(UI.gui)

	for _, v in ipairs(relation_buttons) do
		UI.NextZDeep(0)
        if UI.ImageButton("Happiness" .. v.name, 0, 0, v.image) then
            v.action()
			ClickSound()
        end
		UI.GuiTooltip(GameTextGet(v.name).."\n"..GameTextGet(v.desc))
	end

	UI.NextZDeep(-1000)
    GuiEndAutoBoxNinePiece(UI.gui, 0, 0, 0, false, 0)
	local Info = UI.WidgetInfoTable()
	InputBlockEasy(UI, "BottomHappiness阻挡框", Info)
	UI.LayoutEnd()
end

local HerdX
---@param UI Gui
---@param WidgetInfo GuiInfo
local function RenderHerdMenu(UI, WidgetInfo)
	local y = BottomBoxY - 23
	if HerdX == nil then
        HerdX = 0
		y = -UI.ScreenHeight
	end
	local RowSize = HERD_ROWS
	local ListSize = #HERDS
	local Rows = math.ceil(ListSize / RowSize)--计算行数
    local LastRowSize = ListSize - ((Rows - 1) * RowSize) --求最后一行大小
    UI.BeginHorizontal(HerdX, y, true, 1, 1)
	GuiBeginAutoBox(UI.gui)
	local LastInfo
    for i = ListSize - LastRowSize + 1, ListSize do--最后一行，这个是向上扩展的
        UI.NextZDeep(0)
        if UI.ImageButton("change_herd" .. HERDS[i].name, 0, 0, HERDS[i].image) then
            change_player_herd(HERDS[i].name)
			ClickSound()
        end
		LastInfo = UI.WidgetInfoTable()
		UI.GuiTooltip(HERDS[i].display.."\nID:"..HERDS[i].name)
	end
	local offset_x = -(LastInfo.x - HerdX + LastInfo.width)
	local HeightCount = 2
	local HeightGap = 20
	local size = ListSize - LastRowSize

	while true do--动态排列，下到上调用，实现自动框布局，计算偏移避免自动布局影响（因为自动框想要定位必须开自动布局，绑死的
        if HeightCount > Rows then
            break
        end
        size = size - RowSize
        UI.BeginHorizontal(offset_x, -(HeightCount - 1) * HeightGap, true, 1, 1)
		local Info
        for i = size + 1, size + RowSize do
            UI.NextZDeep(0)
            if UI.ImageButton("change_herd" .. HERDS[i].name, 0, 0, HERDS[i].image) then
                change_player_herd(HERDS[i].name)
				ClickSound()
            end
			Info = UI.WidgetInfoTable()
			UI.GuiTooltip(HERDS[i].display.."\nID: "..HERDS[i].name)
        end
		offset_x = offset_x - Info.width - 1
		UI.LayoutEnd()
		HeightCount = HeightCount + 1
	end

	UI.NextZDeep(-1000)
    GuiEndAutoBoxNinePiece(UI.gui, 0, 0, 0, false, 0)
    local info = UI.WidgetInfoTable()
    HerdX = WidgetInfo.x + WidgetInfo.width * 0.5 - info.width * 0.5
	InputBlockEasy(UI, "BottomHerd阻挡框", info)
	UI.LayoutEnd()
end

local LastScaleWeather = nil
local WindMenuOffsetY = 0
local RainMenuOffsetY = 0
---@param UI Gui
local function RenderWeatherMenu(UI)
    local AirSliders = {
        {
            id = "WeatherWindSlider",
            name = "$conjurer_reborn_power_weather_wind",
            width = 60,
            default = 0,
            min = -499, -- Exclusive, actually goes to -500
            max = 500,
            savedValue = WorldGlobalGetNumber(UI, "WeatherWindSliderSave", "0"),
			normalValue = function ()
				return GetWorldValue("wind_speed")
			end,
			action = function (value)
				WorldGlobalSet(UI, "WeatherWindSliderSave", value)
			end
        },
		{
            id = "WeatherCloudsSlider",
            name = "$conjurer_reborn_power_weather_clouds",
            width = 60,
            default = 0,
            min = 0,
            max = 100,
            savedValue = WorldGlobalGetNumber(UI, "WeatherCloudsSliderSave", "0"),
			normalValue = function ()
				return GetWorldValue("rain")
			end,
			action = function (value)
				WorldGlobalSet(UI, "WeatherCloudsSliderSave", value)
			end
		},
		{
            id = "WeatheFogSlider",
            name = "$conjurer_reborn_power_weather_fog",
            width = 60,
            default = 0,
            min = 0,
            max = 100,
            savedValue = WorldGlobalGetNumber(UI, "WeatheFogSliderSave", "0"),
			normalValue = function ()
				return GetWorldValue("fog")
			end,
			action = function (value)
				WorldGlobalSet(UI, "WeatheFogSliderSave", value)
			end
		}
	}
	local ThisNil = false
    if LastScaleWeather == nil then
        LastScaleWeather = UI.GetScale()
		ThisNil = true
    end
    if LastScaleWeather ~= UI.GetScale() then --缩放不同时重置偏移参数
        LastScaleWeather = UI.GetScale()
        WindMenuOffsetY = 0
        RainMenuOffsetY = 0
        ThisNil = true
    end
	if ThisNil then--隐藏获取基准对齐的操作，静默且美观
		GuiAnimateBegin(UI.gui)
		GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("WeatherWindANI"), 0, 0, false)
	end
	local BaseLine = BottomBoxY - 4
	local WindBoxY = BaseLine - WindMenuOffsetY
	UI.BeginVertical(BottomBoxX + 7, WindBoxY, true)
    GuiBeginAutoBox(UI.gui)--控制风

	UI.NextZDeep(0)
	UI.NextColor(155, 173, 183, 255)
	UI.Text(0,0,"$conjurer_reborn_power_weather_air")

    local WindFlag = ConjurerCheckbox(UI, "WeatherWindCont", 0, 0, "$conjurer_reborn_power_weather_cont", 0, false)
	UI.VerticalSpacing(1)
	UI.GuiTooltip("$conjurer_reborn_power_weather_cont_desc")

	local BigestWidth = 0--计算对齐位置
	for _, v in ipairs(AirSliders) do
		local text = GameTextGet(v.name)
		local newWidth = GuiGetTextDimensions(UI.gui, text)
		if newWidth > BigestWidth then
			BigestWidth = newWidth
		end
	end
	BigestWidth = BigestWidth + 2
    if WindFlag then
		for _,v in ipairs(AirSliders)do
            local sv = SameWidthSlider(UI, v.id, BigestWidth, 0, 0, v.name, v.min, v.max, v.default, v.width, nil, v.savedValue)
			v.action(sv)
		end
    else
        --文本也需要对齐哦！
		for _,v in ipairs(AirSliders)do
            UI.BeginHorizontal(0, 0, true)
			UI.NextZDeep(0)
            UI.Text(0, 0, v.name)

            local NameWidth = GuiGetTextDimensions(UI.gui,GameTextGet(v.name))
            UI.NextZDeep(0)
			UI.NextColor(155, 173, 183, 255)
			UI.Text(BigestWidth - NameWidth, 0, string.format("%.4f",  v.normalValue()))

			UI.LayoutEnd()
		end
	end

	UI.NextZDeep(-1000)
    GuiEndAutoBoxNinePiece(UI.gui, 5, 95, 0, false, 0)
    local AutoBoxInfo = UI.WidgetInfoTable()
    if WindBoxY + AutoBoxInfo.height > BaseLine + WindMenuOffsetY then
        WindMenuOffsetY = WindBoxY + AutoBoxInfo.height - BaseLine --计算对齐基准线用的偏移量
    end
    InputBlockEasy(UI, "WindBox阻挡框", AutoBoxInfo)

    UI.LayoutEnd()
    ---控制雨
    local RainSlider1 = {
        {
			id = "RainDropletsSlider",
			name = "$conjurer_reborn_power_weather_droplets",
			width = 50,
			default = 10,
			min = 1,
			max = 200,
			savedValue = WorldGlobalGetNumber(UI, "RainDropletsSliderSave", "10"),
			action = function (value)
				WorldGlobalSet(UI, "RainDropletsSliderSave", value)
			end
		},
        {
			id = "RainGravitySlider",
			name = "$conjurer_reborn_power_weather_gravity",
			width = 50,
			default = 10,
			min = 1,
			max = 100,
			savedValue =  WorldGlobalGetNumber(UI, "RainGravitySliderSave", "10"),
			action = function (value)
				WorldGlobalSet(UI, "RainGravitySliderSave", value)
			end
		},
    }

    local RainSlider2 = {
		{
			id = "RainVelocityMinSlider",
			name = "$conjurer_reborn_power_weather_velocity_min",
			width = 50,
			default = 30,
			min = 0,
			max = 300,
			savedValue = WorldGlobalGetNumber(UI, "RainVelocityMinSave", "30"),
			action = function (value)
				WorldGlobalSet(UI, "RainVelocityMinSave", value)
			end
        },
		{
			id = "RainVelocityMaxSlider",
			name = "$conjurer_reborn_power_weather_velocity_max",
			width = 50,
			default = 60,
			min = 0,
			max = 300,
			savedValue = WorldGlobalGetNumber(UI, "RainVelocityMaxSave", "60"),
			action = function (value)
				WorldGlobalSet(UI, "RainVelocityMaxSave", value)
			end
        },
		{
			id = "RainExtraWidthSlider",
			name = "$conjurer_reborn_power_weather_extra_width",
			width = 50,
			default = 1280,
			min = 128,
			max = 2048,
            savedValue = WorldGlobalGetNumber(UI, "RainExtraWidthSave", "1280"),
			desc = "$conjurer_reborn_power_weather_extra_width_desc",
			action = function (value)
				WorldGlobalSet(UI, "RainExtraWidthSave", value)
			end
		},
    }
	
    local RainBaseLine = AutoBoxInfo.y - 6
	local RainBoxY = RainBaseLine - RainMenuOffsetY
    UI.BeginVertical(BottomBoxX + 7, RainBoxY, true)
    GuiBeginAutoBox(UI.gui)

	UI.NextZDeep(0)
	UI.NextColor(155, 173, 183, 255)
	UI.Text(0,0,"$conjurer_reborn_power_weather_rain")
    UI.VerticalSpacing(1)
	
    UI.BeginHorizontal(0, 0, true)
    local mat = WorldGlobalGet(UI, "RainContMat", "water")
	if GetMaterial(mat) == nil then--防止非法材料
        mat = "water"
		WorldGlobalSet(UI, "RainContMat", mat)
	end
    local img = string.format("mods/conjurer_unsafe/cache/MatIcon/%s.png", mat)
	UI.NextZDeep(0)
    UI.ImageButton("RainContMatImg", 0, 0, img)--材料图标显示
    UI.BetterTooltipsNoCenter(function()
		UI.Text(0,0,"$conjurer_reborn_power_weather_active_rain_mat")
		MatTooltipText(UI, mat)
    end, UI.GetZDeep() - 1000, 10, 3)

	local icon = "mods/conjurer_reborn/files/gfx/icon_power_on.png"
    local icon_off = "mods/conjurer_reborn/files/gfx/icon_power_off.png"
	local RainContBtnImg = icon_off
    local ContStatus = WorldGlobalGetBool(UI, "GlobalRainCont", false)
	if ContStatus then
		RainContBtnImg = icon
	end
	UI.NextZDeep(0)
    if UI.ImageButton("RainContBtn", 0, 0, RainContBtnImg) then
        WorldGlobalSetBool(UI, "GlobalRainCont", not ContStatus)
		ClickSound()
    end
	local RainTooltip = ContStatus and "$conjurer_reborn_power_weather_rain_end" or "$conjurer_reborn_power_weather_rain_start"
	UI.GuiTooltip(RainTooltip)
	UI.LayoutEnd()

	local RainBigestWidth1 = 0
	local RainBigestWidth2 = 0
	for _,v in ipairs(RainSlider1)do
		local text = GameTextGet(v.name)
		local newWidth = GuiGetTextDimensions(UI.gui, text)
		if newWidth > RainBigestWidth1 then
			RainBigestWidth1 = newWidth
		end
	end
	for _,v in ipairs(RainSlider2)do
		local text = GameTextGet(v.name)
		local newWidth = GuiGetTextDimensions(UI.gui, text)
		if newWidth > RainBigestWidth2 then
			RainBigestWidth2 = newWidth
		end
	end
    RainBigestWidth1 = RainBigestWidth1 + 2
	RainBigestWidth2 = RainBigestWidth2 + 2

	for _,v in ipairs(RainSlider1)do
        local value = SameWidthSlider(UI, v.id, RainBigestWidth1, 0, 0, v.name, v.min, v.max, v.default, v.width, nil, v.savedValue)
		v.action(value)
	end

	for _,v in ipairs(RainSlider2)do
        local value = SameWidthSlider(UI, v.id, RainBigestWidth2, 0, 0, v.name, v.min, v.max, v.default, v.width, v.desc, v.savedValue)
		v.action(value)
	end

    ConjurerCheckbox(UI, "RainBouncyDroplet", 0, 0, "$conjurer_reborn_power_weather_bouncy_droplets", nil, true)
	UI.VerticalSpacing(1)
    ConjurerCheckbox(UI, "RainLongDroplets", 0, 0, "$conjurer_reborn_power_weather_long_droplets", nil, true)

	UI.NextZDeep(-1000)
    GuiEndAutoBoxNinePiece(UI.gui, 5, 95, 0, false, 0)
	UI.LayoutEnd()
    local RainAutoBoxInfo = UI.WidgetInfoTable()
    if RainBoxY + RainAutoBoxInfo.height > RainBaseLine + RainMenuOffsetY then
        RainMenuOffsetY = RainBoxY + RainAutoBoxInfo.height - RainBaseLine --计算对齐基准线用的偏移量
    end
    InputBlockEasy(UI, "RainBox阻挡框", RainAutoBoxInfo)
	
	if ThisNil then
		GuiAnimateEnd(UI.gui)
	end
end

local LastScaleTime = nil
local TimeMenuOffsetY = 0
---更改时间菜单
---@param UI Gui
local function RenderTimeMenu(UI)
	local TimeBtn = {
		{
			id = "WorldTimeSetDawn",
			name = "$conjurer_reborn_power_planetary_controls_dawn",
			image = "mods/conjurer_reborn/files/gfx/power_icons/dawn.png",
			action = function()
				SetWorldValue("time", 0.73)
			end
		},
        {
			id = "WorldTimeSetNoon",
			name = "$conjurer_reborn_power_planetary_controls_noon",
			image = "mods/conjurer_reborn/files/gfx/power_icons/noon.png",
			action = function()
				SetWorldValue("time", 0)--正午
			end
		},
		{
			id = "WorldTimeSetDusk",
			name = "$conjurer_reborn_power_planetary_controls_dusk",
			image = "mods/conjurer_reborn/files/gfx/power_icons/dusk.png",
			action = function()
				SetWorldValue("time", 0.47)
			end
		},
		{
			id = "WorldTimeSetMidnigh",
			name = "$conjurer_reborn_power_planetary_controls_midnight",
			image = "mods/conjurer_reborn/files/gfx/power_icons/midnight.png",
			action = function()
				SetWorldValue("time", 0.6)
			end
		},
    }
    local function to_worldstate_value(val)
        if val <= 0.1 then return 0 end
        return math.max(10 ^ val / 10)
    end
	local function to_slider_log_value(val)
		return math.max(math.log10(val*10), 0)
	end
    local time_dt = to_slider_log_value(GetWorldValue("time_dt"))
    local gradient_sky_alpha_target = GetWorldValue("gradient_sky_alpha_target") * 100
	local sky_sunset_alpha_target = GetWorldValue("sky_sunset_alpha_target") * 100
    local TimeSlider = {
        {
            id = "WorldTimeTorque",
            name = "$conjurer_reborn_power_planetary_controls_torque",
            desc = "$conjurer_reborn_power_planetary_controls_torque_desc",
            isDecimals = true,
            min = 0,
            max = 3.5,
            value = time_dt,
			default = 1,
            formatting = string.format("%.2f", time_dt),
			action = function (value)
				SetWorldValue("time_dt", to_worldstate_value(value))
			end
        },
		{
            id = "WorldTimeSkytop",
            name = "$conjurer_reborn_power_planetary_controls_skytop",
            desc = "$conjurer_reborn_power_planetary_controls_skytop_desc",
            isDecimals = true,
            min = 0,
            max = 100,
            value = gradient_sky_alpha_target,
			formatting = string.format("%.2f", gradient_sky_alpha_target),
			default = 0,
			action = function (value)
				SetWorldValue("gradient_sky_alpha_target", value / 100)
			end
        },
		{
            id = "WorldTimeSunset",
            name = "$conjurer_reborn_power_planetary_controls_sunset",
            desc = "$conjurer_reborn_power_planetary_controls_sunset_desc",
            isDecimals = true,
            min = 0,
            max = 100,
            value = sky_sunset_alpha_target,
			formatting = string.format("%.2f", sky_sunset_alpha_target),
			default = 100,
			action = function (value)
				SetWorldValue("sky_sunset_alpha_target", value / 100)
			end
		}
    }
	local ThisNil = false
    if LastScaleTime == nil then
        LastScaleTime = UI.GetScale()
		ThisNil = true
    end
    if LastScaleTime ~= UI.GetScale() then --缩放不同时重置偏移参数
        LastScaleTime = UI.GetScale()
        TimeMenuOffsetY = 0
        ThisNil = true
    end
    if ThisNil then --隐藏获取基准对齐的操作，静默且美观
        GuiAnimateBegin(UI.gui)
        GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("TimeMenuANI"), 0, 0, false)
    end
	local BaseLine = BottomBoxY - 4
    local TimeBoxY = BaseLine - TimeMenuOffsetY
	UI.BeginVertical(BottomBoxX + 7, TimeBoxY, true)
    GuiBeginAutoBox(UI.gui)--控制时间

	UI.NextZDeep(0)
	UI.NextColor(155, 173, 183, 255)
    UI.Text(0, 0, "$conjurer_reborn_power_planetary_controls_head")

	local Days = GameTextGet("$conjurer_reborn_power_planetary_controls_day",tostring(GetWorldDays()))
	UI.NextZDeep(0)
    UI.Text(0, 0, string.format("%02d:%02d ", GetWorldTimeStr()) .. Days)
	
    UI.VerticalSpacing(1)
	
	UI.BeginHorizontal(0,0,true, 4)

	for _,v in ipairs(TimeBtn)do
        UI.NextZDeep(0)
        if UI.ImageButton(v.id, 0, 0, v.image) then
			v.action()
		end
		UI.GuiTooltip(v.name)
	end

	UI.LayoutEnd()

    local Algin = 0
	for _,v in ipairs(TimeSlider) do
		local text = GameTextGet(v.name)
		local newWidth = GuiGetTextDimensions(UI.gui, text)
		if newWidth > Algin then
			Algin = newWidth
		end
	end

    for _, v in ipairs(TimeSlider) do
		if v.value then
			UI.SetSliderValue(v.id, v.value)
		end
        local value = SameWidthSlider(UI, v.id, Algin, 0, 0, v.name, v.min, v.max, v.default, 50, v.desc, nil, v.isDecimals, v.formatting)
		v.action(value)
	end

	UI.NextZDeep(-1000)
    GuiEndAutoBoxNinePiece(UI.gui, 5, 95, 0, false, 0)
	UI.LayoutEnd()
    local TimeBoxInfo = UI.WidgetInfoTable()
    if TimeBoxY + TimeBoxInfo.height > BaseLine + TimeMenuOffsetY then
        TimeMenuOffsetY = TimeBoxY + TimeBoxInfo.height - BaseLine --计算对齐基准线用的偏移量
    end
    InputBlockEasy(UI, "BottomTime阻挡框", TimeBoxInfo)
	if ThisNil then
		GuiAnimateEnd(UI.gui)
	end
end

local main_menu_items = {
	{
		name = "$conjurer_reborn_power_tran_dim",
		image = "mods/conjurer_reborn/files/gfx/power_icons/dimension_portal.png",
		action = function(UI)
			ToggleActiveOverlay(RenderWorldMenu)
		end,
	},
	{
		name = "$conjurer_reborn_power_memorize",
		image = "mods/conjurer_reborn/files/gfx/power_icons/memorize.png",
        action = function(UI)
			ToggleActiveOverlay(RenderTeleportMenu)
		end,
    },
	{
		name = "$conjurer_reborn_power_weather",
		image = "mods/conjurer_reborn/files/gfx/power_icons/weather.png",
		action = function (UI)
			ToggleActiveOverlay(RenderWeatherMenu)
		end,
	},
	{
		name = "$conjurer_reborn_power_planetary_controls",
		image = "mods/conjurer_reborn/files/gfx/power_icons/planetary_controls.png",
		action = function(UI)
			ToggleActiveOverlay(RenderTimeMenu)
		end,
    },
	{
		name = "$conjurer_reborn_power_happiness_level",
		image_func = GetHappinessImage,
		tip_func = function(UI)
			local value = GetHappiness()
			local tip = GameTextGet("$conjurer_reborn_power_happiness_level_relationship", tostring(value))
			return tip
		end,
		action = function(UI)
			ToggleActiveOverlay(RenderHappinessMenu)
		end,
	},
	{
		name = "$conjurer_reborn_power_change_herd",
		image_func = function (UI)
			return GetPlayerHerdImg()
        end,
		tip_func = function(UI)
            local herd = GetPlayerHerd()
			if herd == nil then
				local unknown =  GameTextGet("$conjurer_reborn_power_change_herd_unknown")
				return GameTextGet("$conjurer_reborn_power_change_herd_active",unknown)
			end
            local str = HerdIdToString(herd)
			return GameTextGet("$conjurer_reborn_power_change_herd_active",str)
		end,
        action = function(UI)
			ToggleActiveOverlay(RenderHerdMenu, UI.WidgetInfoTable())
		end,
	},
	{
		name = "$conjurer_reborn_power_glass_eye",
		image = "mods/conjurer_reborn/files/gfx/power_icons/glass_eye.png",
		action = ToggleCameraControls,
		get_active = function(UI)
			return GetCameraControls()
		end,
	},
	{
		-- TODO: This ugly tooltip & teaching the player
		name = "$conjurer_reborn_power_binoculars",
		image = "mods/conjurer_reborn/files/gfx/power_icons/binoculars.png",
		action = ToggleBinoculars,
		get_active = function(UI)
			return GetBinocularsActive(UI)
		end,
	},
	{
		name = "$conjurer_reborn_power_grid",
		image = "mods/conjurer_reborn/files/gfx/power_icons/grid.png",
		action = ToggleGrid,
		get_active = function(UI)
			local grid = EntityGetWithName("conjurer_reborn_grid_overlay")
			if grid == nil or grid == 0 then
				return false
			end
			return true
		end,
	},
	{
		name = "$conjurer_reborn_power_kalma",
		image = "mods/conjurer_reborn/files/gfx/power_icons/kalma.png",
		action = ToggleKalma,
		update = function(UI)
			local player = GetPlayer()
			if player == nil then
				return
			end
			local active = GetKalma(UI)
			if active then
				local entity = EntityGetWithName("conjurer_reborn_kalma")
				if entity and entity ~= 0 then
					EntityKill(entity)
				end
			else
				local entity = EntityGetWithName("conjurer_reborn_kalma")
				if entity == 0 then
					EntityLoadChild(player, "mods/conjurer_reborn/files/powers/kalma.xml")
				end
			end
		end,
		get_active = function(UI)
			return GetKalma(UI)
		end,
	},
	{
		name = "$conjurer_reborn_power_viima",
		image = "mods/conjurer_reborn/files/gfx/power_icons/viima.png",
		action = ToggleSpeed,
		get_active = function(UI)
			return GetSpeed()
		end,
	},
}

local LastMode
---绘制底部按钮
---@param UI Gui
function BottomBtnDraw(UI)
	for _, v in ipairs(main_menu_items) do --必须更新
		if v.update then
			v.update(UI)
		end
	end
	if GameIsInventoryOpen() then
		return
	end
    if BottomBoxX == nil then
        BottomBoxX = -UI.ScreenWidth
    end
    local mode = ModSettingGet("conjurer_reborn.bottom_pos")
	if mode == "no_display" then
		return
	end
	local Enable = WorldGlobalGetBool(UI, "BottomBoxEnable", true)
    UI.NextZDeep(0)
	if not Enable then
		UI.NextOption(GUI_OPTION.DrawSemiTransparent)
	end
    if UI.ImageButton("BottomBoxSwitch", BottomBoxX - 12, UI.ScreenHeight - 11.5, "mods/conjurer_reborn/files/gfx/BottomSwitch.png") then
        WorldGlobalSetBool(UI, "BottomBoxEnable", not Enable)
        ClickSound()
    end
	if mode ~= LastMode then--隐藏布局的情况下重置
		BottomBoxX = nil
	end
	LastMode = mode
    if not Enable and BottomBoxX ~= nil then

        return
    end
	if BottomBoxX == nil and Enable then
		GuiAnimateBegin(UI.gui)
        GuiAnimateAlphaFadeIn(UI.gui, UI.NewID("BottomMenuANI"), 0, 0, false)
	end
	UI.BeginHorizontal(BottomBoxX, UI.ScreenHeight - 21.5, true)
	GuiBeginAutoBox(UI.gui) --框住用的自动盒子
	for _, v in ipairs(main_menu_items) do
		UI.NextZDeep(0)
		local BtnText = GameTextGet(v.name)
		if v.get_active then --其实相当于picker了）
			local active = v.get_active(UI)
			if not active then
				UI.NextOption(GUI_OPTION.DrawSemiTransparent)
				BtnText = GameTextGet("$conjurer_reborn_picker_open") .. BtnText
			else
				BtnText = GameTextGet("$conjurer_reborn_picker_close") .. BtnText
			end
		end
		if v.tip_func then
			local tip = v.tip_func(UI)
			BtnText = BtnText .. "\n" .. tip
		end
		local image = v.image
		if v.image_func then --如果有图标函数就调用获取
			image = v.image_func(UI)
		end
		local left = UI.ImageButton(v.name, 0, 0, image)
		if left then
            v.action(UI)
			ClickSound()
		end
		UI.GuiTooltip(BtnText)
	end
	UI.NextZDeep(-99)
	GuiEndAutoBoxNinePiece(UI.gui, 1, 0, 0, false, 0, SpriteBG, SpriteBG)
	local info = UI.WidgetInfoTable()
    InputBlockEasy(UI, "BottomBtns阻挡框", info)

	if Enable and BottomBoxX == nil then
		GuiAnimateEnd(UI.gui)
	end
    if mode == "bottom_center" then
		BottomBoxX = UI.ScreenWidth * 0.5 - info.draw_width * 0.5 + 4 --居中
    elseif mode == "bottom_right" then
        BottomBoxX = UI.ScreenWidth - info.draw_width - 2       --靠右
    elseif mode == "bottom_left" then
		BottomBoxX = 14
	end
	
    BottomBoxY = info.y
	UI.LayoutEnd()
	DrawActiveFn(UI)
end
