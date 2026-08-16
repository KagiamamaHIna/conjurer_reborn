function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    if GlobalsGetValue("conjurer_reborn_animals_spawn_corpse", "1") == "1" then
        return
    end
    local entity = GetUpdatedEntityID()
    local dmgComponent = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    if dmgComponent == nil then
        return
    end
    ComponentSetValue2(dmgComponent, "create_ragdoll", false)
end
