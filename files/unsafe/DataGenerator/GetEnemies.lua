dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataInterface/IgnoreEnemies.lua")

local IngoreEntTable = {}
for _, v in pairs(IgnoreEnemies) do
    IngoreEntTable[v] = true
end
IgnoreEnemies = nil

---@class DataWak
local datawak = dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua")
local ModEnableList = ModGetActiveModIDs()

---给定一个路径，获取原版的文件路径和模组新增的文件路径，用id索引来获得数据，isSibling == true的时候把非同级目录内容排除
---@param path string
---@param isSibling boolean? false
---@return table
local function OriAndModDataAppend(path, isSibling)
    isSibling = Default(isSibling, false)
    local GetDirectory
	if isSibling then
		GetDirectory = Cpp.GetDirectoryPath
    else
		GetDirectory = Cpp.GetDirectoryPathAll
	end
	local _result = {Noita = {}}
    for _, v in pairs(datawak:GetFileList()) do
        local projPos = string.find(v, "data/entities/projectiles/")
		if projPos == 1 then--排除投射物文件
			goto continue
		end
        local _, pos = string.find(v, path)
        if not isSibling and pos then --如果不是同级模式，那么就在这里写入吧！
            _result.Noita[#_result.Noita+1] = v
            goto continue
        end
		--因此下面都是同级模式的代码
		if pos == nil then--判断是否为空，如果是空代表它不是我们要的目标
			goto continue
		end
		local pos2 = string.find(v, '/', pos+1)
		if pos2 == nil then--没找到/字符就代表是同级的
            _result.Noita[#_result.Noita+1] = v
        end
		::continue::
    end
	for _, modid in pairs(ModEnableList) do
		local ModPath = ModIdToPath(modid)
        local ModDataPath = ModPath .. path
		_result[modid] = {}
		if not Cpp.PathExists(ModDataPath) then--如果路径不存在就下一次循环
			goto continue
		end
		local Paths = GetDirectory(ModDataPath)
        for _, v in pairs(Paths.File) do
			local modfile = string.sub(v, #ModPath + 1)
			local projPos = string.find(modfile, "data/entities/projectiles/")
			if projPos == 1 then--排除投射物文件
				goto continue
			end
            _result[modid][#_result[modid] + 1] = modfile
			::continue::
		end
		::continue::
	end
	return _result
end

local AnimalList = OriAndModDataAppend("data/entities/")
local AnimalIconList = OriAndModDataAppend("data/ui_gfx/animal_icons/", true)
local OrderedListText = ModTextFileGetContent("data/ui_gfx/animal_icons/_list.txt")
local OrderedListId = {}
local OrderedIdToKey = {}
local EnemiesTable = {}
local HasEnemiesIcon = {}

--构造有序表
if OrderedListText ~= nil and OrderedListText ~= "" then
    local LineFeed = string.byte('\n')--按换行分隔
	local function IsFeed(str, pos)
		return string.byte(str,pos,pos) == LineFeed
	end
	local pos = 1
    local upPos = 1
    while pos <= #OrderedListText do
		if IsFeed(OrderedListText, pos) then
            local key = string.sub(OrderedListText, upPos, pos - 1)
			--移除可能的多余换行符，因为ModTextFileGetContent会在每行插入多余换行(\13)
            key = string.gsub(key, '\n', "")
			key = string.gsub(key, '\13',"")
			if key ~= "" and not IngoreEntTable[key] then
				OrderedListId[#OrderedListId + 1] = key
				OrderedIdToKey[key] = #OrderedListId
			end
            upPos = pos + 1
		end
		pos = pos + 1
	end
end

--构造敌人id列表，后续需要排除有图片但是没敌人的情况
for _,t in pairs(AnimalIconList) do
	for _,v in pairs(t) do
		local type = Cpp.PathGetFileType(v)
		if type == nil or type ~= "png" then--找不到或者不是png的时候
			goto continue
		end
	
		local name = Cpp.PathGetFileName(v)
        name = string.sub(name, 1, #name - 4) --减去不需要的后缀名
		if IngoreEntTable[name] then--被标记要被忽视的跳过
			goto continue
		end
		HasEnemiesIcon[name] = true
		if OrderedIdToKey[name] == nil then--如果是未写入有序表但是有贴图的，往最后面排
			OrderedListId[#OrderedListId + 1] = name
			OrderedIdToKey[name] = #OrderedListId
		end
		::continue::
	end
end

local HasEnemies = {}
local DollarChar = string.byte('$')

for modid, t in pairs(AnimalList) do --遍历文件，写入数据
    for _, v in pairs(t) do
        local type = Cpp.PathGetFileType(v)
        if type == nil or type ~= "xml" then --找不到或者不是xml的时候
            goto continue
        end

        local name = Cpp.PathGetFileName(v)
        name = string.sub(name, 1, #name - 4) --减去不需要的后缀名
        if HasEnemiesIcon[name] == nil or IngoreEntTable[name] then --如果不是有icon的，或者是被标记要被忽视的
            goto continue
        end
        --有，那么就要开始处理了
		if EnemiesTable[name] then--多重文件
            EnemiesTable[name].files[#EnemiesTable[name].files + 1] = v
			if modid == "Noita" then--假定出现了Noita，那么就强制设置，因为noita的实体可能被覆盖
				EnemiesTable[name].from_id = "Noita"
			end
        else --单文件
            local LocalKey = "$animal_" .. name
            local LocalName = GameTextGetTranslatedOrNot(LocalKey)
			if LocalName == "" then--如果获取失败
				LocalKey = name--设置成id
			end
            EnemiesTable[name] = {
				name = LocalKey,
				from_id = modid,
				tags = nil,
                png = Cpp.ConcatStr("data/ui_gfx/animal_icons/", name, ".png"),
				files = {v},
                fileXMLMap = {},
			}
		end

        local AnimalXml = ParseXmlAndBase(v)
        if AnimalXml == nil then --解析失败
            goto continue
        end
		EnemiesTable[name].fileXMLMap[v] = AnimalXml
        if AnimalXml.attr.name and string.byte(AnimalXml.attr.name, 1, 1) == DollarChar then
			if string.byte(EnemiesTable[name].name,1,1) ~= DollarChar then
				EnemiesTable[name].name = AnimalXml.attr.name --赋值为有本地化key的名字
			end
        end

		if EnemiesTable[name].herd_id == nil then--假定多文件情况下herd_id不变
			for _, child in pairs(AnimalXml.children) do
				if child.name == "GenomeDataComponent" and child.attr.herd_id then
					EnemiesTable[name].herd_id = child.attr.herd_id
				end
			end
		end

		if EnemiesTable[name].tags == nil then--假定多文件情况下tags不变
			if AnimalXml.attr.tags and AnimalXml.attr.tags ~= "" then
				EnemiesTable[name].tags = split(AnimalXml.attr.tags, ',')
			end
		end

		HasEnemies[name] = true--用于记录已写入的敌人数据，后续可以拿来判断需要删除的敌人
        ::continue::
    end
end

--后续需要移除有图片但是没敌人的情况
for k,_ in pairs(HasEnemiesIcon)do
	if HasEnemies[k] == nil then--如果不存在此敌人
		for enemyKey,v in pairs(EnemiesTable)do--简单点写法就这样了，数据量应该不会很大
			if v == k then
				table.remove(EnemiesTable, enemyKey)
			end
		end
	end
end

local KeyToEnemy = {}
for i,v in ipairs(OrderedListId)do
	KeyToEnemy[v] = i
end

return {EnemiesTable, OrderedListId, KeyToEnemy}
