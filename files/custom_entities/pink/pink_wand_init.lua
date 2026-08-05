local update = GetUpdatedEntityID()
local sprite = EntityGetFirstComponentIncludingDisabled(update, "SpriteComponent")
if sprite == nil then
    return
end
GameAddFlagRun("conjurer_reborn_has_pink_wand")
ComponentSetValue2(sprite, "image_file", "mods/conjurer_reborn/files/custom_entities/pink/pink_wand.png")
EntityRefreshSprite(update, sprite)
