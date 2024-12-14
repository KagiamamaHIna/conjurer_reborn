dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataInterface/IgnoreMaterials.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/mat_brushe_entity.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/mat_draw.lua")

local Brushes = GetBrushesTable()

local IngoreMatTable = {}
for _,v in pairs(IgnoreMaterials)do
	IngoreMatTable[v] = true
end
IgnoreMaterials = nil

---@type function|nil
local ActiveMatwandFn
local MatTable = GetMaterialData()

---@param fn function
local function ToggleActiveOverlay(fn)
	ActiveMatwandFn = (ActiveMatwandFn ~= fn) and fn or nil
end

local function DrawActiveMatwandFn(UI)
	if ActiveMatwandFn then
		ActiveMatwandFn(UI)
	end
end

---绘制材料文本，不含悬浮窗
---@param UI Gui
---@param id string
local function MatTooltipText(UI, id)
	local rightMargin = 72
	local function NewLine(str1, str2, callback)
		local text = GameTextGetTranslatedOrNot(str1)
		local w = GuiGetTextDimensions(UI.gui,text)
        GuiLayoutBeginHorizontal(UI.gui, 0, 0, true, 2, -1)
        GuiText(UI.gui, 0, 0, text)
        GuiRGBAColorSetForNextWidget(UI.gui, 255, 222, 173, 255)
        if w + 8 > rightMargin then
            GuiText(UI.gui, w + 8 - w, 0, str2)
        else
            GuiText(UI.gui, rightMargin - w, 0, str2)
        end
		if callback then
			callback()
		end
		GuiLayoutEnd(UI.gui)
	end

    local name = GetNameOrKey(MatTable[id].attr.ui_name)
	if name == "" then
		name = MatTable[id].attr.name
	end
	UI.Text(0, 0, name)--本地化名称显示
	UI.NextColor(127, 127, 127, 255)
    UI.Text(0, 0, id) --id显示
	
	UI.NextColor(127, 127, 255, 255)
	local typeText = GameTextGet(MatTypeToLocal[MatTable[id].conjurer_unsafe_type])
    UI.Text(0, 0, typeText) --类型显示
    local shift = InputIsKeyDown(Key_RSHIFT) or InputIsKeyDown(Key_LSHIFT)
	if shift then
		local tagStr
        if MatTable[id].attr.tags then
            tagStr = table.concat(MatTable[id].attr.tags, ",")
        end
        if tagStr == "" then
            tagStr = GameTextGet("$conjurer_reborn_material_tooltip_tag_none")
        end
		
        UI.Text(0, 0, GameTextGet("$conjurer_reborn_material_tooltip_tag", tagStr))
		
        NewLine("$conjurer_reborn_material_tooltip_wang_color", MatTable[id].attr.wang_color:upper(), function()
            local wang = "mods/conjurer_unsafe/cache/MatWang/" .. id .. ".png"
            local _, _, _, _, _, _, height = UI.WidgetInfo()
            local ImgHeight = GuiGetImageDimensions(UI.gui, wang)
            UI.Image("MatTooltipWangColorImg", 0, height / 2 - ImgHeight / 2, wang)--居中算法
		end)

        local liquid_static = MatTable[id].attr.liquid_static ~= "0"--是否静态
        NewLine("$conjurer_reborn_material_tooltip_static", liquid_static and "$menu_yes" or "$menu_no")
        local electrical_conductivity = MatTable[id].attr.electrical_conductivity ~= "0"--是否导电
        NewLine("$conjurer_reborn_material_tooltip_electrical", electrical_conductivity and "$menu_yes" or "$menu_no")
		local burnable = MatTable[id].attr.burnable ~= "0"--是否可燃
        NewLine("$conjurer_reborn_material_tooltip_burns", burnable and "$menu_yes" or "$menu_no")
        local on_fire = MatTable[id].attr.on_fire ~= "0"--是否始终燃烧
        NewLine("$conjurer_reborn_material_tooltip_on_fire", on_fire and "$menu_yes" or "$menu_no")
		if burnable or on_fire then
			NewLine("$conjurer_reborn_material_tooltip_fire_hp", MatTable[id].attr.fire_hp)
		end
		NewLine("$conjurer_reborn_material_tooltip_hp", MatTable[id].attr.hp)
        NewLine("$conjurer_reborn_material_tooltip_density", MatTable[id].attr.density)
        NewLine("$conjurer_reborn_material_tooltip_durability", MatTable[id].attr.durability)
        local StainsEffect = nil
		local HasStains = false
		local IngestionEffect = nil
		if MatTable[id].attr.status_effects and MatTable[id].attr.liquid_stains ~= "0" then
            StainsEffect = {MatTable[id].attr.status_effects}
			HasStains = true
		end
        for _, v in pairs(MatTable[id].children) do --为了健壮性的实现索引写的很复杂
            if v.name ~= "StatusEffects" then
                goto continue
            end
            for _, EffectElem in pairs(v.children) do
                for _, effect in pairs(EffectElem.children) do
                    if effect.name ~= "StatusEffect" then --过滤垃圾
                        goto continue
                    end
                    if EffectElem.name == "Stains" then          --两步判断也是过滤垃圾
                        if StainsEffect then                     --判断是否已经有了
                            if HasStains and StainsEffect[1] == effect.attr.type then --沾湿与字段沾湿定义判重
                                goto continue
                            else                                 --如果不是重复的或不是提前定义的
                                StainsEffect[#StainsEffect + 1] = effect.attr.type
                            end
                        else --没有的话，那么就新建表增加
                            StainsEffect = { effect.attr.type }
                        end
                    elseif EffectElem.name == "Ingestion" then
                        if IngestionEffect then
                            IngestionEffect[#IngestionEffect+1] = { effect.attr.type, effect.attr.amount }
                        else
                            IngestionEffect = {
                                { effect.attr.type, effect.attr.amount },
							}
                        end
                    end
                    ::continue::
                end
            end
            ::continue::
        end
        if StainsEffect then--显示沾湿状态
            NewLine("$conjurer_reborn_material_tooltip_stain", "", function()
                for k, v in ipairs(StainsEffect) do
					local effect = StatusTable[v][1]
					if effect == nil then
						goto continue
					end
                    local Name = GetNameOrKey(effect.ui_name)
					local _,TextHeight = GuiGetTextDimensions(UI.gui, Name)
                    local ImgHeight = GuiGetImageDimensions(UI.gui, effect.ui_icon)
                    local ImgX = k == 1 and -5 or 0--第一个向左偏移一点，好看
					
					UI.Image(Name..tostring(k).."Stain",ImgX,TextHeight / 2 - ImgHeight / 2, effect.ui_icon)
                    UI.Text(-2, 0, Name)
					::continue::
				end
			end)
        end
		if IngestionEffect then--显示摄取状态
			NewLine("$conjurer_reborn_material_tooltip_ingest", "",function ()
				for k,v in ipairs(IngestionEffect)do
                    local effect = StatusTable[v[1]][1]
					if effect == nil then
						goto continue
					end
                    local Name = GetNameOrKey(effect.ui_name)
                    local _,TextHeight = GuiGetTextDimensions(UI.gui, Name)
                    local ImgHeight = GuiGetImageDimensions(UI.gui, effect.ui_icon)
                    local ImgX = k == 1 and -5 or 0
					
					UI.Image(Name..tostring(k).."Stain",ImgX,TextHeight / 2 - ImgHeight / 2, effect.ui_icon)
                    UI.Text(-2, 0, Name)
					local PxielText = GameTextGet("$conjurer_reborn_material_tooltip_ingest_pixel",v[2])
                    UI.Text(0, 0, PxielText)
					::continue::
				end
			end)
		end
		if MatTable[id].attr._parent then--显示继承链
			local list = {id}
            local CurrentMat = MatTable[id].attr._parent
            while CurrentMat do
                list[#list + 1] = CurrentMat
                CurrentMat = MatTable[CurrentMat].attr._parent
            end
            local Inherited = table.concat(list, " <- ")
			NewLine("$conjurer_reborn_material_tooltip_inheritance", Inherited)
		end
    else
		UI.Text(0, 0, "$conjurer_reborn_material_tooltip_tip")
	end
	
	UI.VerticalSpacing(3)
	UI.NextColor(72, 209, 204, 255)
	local modName
	if MatTable[id].conjurer_unsafe_from_id ~= "Noita" then
		modName = ModIdToName(MatTable[id].conjurer_unsafe_from_id) or "?"
	else
		modName = "Noita"
	end
	UI.Text(0,0,modName)
end

local SwtichType = {
    {
        name = "$conjurer_reborn_material_type_all",
        id = "AllMaterials",
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_all_mat.png",
        icon_off = "mods/conjurer_reborn/files/gfx/matwand_icons/icon_all_mat_off.png",
        items = GetMaterialList(),
	},
	{
        name = "$conjurer_reborn_material_type_solid",
        id = MatType.Solid,
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_solid.png",
		icon_off="mods/conjurer_reborn/files/gfx/matwand_icons/icon_solid_off.png",
        items = GetMaterialTypeList()[MatType.Solid],
    },
	{
		name = "$conjurer_reborn_material_type_powder",
        id = MatType.Powder,
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_sand.png",
		icon_off="mods/conjurer_reborn/files/gfx/matwand_icons/icon_sand_off.png",
        items = GetMaterialTypeList()[MatType.Powder],
	},
	{
		name = "$conjurer_reborn_material_type_liquid",
        id = MatType.Liquid,
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_liquid.png",
		icon_off="mods/conjurer_reborn/files/gfx/matwand_icons/icon_liquid_off.png",
        items = GetMaterialTypeList()[MatType.Liquid],
    },
	{
		name = "$conjurer_reborn_material_type_gas",
        id = MatType.Gas,
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_gas.png",
		icon_off="mods/conjurer_reborn/files/gfx/matwand_icons/icon_gas_off.png",
        items = GetMaterialTypeList()[MatType.Gas],
    },
	{
		name = "$conjurer_reborn_material_type_box2d",
        id = MatType.Box2d,
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_box2d.png",
		icon_off="mods/conjurer_reborn/files/gfx/matwand_icons/icon_box2d_off.png",
        items = GetMaterialTypeList()[MatType.Box2d],
    },
	{
		name = "$conjurer_reborn_material_type_fire",
        id = MatType.Fire,
		icon="mods/conjurer_reborn/files/gfx/matwand_icons/icon_fire.png",
		icon_off="mods/conjurer_reborn/files/gfx/matwand_icons/icon_fire_off.png",
        items = GetMaterialTypeList()[MatType.Fire],
	}
}

for _, t in pairs(SwtichType) do--移除掉被指定需要被忽略的材料
	for k=#t.items,1,-1 do
		if IngoreMatTable[t.items[k]] then
            table.remove(t.items, k)
        end
	end
end

local MatWandSpriteBG = "mods/conjurer_reborn/files/gfx/9piece_brown.png"
local MatWandSpriteTab = "mods/conjurer_reborn/files/gfx/9piece_brown_tab.png"

local function GetEraserCategories(UI)
    local ActiveMaterial = GetActiveMaterial(UI)
	local eraser_categories = {
		{
            {
				id = "EraserPickerTypeAll",
                text = "$conjurer_reborn_material_eraser_options_all",
				mode = "ALL",
                image = GetEraserSprites("ALL"),
			},
            {
				id = "EraserPickerTypeSelected",
				text = "$conjurer_reborn_material_eraser_options_selected",
				mode = "SELECTED",
				image = GetActiveMaterialsImage(UI),
                desc_fn = function()
					UI.VerticalSpacing(2)
                    UI.Text(0, 0, "$conjurer_reborn_material_eraser_options_selected_desc")
					UI.VerticalSpacing(2)
					MatTooltipText(UI, ActiveMaterial)
				end,
			},
		},
		{
            {
				id = "EraserPickerTypeOfSolid",
				text = "$conjurer_reborn_material_type_solid",
				mode = MatType.Solid,
				image = GetEraserSprites(MatType.Solid),
				desc_fn = function ()
					
				end
            },
			{
				id = "EraserPickerTypeOfPowder",
				text = "$conjurer_reborn_material_type_powder",
				mode = MatType.Powder,
				image = GetEraserSprites(MatType.Powder),
			},
            {
				id = "EraserPickerTypeOfLiquid",
				text = "$conjurer_reborn_material_type_liquid",
				mode = MatType.Liquid,
                image = GetEraserSprites(MatType.Liquid),
			},
            {
				id = "EraserPickerTypeOfGas",
				text = "$conjurer_reborn_material_type_gas",
				mode = MatType.Gas,
                image = GetEraserSprites(MatType.Gas),
            },
			{
				id = "EraserPickerTypeOfBox2D",
				text = "$conjurer_reborn_material_type_box2d",
				mode = MatType.Box2d,
                image = GetEraserSprites(MatType.Box2d),
			},
			{
				id = "EraserPickerTypeOfFire",
				text = "$conjurer_reborn_material_type_fire",
				mode = MatType.Fire,
				image = GetEraserSprites(MatType.Fire),
				desc_fn = function ()
					UI.VerticalSpacing(2)
                    UI.Text(0, 0, "$conjurer_reborn_material_eraser_options_type_fire_desc")
				end
			},
		}
	}
	return eraser_categories
end
local favType = {
    Material = "Material",
    Brush = "Brush",
	Eraser = "Eraser"
}

local favItems
local favStr = ModSettingGet(ModID .. "MatPickerFav")
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
	ModSettingSet(ModID.."MatPickerFav", "return {"..SerializeTable(favItems).."}")
end

---添加材料到收藏中
---@param mat string
local function AddMatFav(mat)
    table.insert(favItems, {
        Type = favType.Material,
        matid = mat
    })
	SavedFavToSetting()
end

---添加画刷到收藏中
---@param CategoryIndex integer
---@param Index integer
local function AddBrushFav(CategoryIndex, Index)
    local brush = GetBrushForKey(CategoryIndex, Index)
	if brush == nil then
		return
	end
	table.insert(favItems, {
        Type = favType.Brush,
        name = brush.name,
        CategoryIndex = CategoryIndex,
		Index = Index
    })
	SavedFavToSetting()
end

---添加橡皮擦到收藏中
---@param mode string
---@param CategoryIndex integer
---@param Index integer
local function AddEraserFav(mode, CategoryIndex, Index)
	table.insert(favItems, {
        Type = favType.Eraser,
        EraserMode = mode,
        CategoryIndex = CategoryIndex,
		Index = Index
    })
	SavedFavToSetting()
end

---橡皮擦选项选择器
---@param UI Gui
local function EraserPicker(UI)
	local X = 30
    local Y = 66
	local eraser_categories = GetEraserCategories(UI)
    UI.Text(X + 2, Y - 19, GameTextGet("$conjurer_reborn_material_eraser_options_head"))
    UI.ScrollContainer("EraserPickerBox", X, Y - 2, 0, 0, 2, 2) --自动宽高
    UI.AddAnywhereItem("EraserPickerBox", function()
		UI.NextZDeep(0)
        UI.Text(0, 0, "$conjurer_reborn_material_eraser_options_material_filters")--开头文字
        UI.GuiTooltip("$conjurer_reborn_material_eraser_options_material_filters_desc")
		UI.VerticalSpacing(2)--稍微增加的间距，美观点
        for i, t in ipairs(eraser_categories) do--渲染那些类型选择格
            UI.BeginHorizontal(0, 0, true)
            for j, v in ipairs(t) do
				UI.NextZDeep(0)
                local left,right = UI.ImageButton(v.id, 0, 0, v.image)
                UI.BetterTooltipsNoCenter(function ()
					UI.Text(0,0,GameTextGetTranslatedOrNot(v.text))
					if v.desc_fn then
						v.desc_fn()
					end
				end,UI.GetZDeep()-100,10)
				
                if left then
                    ClickSound()
                    SetEraserMode(UI, v.mode)
                end
                if right then
					ClickSound()
					AddEraserFav(v.mode, i, j)
				end
            end
            UI.LayoutEnd()
        end
        UI.VerticalSpacing(4)
		--替换模式
        local ReplaceFlag, ReplaceClick = ConjurerCheckbox(UI, "EraserReplaceBtn", 0, 0, "$conjurer_reborn_material_eraser_options_eraser_replace")
		if ReplaceClick then
			SetEraserUseReplacer(UI, ReplaceFlag)
		end
        UI.GuiTooltip("$conjurer_reborn_material_eraser_options_eraser_replace_desc")

		UI.VerticalSpacing(2)
        local WashFlag, WashClick = ConjurerCheckbox(UI, "EraserWashBtn", 0, 0, "$conjurer_reborn_material_eraser_options_eraser_wash")
		if WashClick then
			SetEraserWashMode(UI, WashFlag)
		end
        UI.GuiTooltip("$conjurer_reborn_material_eraser_options_eraser_wash_desc")

		UI.VerticalSpacing(2)

		--网格对齐模式
		local UseBrushGrid, UseBrushClick = ConjurerCheckbox(UI, "EraserUseBrushBtn", 0, 0, "$conjurer_reborn_material_eraser_options_eraser_use_brush_grid", 0, true)
        if UseBrushClick then
            SetEraserUseBrushGrid(UI, UseBrushGrid)
		end
        UI.GuiTooltip("$conjurer_reborn_material_eraser_options_eraser_use_brush_grid_desc")
        if not UseBrushGrid then--关闭共享网格对齐后显示滑条
            UI.VerticalSpacing(2)
            UI.NextZDeep(0)
			
			local GridSliderText = GameTextGet("$conjurer_reborn_material_eraser_grid")
            local value = EasySlider(UI, "EraserPickerGridSlider", 0, 0, GridSliderText, 1, 100, 1, 100, GetEraserGridSize(UI))
			UI.GuiTooltip("$conjurer_reborn_material_eraser_grid_desc")
			SetEraserGridSize(UI, value)
		end

        local FormatNumber = UI.GetSliderValue("EraserGridSize") or 2
		local FormatStr = tostring(FormatNumber * 5).."px"
        UI.VerticalSpacing(4)
        UI.NextZDeep(0)
		local GridSizeText = GameTextGet("$conjurer_reborn_material_eraser_options_size")
		local value = EasySlider(UI, "EraserGridSize", 0, 0, GridSizeText, 1, 20, 2, 60, GetEraserSize(UI), FormatStr)
        SetEraserSize(UI, value)
    end)
	UI.DrawScrollContainer("EraserPickerBox", false, true, MatWandSpriteBG)
end

---绘制画刷选择器
---@param UI Gui
local function BrushPicker(UI)
    local function DrawGridSlot(row, list, TypeIndex) --绘制格子内容
        local count = 1
        UI.BeginHorizontal(0, 0, true)
        for i, v in ipairs(list) do --遍历列表，绘制图标
            if count > row then
                count = 1
                UI.LayoutEnd()
                UI.BeginHorizontal(0, 0, true)
            end
            count = count + 1
            UI.NextZDeep(0)
            local left, right = UI.ImageButton("BrushPickerBox" .. v.name, 0, 0, v.icon_file) --点击操作
            if left then
                ClickSound()
                ChangeActiveBrush(UI, TypeIndex, i)
            end
            if right then
                ClickSound()
                AddBrushFav(TypeIndex, i)
            end
            local Text = GameTextGet(v.name)
            if v.desc then --如果有多余的文本需要，那么就附加上去
                Text = Text .. "\n" .. GameTextGet(v.desc)
            end
            UI.GuiTooltip(Text)
        end
        UI.LayoutEnd()
    end
	
	local X = 30
    local Y = 66
	
    UI.Text(X + 2, Y-19, "$conjurer_reborn_material_brush_options_head")
    UI.ScrollContainer("BrushPickerBox", X, Y-2, 0, 0, 2, 2)--自动宽高
	UI.AddAnywhereItem("BrushPickerBox",function ()
        for i,v in ipairs(Brushes) do
            UI.NextZDeep(0)
            UI.Text(0, 0, GameTextGet(v.name))
            UI.GuiTooltip(GameTextGet(v.tooltip))
            UI.VerticalSpacing(4)
            DrawGridSlot(7, v.brushes, i)--每行七个，和原版conjurer一致
        end
        UI.VerticalSpacing(4)
        UI.NextZDeep(0) --最后一个那个滑条

		local BrushSliderText = GameTextGet("$conjurer_reborn_material_brushes_grid")
		local value = EasySlider(UI, "BrushPickerGridSlider", 0, 0, BrushSliderText, 1, 100, 1, 100, GetBrushGridSize(UI))
        UI.GuiTooltip(GameTextGet("$conjurer_reborn_material_brushes_grid_desc"))
        SetBrushGridSize(UI, value)
		
    end)
	UI.NextZDeep(-100)
	UI.DrawScrollContainer("BrushPickerBox",false, true, MatWandSpriteBG)
end

local SpeChar = string.byte('@')

local LastKeyword
---绘制材料选择框
---@param UI Gui
local function MatPicker(UI)
    local X = 30
    local Y = 58
	local refresh = false
    --渲染选择格
	if UI.UserData["MatWandPageSwitchIndex"] == nil then
		UI.UserData["MatWandPageSwitchIndex"] = 1
	end
    local SwitchIndex = UI.UserData["MatWandPageSwitchIndex"]
	UI.BeginHorizontal(X + 8, Y - 11, true, 4)
	for k,v in pairs(SwtichType)do
		local thiskey = "MatWandPageTap" .. v.id
		GuiBeginAutoBox(UI.gui)--框住用的自动盒子
		local ThisIcon = v.icon_off
        local ThisBG = MatWandSpriteBG
        if SwitchIndex == k then
            ThisIcon = v.icon
			ThisBG = MatWandSpriteTab
        end
        UI.NextZDeep(1)
		local left = UI.ImageButton(thiskey .. "Btn",0,0, ThisIcon)
        if left then
            ClickSound()
            UI.UserData["MatWandPageSwitchIndex"] = k
            SwitchIndex = k
            refresh = true
        end
		UI.BetterTooltipsNoCenter(function ()
            UI.Text(0, 0, v.name)
        end, UI.GetZDeep() - 10, 10, 3)

		UI.NextZDeep(0)
        GuiEndAutoBoxNinePiece(UI.gui, 0, 0, 0, false, 0, ThisBG)
	end
    UI.LayoutEnd()

    local list = SwtichType[SwitchIndex].items
	local return_keyword = ""
    local PageId = "MatWandPage" .. SwtichType[SwitchIndex].id
	UI.NextZDeep(0)
    list, return_keyword = SearchInputBox(UI, "MatwandSearch", list, X + 30, Y + 215, 102.5, 0, refresh,
        function(item, keyword)
			keyword = keyword:lower()
            local Name = GetNameOrKey(MatTable[item].attr.ui_name) --搜索材料本地化名字
            if Name == "" then
                Name = MatTable[item].attr.name
            end
			local lowerName = Name:lower()
            --默认分数是0，分数最低下限也是0，那么第一次获取分数可以不用判断直接赋值
			--减少分支优化
			local score = Cpp.AbsPartialPinyinRatio(lowerName,keyword)

			local lowerId = MatTable[item].attr.name:lower()
            local newScore = Cpp.AbsPartialPinyinRatio(lowerId, keyword)--搜索材料id
            if newScore > score then
                score = newScore
            end
			if string.byte(keyword,1,1) == SpeChar then--搜索模组id/模组名字
				local modId = MatTable[item].conjurer_unsafe_from_id or "?"
				local lowerModId = modId:lower()
				newScore = Cpp.AbsPartialPinyinRatio(lowerModId, string.sub(keyword,2):lower())
                if newScore > score then
                    score = newScore
                end
				local modName = ModIdToName(modId)--获取模组名字
				if modName then--对模组名字判空
					newScore = Cpp.AbsPartialPinyinRatio(modName:lower(), string.sub(keyword,2):lower())
					if newScore > score then
						score = newScore
					end
				end
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
	PageGrid(UI, PageId,list,X,Y+10,160,200,9,10,MatWandSpriteBG,
		function(id)--回调执行表格操作
            UI.NextZDeep(1)
			local path = string.format("mods/conjurer_unsafe/cache/MatIcon/%s.png", id)
			local left,right = UI.ImageButton("MatwandMatPicker" .. id, 0, 0, path)
			UI.BetterTooltipsNoCenter(function()
				MatTooltipText(UI, id)
            end, UI.GetZDeep() - 10, 10, 3)
			
            if left then
                SetActiveMaterial(UI, id)
            end
            if right then
				ClickSound()
				AddMatFav(id)
			end
        end
	)
end

---绘制收藏格
---@param UI Gui
local function DrawFav(UI)
	local OnceRemove = false
    VerticalPage(UI, "MatWandFavVerticalPage", favItems, 6, 138, 0, 0, 9, MatWandSpriteBG, function(value, index)
		UI.NextZDeep(0)
        local right = false
		local left = false
		local NoHasItem = false
        if value.Type == favType.Material then
            if MatTable[value.matid] then
                local path = string.format("mods/conjurer_unsafe/cache/MatIcon/%s.png", value.matid)
                local id = "FAV" .. value.matid .. tostring(index)
                left, right = UI.ImageButton(id, 0, 0, path)
                UI.BetterTooltipsNoCenter(function()
                    MatTooltipText(UI, value.matid)
                end, UI.GetZDeep() - 100, 10)
                if left then
                    ClickSound()
                    SetActiveMaterial(UI, value.matid)
                end
            else
                NoHasItem = true
            end
        elseif value.Type == favType.Eraser then
            local erasers = GetEraserCategories(UI)
            local t = erasers[value.CategoryIndex][value.Index]
            if t == nil or value.EraserMode ~= t.mode then
                NoHasItem = true
            else
                left, right = UI.ImageButton(t.id .. tostring(index), 0, 0, t.image)
                UI.BetterTooltipsNoCenter(function()
                    UI.Text(0, 0, GameTextGetTranslatedOrNot(t.text))
                    if t.desc_fn then
                        t.desc_fn()
                    end
                end, UI.GetZDeep() - 100, 10)

                if left then
                    ClickSound()
                    SetEraserMode(UI, t.mode)
                end
            end
        elseif value.Type == favType.Brush then
            local brush = GetBrushForKey(value.CategoryIndex, value.Index)
            if brush == nil or brush.name ~= value.name then
                NoHasItem = true
            else
                left, right = UI.ImageButton("BrushPickerBox" .. brush.name .. tostring(index), 0, 0, brush.icon_file) --点击操作
                if left then
                    ClickSound()
                    ChangeActiveBrush(UI, value.CategoryIndex, value.Index)
                end
                local Text = GameTextGet(brush.name)
                if brush.desc then --如果有多余的文本需要，那么就附加上去
                    Text = Text .. "\n" .. GameTextGet(brush.desc)
                end
                UI.GuiTooltip(Text)
            end
        end
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

---绘制悬浮材料文本提示
---@param UI Gui
local function MatText(UI)
    local brush = GetActiveBrush(UI)
	local brushEntiy = EntityGetWithName("conjurer_reborn_brush_reticle")
    if brush.name == "$conjurer_reborn_material_tools_eyedropper_tool" and brushEntiy then
		local x, y = EntityGetTransform(brushEntiy)
        local id = GlobalsGetValue("conjurer_reborn.checkmat_material_str_id")
        x, y = UI.GetScreenPosition(x, y)
        local path = string.format("mods/conjurer_unsafe/cache/MatIcon/%s.png", id)
		GuiZSetForNextWidget(UI.gui,3000)
        UI.Image("EyedropperMatImage", x + 2, y + 2, path)
		GuiZSetForNextWidget(UI.gui,3000)
		UI.Text(x, y+22, id)
	end
end

local MainMatBtns = {
    {
		id = "material_picker",
		name = "$conjurer_reborn_material_picker",
        image_func = function(UI)
            return GetActiveMaterialsImage(UI)
		end,
        action = function()
            ToggleActiveOverlay(MatPicker)
		end,
        desc = function(UI)
			MatTooltipText(UI, GetActiveMaterial(UI))
		end
    },
	{
		id = "material_brush_options",
		name = "$conjurer_reborn_material_brush_options",
        image_func = function(UI)
			return GetActiveBrush(UI).icon_file
		end,
        action = function()
            ToggleActiveOverlay(BrushPicker)
		end,
        desc = function(UI)
            UI.Text(0, 0, "$conjurer_reborn_material_brush_options_desc")
		end
	},
    {
		id = "material_eraser_options",
		name = "$conjurer_reborn_material_eraser_options",
		image_func = function (UI)
			return GetActiveEraserImage(UI)
		end,
        action = function()
            ToggleActiveOverlay(EraserPicker)
		end,
		desc = function (UI)
			UI.Text(0,0,"$conjurer_reborn_material_eraser_options_desc")
		end
	},
}

---绘制左边的主按钮
---@param UI Gui
local function MatwandButtons(UI)
    UI.BeginVertical(7, 65, true, 2,2)
	GuiBeginAutoBox(UI.gui)--框住用的自动盒子
    for _, v in ipairs(MainMatBtns) do
        UI.NextZDeep(0)
        local left = UI.ImageButton(v.id, 0, 0, v.image_func(UI))
        if left then
			ClickSound()
            v.action()
        end
        UI.BetterTooltipsNoCenter(function()
            UI.Text(0, 0, v.name)--文本间隔
			UI.VerticalSpacing(3)
            v.desc(UI)
        end, UI.GetZDeep() - 1000, 10, 3)
    end
	UI.NextZDeep(-10)
    GuiEndAutoBoxNinePiece(UI.gui, 1, 0, 0, false, 0, MatWandSpriteBG, MatWandSpriteBG)
    UI.ImageButton("MatPickerFavIcon", 2.5, 2, "mods/conjurer_reborn/files/gfx/fav_icon.png")
	UI.GuiTooltip("$conjurer_reborn_material_fav")
	UI.LayoutEnd()
end

---绘制Matwand的GUI
---@param UI Gui
function DrawMatWandGui(UI)
    EnabledBrushes(UI, true) --保持存在
    MaterialToolEntityUpdate(UI)
	if GetPlayer() == nil or GameIsInventoryOpen() then
		return
	end
	MatText(UI)
    if EyedropperEnable then--判断吸管工具触发
        EyedropperEnable = false
        local id = GlobalsGetValue("conjurer_reborn.checkmat_material_str_id")
        if IngoreMatTable[id] == nil and id then
            SetActiveMaterial(UI, id)
        end
    end
	
    MatwandButtons(UI)
	DrawFav(UI)
    DrawActiveMatwandFn(UI)
end
