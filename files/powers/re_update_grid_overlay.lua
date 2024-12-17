local grid = GetUpdatedEntityID()
function CalculateGridPosition()
	local x, y = GameGetCameraPos()
	local GRID_SIZE = 100

	-- Lock to grid
	x = x - x % GRID_SIZE
	y = y - y % GRID_SIZE

	return x, y
end

local x, y = CalculateGridPosition(grid)
EntitySetTransform(grid, x, y)
