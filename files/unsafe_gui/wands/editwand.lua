dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/edit_draw.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/wand_utilities.lua")

local function IsPhysicalEntity(entity)
	local result = EntityFirstComponent(entity, "PhysicsBody2Component") or
	EntityFirstComponent(entity, "PhysicsBodyComponent")
	return result
end

local EditWandSpriteBG = "data/ui_gfx/decorations/9piece0.png"

local EntityEditActive = true

local MainEditBtns = {
	{
		id = "editwand_move_btn",
		name = "$conjurer_reborn_editwand_move_btn",
		image = "mods/conjurer_reborn/files/gfx/editwand_icons/icon_m1.png",
		desc = "$conjurer_reborn_editwand_move_btn_desc"
	},
	{
		id = "editwand_rotate_btn",
		name = "$conjurer_reborn_editwand_rotate_btn",
		image = "mods/conjurer_reborn/files/gfx/editwand_icons/icon_m2.png",
		desc = "$conjurer_reborn_editwand_rotate_btn_desc"
	},
	{
		id = "editwand_help_btn",
		name = "$conjurer_reborn_editwand_help_btn",
		image = "mods/conjurer_reborn/files/gfx/editwand_icons/icon_use.png",
		desc = "$conjurer_reborn_editwand_help_btn_desc"
	},
}

---绘制左边的主按钮
---@param UI Gui
local function EditwandButtons(UI)
	UI.BeginVertical(7, 65, true, 2, 2)
	GuiBeginAutoBox(UI.gui) --框住用的自动盒子
	for _, v in ipairs(MainEditBtns) do
		UI.NextZDeep(0)
		UI.ImageButton(v.id, 0, 0, v.image)

		UI.GuiTooltip(GameTextGet(v.name) .. "\n" .. GameTextGet(v.desc))
	end

	if UI.UserData["EditWandEntityToInspectEntity"] then
		UI.NextZDeep(0)
		local left = UI.ImageButton("EntityEditActiveBtn", 0, 0,
			"mods/conjurer_reborn/files/gfx/editwand_icons/icon_entity_properties.png")
		UI.GuiTooltip("$conjurer_reborn_editwand_entity_properties")
		if left then
			EntityEditActive = not EntityEditActive
			ClickSound()
		end
	end

	UI.NextZDeep(-10)
	GuiEndAutoBoxNinePiece(UI.gui, 1, 0, 0, false, 0, EditWandSpriteBG, EditWandSpriteBG)
    local ButtonsBoxInfo = UI.WidgetInfoTable()
	InputBlockEasy(UI, "EditwandButtons阻止框", ButtonsBoxInfo)
	
	UI.LayoutEnd()
end

local function GetEntityName(active_entity)
	local filename = EntityGetFilename(active_entity)
	local name = GetNameOrKey(EntityGetName(active_entity))
	if name == "" or name == "unknown" then
		name = Cpp.PathGetFileName(filename)
		name = name:gsub("_", " ")             --将_替换为空格
		local type = Cpp.PathGetFileType(name) --获取后缀名
		local Frist = Cpp.UTF8StringSub(name, 1, 1):upper()
		if type then                           --除去后缀名，移除首字母
			name = Cpp.UTF8StringSub(name, 2, #name - #type - 1)
		else                                   --如果没有后缀名，就只移除首字母
			name = Cpp.UTF8StringSub(name, 2, #name)
		end
		name = Frist .. name
	end
	return name
end

local LastEntity
---如果有标记实体就绘制
---@param UI Gui
local function EditwandInspect(UI)
	local entity = UI.UserData["EditWandEntityToInspectEntity"]
    if entity and LastEntity ~= entity then --切换时强制显示面板
        EntityEditActive = true
    end

	if entity == nil or not EntityGetIsAlive(entity) or not EntityEditActive then
		if not EntityGetIsAlive(entity) then --如果非存活，清理并使打开按钮不显示
			UI.UserData["EditWandEntityToInspectEntity"] = nil
		end
		return
	end
	LastEntity = entity
	local X = 30
	local Y = 66
	local name = GetEntityName(entity)
    if name == "" then
        name = "$conjurer_reborn_editwand_entity_nameless"
    end
	UI.NextZDeep(0)
	UI.Text(X + 2, Y - 19, name)
	UI.ScrollContainer("EditWandEntityEdit", X, Y - 2, 0, 0, 3.5, 3.5) --自动宽高
	UI.AddAnywhereItem("EditWandEntityEdit", function()
		local x, y, rotation, scale_x, scale_y = EntityGetTransform(entity)
		local PositionText = string.format("X: %.2f, Y: %.2f", x, y)
		UI.BeginHorizontal(0, 0, true)
		UI.NextZDeep(0)
		UI.Image("EditWandPositionImg", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/info_position.png")
		UI.GuiTooltip("$conjurer_reborn_editwand_position")
		UI.HorizontalSpacing(1)

		UI.NextZDeep(0)
		UI.Text(0, 0, PositionText)
		UI.GuiTooltip("$conjurer_reborn_editwand_position")
		UI.LayoutEnd()

		local RadText = string.format("%.2f", rotation)
		local deg = math.deg(rotation)
        if deg < 0 then
            deg = deg + 360
		end
		local DegText = string.format("%.2f", deg)
		local RotationText = GameTextGet("$conjurer_reborn_editwand_rotation_text", RadText, DegText)
		UI.BeginHorizontal(0, 0, true)
		UI.NextZDeep(0)
		UI.Image("EditWandRotationImg", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/info_rotation.png")
		UI.GuiTooltip("$conjurer_reborn_editwand_rotation")
		UI.HorizontalSpacing(1)

		UI.NextZDeep(0)
		UI.Text(0, 0, tostring(RotationText))
		UI.GuiTooltip("$conjurer_reborn_editwand_rotation")
		UI.LayoutEnd()

		local ScaleText = string.format("%.2f, %.2f", scale_x, scale_y)
		UI.BeginHorizontal(0, 0, true)
		UI.NextZDeep(0)
		UI.Image("EditWandSacleImg", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/info_scale.png")
		UI.GuiTooltip("$conjurer_reborn_editwand_scale")
		UI.HorizontalSpacing(1)

		UI.NextZDeep(0)
		UI.Text(0, 0, tostring(ScaleText))
		UI.GuiTooltip("$conjurer_reborn_editwand_scale")
		UI.LayoutEnd()

		local tags = EntityGetTags(entity)
        if not tags or tags == "" then
            tags = "$conjurer_reborn_editwand_no_tag"
        end
		local TagsText = GameTextGet("$conjurer_reborn_editwand_tag", GameTextGetTranslatedOrNot(tags))
		local XmlPath = GameTextGet("$conjurer_reborn_editwand_entity", EntityGetFilename(entity))
		local EntityIDText = GameTextGet("$conjurer_reborn_editwand_entity_id", tostring(entity))
		UI.BeginHorizontal(0, 0, true)
		UI.NextZDeep(0)
		UI.Image("EditWandHoverImg", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/info_xml.png")
		UI.GuiTooltip("$conjurer_reborn_editwand_info_xml")
		UI.HorizontalSpacing(1)

		UI.NextColor(180, 159, 129, 255)
		UI.NextZDeep(0)
		UI.Text(0, 0, "$conjurer_reborn_editwand_info_xml_text")
		UI.GuiTooltip(EntityIDText.."\n"..XmlPath .. "\n" .. TagsText)
		UI.LayoutEnd()

		UI.VerticalSpacing(2)
		UI.NextColor(155, 173, 183, 255)
		UI.NextZDeep(0)
		UI.Text(0, 0, "$conjurer_reborn_editwand_fine_tuning")
        if IsPhysicalEntity(entity) then
            UI.NextColor(180, 159, 129, 255)
            UI.NextZDeep(0)
            UI.Text(0, 0, "$conjurer_reborn_editwand_not_supported")
			UI.GuiTooltip("$conjurer_reborn_editwand_not_supported_desc")
        else
            local function incr(var, amount)
                local sign = var < 0 and -1 or 1
                return var + amount * sign
            end


            local function decr(var, amount)
                local sign = var < 0 and -1 or 1

                local new = var - amount * sign

                if sign == 1 then
                    return math.max(0.01, new)
                end

                return math.min(0.01, new)
            end

            local function EasyIncr(amount)
                EntitySetTransform(entity, x, y, rotation, incr(scale_x, amount), incr(scale_y, amount))
            end

            local function EasyDecr(amount)
                EntitySetTransform(entity, x, y, rotation, decr(scale_x, amount), decr(scale_y, amount))
            end

            local function AddRot(add_deg)
                EntitySetTransform(entity, x, y, rotation + math.rad(add_deg), scale_x, scale_y)
            end

            local function AddXPos(add_pos)
                EntitySetTransform(entity, x + add_pos, y, rotation, scale_x, scale_y)
            end

            local function AddYPos(add_pos)
                EntitySetTransform(entity, x, y + add_pos, rotation, scale_x, scale_y)
            end

            ---第一行
            UI.BeginHorizontal(0, -5, true)

            UI.NextZDeep(0)
            if UI.ImageButton("little_rot_deg_sub", 11, 12, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_left_cycle_small.png") then
                AddRot(-0.5)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_little_rot_deg_sub")

            UI.NextZDeep(0)
            if UI.ImageButton("little_rot_deg_add", 12, 12, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_right_cycle_small.png") then
                AddRot(0.5)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_little_rot_deg_add")

            UI.LayoutEnd()

            ---第二行
            UI.BeginHorizontal(0, 2, true)

            UI.NextZDeep(0)
            if UI.ImageButton("large_rot_deg_sub", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_left_cycle.png") then
                AddRot(-90)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_large_rot_deg_sub")

            UI.NextZDeep(0)
            if UI.ImageButton("y_pos_add", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_up.png") then
                AddYPos(-1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_y_pos_add")

            UI.NextZDeep(0)
            if UI.ImageButton("large_rot_deg_add", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_right_cycle.png") then
                AddRot(90)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_large_rot_deg_add")

            UI.LayoutEnd()

            ---第三行
            UI.BeginHorizontal(0, 2, true)

            UI.NextZDeep(0)
            if UI.ImageButton("x_pos_sub", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_left.png") then
                AddXPos(-1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_x_pos_sub")

            UI.NextZDeep(0)
            if UI.ImageButton("y_pos_sub", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_down.png") then
                AddYPos(1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_y_pos_sub")

            UI.NextZDeep(0)
            if UI.ImageButton("x_pos_add", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_right.png") then
                AddXPos(1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_x_pos_add")

            UI.LayoutEnd()

            ---第四行
            UI.BeginHorizontal(0, 2, true)

            UI.BeginVertical(0, 1, true)
            UI.NextZDeep(0)
            if UI.ImageButton("scale_add_01", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_plus_small.png") then
                EasyIncr(0.1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_scale_add_01")

            UI.VerticalSpacing(1)

            UI.NextZDeep(0)
            if UI.ImageButton("scale_add_001", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_plus_small.png") then
                EasyIncr(0.01)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_scale_add_001")
            UI.LayoutEnd()

            ---垂直排列之后
            UI.HorizontalSpacing(2)
            UI.NextZDeep(0)
            if UI.ImageButton("scale_add_05", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_plus.png") then
                EasyIncr(0.5)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_scale_add_05")

            UI.NextZDeep(0)
            if UI.ImageButton("scale_sub_0", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_minus.png") then
                EasyDecr(0.5)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_scale_sub_05")

            ---第二个垂直排列
            UI.BeginVertical(0, 1, true)
            UI.NextZDeep(0)
            if UI.ImageButton("scale_sub_01", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_minus_small.png") then
                EasyDecr(0.1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_scale_sub_01")

            UI.VerticalSpacing(1)

            UI.NextZDeep(0)
            if UI.ImageButton("scale_sub_001", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_minus_small.png") then
                EasyDecr(0.01)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_scale_sub_001")
            UI.LayoutEnd()

            UI.LayoutEnd()

            UI.BeginHorizontal(-1, 13, true)

            UI.NextZDeep(0)
            if UI.ImageButton("editwand_flip_horizontally", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_horizontal.png") then
                EntitySetTransform(entity, x, y, rotation, scale_x * -1, scale_y)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_flip_horizontally")

            UI.NextZDeep(0)
            if UI.ImageButton("editwand_flip_vertically", 0, 0, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_arrow_vertical.png") then
                EntitySetTransform(entity, x, y, rotation, scale_x, scale_y * -1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_flip_vertically")

            UI.NextZDeep(0)
            if UI.ImageButton("editwand_reset_entity", 0, 1, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_reset_3.png") then
                EntitySetTransform(entity, x, y, 0, 1, 1)
                ClickSound()
            end
            UI.GuiTooltip("$conjurer_reborn_editwand_reset_entity")

            UI.LayoutEnd()
        end
        UI.VerticalSpacing(18)
		UI.NextColor(155, 173, 183, 255)
		UI.NextZDeep(0)
        UI.Text(0, 0, "$conjurer_reborn_editwand_other")
		
        UI.BeginHorizontal(0, 0, true)
		
		UI.NextZDeep(0)
		if UI.ImageButton("editwand_kill_entity", 0, 1, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_kill.png") then
			EntityTrueKillOrDelete(entity, true)
			ClickSound()
		end
		UI.GuiTooltip("$conjurer_reborn_editwand_kill_entity")

		UI.NextZDeep(0)
		if UI.ImageButton("editwand_delete_entity", 0, 1, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_del.png") then
			EntityKill(entity)
			ClickSound()
		end
		UI.GuiTooltip("$conjurer_reborn_editwand_delete_entity")

		UI.NextZDeep(0)
		if UI.ImageButton("editwand_clone_entity", 0, 1, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_cln.png") then
            EntityLoadProcessed(EntityGetFilename(entity), x + 10, y - 10)
			ClickSound()
		end
		UI.GuiTooltip(GameTextGet("$conjurer_reborn_editwand_clone_entity").."\n"..GameTextGet("$conjurer_reborn_editwand_clone_entity_desc"))

		UI.LayoutEnd()
	end)
	UI.DrawScrollContainer("EditWandEntityEdit", true, true)
end

---绘制Entwand的GUI
---@param UI Gui
function DrawEditWandGui(UI)
    EditWandUpdate(UI)
	if GameIsInventoryOpen() then --下面只是按钮绘制
		return
	end

	EditwandButtons(UI)
	EditwandInspect(UI)
end
