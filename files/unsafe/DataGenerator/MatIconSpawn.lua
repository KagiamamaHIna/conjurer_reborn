dofile_once("mods/conjurer_reborn/files/unsafe/DataInterface/NearestMaterials.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")

dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
---@type DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")
local IconList = Cpp.GetDirectoryPathAll("mods/conjurer_unsafe/cache/MatIcon/")
local IconTable = {}
local MatTable = GetMaterialData()
if ModSettingGet("conjurer_reborn.regen_mat_img_every_time") then
	Cpp.RemoveAll("mods/conjurer_unsafe/cache/MatWang/")
    Cpp.RemoveAll("mods/conjurer_unsafe/cache/MatIcon/")
    Cpp.CreateDir("mods/conjurer_unsafe/cache/MatWang/")
	Cpp.CreateDir("mods/conjurer_unsafe/cache/MatIcon/")
else
	for _,v in pairs(IconList.File)do--用于判断是否需要生成新图片/删除图片
		if Cpp.PathGetFileType(v) == "png" then
			local name = Cpp.PathGetFileName(v)
			local key = string.sub(name, 1, #name - 4)
			if MatTable[key] then
				IconTable[key] = true
			else--不存在就删除缓存
				Cpp.Remove(v)
				Cpp.Remove("mods/conjurer_unsafe/cache/MatWang/"..key..".png")
			end
		end
	end
end

local NearestTable = {}
for _,v in pairs(NearestMaterials) do
	NearestTable[v] = true
end

local ModsToDataPath = {}

for _,v in pairs(ModGetActiveModIDs())do
    local path = ModIdToPath(v)
	ModsToDataPath[#ModsToDataPath+1] = path
end

local function IsDataPng(v)
    if v.name ~= "Graphics" then
        return false
    end
	if v.attr.texture_file == nil or v.attr.texture_file == "" then
		return false
	end
	local modid = PathGetModId(v.attr.texture_file)
    if modid ~= nil then
		return false
    end
	return true
end

local function IsModPng(v)
	if v.name ~= "Graphics" then
        return false
    end
    if v.attr.texture_file == nil or v.attr.texture_file == "" then
        return false
    end
	local modid = PathGetModId(v.attr.texture_file)
    if modid == nil then
		return false
    end
	return true
end

local IconWidth = 16
local IconHeight = 16

for matid, mat in pairs(MatTable) do
    if IconTable[matid] then--已有的直接跳过
		goto continue
	end
    local WritePath = "mods/conjurer_unsafe/cache/MatIcon/" .. matid .. ".png"
	local WriteWangPath = "mods/conjurer_unsafe/cache/MatWang/" .. matid .. ".png"
    local WriteFlag = false
	local r, g, b, a = StrGetRGBANumber(MatWangRGBA(mat.attr.wang_color, true, true))
	if r ~= nil then--生成王浩瓷砖纯色图
		Cpp.RGBAPng(WriteWangPath, 8, 8, r, g, b, 255)
	end
    for _, v in pairs(mat.children) do
        if IsDataPng(v) then
            local flag = false                  --用于判断是否正常执行
            if datawak:HasFile(v.attr.texture_file) then --判断是否真的存在于data
                flag = true
                if NearestTable[mat.attr.name] then
                    datawak:GetImgToScale(v.attr.texture_file, WritePath, IconWidth, IconHeight)
                else
                    datawak:GetImgFlatAndCropping(v.attr.texture_file, WritePath, IconWidth, IconHeight)
                end
            else --判断模组写入到了data里的逻辑

                for _, path in pairs(ModsToDataPath) do
                    local ModDataPath = path .. v.attr.texture_file
                    flag = true
					if Cpp.PathExists(ModDataPath) then
                        if NearestTable[mat.attr.name] then
                            Cpp.PngScaleToFile(ModDataPath, WritePath, IconWidth, IconHeight)
                        else
                            Cpp.PngFlatAndCroppingToFile(ModDataPath, WritePath, IconWidth, IconHeight)
                        end
                    end--没有图片:(
                end
            end
            if flag then --如果正常执行了，那么就设置标志位并退出，否则就到下一步渲染纯色图片
                WriteFlag = true
                break
            end
        elseif IsModPng(v) then
            local PngPath = v.attr.texture_file
            local modid = PathGetModId(v.attr.texture_file) --可能是被覆写的，所以这样获得id
            local ModPath = ModIdToPath(modid)
            if ModPath == nil then
                goto continue
            end
            PngPath = ModPath .. string.gsub(PngPath, "mods/" .. modid .. "/", "", 1) --删掉前缀再拼上去真实路径
			if Cpp.PathExists(PngPath) then
				if NearestTable[mat.attr.name] then
					Cpp.PngScaleToFile(PngPath, WritePath, IconWidth, IconHeight)
				else
					Cpp.PngFlatAndCroppingToFile(PngPath, WritePath, IconWidth, IconHeight)
				end
            else--没有图片:(
				Cpp.RGBAPng(WritePath, IconWidth, IconHeight, 0, 0, 0, 0)
			end
            WriteFlag = true
            break
        elseif v.name == "Graphics" and v.attr.color and v.attr.color ~= "" then --判断Graphics纯色
            local r, g, b, a = StrGetRGBANumber(MatWangRGBA(v.attr.color, true, true))
            if r == nil then
                goto continue
            end
            Cpp.RGBAPng(WritePath, IconWidth, IconHeight, r, g, b, 255)
            WriteFlag = true
            break
        end
        ::continue::
    end
    if not WriteFlag then --wang_color 纯色图片
        local r, g, b, a = StrGetRGBANumber(MatWangRGBA(mat.attr.wang_color, true, true))
        if r == nil then
            print_error("conjurer_unsafe:? ", matid, "'s wang_color is:", mat.attr.wang_color, ".Is this wrong?")
            Cpp.RGBAPng(WritePath, IconWidth, IconHeight, 0, 0, 0, 0)
        else
            Cpp.RGBAPng(WritePath, IconWidth, IconHeight, r, g, b, 255)
        end
    end
	::continue::
end
