--需要大小写不敏感，拉丁字母转换，这些可以隐式进行

--- getStrs返回的字符串会被自动处理为小写和芬兰语字母转换
---@param list table
---@param getStrs fun(item:any):...
---@return fun(keyword:string):any[]
function NewSearcher(list, getStrs)
    if SharedPinin == nil then--初始化
        SharedPinin = PinInLua.PinIn("mods/conjurer_unsafe/files/pinyin/pinyin.txt")
    end
    if SharedPinin == nil then--如果初始化失败了
        error("conjurer reborn: Fatal error: PinIn failed to initialize")
    end
    local tree = PinInLua.TreeSearcher(PinInLua.Logic.CONTAIN, SharedPinin)
    local IdToObj = {}
    for _, v in pairs(list) do
        for _, str in ipairs({ getStrs(v) }) do --这些id都能表示同一个东西
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
