dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/edit_draw.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/wand_utilities.lua")
---@module "basexx"
local basexx = dofile_once("mods/conjurer_reborn/files/lib/basexx.lua")

---将玩家变形为任意实体
---@param src integer
---@param target integer
local function PolymorphToEntity(src, target)
    local SrcBase64 = basexx.to_base64(APIExtend.SerializeEntity(src))
    APIExtend.SetPlayerEntity(target)
    EntityKill(src)
    local srcObj = EntityObj(src)
    local entityObj = EntityObj(target)
    entityObj:NewChild().NewComp.GameEffectComponent {
        frames = 2147483647,
        disable_movement = false,
        effect = "POLYMORPH",
        mSerializedData = SrcBase64,
    }.NewComp.InheritTransformComponent {}

    EntityRemoveTag(src, "player_unit")--让他不再被视为玩家，因为实体删除本身是有延迟的
    entityObj:AddTag("polymorphed_player"):AddTag("polymorphed")
    local cursor = entityObj:GetChildWithName("conjurer_reborn_editwand_cursor")
    if cursor then
        cursor:Kill()
    end
    local indicator = entityObj:GetChildWithName("conjurer_reborn_editwand_indicator")
    if indicator then
        indicator:Kill()
    end

    local cc = entityObj.comp_all.ControlsComponent
    if cc == nil then
        _, cc = entityObj.NewComp.ControlsComponent {
            enabled = true,
            polymorph_hax = true
        }
    else
        cc[1].attr.enabled = true
        cc[1].attr.polymorph_hax = true
        cc[1]:SetEnable(true)
    end
    local ai = entityObj.comp_all.AnimalAIComponent
    if ai ~= nil then
        ai[1]:SetEnable(false)
    end
    local dragonBoss = entityObj.comp.BossDragonComponent
    if dragonBoss ~= nil then
        entityObj.NewComp.WormComponent {
            speed = dragonBoss[1].attr.speed,
            acceleration = dragonBoss[1].attr.acceleration,
            gravity = 0,
            tail_gravity = dragonBoss[1].attr.tail_gravity,
            part_distance = dragonBoss[1].attr.part_distance,
            ground_check_offset = dragonBoss[1].attr.ground_check_offset,
            hitbox_radius = dragonBoss[1].attr.hitbox_radius,
            bite_damage = dragonBoss[1].attr.bite_damage,
            target_kill_radius = dragonBoss[1].attr.target_kill_radius,
            target_kill_ragdoll_force = dragonBoss[1].attr.target_kill_ragdoll_force,
            jump_cam_shake = dragonBoss[1].attr.jump_cam_shake,
            jump_cam_shake_distance = dragonBoss[1].attr.jump_cam_shake_distance,
            eat_anim_wait_mult = dragonBoss[1].attr.eat_anim_wait_mult,
            ragdoll_filename = dragonBoss[1].attr.ragdoll_filename,
        }
        dragonBoss[1]:SetEnable(false)
    end
    local worm = entityObj.comp.WormComponent
    if worm ~= nil then
        entityObj.NewComp.WormPlayerComponent {}
    end

    entityObj.NewComp.FogOfWarRadiusComponent {}
    entityObj.NewComp.FogOfWarRemoverComponent {}
    local srcGSC = srcObj.comp.GameStatsComponent
    if srcGSC then
        entityObj.NewComp.GameStatsComponent {
            name = srcGSC[1].attr.name,
            stats_filename = srcGSC[1].attr.stats_filename,
            extra_death_msg = GameTextGet("$death_polymorph", GameTextGetTranslatedOrNot(entityObj:GetName())),
            dont_do_logplayerkill = srcGSC[1].attr.dont_do_logplayerkill,
            player_polymorph_count = srcGSC[1].attr.player_polymorph_count + 1
        }
    end
    for _, v in ipairs(entityObj.comp_all.CameraBoundComponent or {}) do
        v:RemoveSelf() --防止因为cbc删了玩家
    end
    for _, v in ipairs(entityObj.comp_all.WormAIComponent or {}) do
        v:SetEnable(false)
    end
end

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

local function GetEntityName(active_entity, isFileName)
	local filename = EntityGetFilename(active_entity)
	local name = GetNameOrKey(EntityGetName(active_entity))
	if name == "" or name == "unknown" or isFileName then
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
            local BinEntity = APIExtend.SerializeEntity(entity)
            local NewEntity = APIExtend.DeserializeEntity(EntityCreateNew(), BinEntity, x + 10, y - 10)
            NewEntity = EntityObj(NewEntity)
            
            local cursor = NewEntity:GetChildWithName("conjurer_reborn_editwand_cursor")
            if cursor then
                cursor:Kill()
            end
            local indicator = NewEntity:GetChildWithName("conjurer_reborn_editwand_indicator")
            if indicator then
                indicator:Kill()
            end
			ClickSound()
		end
		UI.GuiTooltip("$conjurer_reborn_editwand_clone_entity")

        UI.NextZDeep(0)
        if UI.ImageButton("editwand_save_entity", 0, 1, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_sav.png") then
            local basename = GetEntityName(entity, true)
            local save_file = "debug/conjurer_" .. basename .. ".xml"
            if DebugGetIsDevBuild() then
                EntitySave(entity, save_file)
            else
                if not Cpp.PathExists("debug") then
                    Cpp.CreateDir("debug")
                end
                local save = io.open(save_file, "w+")
                TryCatch(
                    function()
                        save:write(EntitySerialize(entity))
                    end,
                    function(...)
                        GamePrint("Dump Error:", ...)
                    end)()
                save:close()
            end
            GamePrint(GameTextGet("$conjurer_reborn_editwand_save_entity_game_print", save_file))
            ClickSound()
        end
        if DebugGetIsDevBuild() then
            UI.GuiTooltip("$conjurer_reborn_editwand_save_entity_desc")
        else
            UI.GuiTooltip("$conjurer_reborn_editwand_save_entity_desc", "$conjurer_reborn_editwand_save_entity_desc_normal")
        end

        UI.NextZDeep(0)
        if UI.ImageButton("editwand_poly_entity", 0, 1, "mods/conjurer_reborn/files/gfx/editwand_icons/icon_pol.png") then
            local player = GetPlayer()
            if player ~= nil then
                PolymorphToEntity(player, entity)
            end
        end
        UI.GuiTooltip("$conjurer_reborn_editwand_poly_entity", "$conjurer_reborn_editwand_poly_entity_desc")

        UI.LayoutEnd()
        local entityObj = EntityObj(entity)
        if entityObj.comp.HitboxComponent then
            UI.VerticalSpacing(2)
            local HitBoxChild = entityObj:GetChildWithName("conjurer_reborn_hitbox_updater")

            if HitBoxChild then
                UI.UserData["editwand_show_hitboxesStatus"] = true
            else
                UI.UserData["editwand_show_hitboxesStatus"] = false
            end
            local enable, click = ConjurerCheckboxNoSave(UI, "editwand_show_hitboxes", 0, 0, "$conjurer_reborn_editwand_show_hitboxes")
            if click then
                if HitBoxChild then
                    HitBoxChild:Kill()
                else
                    entityObj:NewChild("conjurer_reborn_hitbox_updater")
                    .NewComp.LuaComponent {
                        script_source_file="mods/conjurer_reborn/files/scripts/update_hitbox_sprites.lua",
                        execute_on_added=true,
                        execute_every_n_frame=1,
                    }
                    .NewComp.InheritTransformComponent {}
                end
            end
        end
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
