function item_pickup(fake_ball, entity_pickupper, item_name)
  GameKillInventoryItem(entity_pickupper, fake_ball)

  local real_ball = EntityLoad("mods/conjurer_reborn/files/custom_entities/ball/ball.xml")
  GamePickUpInventoryItem(entity_pickupper, real_ball)
end
