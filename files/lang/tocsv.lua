--This lua will check whether there is a lua file with the corresponding language id. For multi-language support, please refer to en.lua--

local langPath = "mods/conjurer_reborn/files/lang"
local langIds = {
    "en",
    "ru",
    "pt-br",
    "es-es",
    "de",
    "fr-fr",
    "it",
    "pl",
    "zh-cn",
    "jp",
    "ko"
}
--多余的逗号
local moreComma = 13

--处理--

--路径预处理
if langPath:byte(#langPath,#langPath) ~= string.byte("/") then
    langPath = langPath .. "/"
end

--加载语言文件
local HasLangFiles = {}
local LangToData = {}
for _, v in ipairs(langIds) do
    local tempPath = langPath .. v .. ".lua"
    if ModDoesFileExist(tempPath) then
        local f, err = loadfile(tempPath)
        if f == nil then
            print_error(tempPath, " lang load error:", err)
        else
            local env = {}
            setfenv(f, env)()
            local ThisLangResult = {}
            for key,value in pairs(env)do--筛选出字符串
                if type(value) == "string" then
                    ThisLangResult[key] = value
                    if LangToData[key] == nil then--初始化数据
                        LangToData[key] = {key}
                        for i=2,#langIds + moreComma do
                            LangToData[key][i] = ""
                        end
                    end
                end
            end
            HasLangFiles[#HasLangFiles + 1] = {
                lang = v,
                datas = ThisLangResult
            }
        end
    end
end

--生成语言头标识
local LangHeadTemp = { "" }
local LangHeadToNumID = {}
for i,v in ipairs(langIds) do
    LangHeadTemp[#LangHeadTemp + 1] = v
    LangHeadToNumID[v] = i + 1
end
for i=1,moreComma do--补全逗号
    LangHeadTemp[#LangHeadTemp+1] = ""
end

for _,t in ipairs(HasLangFiles) do
    for k,v in pairs(t.datas) do--读取数据并重写对应字段
        if v ~= "" then
            LangToData[k][LangHeadToNumID[t.lang]] = '"' .. v .. '"'--都加双引号，更加安全且自动化
        end
    end
end

local cache = {table.concat(LangHeadTemp, ",")}
for _, v in pairs(LangToData) do
    local safeStr = table.concat(v, ","):gsub("\n", [[\n]])--安全的转换换行
    cache[#cache + 1] = safeStr
end
return table.concat(cache, "\n") .. "\n" --最后也要加一个换行，防止出问题
