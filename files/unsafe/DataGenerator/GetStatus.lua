dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/SimulateAppend.lua")

---@type DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")

local sandbox = dofile_once("mods/conjurer_reborn/files/lib/SandBox.lua")

local fn, env = sandbox(function ()
	dofile("data/scripts/status_effects/status_list.lua")
end)
pcall(fn)
_GLOBAL_INDEX_TABLES[#_GLOBAL_INDEX_TABLES+1] = env

--先加载所有的内容
local result = {}
local TempStatusData = {}
HasStatusEntityList = {}
StatusNumIDToTables = {}
local count = 1
for i,v in ipairs(status_effects)do
    if result[v.id] == nil then
        if v.effect_entity then
            HasStatusEntityList[#HasStatusEntityList+1] = v
        end
        result[v.id] = {}
        TempStatusData[v.id] = {}
        TempStatusData[v.id].conjurer_reborn_status_num_id = count
        TempStatusData[v.id].conjurer_unsafe_from_id = "?" --提前标记为?，方便后续处理，因为不能检测set文件的
        StatusNumIDToTables[count] = result[v.id]
        count = count + 1
    end
    result[v.id][#result[v.id] + 1] = v
    v.conjurer_reborn_status_num_id = TempStatusData[v.id].conjurer_reborn_status_num_id
    v.min_threshold_normalized = tonumber(v.min_threshold_normalized)
end

--加载原生的内容
local OriEffectLua = datawak:At("data/scripts/status_effects/status_list.lua")
local fn,env = sandbox(loadstring(OriEffectLua))
fn()
for _,v in pairs(env.status_effects) do
    if TempStatusData[v.id] then--如果存在数据，标记为noita
		TempStatusData[v.id].conjurer_unsafe_from_id = "Noita"
	end
end
local AppendsModToFile = GetAppendedModIdToFile(OriEffectLua, "data/scripts/status_effects/status_list.lua")

for modid, v in pairs(AppendsModToFile) do
    local fn, env = sandbox(loadstring(v))
    fn()
    for _, effect in ipairs(env.status_effects) do
        if TempStatusData[effect.id] and TempStatusData[effect.id].conjurer_unsafe_from_id == "?" then --如果存在数据，且为?，那么标记为模组id
            TempStatusData[effect.id].conjurer_unsafe_from_id = modid
        end
    end
end

for _, t in pairs(result) do
    for _, v in ipairs(t) do --挨个标记
        v.conjurer_unsafe_from_id = TempStatusData[v.id].conjurer_unsafe_from_id
    end
    if #t > 1 then
        table.sort(t,function (a, b)--需要排序
            local a_min = a.min_threshold_normalized or 0
            local b_min = b.min_threshold_normalized or 0
            return a_min < b_min
        end)
    end
end

--status_effects = nil--需要了：）
return result
