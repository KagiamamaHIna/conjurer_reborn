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

function unsafe_filler_action(material, brush, ix, iy)
	local cmatid
    if MatNumIdToType(CellFactory_GetType(material)) == MatType.Box2d then
        cmatid = CellFactory_GetType("conjurer_reborn_construction_paste")
    else
        cmatid = CellFactory_GetType(material)
    end
	local world_ffi = World.capi
	local cmatptr = world_ffi.get_material_ptr(cmatid)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    local tpcell = world_ffi.get_cell(chunkMap, ix, iy)
	local target = nil
	if tpcell[0] ~= nil then
        local cell = tpcell[0]
		target = cell.material_ptr.material_type
	end
	if target == cmatid then--避免死循环
		return
	end
    ---有几种情况，如果要填充的是空气，那么target是nil
    ---如果要填充的是材料，则target是材料id
    ---检测到不符合的时候返回假
    ---返回一个检查目标单元是否和target单元类型一致的函数
	---@return fun(x:integer,y:integer):boolean
    local function getCellMatch()
		if target then
			return function (x, y)
                --若目标材料不是空气，那么意味着get出空指针，毫无疑问是边界
				--如果get出来不是空指针，检查
				local pcell = world_ffi.get_cell(chunkMap, x, y)
                if pcell[0] == nil then
                    return false
                end
				return pcell[0].material_ptr.material_type == target
			end
        else
            return function(x, y)
                --若目标材料为空气，则获取空指针可能存在两种情况，一个是处于未加载区块，一个是处于加载区块
                --get cell自身存在区块加载的判断，若先判断区块加载再get cell，如果获取出来的是材料，则多检查了一次
				--所以先尝试get cell进行快速失败，避免可能的检查
                local pcell = world_ffi.get_cell(chunkMap, x, y)
                if pcell[0] ~= nil then
                    return false
                end
                --发现检查出来是空指针，那么根据区块加载检查结果来决定是否有效
                --因为如果区块是加载的，但获取的是空指针，那么意味着是空气
				--如果区块不是加载的，则无效
				return world_ffi.chunk_loaded(chunkMap, x, y)
			end
		end
	end
	local CellMatch = getCellMatch()
    local stack = { ix, iy }

	--扫描邻行并压栈的内部函数
    local function scanLineForSeeds(ny, xLeft, xRight)
        local spanAdded = false --标记当前连续的待填充片段是否已压栈
		for i = xLeft,xRight do
            if CellMatch(i, ny) then
                if not spanAdded then
					stack[#stack+1] = i
					stack[#stack+1] = ny
					spanAdded = true
				end
			else
				spanAdded = false
			end
		end
    end

    while #stack > 0 do
        local y = stack[#stack]
		stack[#stack] = nil
        local x = stack[#stack]
		stack[#stack] = nil
		
        if not CellMatch(x, y) then
            goto continue
        end
		
        local xLeft = x
        while CellMatch(xLeft - 1, y) do
            xLeft = xLeft - 1
        end
		
		local xRight = x;
        while CellMatch(xRight + 1, y) do
            xRight = xRight + 1
		end
        for i = xLeft, xRight do
            local pcell = world_ffi.get_cell(chunkMap, i, y)
			if pcell[0] == nil then
                pcell[0] = world_ffi.construct_cell(grid, i, y, cmatptr, nil)
            else
				pcell[0].vtable.cell_overwrite(pcell[0], grid, cmatid)
			end
        end
		scanLineForSeeds(y - 1, xLeft, xRight)
		scanLineForSeeds(y + 1, xLeft, xRight)
		::continue::
	end
end

function unsafe_filler_release_action(material, brush, x, y)
    if MatNumIdToType(CellFactory_GetType(material)) == MatType.Box2d then
        ConvertMaterialOnAreaInstantly(
            x - 1000, y - 1000,
            2000, 2000,
            CellFactory_GetType("conjurer_reborn_construction_paste"), CellFactory_GetType(material),
            true,
            false
        )
    end
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
