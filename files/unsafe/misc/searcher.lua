local function Default(arg, default)
    if arg == nil then
        return default
    end
    return arg
end

function UpdateSharedPinin()
    if SharedPinin == nil then
        return
    end
    if ModTextFileGetContent("mods/conjurer_reborn/is_refresh_pinin.txt") ~= "1" then
        return
    end
    local config = SharedPinin:GetConfig()
    if ModTextFileGetContent("mods/conjurer_reborn/is_refresh_keyboard.txt") == "1" then
        config.keyboard = PinInLua.Keyboard[Default(CurSettingGet("keyboard_switch"), "QUANPIN")]
    end
    config.fFirstChar = Default(CurSettingGet("first_letter"), true)
    config.fZh2Z = Default(CurSettingGet("zh_eq_z"), true)
    config.fSh2S = Default(CurSettingGet("sh_eq_s"), true)
    config.fCh2C = Default(CurSettingGet("ch_eq_c"), true)
    config.fAng2An = Default(CurSettingGet("ang_eq_an"), true)
    config.fEng2En = Default(CurSettingGet("eng_eq_en"), true)
    config.fU2V = Default(CurSettingGet("v_eq_u"), true)
    config:Commit()

    VirtualFileSet("mods/conjurer_reborn/is_refresh_keyboard.txt", "0")
    VirtualFileSet("mods/conjurer_reborn/is_refresh_pinin.txt", "0")
end

local function GetSharedPinin()
    if SharedPinin ~= nil then--初始化
        return SharedPinin
    end
    SharedPinin = PinInLua.PinIn("mods/conjurer_unsafe/files/pinyin/pinyin.txt")
    VirtualFileSet("mods/conjurer_reborn/is_refresh_keyboard.txt", "1")
    VirtualFileSet("mods/conjurer_reborn/is_refresh_pinin.txt", "1")
    UpdateSharedPinin()
    return SharedPinin
end

--需要大小写不敏感，拉丁字母转换，这些可以隐式进行

--- getStrs返回的字符串会被自动处理为小写和芬兰语字母转换
--- 返回的函数对输入的参数会自动进行小写转换
---@param list table
---@param getStrs fun(item:any):...
---@return fun(keyword:string):any[]
function NewSearcher(list, getStrs)
    if SharedPinin == nil then--初始化
        SharedPinin = GetSharedPinin()
    end
    if SharedPinin == nil then--如果初始化失败了
        error("conjurer reborn: Fatal error: PinIn failed to initialize")
    end
    local tree = PinInLua.TreeSearcher(PinInLua.Logic.CONTAIN, SharedPinin)
    local IdToObj = {}
    for _, v in pairs(list) do
        for _, str in pairs({ getStrs(v) }) do --这些id都能表示同一个东西
            if type(str) == "string" and str ~= "" then
                local id = tree:PutString(Cpp.FinnishToEnLower(str):lower())
                IdToObj[id] = v
            end
        end
    end
    return function (...)
        local result = {}
        local hasObj = {}
        for _, str in ipairs({ ... }) do
            str = str:lower()
            for _, id in ipairs(tree:ExecuteSearchGetIds(str)) do
                local obj = IdToObj[id]
                if hasObj[obj] == nil then
                    result[#result + 1] = obj
                    hasObj[obj] = true
                end
            end
        end
        return result
    end
end

---@param list any[]
---@param getStrs fun(item:any):...
---@return function
function NewReverseSearcher(list, getStrs)
    if SharedPinin == nil then--初始化
        SharedPinin = GetSharedPinin()
    end
    if SharedPinin == nil then--如果初始化失败了
        error("conjurer reborn: Fatal error: PinIn failed to initialize")
    end
    local tree = PinInLua.TreeSearcher(PinInLua.Logic.CONTAIN, SharedPinin)
    local IdToObj = {}
    for _, v in pairs(list) do
        for _, str in pairs({ getStrs(v) }) do --这些id都能表示同一个东西
            if type(str) == "string" and str ~= "" then
                local id = tree:PutString(Cpp.FinnishToEnLower(str):lower())
                IdToObj[id] = v
            end
        end
    end
    return function(...)
        local result = {}
        local hasObj = {}
        for _, str in ipairs({ ... }) do
            str = str:lower()
            for _, id in ipairs(tree:ExecuteSearchGetIds(str)) do
                local obj = IdToObj[id]
                if obj ~= nil then
                    hasObj[obj] = true
                end
            end
        end
        for _, v in ipairs(list) do
            if hasObj[v] == nil then
                result[#result + 1] = v
            end
        end
        return result
    end
end

---"与"逻辑筛选
---@param arg table<string, fun(keyword:string):any[]>
---@return fun(KeywordArgs:table<string, string[]>):any[]
function NewSearcherSet(arg)
    return function (keywordArgs)
        local results = {}
        for k, v in pairs(keywordArgs) do
            if arg[k] == nil then
                goto continue
            end
            for _, str in ipairs(v) do
                local list = arg[k](str)
                if list[1] ~= nil and type(list[1]) == "table" and list[1][1] ~= nil then--解包列表的列表，用于处理那种模组id且成组的
                    local merge = {}
                    for _, l in ipairs(list) do
                        for _, data in ipairs(l) do
                            merge[#merge + 1] = data
                        end
                    end
                    results[#results + 1] = merge
                else
                    results[#results + 1] = list
                end
            end
            ::continue::
        end
        local size = #results
        if size == 1 then
            return results[1]
        elseif size == 0 then
            return {}
        end
        --求交集
        local result = {}
        local set = {}
        for _, v in ipairs(results[1]) do
            set[v] = true
        end
        for i = 2, size do
            local newSet = {}
            for _, v in ipairs(results[i]) do
                if set[v] then
                    newSet[v] = true
                end
            end
            set = newSet
        end
        --尽量保证顺序不变，虽然结果多的情况顺序依然会很怪
        for _, v in ipairs(results[1]) do
            if set[v] then
                result[#result + 1] = v
            end
        end
        return result
    end
end

---@param getID fun(item:any):string
---@return function
function GetDataToModlist(getID)
    return function(items)
		local modToMats = {}
        for _, v in ipairs(items) do
            local modid = getID(v)
            if modToMats[modid] == nil then
                modToMats[modid] = { v }
            else
                modToMats[modid][#modToMats[modid] + 1] = v
            end
        end
		return modToMats
    end
end

---@param getID fun(item:any):string
---@return function
function GetInitSearcherModid(getID)
    return function(item)
        local modid = getID(item)
        local modName
        if modid ~= "Noita" then
            modName = ModIdToName(modid) or "?"
        end
        return modid, modName
    end
end

---@class KeywordPreprocessingParam
---@field delim string
---@field prefix string[]

---@param param KeywordPreprocessingParam
---@return fun(keyword:string, isDelim: boolean):table
function GetKeywordPreprocessing(param)
    local ByteMap = {}
    for k, v in ipairs(param.prefix) do
        ByteMap[v:byte(1, 1)] = v:sub(1, 1)
    end
    return function(keyword, isDelim)
        local result = {}
        for k, v in pairs(ByteMap) do
            result[v] = {}
        end
        result.common = {}
        local function set(str)
            if str == "" then
                return
            end
            local prefix = ByteMap[str:byte(1, 1)]
            if prefix ~= nil then
                result[prefix][#result[prefix] + 1] = str:sub(2)
            else
                result.common[#result.common + 1] = str
            end
        end
        if not isDelim then
            set(keyword)
            return result
        end
        --解析
        local keywordList = split(keyword, param.delim)

        for _, v in ipairs(keywordList) do
            set(v)
        end
        return result
    end
end
