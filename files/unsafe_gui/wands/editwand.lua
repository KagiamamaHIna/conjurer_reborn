dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")

local EditWandSpriteBG = "data/ui_gfx/decorations/9piece0.png"

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
    UI.BeginVertical(7, 65, true, 2,2)
	GuiBeginAutoBox(UI.gui)--框住用的自动盒子
    for _, v in ipairs(MainEditBtns) do
        UI.NextZDeep(0)
        UI.ImageButton(v.id, 0, 0, v.image)

		UI.GuiTooltip(GameTextGet(v.name).."\n"..GameTextGet(v.desc))
    end
	UI.NextZDeep(-10)
    GuiEndAutoBoxNinePiece(UI.gui, 1, 0, 0, false, 0, EditWandSpriteBG, EditWandSpriteBG)

	UI.LayoutEnd()
end

---绘制Entwand的GUI
---@param UI Gui
function DrawEditWandGui(UI)
	EditwandButtons(UI)
end
