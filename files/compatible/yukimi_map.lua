local __conjurer_reborn_old_SessionNumbersGetValue = SessionNumbersGetValue
SessionNumbersGetValue = function(key)
    local result = __conjurer_reborn_old_SessionNumbersGetValue(key)
    --检查并替换
    if key == "BIOME_MAP_PIXEL_SCENES" and result == "mods/conjurer_reborn/files/overrides/original_pixel_scenes.xml" then
        return "data/biome/_pixel_scenes.xml"
    end
    return result
end

MapPin["data/biome/shop_room.xml"] = {
    icon = "mods/biome_map_viewer/files/gfx/location.png",
    name = "$biome_shop_room",
}
MapPin["data/biome/temple_altar_secret.xml"] = {
    icon = "mods/biome_map_viewer/files/gfx/location.png",
    name = "$biome_holymountain",
}
