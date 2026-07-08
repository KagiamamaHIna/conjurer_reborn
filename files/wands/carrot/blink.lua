dofile_once("mods/conjurer_reborn/files/scripts/utilities.lua")
dofile_once("data/scripts/debug/keycodes.lua")
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
---可以同时设置相机和玩家位置的函数
---@param x number?
---@param y number?
function SetCameraPlayerXY(x, y)
    local player = GetPlayerObj()
    if player == nil then
        return
    end
    x = x and x or player.attr.x
    y = y and y or player.attr.y
    player.attr.x = x
    player.attr.y = y
    local pspc = player.comp.PlatformShooterPlayerComponent
    if pspc then
        local SrcPos = pspc[1].attr.mSmoothedCameraPosition
        local Desired = pspc[1].attr.mDesiredCameraPos
        local xOffset = Desired.x - SrcPos.x
        local yOffset = Desired.y - SrcPos.y
        pspc[1].set_attrs = {
            mSmoothedCameraPosition = { x = x, y = y },
            mDesiredCameraPos = {x = x + xOffset, y = y + yOffset}
        }
    end
end
if has_clicked_m1() or is_holding_m2() then
	local item = GetActiveItem()
	local player = GetPlayerObj()
	if player and EntityGetName(item or 0) == "conjurer_reborn_carrot" then
        local x, y = DEBUG_GetMouseWorld()
        if InputIsKeyDown(Key_LSHIFT) or InputIsKeyDown(Key_RSHIFT) then
            SetCameraPlayerXY(x, y)
        else
            player.attr.x = x
            player.attr.y = y
        end
		--等价的
		-- 1. Make the arrival less janky when teleporting in-air.
		--
		-- 2. If the Eye of Conjurer is active while we give the player some velocity
		-- it'll make the player float off helpless, so we disable it in that case.
		if GlobalsGetValue("conjurer_unsafePowerBinocularsActive", "0") == "1" and player.comp.CharacterDataComponent then
            player.comp.CharacterDataComponent[1].set_attrs = {
                mVelocity = { x = 0, y = 0 },
			}
		end
	end
end
