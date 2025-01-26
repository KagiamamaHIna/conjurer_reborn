----------------------------------------------------
---废弃！！！ 目前没有合适的解决方案
----------------------------------------------------

dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
local PickupCachePath = "mods/conjurer_unsafe/cache/PickupIcon"
if not Cpp.PathExists(PickupCachePath) then
    Cpp.CreateDir(PickupCachePath)
end

local PickupCachePath = "mods/conjurer_unsafe/cache/PickupIcon"
local IconWidth = 16
local IconHeight = 16

---@type DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")
--只考虑原版文件

---名字生成
---@param path string
local function NameGen(path)
    path = path:gsub("_", " ")
    local result = Cpp.UTF8StringSub(path, 1, 1):upper() .. Cpp.UTF8StringSub(path, 2, #path)
	return result
end

local CurrentPathStr = "data/entities/items/"
local CurrentPaths = {}
local ChildPathMaps = {}
for _, v in pairs(datawak:GetFileList()) do
	local itemPos = string.find(v, CurrentPathStr)
    if itemPos == nil or itemPos ~= 1 then --排除不是这个路径的
        goto continue
    end
    local filetype = Cpp.PathGetFileType(v)
    if filetype ~= "xml" then
        goto continue
    end
	local item = ParseXmlAndBase(v)
    if item == nil then
        goto continue
    end
	local image_file = nil
	local hasItemComponent = false
	for _,elem in ipairs(item.children) do--判断是否有组件和图像
		if elem.name == "ItemComponent" then
            hasItemComponent = true
			image_file = elem.attr.ui_sprite or ""
        end
		if hasItemComponent and image_file then
			break
		end
		::continue::
	end
	if image_file == nil or not hasItemComponent then
		goto continue
	end
	local isChild = false
	local ChildKey = nil
	local childPos = string.find(v, "/", itemPos+1, false)
	if childPos ~= nil then
        isChild = true
        local name = Cpp.PathGetFileName(v)
        ChildKey = v:gsub(CurrentPathStr, "", 1):gsub(name, "", 1)
	end

	local SrcName = Cpp.PathGetFileName(v)--能加载出来文件那应该不用判空了
    local name = NameGen(string.sub(SrcName, 1, #SrcName - 4)) --减去不需要的后缀名并生成合适的后缀名
    --图像生成
    local pngPath = PickupCachePath .. "/"
	if isChild then
		pngPath = pngPath .. ChildKey
        Cpp.CreateDirs(pngPath)
	end
    local pngfile = pngPath .. string.sub(SrcName, 1, #SrcName - 4) .. ".png"
	datawak:GetImgFlatAndCropping(image_file, pngfile, IconWidth, IconHeight)
    if isChild then
        if ChildPathMaps[ChildKey] == nil then
            ChildPathMaps[ChildKey] = {}
        end
        ChildPathMaps[ChildKey][#ChildPathMaps[ChildKey] + 1] = {
            name = name,
            path = v,
            image_file = image_file,
			pngfile = pngfile
        }
    else
        CurrentPaths[#CurrentPaths + 1] = {
            name = name,
            path = v,
            image_file = image_file,
			pngfile = pngfile
        }
    end
	::continue::
end
local ChildMaps = {}
for k,_ in pairs(ChildPathMaps) do
	ChildMaps[#ChildMaps+1] = k
end

--开始排序
local SortFn = function(a, b)
    -- 取字符串的首字母
    local firstA = a:sub(1, 1):lower() -- 转小写以忽略大小写差异
    local firstB = b:sub(1, 1):lower()
    return firstA < firstB
end

table.sort(ChildMaps, SortFn)
table.sort(CurrentPaths, function (a, b)
	return SortFn(a.name, b.name)
end)

for _,v in ipairs(ChildMaps) do
	table.sort(ChildPathMaps[v], function (a, b)
		return SortFn(a.name, b.name)
    end)
	for _,item in ipairs(ChildPathMaps[v])do
		CurrentPaths[#CurrentPaths+1] = item
	end
end

return {CurrentPaths}
