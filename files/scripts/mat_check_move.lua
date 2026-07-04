local update = GetUpdatedEntityID()
local parent = EntityGetParent(update)
if parent and parent ~= 0 then
    return
end

local function GetPlayer()
    local player = EntityGetWithTag("player_unit")[1]
    if player then
        return player
    end
    player = EntityGetWithTag("polymorphed_player")[1]
    if player then
        return player
    end
    player = EntityGetWithTag("polymorphed_cessation")[1]
    if player then
        return player
    end
    return nil
end

local player = GetPlayer()
if player ~= nil then
    local x,y = EntityGetTransform(player)
    EntitySetTransform(update, x, y)
end
