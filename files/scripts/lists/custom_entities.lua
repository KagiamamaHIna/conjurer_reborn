function create_image_spawner(z_index)
	return function(path, offset_x, offset_y)
		return function(x, y)
			-- Cursor offsets can be set very accurately for backgrounds.
			local cursor_x = 5
			local cursor_y = 10

			local bg = EntityLoad("mods/conjurer_reborn/files/custom_entities/base_bg_generated.xml", x, y)
			EntityAddComponent2(bg, "SpriteComponent", {
				image_file = path,
				z_index = z_index,
				offset_x = offset_x + cursor_x,
				offset_y = offset_y + cursor_y,
			})

			return bg
		end
	end
end

local spawn_img = create_image_spawner(100)
CUSTOM_ENTITIES = {
	{
		name = "$conjurer_reborn_custom_entities_generator",
		desc = "$conjurer_reborn_custom_entities_generator_desc",
		path = "mods/conjurer_reborn/files/custom_entities/generator/generator.xml",
		image = "mods/conjurer_reborn/files/custom_entities/generator/icon_generator.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_generator_switch",
		desc = "$conjurer_reborn_custom_entities_generator_switch_desc",
		path = "mods/conjurer_reborn/files/custom_entities/generator/switch.xml",
		image = "mods/conjurer_reborn/files/custom_entities/generator/icon_switch.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_door",
		path = "mods/conjurer_reborn/files/custom_entities/door/door.xml",
		image = "mods/conjurer_reborn/files/custom_entities/door/icon_door.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_metal_door",
		desc = "$conjurer_reborn_custom_entities_metal_door_desc",
		path = "mods/conjurer_reborn/files/custom_entities/door_metal/door_metal.xml",
		image = "mods/conjurer_reborn/files/custom_entities/door_metal/icon_door.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_hatch",
		path = "mods/conjurer_reborn/files/custom_entities/hatch/hatch.xml",
		image = "mods/conjurer_reborn/files/custom_entities/hatch/icon_hatch.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_magical_drain",
		desc = "$conjurer_reborn_custom_entities_magical_drain_desc",
		path = "mods/conjurer_reborn/files/custom_entities/drain/drain.xml",
		image = "mods/conjurer_reborn/files/custom_entities/drain/drain.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_grid",
		path = "mods/conjurer_reborn/files/custom_entities/grid/grid.xml",
		image = "mods/conjurer_reborn/files/custom_entities/grid/icon_grid.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_ball",
		path = "mods/conjurer_reborn/files/custom_entities/ball/ball.xml",
		image = "mods/conjurer_reborn/files/custom_entities/ball/ui_gfx.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_bg20win",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_20_window.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg_window.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_bg20",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_20.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_bg40",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_40.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_bg80",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_80.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_bg160",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_160.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_mounted_gun",
		path = "mods/conjurer_reborn/files/custom_entities/mounted_gun/hmg.xml",
		image = "mods/conjurer_reborn/files/custom_entities/mounted_gun/icon.png",
	},
	{
		name = "$conjurer_reborn_custom_entities_domino_blocks",
		path = "mods/conjurer_reborn/files/custom_entities/dominos/physics_domino.xml",
		image = "mods/conjurer_reborn/files/custom_entities/dominos/gfx/icon.png",
    },
	{
		name = "$conjurer_reborn_free_perk_reroll",
		path = "mods/conjurer_reborn/files/custom_entities/free_perk_reroll/free_perk_reroll.xml",
		image = "mods/conjurer_reborn/files/gfx/pickup_icons/perk_reroll.png",
	},
}
