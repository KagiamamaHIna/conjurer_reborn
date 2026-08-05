local update = GetUpdatedEntityID()
local sprite = EntityGetFirstComponentIncludingDisabled(update, "SpriteComponent")
if sprite == nil then
    return
end
local root = EntityGetRootEntity(update)
if root == 0 then--没有根实体时，不需要判断进行翻转
    ComponentSetValue2(sprite, "special_scale_y", -0.5)
    return
end
local _,_,_,scaleX = EntityGetTransform(root)
if scaleX > 0 then
    ComponentSetValue2(sprite, "special_scale_y", 0.5)
else
    ComponentSetValue2(sprite, "special_scale_y", -0.5)
end

