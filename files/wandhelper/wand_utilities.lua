dofile_once("mods/conjurer_reborn/files/wands/entwand/processors.lua")
dofile_once("mods/conjurer_reborn/files/wandhelper/ent_helper.lua")

ENTITY_POST_PROCESSORS = {
	disable_new_physicsbody_optimizations,
	remove_spawn_limits_set_by_camerabound,
	add_friendly_fire_corrector,
}

function PostprocessEntity(entity, x, y)
	for _, func in ipairs(ENTITY_POST_PROCESSORS) do
		func(entity, x, y)
	end
end

function EntityLoadProcessed(path, x, y)
	local entity = EntityLoad(path, x, y)
	PostprocessEntity(entity, x, y)
	return entity
end

function IsFreecamEntity(entity, name)
	-- Upon activating the free camera (Conjurer Eye), an entity appears approximately
	-- in the middle of the screen. It seems this entity is tied to something on the
	-- engine side, because deleting this causes a fairly certain crash to desktop
	-- soon after. So we make sure it cannot be deleted.
	--
	-- This entity has no name, no tags and exactly two LightComponents.
	--
	-- We were also unable to detect it upon Conjurer Eye activation (eg. to give it
	-- an easily fetchable name). So we do a bit more hax here.
	--
	-- Has to be checked even when freecam is not in use, because toggling it off will
	-- actually leave this entity lying behind.
	local components = EntityGetAllComponents(entity)
	local basic_signature_matches = (
		name == "" and
		#components == 2 and
		EntityGetTags(entity) == ""
	)

	if basic_signature_matches then
		-- Final check, the component types.
		for i, comp in ipairs(components) do
			if ComponentGetTypeName(comp) ~= "LightComponent" then
				-- TODO: If we start running into false positives, check
				-- that all colors are 255 and radius is 750
				return false
			end
		end

		-- All checks pass and signature matches.
		-- This entity should not be deleted.
		return true
	end

	-- Failed at component inspection, not our guy.
	return false
end

function IsValidEntity(UI, entity)
	local name = EntityGetName(entity)
	local basic_checks = (
		entity ~= nil and
		entity ~= 0 and
		name ~= "conjurer_reborn_entwand_cursor" and
		name ~= "conjurer_reborn_editwand_cursor" and
		name ~= "conjurer_reborn_grid_overlay" and
		-- The reticle shouldn't ever even be detected, but good to have anyway.
		name ~= "conjurer_reborn_spawner_reticle" and
		not IsPlayer(entity) and
		entity ~= GameGetWorldStateEntity() and
		-- This is something that always exists in 0,0.
		name ~= "example_container"
	)

	if GetEntWandIgnoreBG(UI) and name == BG_NAME then
		return false
	end

	if not basic_checks then
		return false
	end

	if IsFreecamEntity(entity, name) then
		return false
	end

	return true
end

---杀死或删除实体
---@param id integer
function EntityTrueKillOrDelete(id)
    if id == nil or id == 0 then
        return
    end
    local DamageModel = EntityGetFirstComponentIncludingDisabled(id, "DamageModelComponent")
	if DamageModel then
        EntitySetComponentIsEnabled(id, DamageModel, true)
		--[[
		for _, v in pairs(EntityGetAllChildren(id) or {}) do
            for _, comp in pairs(EntityGetComponentIncludingDisabled(v, "GameEffectComponent") or {}) do
                ComponentSetValue2(comp, "effect", 0)
                ComponentSetValue2(comp, "frames", 0)
            end
        end]]
		ComponentSetValue2(DamageModel, "wait_for_kill_flag_on_death", true)
        ComponentSetValue2(DamageModel, "kill_now", true)
		-- Thanks KeithSammut!
		ComponentSetValue2(DamageModel, "hp", -1)
		ComponentSetValue2(DamageModel, "air_needed", true)
        ComponentSetValue2(DamageModel, "air_in_lungs", 0)
    else
		EntityKill(id)
	end
end
