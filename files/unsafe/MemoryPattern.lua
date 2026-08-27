---@module 'MemoryPattern'
local ffi = require("ffi")

-- 1. 声明函数原型（因为bug所以这么玩加载了）
ffi.cdef[[
    void* LoadLibraryA(const char* lpLibFileName);
    void* GetProcAddress(void* hModule, const char* lpProcName);

    typedef uintptr_t (*FindPatternInModule_t)(const char* moduleName, const char* signature);
    typedef uintptr_t (*FindPattern_t)(uintptr_t startAddress, uintptr_t searchSize, const char* signature);
    typedef uintptr_t (*ResolveRelativeAddress_t)(uintptr_t address, int offset, int instructionSize);
    typedef uintptr_t (*FindFuncStart_t)(uintptr_t func_body);
]]

-- 2. 加载 DLL
local hMod = ffi.C.LoadLibraryA("mods/conjurer_unsafe/files/module/YNoitaPatcher.dll")
if hMod == nil then
    error("Failed to load YNoitaPatcher.dll")
end

-- 3. 封装一个便捷的加载器（或者手动一个个 cast）
local function bind(func_name, cast_type)
    local p = ffi.C.GetProcAddress(hMod, func_name)
    if p == nil then
        error("Cannot resolve symbol: " .. func_name)
    end
    return ffi.cast(cast_type, p)
end

-- 4. 导出函数对象
local YNP = {
    ---@type fun(moduleName:string?, signature:string):integer
    FindPatternInModule    = bind("FindPatternInModule", "FindPatternInModule_t"),
    ---@type fun(startAddress:integer, searchSize:integer, signature:string):integer
    FindPattern            = bind("FindPattern", "FindPattern_t"),
    ---@type fun(address:integer, offset:integer, instructionSize:integer):integer
    ResolveRelativeAddress = bind("ResolveRelativeAddress", "ResolveRelativeAddress_t"),
    ---@type fun(func_body:integer):integer
    FindFuncStart          = bind("FindFuncStart", "FindFuncStart_t"),
}

return YNP
