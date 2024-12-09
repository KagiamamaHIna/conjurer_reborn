dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")

---获得创意工坊的路径，获取失败返回nil
---@return string|nil
function GetWorkshopPath()
	local SteamPath = Cpp.RegLMGetValue("SOFTWARE\\WOW6432Node\\Valve\\Steam\\NSIS", "Path")
    if SteamPath then
		return SteamPath .. "/steamapps/workshop/content/881100/"
    end
end
