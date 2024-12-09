dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/GetSteamWorkshop.lua")
local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")

local workshopPath = GetWorkshopPath()
local mod_config_text = ReadFileAll(SavePath .. "save00/mod_config.xml")
local mod_config = Nxml.parse(mod_config_text)

local ModIdToNameTable = {}
local ModIdToPathTable = {}
local ModWorkshopToId = {}
for _, v in pairs(mod_config.children) do --解析来获取一个id到模组实际路径的表
    if v.name ~= "Mod" then
        goto continue
    end
    if v.attr.workshop_item_id ~= "0" and workshopPath then --创意工坊模组，且要有 有效的workshopPath
        ModIdToPathTable[v.attr.name] = workshopPath .. v.attr.workshop_item_id .. "/"
		ModWorkshopToId[v.attr.workshop_item_id] = v.attr.name
    else                                   --本地模组，用相对路径即可
        ModIdToPathTable[v.attr.name] = "mods/" .. v.attr.name .. "/"
    end
    local path = ModIdToPathTable[v.attr.name] .. "mod.xml"
	if Cpp.PathExists(path) then--如果存在mod.xml的话
        local ModXml = Nxml.parse(ReadFileAll(path))
		ModIdToNameTable[v.attr.name] = ModXml.attr.name
	end
    ::continue::
end

---从路径上获取模组的id，支持本地路径/创意工坊模组的虚拟路径/创意工坊模组的真实路径
---@param str string
---@return string|nil
function PathGetModId(str)
    local _, pos = string.find(str, "mods/")
	local isWorkshop = false
    if pos == nil then
        _, pos = string.find(str, "/steamapps/workshop/content/881100/") --如果找不到就找创意工坊的
		isWorkshop = true
    end
    if pos == nil then --还找不到就退出
        return
    end
	local pos2 = string.find(str, "/", pos + 1)
    if pos2 == nil then
        return
    end
	if isWorkshop then
        local WorkshopNumberStr = string.sub(str, pos + 1, pos2 - 1)
		return ModWorkshopToId[WorkshopNumberStr]
    else
		return string.sub(str, pos + 1, pos2 - 1)
	end
end

---从模组id获取模组名字
---@param modid string
---@return string|nil
function ModIdToName(modid)
	return ModIdToNameTable[modid]
end

---从模组id获取模组真实路径
---@param modid string
---@return string|nil
function ModIdToPath(modid)
	return ModIdToPathTable[modid]
end
