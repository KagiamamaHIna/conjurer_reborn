dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")

--[[
---获得创意工坊的路径，获取失败返回nil
---@return string|nil
function GetWorkshopPath()
	local SteamPath = Cpp.RegLMGetValue("SOFTWARE\\WOW6432Node\\Valve\\Steam\\NSIS", "Path")
    if SteamPath then
        return SteamPath .. "/steamapps/workshop/content/881100/"
    else
        local flag = Cpp.PathExists("../../workshop/content/881100/")
		if flag then
			return "../../workshop/content/881100/"
		end
    end
end

---获得创意工坊的路径，获取失败返回nil
---@return string|nil
function GetWorkshopPath()
	local flag = Cpp.PathExists("../../workshop/content/881100/")
	if flag then
		return "../../workshop/content/881100/"
	end
end
]]

local initResult
---返回是否存在Steam API
---@return boolean
function GetSteamAPIInit()
    if Cpp.PathExists("steam_api.dll") then
		if initResult == nil then
			initResult = require("LuaSteamAPI").GetSteamAPIInit()
		end
        return initResult
    end
	return false
end

local api
---返回创意工坊模组路径
---@param strid string
---@return string|nil
function GetWorkShopModPath(strid)
    if not GetSteamAPIInit() then
        return
    end
	if api == nil then
		api = require("LuaSteamAPI")
	end
	return api.GetModPath(strid)
end
