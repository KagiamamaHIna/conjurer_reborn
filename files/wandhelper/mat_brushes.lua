dofile_once("mods/conjurer_reborn/files/wandhelper/mat_tools.lua")

local _radial_warning="$conjurer_reborn_material_brushes_radial_warning"

local Brushes = {
	{
		name = "$conjurer_reborn_material_brushes_1px",
		desc = "$conjurer_reborn_material_brushes_1px_desc",
		offset_x = 1,
		offset_y = 0,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/1_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/1_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/1_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_2px",
		offset_x = 1,
		offset_y = 1,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/2_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/2_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/2_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_5px",
		offset_x = 3,
		offset_y = 2,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/5_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/5_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/5_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_10px",
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/10_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/10_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/10_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_20px",
		offset_x = 10,
		offset_y = 10,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/20_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/20_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/20_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_80px",
		offset_x = 40,
		offset_y = 40,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/80_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/80_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/80_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_horizontal_40px",
		offset_x = 20,
		offset_y = 1,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_lh_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_lh_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_lh_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_vertical_40px",
		offset_x = 1,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_lv_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_lv_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_lv_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_diagonal_40px_1",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_d1_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_d1_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_d1_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_diagonal_40px_2",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_d2_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_d2_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_d2_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_hollow_box_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_box_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_box_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_box_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_triangle_up_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_tri_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_tri_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_tri_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_triangle_left_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_trir_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_trir_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_trir_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_triangle_down_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_trid_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_trid_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_trid_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_triangle_right_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_tril_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_tril_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_tril_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_circular_40px",
		offset_x = 20,
		offset_y = 20,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_cir_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_cir_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/40_cir_icon.png",
		physics_supported = true,
	},
	{
		name = "$conjurer_reborn_material_brushes_cauldron_40px",
		offset_x = 12,
		offset_y = 13,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/cauldron_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/cauldron_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/cauldron_icon.png",
		physics_supported = true,
	},
}


local Growers = {
	{
		name = "$conjurer_reborn_material_growing_brushes_tree",
		desc = _radial_warning,
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/tree_2_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/tree_2_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/tree_2_icon.png",
		click_to_use = true,
		physics_supported = false,
		raytrace_from_center = true,
	},
	{
		name = "$conjurer_reborn_material_growing_brushes_small_radial_expander",
		desc = _radial_warning,
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_xs_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_xs_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_xs_icon.png",
		click_to_use = true,
		physics_supported = false,
		raytrace_from_center = true,
	},
	{
		name = "$conjurer_reborn_material_growing_brushes_medium_radial_expander",
		desc = _radial_warning,
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_s_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_s_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_s_icon.png",
		click_to_use = true,
		physics_supported = false,
		raytrace_from_center = true,
	},
	{
		name = "$conjurer_reborn_material_growing_brushes_large_radial_expander",
		desc = _radial_warning,
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_m_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_m_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_m_icon.png",
		click_to_use = true,
		physics_supported = false,
		raytrace_from_center = true,
	},
	{
		name = "$conjurer_reborn_material_growing_brushes_huge_radial_expander",
		desc = _radial_warning,
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_l_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_l_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/radial_l_icon.png",
		click_to_use = true,
		physics_supported = false,
		raytrace_from_center = true,
	},
}

local Tools = {
	{
		name = "$conjurer_reborn_material_tools_filler_tool",
		desc = "$conjurer_reborn_material_tools_filler_tool_desc",
		offset_x = 5,
		offset_y = 5,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/filler_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/filler_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/filler_icon.png",
		click_to_use = true,
		physics_supported = true,
		action = filler_action,
		release_action = filler_release_action,
    },
	{
        name = "$conjurer_reborn_material_tools_eyedropper_tool",
		desc = "$conjurer_reborn_material_tools_eyedropper_tool_desc",
		offset_x = 0,
		offset_y = 10,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/eyedropper_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/0_reticle.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/eyedropper_icon.png",
		click_to_use = true,
		physics_supported = true,
		action = EyedropperAction,
		release_action = EyedropperReleaseAction,
	},
	{
		name = "$conjurer_reborn_material_tools_line_tool",
		desc = "$conjurer_reborn_material_tools_not_filler_desc",
		offset_x = 0,
		offset_y = 0,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/0_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/scaled_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/line_icon.png",
		physics_supported = true,
		click_to_use = false,
		action = line_action,
		release_action = dragger_release_action,
	},
	{
		name = "$conjurer_reborn_material_tools_rectangle_tool",
		desc = "$conjurer_reborn_material_tools_not_filler_desc",
		offset_x = 0,
		offset_y = 0,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/0_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/scaled_brush.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/rectangle_icon.png",
		brush_sprite_size = 1,
		physics_supported = true,
		click_to_use = false,
		action = corner_aligned_polygon_action,
		release_action = dragger_release_action,
	},
	{
		name = "$conjurer_reborn_material_tools_ellipse_tool",
		desc = "$conjurer_reborn_material_tools_not_filler_desc",
		offset_x = 0,
		offset_y = 0,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/0_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/scaled_brush_circle.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/circle_icon.png",
		brush_sprite_size = 500,
		physics_supported = true,
		click_to_use = false,
		action = corner_aligned_polygon_action,
		release_action = dragger_release_action,
	},
	{
		name = "$conjurer_reborn_material_tools_rectangle_tool_hollow",
		desc = "$conjurer_reborn_material_tools_not_filler_desc",
		offset_x = 0,
		offset_y = 0,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/0_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/scaled_brush_empty.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/rectangle_icon_empty.png",
		brush_sprite_size = 500,
		physics_supported = true,
		click_to_use = false,
		action = corner_aligned_polygon_action,
		release_action = dragger_release_action,
    },
	{
		name = "$conjurer_reborn_material_tools_ellipse_tool_hollow",
		desc = "$conjurer_reborn_material_tools_not_filler_desc",
		offset_x = 0,
		offset_y = 0,
		reticle_file = "mods/conjurer_reborn/files/wands/matwand/brushes/0_reticle.png",
		brush_file = "mods/conjurer_reborn/files/wands/matwand/brushes/scaled_brush_circle_empty.png",
		icon_file = "mods/conjurer_reborn/files/wands/matwand/brushes/circle_icon_empty.png",
		brush_sprite_size = 500,
		physics_supported = true,
		click_to_use = false,
		action = corner_aligned_polygon_action,
		release_action = dragger_release_action,
	},
}

local f, err = loadfile("mods/conjurer_reborn/files/scripts/lists/new_brushes.lua")
if f == nil then
    print("conjurer_reborn:new_brushes.lua has error! err:",err)
else
	local env = {}
	setmetatable(env, { __index = _G }) --继承全局环境
    setfenv(f, env)()
	for _, v in pairs(env.BRUSHES or {}) do
		Brushes[#Brushes + 1] = v
	end
	for _, v in pairs(env.GROWERS or {}) do
		Growers[#Growers+1] = v
	end
	for _, v in pairs(env.TOOLS or {}) do
		Tools[#Tools+1] = v
	end
end

local ALL_DRAWING_TOOLS = {
	{
		name = "$conjurer_reborn_material_brushes_type_basic",
		tooltip = "$conjurer_reborn_material_brushes_type_basic_desc",
		brushes = Brushes,
	},
	{
		name = "$conjurer_reborn_material_brushes_type_growing",
		tooltip = "$conjurer_reborn_material_brushes_type_growing_desc",
		brushes = Growers,
	},
	{
		name = "$conjurer_reborn_material_brushes_type_tools",
		tooltip = "$conjurer_reborn_material_brushes_type_tools_desc",
		brushes = Tools,
	},
}


return ALL_DRAWING_TOOLS
