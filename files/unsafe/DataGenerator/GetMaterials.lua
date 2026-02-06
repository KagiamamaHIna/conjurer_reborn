--返回一个id到数据表和材料id有序表
dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/misc/ModIdUtilities.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataInterface/MaterialsDesc.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/DataInterface/MatModidSet.lua")

--需要给材料分类：
---液体，固体，粉末，box2d，气体，火焰。会标记材料是否静止，始终燃烧等
MatType = {
    Liquid = "Liquid",
    Solid = "Solid",
	Powder = "Powder",
    Box2d = "Box2d",
	Gas = "Gas",
    Fire = "Fire",
	ErrorType = "ErrorType"
}

MatTypeToLocal = {
	[MatType.Liquid] = "$conjurer_reborn_material_type_liquid",
    [MatType.Solid] = "$conjurer_reborn_material_type_solid",
    [MatType.Powder] = "$conjurer_reborn_material_type_powder",
    [MatType.Box2d] = "$conjurer_reborn_material_type_box2d",
    [MatType.Gas] = "$conjurer_reborn_material_type_gas",
    [MatType.Fire] = "$conjurer_reborn_material_type_fire",
	[MatType.ErrorType] = "$conjurer_reborn_material_type_error"
}

local MatTypeIdList = {}
for _,v in pairs(MatType)do
	MatTypeIdList[v] = {}
end

local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")
local ModMatXmlList = ModMaterialFilesGet()
local MatXml = Nxml.parse(ModTextFileGetContent("data/materials.xml"))

local MatTable = {}
local MatOrderedIdList = {}
local MatOrderedIdToKey = {}

local function IsNil(value)
	if value then
		return false
	end
	return true
end

---判断是否是材料元素
---@param v table
---@return boolean
local function IsMaterial(v)
    if v.attr.conjurer_reborn_tech_mat == "1" then --技术性材料标记特判
        return false
    end
	if v.attr.name == nil then--筛掉没有id的
		return false
	end
    if (v.name == "CellData" or v.name == "CellDataChild") and v.attr.is_just_particle_fx ~= "1" then
        return true
    end
	return false
end

---判断增添材料，顺带判断是否符合条件
---@param v table
local function MaterialAdd(v, modid)
    if IsMaterial(v) then
		if modid then--有填写的话就写入
            v.conjurer_unsafe_from_id = modid
		end
        MatTable[v.attr.name] = v
		if MatOrderedIdToKey[v.attr.name] == nil then--有可能会有模组覆盖数据，所以需要判断是否已经存在
			MatOrderedIdList[#MatOrderedIdList + 1] = v.attr.name
			MatOrderedIdToKey[v.attr.name] = #MatOrderedIdList
		end
        if v.name == "CellDataChild" and v.attr._inherit_reactions == nil then
            v.attr._inherit_reactions = "0"
        end
        local DeduplicationTable = {}--去重用
        local NewChildren = {}--去重完成的表
        for _, elem in ipairs(v.children) do
            if DeduplicationTable[elem.name] == nil then
                DeduplicationTable[elem.name] = elem
                NewChildren[#NewChildren+1] = elem
            end
        end
		v.children = NewChildren
	end
end

--需要先构造好材料表
--原版的材料表
for _,v in pairs(MatXml.children)do
	MaterialAdd(v, "Noita")
end

--模组的材料表
for _, xmlPath in pairs(ModMatXmlList) do
	if xmlPath == "data/materials.xml" then
		goto continue
	end
    local modid = PathGetModId(xmlPath)
    local text = ModTextFileGetContent(xmlPath)
    if text == nil or text == "" then
        goto continue
    end
    local xml = Nxml.parse(text)
    for _, v in pairs(xml.children) do
        MaterialAdd(v, modid)
    end
    ::continue::
end

local function ChildExpansion(mat)
    local function RecursiveParse(ReadTable, WriteTable)
        for k, v in pairs(ReadTable.attr or {}) do --可能子元素的字段是继承，子元素的子元素是直接覆盖，所以这么写
            if WriteTable.attr[k] == nil then
                WriteTable.attr[k] = v
            end
        end
        local ElemChildTable = {}
        for _, v in ipairs(WriteTable.children) do
			if ElemChildTable[v.name] == nil then
	            ElemChildTable[v.name] = v
			end
        end
		local newChilds = {}
        for _, c in ipairs(ReadTable.children) do
            if ElemChildTable[c.name] == nil then
                ElemChildTable[c.name] = c
                newChilds[#newChilds + 1] = c
            end
        end
		WriteTable:add_children(newChilds)
	end
	local function IsChild(m)--判断是否为继承材料
        if m.name == "CellDataChild" then
            return true
        end
		return false
	end
    if not IsChild(mat) then--不是直接返回
        return
    end
	
    local MatChildTable = {}--构造一个子材料已有的数据表
    for _, v in pairs(mat.children) do
		MatChildTable[v.name] = v
	end

	local function SetParentData(ParentMat)
        for k, v in pairs(ParentMat.attr) do --判断是否有 没有的材料属性，如果没有就写入
            if mat.attr[k] == nil then
                mat.attr[k] = v
            end
        end
		
		local newChilds = {}--遍历判断是否有 没有的子元素，没有就写入表中
        for k, v in pairs(ParentMat.children) do
            if MatChildTable[v.name] == nil then
                MatChildTable[v.name] = v
				newChilds[#newChilds+1] = v
            else--已有的
				RecursiveParse(v, MatChildTable[v.name])
            end
        end
		
        mat:add_children(newChilds)--增加新元素
	end

    local ParentMat = MatTable[mat.attr._parent]
    while ParentMat and IsChild(ParentMat) do
        SetParentData(ParentMat)
        ParentMat = MatTable[ParentMat.attr._parent]
    end
	if ParentMat then
		SetParentData(ParentMat)--最后是最祖父的元素，所以也要解析一次
	end
end

--构造好后展开子材料数据
for _,v in pairs(MatTable) do
    ChildExpansion(v)
end

-- local RemoveMatList = {}
-- --因为有可能会继承is_just_particle_fx，所以要在解析结束到最后再来判断一次，筛选出来不符合条件的材料并删除
-- for _,v in pairs(MatTable) do
--     if IsMaterial(v) then
--         goto continue
--     end
-- 	MatTable[v.attr.name] = nil
-- 	RemoveMatList[v.attr.name] = true
-- 	::continue::
-- end

-- for i=#MatOrderedIdList,1,-1 do
-- 	if RemoveMatList[MatOrderedIdList[i]] then
-- 		table.remove(MatOrderedIdList, i)
-- 	end
-- end

--将tags分割成表方便以后处理，顺带归类材料和初始化一些材料属性
for i = 1, #MatOrderedIdList do--通过有序表来获得数据，确保归类材料出来的表也是有序的
	local v = MatTable[MatOrderedIdList[i]]
    v.attr.tags = split(v.attr.tags or "", ',')
    if IsNil(v.attr.liquid_static) then --liquid_static默认为0
        v.attr.liquid_static = "0"
    end

    if IsNil(v.attr.liquid_sand) then
        v.attr.liquid_sand = "0"
    end

    if IsNil(v.attr.cell_type) then--默认是液体材料
        v.attr.cell_type = "liquid"
    end
	
    if IsNil(v.attr.density) then--默认密度是1
        v.attr.density = "1"
    end

    if IsNil(v.attr.burnable) then--默认不可燃
        v.attr.burnable = "0"
    end

    if IsNil(v.attr.durability) then--默认硬度是0
        v.attr.durability = "0"
    end

    if IsNil(v.attr.hp) then--默认血量是100
        v.attr.hp = "100"
    end

    if IsNil(v.attr.fire_hp) then--默认燃烧血量是0
        v.attr.fire_hp = "0"
    end

    if IsNil(v.attr.on_fire) then--默认不会始终燃烧
        v.attr.on_fire = "0"
    end

	if IsNil(v.attr.liquid_stains) then--默认关闭
		v.attr.liquid_stains = "0"
	end

	if IsNil(v.attr.lifetime) then--存在时间默认是0，代表永久时间
		v.attr.lifetime = "0"
	end

	if IsNil(v.attr.platform_type) then--默认0，代表无法站立
		v.attr.platform_type = "0"
	end

	if IsNil(v.attr.electrical_conductivity) then
		if v.attr.liquid_sand == "0" and v.attr.cell_type == "liquid" then--液体材料情况下默认导电
            v.attr.electrical_conductivity = "1"
        else
			v.attr.electrical_conductivity = "0"
		end
	end

	if v.attr.cell_type == "solid" then--cell_type="solid"是box2d
		v.conjurer_unsafe_type = MatType.Box2d
        table.insert(MatTypeIdList[MatType.Box2d], v.attr.name)
	elseif v.attr.cell_type == "liquid" and v.attr.liquid_sand == "0" then--液体，把静态液体也分类进去了
		v.conjurer_unsafe_type = MatType.Liquid
        table.insert(MatTypeIdList[MatType.Liquid], v.attr.name)
	elseif v.attr.cell_type == "liquid" and v.attr.liquid_sand == "1" and v.attr.liquid_static == "0" then--粉末
		v.conjurer_unsafe_type = MatType.Powder
        table.insert(MatTypeIdList[MatType.Powder], v.attr.name)
	elseif v.attr.cell_type == "liquid" and v.attr.liquid_sand == "1" and v.attr.liquid_static == "1" then--固体
		v.conjurer_unsafe_type = MatType.Solid
        table.insert(MatTypeIdList[MatType.Solid], v.attr.name)
	elseif v.attr.cell_type == "fire" then--火焰
		v.conjurer_unsafe_type = MatType.Fire
        table.insert(MatTypeIdList[MatType.Fire], v.attr.name)
	elseif v.attr.cell_type == "gas" then--气体
		v.conjurer_unsafe_type = MatType.Gas
        table.insert(MatTypeIdList[MatType.Gas], v.attr.name)
    else--错误类型，因为cell_type当前只有solid,liquid,fire,gas，如果出现不符合的代表类型是错误的
		v.conjurer_unsafe_type = MatType.ErrorType
		table.insert(MatTypeIdList[MatType.ErrorType], v.attr.name)
	end
end

for k,v in pairs(MaterialsDesc) do
	if MatTable[k] then
		MatTable[k].conjurer_reborn_custom_desc = v
	end
end
MaterialsDesc = nil

for k,v in pairs(MatModidSet) do
	if MatTable[k] then
		MatTable[k].conjurer_unsafe_from_id = v
	end
end
MatModidSet = nil

---获取wang_color(argb) rgb部分
---@param color string
---@param isStr boolean? isStr = false
---@return number|nil
function MatWangRGB(color, isStr)
	isStr = Default(isStr, false)
	local text = string.sub(color,3)
	if isStr then
		return text
	end
	return tonumber(text,16)
end

---获取wang_color(argb) rgba部分，如果isTrue为真则返回真正的rgba，因为如果是王浩瓷砖中的材料，即使是rgba通道的图片，alpha通道也会强制是FF
---@param color string
---@param isStr boolean? isStr = false
---@param isTrue boolean? isTrue = false
---@return number|string|nil
function MatWangRGBA(color, isStr, isTrue)
	isStr = Default(isStr, false)
    isTrue = Default(isTrue, false)
    if isTrue then
		local rgbText = string.sub(color,3)--裁剪rgb部分
		local numStr = rgbText .. string.sub(color, 1, 2)
		if isStr then
			return numStr
		else
			return tonumber(numStr, 16)--因为是argb，所以alpha是在前面的
		end
    end
	local numStr = string.sub(color,3).."FF"
	if isStr then
		return numStr
	else
		return tonumber(numStr, 16)--因为是argb，所以alpha是在前面的
	end
end

return {MatTable, MatOrderedIdList, MatTypeIdList}
