local t = dofile_once("mods/conjurer_reborn/visual_ingore_mats.lua")
function material_area_checker_success()
    local entity = GetUpdatedEntityID()
    local AreaComp = EntityGetFirstComponentIncludingDisabled(entity, "MaterialAreaCheckerComponent")
    local MatNumId = ComponentGetValue2(AreaComp, "material")
    if t[CellFactory_GetName(MatNumId)] then
        GlobalsSetValue("conjurer_reborn.checkmat_material_str_id", "air")
        return
    end
	GlobalsSetValue("conjurer_reborn.checkmat_material_str_id",CellFactory_GetName(MatNumId))
end
