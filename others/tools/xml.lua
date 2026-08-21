local xml = {}
package.path = package.path .. ";../../files/lib/?.lua"
xml.nxml = require("nxml")

local nxml = xml.nxml
---读取整个文件
---@param path string
---@return string
function xml.ReadFileAll(path)
    local resultCache = {}
	local cacheCount = 1
    for v in io.lines(path) do
        resultCache[cacheCount] = v
        resultCache[cacheCount + 1] = '\n'
        cacheCount = cacheCount + 2
    end
    return table.concat(resultCache)
end

function xml.ParseXmlAndBase(data, filepath)
    local text = xml.ReadFileAll(data .. filepath)
	if text == "" or nil then
		return
	end
	local result = nxml.parse(text)
    local function RecursiveParse(ReadTable, WriteTable)
        for k, v in pairs(ReadTable.attr or {}) do --继承后子元素会继承值，所以需要递归解析子元素
            if WriteTable.attr[k] == nil then
                WriteTable.attr[k] = v
            end
        end
        if ReadTable.children then
            RecursiveParse(ReadTable.children, WriteTable)
        end
    end
    local function recursionBase(SrcXml)
        local BaseList = {}
        local HasElem = {}
        for _, v in pairs(SrcXml.children) do --遍历子元素
            if v.name ~= "Base" then          --把不是base的存下来
                if HasElem[v.name] == nil then
                    HasElem[v.name] = v--只记录第一个
                end
            else --是base的存入另一个表
                BaseList[#BaseList + 1] = v
            end
        end
        for _, base in pairs(BaseList) do --先遍历，对已有的最高优先级元素，覆盖
            for _, v in pairs(base.children) do
                if HasElem[v.name] then
					RecursiveParse(v, HasElem[v.name])
                else
                    HasElem[v.name] = v
                    SrcXml:add_child(v)
                end
            end
        end
        for _, base in pairs(BaseList) do
            local NewXml = nxml.parse(xml.ReadFileAll(data .. base.attr.file))
            recursionBase(NewXml)
            RecursiveParse(NewXml, SrcXml)--最外层的属性继承
            for _, v in pairs(NewXml.children) do--子元素递归继承
                if HasElem[v.name] then
                    RecursiveParse(v, HasElem[v.name])
                else
                    HasElem[v.name] = v
                    SrcXml:add_child(v)
                end
            end
        end
    end
	local flag,err = pcall(recursionBase, result)
    if not flag then
        print(err)
		return
	end
	return result
end

return xml
