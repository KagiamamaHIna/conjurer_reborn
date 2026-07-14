ModDir = "mods/conjurer_unsafe/"
ModID = "conjurer_unsafe"
local ModID2 = ModID .. ".r_"--其实是reborn
-- ModVersion = "0.0.1"
-- ModLink = "none"
Int64Max = 2^63-1
Int32Max = 2^31-1

QuietNaN = 0/0

DebugMode = false

StatsSalakieliKey = { 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x73, 0x4f, 0x66, 0x54, 0x68, 0x65, 0x41, 0x6c, 0x6c, 0x53 }
StatsSalakieliIV = { 0x54, 0x68, 0x72, 0x65, 0x65, 0x45, 0x79, 0x65, 0x73, 0x41, 0x72, 0x65, 0x57, 0x61, 0x74, 0x63 }

RequiredUnsafeVer = 6
UnsafeTrueVer = true

if ConjurerRebornUnsafeVer and RequiredUnsafeVer > ConjurerRebornUnsafeVer then
	UnsafeTrueVer = false
end

---Returns the value of a mod setting. 'id' should normally be in the format 'mod_name.setting_id'. Cache the returned value in your lua context if possible.
---@param id string
---@param def any
---@return boolean|number|string|nil
function SettingGet(id, def)
    local result = ModSettingGet(ModID2 .. id)
    if result == nil then
        return def
    end
    return result
end

---Sets the value of a mod setting. 'id' should normally be in the format 'mod_name.setting_id'.
---@param id string
---@param value boolean|number|string
function SettingSet(id, value)
    ModSettingSet(ModID2 .. id, value)
end

---@param id string
---@return boolean was_removed
function SettingRemove(id)
    return ModSettingRemove(ModID2 .. id)
end
