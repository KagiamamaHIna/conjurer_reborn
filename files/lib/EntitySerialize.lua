local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")

---@param try function
---@param catch function?
---@return function
local function TryCatch(try, catch)
    catch = catch or function (...)
        return ...
    end
    return function (...)
        local result = {pcall(try, ...)}
        if result[1] then
            table.remove(result,1)
            return unpack(result)
        else
            return catch(unpack(result))
        end
    end
end

local function TestVecValue(comp_id, key)
    local safeGetValue = TryCatch(ComponentGetVectorValue)
    if safeGetValue(comp_id, key, "int", 0) then
        return "int"
    end
    if safeGetValue(comp_id, key, "float", 0) then
        return "float"
    end
    if safeGetValue(comp_id, key, "string", 0) then
        return "string"
    end
end

---@param entity_id integer
local function OneEntitySerialize(entity_id)
    local result = Nxml.new_element("Entity")
    --初始化参数
    result.attr._version = "1"
    result.attr.name = EntityGetName(entity_id)
    result.attr.serialize = "1"
    result.attr.tags = EntityGetTags(entity_id)

    --初始化坐标参数
    local _Transform = Nxml.new_element("_Transform")
    local x, y, rot, scalex, scaley = EntityGetTransform(entity_id)
    _Transform.attr["position.x"] = tostring(x)
    _Transform.attr["position.y"] = tostring(y)
    _Transform.attr["rotation"] = tostring(rot)
    _Transform.attr["scale.x"] = tostring(scalex)
    _Transform.attr["scale.y"] = tostring(scaley)
    result:add_child(_Transform)

    for _, c in ipairs(EntityGetAllComponents(entity_id)) do --序列化组件
        local comp = Nxml.new_element(ComponentGetTypeName(c))
        comp.attr._enabled = ComponentGetIsEnabled(c) and "1" or "0" --序列化启用字段
        local _tags = ComponentGetTags(c)--序列化tags字段
        if _tags and _tags ~= "" then
            comp.attr._tags = _tags
        end
        for k, v in pairs(ComponentGetMembers(c) or {}) do--序列化组件字段
            if v ~= "" then
                comp.attr[k] = v
            else--如果是空，则检查是否是object
                local objFields = ComponentObjectGetMembers(c, k)
                if objFields then--不是object就下一个
                    local obj = Nxml.new_element(k)--是的话就序列化
                    for objKey, objField in pairs(objFields or {}) do
                        if objField then
                            obj.attr[objKey] = objField
                        end
                    end
                    comp:add_child(obj)
                else
                    local vecType = TestVecValue(c, k)
                    if vecType then
                        local vec = Nxml.new_element(k) --是的话就序列化
                        local ElemName = "primitive"
                        if vecType == "string" then
                            ElemName = vecType
                        end
                        local size = ComponentGetVectorSize(c, k, vecType)
                        for i = 0, size - 1 do
                            local value = ComponentGetVectorValue(c, k, vecType, i)
                            local ChildData = ("<%s>"):format(ElemName)..tostring(value)..("</%s>"):format(ElemName)
                            vec:add_child(Nxml.parse(ChildData))
                        end
                        comp:add_child(vec)
                    end
                end

            end
            ::continue::
        end
        result:add_child(comp)
    end
    return result
end

---实体序列化
---@param entity_id integer
function EntitySerialize(entity_id)
    local function SetChilds(xmlobj, ent)
        for _,child in ipairs(EntityGetAllChildren(ent) or {})do
            local childXml = OneEntitySerialize(child)
            if EntityGetAllChildren(child) then
                SetChilds(childXml, child)
            end
            xmlobj:add_child(childXml)
        end
    end
    local result = OneEntitySerialize(entity_id)
    SetChilds(result, entity_id)
    local nxml_tostring = Nxml.unofficial_tostring
    if nxml_tostring == nil then
        nxml_tostring = Nxml.tostring
    end
    return nxml_tostring(result)
end
