local update = GetUpdatedEntityID()
local x,y = EntityGetTransform(update)
local id = EntityLoad("data/entities/animals/boss_centipede/boss_centipede.xml", x, y)
EntityAddTag(id, "reference")
