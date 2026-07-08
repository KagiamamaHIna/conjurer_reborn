dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")
local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)
local player = GetPlayerObj()
if player == nil then
    return
end
local px,py = player:GetTransform()
local len = math.sqrt((px - pos_x)^2 + (py - pos_y)^2)
if len > 256 then--距离大于256之后直接传送
	SetRandomSeed(pos_x, pos_y)
    pos_x = px + Random(-10,10)
    pos_y = py - Random(2,10)
    local effect = EntityLoad("data/entities/particles/teleportation_blast.xml", pos_x, pos_y)
    EntityAddComponent2(effect, "LifetimeComponent", {
		lifetime = 15
	})
	GamePlaySound("data/audio/Desktop/misc.bank", "game_effect/teleport/tick", GameGetCameraPos())
end

EntitySetTransform( entity_id, pos_x, pos_y)
