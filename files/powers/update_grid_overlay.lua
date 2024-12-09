dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/powers/grid_overlay.lua")


local grid = GetUpdatedEntityID()

local x, y = calculate_grid_position(grid)
EntitySetTransform(grid, x, y)
