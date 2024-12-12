dofile_once("mods/conjurer_reborn/files/wandhelper/ent_helper.lua")

function EnabledReticle(UI, is_enabled)
	local reticle = EntityGetWithName("conjurer_reborn_spawner_reticle")
    if is_enabled and reticle == 0 then
		ChangeSpawnerReticle(UI)
		return
	end
	if is_enabled then
		return
	end
	if reticle and reticle ~= 0 then EntityKill(reticle) end
end
