dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
---返回玩家当前手持物品
---@return integer|nil
function GetActiveItem()
    local player = EntityGetWithTag("player_unit")[1]
	if player == nil then
		return
	end
    local inventory2 = EntityGetFirstComponent(player, "Inventory2Component")
    if inventory2 ~= nil then
		return ComponentGetValue2(inventory2, "mActiveItem")
	end
end

if has_clicked_m1() or is_holding_m2() then
    local item = GetActiveItem()
	if EntityGetName(item or 0) == "conjurer_reborn_carrot" then
		local x, y = DEBUG_GetMouseWorld()
		teleport_player(x, y)
	end
end
