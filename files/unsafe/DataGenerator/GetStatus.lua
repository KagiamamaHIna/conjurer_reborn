--简单的获取就行了
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("data/scripts/status_effects/status_list.lua")

local result = {}
for _,v in pairs(status_effects)do
    if result[v.id] == nil then
        result[v.id] = {}
    end
	result[v.id][#result[v.id]+1] = v
end
status_effects = nil
return result
