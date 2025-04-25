local DRAGGER_NAME = "conjurer_reborn_matwand_dragger_reticle"

--
-- Filler tool
--
function filler_action(material, brush, x, y)
	local filler = EntityCreateNew()

	EntityAddComponent2(filler, "LifetimeComponent", { lifetime = 2 })
	EntityAddComponent2(
		filler,
		"ParticleEmitterComponent",
		GetMatDrawVars("conjurer_reborn_construction_paste", brush)
	)

	EntitySetTransform(filler, x, y)
end

function filler_release_action(material, brush, x, y)
	ConvertMaterialOnAreaInstantly(
		x - 1000, y - 1000,
		2000, 2000,
		CellFactory_GetType("conjurer_reborn_construction_paste"), CellFactory_GetType(material),
		true,
		false
	)
end

--
-- Line tool
--
function line_action(material, brush, x, y)
	local FINAL_WIDTH = 4
	local WIDTH_OFFSET = 0.5

	local line = EntityGetWithName(DRAGGER_NAME)

	if EntityGetIsAlive(line) then
		-- Get coordinates of starting point
		local line_x, line_y = EntityGetTransform(line)

		local length = get_distance(line_x, line_y, x, y)
		local rotation = math.atan2(y - line_y, x - line_x)
        if InputIsKeyDown(Key_LSHIFT) or InputIsKeyDown(Key_RSHIFT) then
			local isNeg = false
			if rotation < 0 then--将负数度数（其实就是>180）转换为正数处理，后续换回负数
				isNeg = true
				rotation = -rotation
			end
			local rotationDeg = math.deg(rotation)
            
            local OneLen = 180 / 8--计算单次弧度的大小，一共分为8组，以180度为基础
			local HalfOne = OneLen / 2--单次的一半，用于计算应该选用的范围
            local RotLen = math.floor(rotationDeg / OneLen)--计算具体在那个位置
            local RotMore = rotationDeg % OneLen--求出多出来的部分
            if RotMore > HalfOne then--如果多出来的部分大于HalfOne，那么就代表应该是下一个位置了，这样来实现一个区间检测
                RotLen = RotLen + 1
            end
			rotationDeg = RotLen * OneLen
            rotation = math.rad(rotationDeg)--转换回去
			if isNeg then
				rotation = -rotation
			end
		end
		EntitySetTransform(line, line_x, line_y, rotation, length, FINAL_WIDTH)
	else
		line = EntityCreateNew(DRAGGER_NAME)
		EntitySetTransform(line, x, y - WIDTH_OFFSET)
		EntityAddComponent2(line, "SpriteComponent", {
			image_file = brush.brush_file,
			alpha = 0.1,
			additive = true,
			emissive = true,
			z_index = 80,
			offset_y = WIDTH_OFFSET,
		})
	end
end

--
-- Shape tools
--
function dragger_release_action(material, brush, x, y)
	local line = EntityGetWithName(DRAGGER_NAME)
	EntityConvertToMaterial(line, material)
	EntityKill(line)
end

function corner_aligned_polygon_action(material, brush, x, y, rotation)
	local rect = EntityGetWithName(DRAGGER_NAME)
	local SPRITE_SIZE = brush.brush_sprite_size

	if EntityGetIsAlive(rect) then
		-- Get coordinates of starting point
		local rect_x, rect_y = EntityGetTransform(rect)

		local width = rect_x - x
		local height = rect_y - y
		if InputIsKeyDown(Key_LSHIFT) or InputIsKeyDown(Key_RSHIFT) then
            local widthIsNeg = false
			if width < 0 then
                widthIsNeg = true
				width = -width
			end
            local heightIsNeg = false
            if height < 0 then
                heightIsNeg = true
                height = -height
            end
            if height < width then--最小边
                width = height
            else
                height = width
            end
			
            if widthIsNeg then
                width = -width
            end
			if heightIsNeg then
				height = -height
			end
		end
		EntitySetTransform(rect, rect_x, rect_y, 0, -width / SPRITE_SIZE, -height / SPRITE_SIZE)
	else
		rect = EntityCreateNew(DRAGGER_NAME)
		EntitySetTransform(rect, x, y, 0, 1 / SPRITE_SIZE, 1 / SPRITE_SIZE)
		EntityAddComponent2(rect, "SpriteComponent", {
			image_file = brush.brush_file,
			alpha = 0.1,
			additive = true,
			emissive = true,
			z_index = 80,
		})
	end
end

function EyedropperAction(material, brush, x, y)

end

function EyedropperReleaseAction(material, _, x, y)
	EyedropperEnable = true
end
