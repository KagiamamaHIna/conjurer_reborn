
function material_area_checker_success()
    local entity = GetUpdatedEntityID()
    local AreaComp = EntityGetFirstComponentIncludingDisabled(entity, "MaterialAreaCheckerComponent")
    local MatNumId = ComponentGetValue2(AreaComp, "material")
	GlobalsSetValue("conjurer_reborn.checkmat_material_str_id",CellFactory_GetName(MatNumId))
end
