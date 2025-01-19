dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")

---给定一个原生文本和文件名路径，返回模拟被append后的表 key:modid value:table<string> 
---@param oriLua string
---@param filename string
function GetAppendedModIdToFile(oriLua, filename)
	local Appends = ModLuaFileGetAppends(filename)
    local AppendsModToFiles = {}
    for _, v in pairs(Appends or {}) do
        local modid = PathGetModId(v) or "?"
        if AppendsModToFiles[modid] == nil then
            AppendsModToFiles[modid] = {}
        end
        AppendsModToFiles[modid][#AppendsModToFiles[modid] + 1] = ModTextFileGetContent(v)
    end
	local result = {}
    for k, v in pairs(AppendsModToFiles) do
		local tempLua = {oriLua}
        for i = 1, #v do
            tempLua[#tempLua + 1] = v[i]
        end
		result[k] = table.concat(tempLua, '\n')
    end
	return result
end
