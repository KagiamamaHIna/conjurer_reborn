dofile_once("mods/conjurer_reborn/files/wandhelper/mat_helper.lua")

local function CreateBrush(UI)
    local x, y = DEBUG_GetMouseWorld()
    local brush = EntityGetWithName("conjurer_reborn_brush_reticle")
    if brush == 0 then
        brush = EntityLoad("mods/conjurer_reborn/files/wands/matwand/brushes/re_brush_reticle.xml", x, y)
        RefreshBrushSprite(UI)
		--材料检查
		local luacomp = {
			script_material_area_checker_success = "mods/conjurer_reborn/files/wandhelper/checkmat.lua",
            remove_after_executed = false,
			execute_every_n_frame = 1
		}
		local vars = {
            material = nil,
			update_every_x_frame = 1,
			look_for_failure = false,
			always_check_fullness = true,
			kill_after_message = false,
		}
        for _, v in pairs(GetMaterialData()) do
            local new = EntityCreateNew()
			EntityAddChild(brush, new)
            EntityAddComponent2(new, "LuaComponent", luacomp)
            EntityAddComponent2(new, "InheritTransformComponent", {})
			local num = CellFactory_GetType(v.attr.name)
			vars.material = num
			local comp = EntityAddComponent2(new, "MaterialAreaCheckerComponent", vars)
            ComponentSetValue2(comp, "area_aabb", 0, 0, 0, 0)
		end
    end
    local eraser = EntityGetWithName("conjurer_reborn_eraser_reticle")
	
	if eraser == 0 then
		EntityLoad("mods/conjurer_reborn/files/wands/matwand/brushes/re_eraser_reticle.xml", x, y)
		RefreshEraserReticleSprite(UI)
	end
end

---启用或移除画刷和橡皮擦
---@param is_enabled boolean
function EnabledBrushes(UI, is_enabled)
	if is_enabled then
		CreateBrush(UI)
		return
	end

	local brush = EntityGetWithName("conjurer_reborn_brush_reticle")
	if brush ~= 0 then EntityKill(brush) end

	local eraser = EntityGetWithName("conjurer_reborn_eraser_reticle")
	if eraser ~= 0 then EntityKill(eraser) end
end
