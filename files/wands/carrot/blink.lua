dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")
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
	local player = GetPlayerObj()
	if player and EntityGetName(item or 0) == "conjurer_reborn_carrot" then
		local x, y = DEBUG_GetMouseWorld()
		player.attr.x = x
		player.attr.y = y
		--等价的
		-- 1. Make the arrival less janky when teleporting in-air.
		--
		-- 2. If the Eye of Conjurer is active while we give the player some velocity
		-- it'll make the player float off helpless, so we disable it in that case.
		if GlobalsGetValue("conjurer_unsafePowerBinocularsActive", "0") == "1" and player.comp.CharacterDataComponent then
			local mVelocity = player.comp.CharacterDataComponent[1].attr.mVelocity
			mVelocity.x = 0
			mVelocity.y = 0
		end
	end
end
