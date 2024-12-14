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
		name = "Generator",
		desc = "Requires a switch to work",
		path = "mods/conjurer_reborn/files/custom_entities/generator/generator.xml",
		image = "mods/conjurer_reborn/files/custom_entities/generator/icon_generator.png",
	},
	{
		name = "Generator switch",
		desc = "Toggles the closest generator",
		path = "mods/conjurer_reborn/files/custom_entities/generator/switch.xml",
		image = "mods/conjurer_reborn/files/custom_entities/generator/icon_switch.png",
	},
	{
		name = "Door",
		path = "mods/conjurer_reborn/files/custom_entities/door/door.xml",
		image = "mods/conjurer_reborn/files/custom_entities/door/icon_door.png",
	},
	{
		name = "Metal door",
		desc = "Can be powered by electricity.",
		path = "mods/conjurer_reborn/files/custom_entities/door_metal/door_metal.xml",
		image = "mods/conjurer_reborn/files/custom_entities/door_metal/icon_door.png",
	},
	{
		name = "Hatch",
		path = "mods/conjurer_reborn/files/custom_entities/hatch/hatch.xml",
		image = "mods/conjurer_reborn/files/custom_entities/hatch/icon_hatch.png",
	},
	{
		name = "Magical Drain",
		desc = "Sucks up liquids, sands & gases.\nMakes sewage a breeze!",
		path = "mods/conjurer_reborn/files/custom_entities/drain/drain.xml",
		image = "mods/conjurer_reborn/files/custom_entities/drain/drain.png",
	},
	{
		name = "Grid",
		path = "mods/conjurer_reborn/files/custom_entities/grid/grid.xml",
		image = "mods/conjurer_reborn/files/custom_entities/grid/icon_grid.png",
	},
	{
		name = "Ball",
		path = "mods/conjurer_reborn/files/custom_entities/ball/ball.xml",
		image = "mods/conjurer_reborn/files/custom_entities/ball/ui_gfx.png",
	},
	{
		name = "Background 20px - Windowed",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_20_window.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg_window.png",
	},
	{
		name = "Background 20px",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_20.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "Background 40px",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_40.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "Background 80px",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_80.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "Background 160px",
		spawn_func = spawn_img("mods/conjurer_reborn/files/custom_entities/backgrounds/bg_160.png", 0, 0),
		image = "mods/conjurer_reborn/files/custom_entities/backgrounds/icon_bg.png",
	},
	{
		name = "Mounted Gun",
		path = "mods/conjurer_reborn/files/custom_entities/mounted_gun/hmg.xml",
		image = "mods/conjurer_reborn/files/custom_entities/mounted_gun/icon.png",
	},
	{
		name = "Domino Blocks",
		path = "mods/conjurer_reborn/files/custom_entities/dominos/physics_domino.xml",
		image = "mods/conjurer_reborn/files/custom_entities/dominos/gfx/icon.png",
	},
}
