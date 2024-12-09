---@class Gui
local UI = dofile("mods/conjurer_reborn/files/unsafe/gui.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/SearchForList.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")

CSV = ParseCSV(ModTextFileGetContent("data/translations/common.csv"))

--GUI加载
dofile_once("mods/conjurer_reborn/files/unsafe_gui/wands/matwand.lua")

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

local BtnX = 20
local BtnY = 7.5

local function A()
	
end

local function B()
	
end

local MainBtns = {
    {
        name = "$conjurer_reborn_wand_matwand",
		desc = "$conjurer_reborn_wand_matwand_desc",
        id = "MatWandBtn",
        image = "mods/conjurer_reborn/files/wands/matwand/matwand.png",
        action = DrawMatWandGui,
		active = function ()
			EnabledBrushes(UI, true)
		end,
		release = function ()
			EnabledBrushes(UI, false)
		end
    },
	{
        name = "$conjurer_reborn_wand_entwand",
		desc = "$conjurer_reborn_wand_entwand_desc",
        id = "EntWandBtn",
        image = "mods/conjurer_reborn/files/wands/entwand/entwand.png",
        action = A,
		active = function ()
			
		end,
		release = function ()
			
		end
    },
	{
        name = "$conjurer_reborn_wand_editwand",
		desc = "$conjurer_reborn_wand_editwand_desc",
        id = "EditWandBtn",
        image = "mods/conjurer_reborn/files/wands/editwand/editwand.png",
        action = B,
		active = function ()
			
		end,
		release = function ()
			
		end
	}
}

UI.OnceCallOnExecute(function ()--尝试移除
	EnabledBrushes(UI, false)
end)

UI.MainTickFn["Main"] = function()
    for i = 1, #MainBtns do
		if ActiveTable ~= MainBtns[i] then--未激活是半透明的
            UI.NextOption(GUI_OPTION.DrawSemiTransparent)
		end
		UI.NextZDeep(0)
        local left = UI.EasyMoveImgBtn(MainBtns[i].id, BtnX + 20 * (i - 1), BtnY, MainBtns[i].image)
		UI.BetterTooltipsNoCenter(function ()
            UI.Text(0, 0, MainBtns[i].name)
			UI.VerticalSpacing(2)
			UI.Text(0, 0, MainBtns[i].desc)
        end, -3000, 10)
		
        if left then
			ClickSound()
            ToggleActiveOverlay(MainBtns[i])
		end
	end
    if ActiveTable then
        ActiveTable.action(UI)
    end
end

return UI.DispatchMessage
