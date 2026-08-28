---@module 'APIExtend'
dofile_once("mods/conjurer_unsafe/files/YNPCommon.lua")

---@module 'MemoryPattern'
local mp = dofile_once("mods/conjurer_reborn/files/unsafe/MemoryPattern.lua")
local ffi = require("ffi")
ffi.cdef[[
typedef int __fastcall StatsGetKeyValue(struct std_string* key, bool* out_exists);
typedef int* __thiscall MapGetValuePtr(void* this, struct std_string* key);
]]

local function ToStdString(str)
    local stdstrPtr = ffi.new("struct std_string[1]")
	local stdstr = stdstrPtr[0]
    stdstr.size = str:len()
    if str:len() >= 16 then
        stdstr.data.buffer = ffi.new("char[?]", str:len() + 1)
        for i = 0, str:len() - 1 do
            stdstr.data.buffer[i] = str:byte(i + 1, i + 1)
        end
        stdstr.data.buffer[str:len()] = 0
        stdstr.capacity = str:len()
    else
        stdstr.capacity = 15
		if str:len() == 0 then
            stdstr.size = 0
            stdstr.data.sso_buffer[0] = 0
			return stdstrPtr
		end
        for i = 0, str:len() - 1 do
            stdstr.data.sso_buffer[i] = str:byte(i + 1, i + 1)
        end
        stdstr.data.sso_buffer[str:len()] = 0
    end
    return stdstrPtr
end

local extend = {}

local StatsGetKeyValueCode = mp.FindPatternInModule(nil, "8D ? ? E8 ? ? ? ? 8D ? ? ? ? ? 8B F0 8D ? ? E8")
if StatsGetKeyValueCode ~= nil then
    local StatsGetKeyValue = ffi.cast("StatsGetKeyValue*", mp.ResolveRelativeAddress(StatsGetKeyValueCode + 3, 1, 5))

    local out_exists = ffi.new("bool[1]")--由于不能并行，这是安全的
    ---获取_stats里KEY_VALUE_STATS，key所对应的value
    ---@param key string
    ---@return integer
    ---@return boolean
    function extend.StatsGetKeyValue(key)
        local value = StatsGetKeyValue(ToStdString(key), out_exists)
        return value, out_exists[0]
    end
end

local StatsSetKeyValueCode = mp.FindPatternInModule(nil, "8D 45 C0 B9 ? ? ? ? 50 74 ? E8 ? ? ? ? 8B 10")
if StatsSetKeyValueCode ~= nil then
    local statsPtr = ffi.cast("char**", StatsSetKeyValueCode + 4)[0]
    local MapGetValuePtr = ffi.cast("MapGetValuePtr*", mp.ResolveRelativeAddress(StatsSetKeyValueCode + 11, 1, 5))
    ---设置_stats里KEY_VALUE_STATS，key所对应的value
    ---@param key string
    ---@param value integer
    function extend.StatsSetKeyValue(key, value)
        local valuePtr = MapGetValuePtr(statsPtr, ToStdString(key))
        valuePtr[0] = value
    end
end
return extend
