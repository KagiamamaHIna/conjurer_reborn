dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")

local ffi = require("ffi")
---设置StatusEffectDataComponent组件上的值
---@param comp integer
---@param array_name string
---@param key integer
---@param value number|integer
function SetSEDCompVectorValue(comp, array_name, key, value)
    local offest = 0
    local base_offest = 72
	if DebugGetIsDevBuild() then
		base_offest = 80
	end
    local arraySize = 3 * 4
	local VecType
    if array_name == "stain_effects" then
        offest = base_offest
        VecType = "float"
    elseif array_name == "stain_effect_cooldowns" then
        offest = base_offest + arraySize
        VecType = "int"
    elseif array_name == "effects_previous" then
        offest = base_offest + arraySize * 2
        VecType = "float"
    elseif array_name == "ingestion_effects" then
        offest = base_offest + arraySize * 3
        VecType = "float"
    elseif array_name == "ingestion_effect_causes" then
        offest = base_offest + arraySize * 4
        VecType = "int"
    elseif array_name == "ingestion_effect_causes_many" then
        offest = base_offest + arraySize * 5
        VecType = "int"
	elseif array_name == "mStainEffectsSmoothedForUI" then
		offest = base_offest + arraySize * 6 + 4
		VecType = "float"
    else
        print_error("StatusEffectDataComponent array_name:", array_name, " is error")
        return
    end
    local size = ComponentGetVectorSize(comp, array_name, VecType)
    if key >= size then
        print_error("StatusEffectDataComponent key:", key, " is too large")
        return
    end
    local VecAddres = NP.GetComponentAddress(comp) + offest
    local VecPtr
    if VecType == "float" then
        VecPtr = ffi.cast("float**", VecAddres)[0]
    elseif VecType == "int" then
        VecPtr = ffi.cast("int**", VecAddres)[0]
    end
    VecPtr[key] = value
end
