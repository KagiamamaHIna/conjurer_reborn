dofile_once("mods/conjurer_reborn/files/lib/fp.lua")
dofile_once("mods/conjurer_reborn/files/lib/define.lua")
local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")
local fastConcatStr
if Cpp == nil then
    fastConcatStr = function(...)
        return table.concat({ ... })
    end
else
    fastConcatStr = Cpp.ConcatStr
end

function TryCatch(try, catch)
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

local noita_print = print

---重新实现来模拟正确的print行为
---@param ... any
print = function(...)
	local cache = {}
	local cacheCount = 1
	for _, v in pairs({ ... }) do
		cache[cacheCount] = tostring(v)
		cacheCount = cacheCount + 1
	end
	noita_print(table.concat(cache))
end

local noita_print_error = print_error

---重新实现
---@param ... string
print_error = function (...)
	local cache = {}
	local cacheCount = 1
	for _, v in pairs({ ... }) do
		cache[cacheCount] = tostring(v)
		cacheCount = cacheCount + 1
	end
	noita_print_error(table.concat(cache))
end

local noita_game_print = GamePrint

--重新实现一个
---@param ... any
GamePrint = function(...)
	local cache = {}
	local cacheCount = 1
	for _, v in pairs({ ... }) do
		cache[cacheCount] = tostring(v)
		cacheCount = cacheCount + 1
	end
	noita_game_print(table.concat(cache))
end

function PushValueOnList(t, v)
	if t == nil then
		return
	end
	t[#t + 1] = v
end

function PopValueOnList(t)
	if t == nil or #t == 0 then
		return
	end
    local result = t[#t]
    t[#t] = nil
	return result
end

---Clamp
---@param value number
---@param min number
---@param max number
---@return number
function Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

---深拷贝函数，主要是拷贝表，因为只能深拷贝这个（
---@param original any
---@return any
function DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for orig_key, orig_value in next, original, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(original)))
    else -- 非表类型直接复制
        copy = original
    end
    return copy
end

---打印一个表
---@param t table
function TablePrint(t)
	local print_r_cache = {}
	local function sub_print_r(t, indent)
		if (print_r_cache[tostring(t)]) then
			print(indent .. "*" .. tostring(t))
		else
			print_r_cache[tostring(t)] = true
			if (type(t) == "table") then
				for pos, val in pairs(t) do
					if (type(val) == "table") then
						print(indent .. "[" .. pos .. "] : " .. tostring(t) .. " {")
						sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
						print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
					elseif (type(val) == "string") then
						print(indent .. "[" .. pos .. '] : "' .. val .. '"')
					else
						print(indent .. "[" .. pos .. "] : " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end
	if (type(t) == "table") then
		print(tostring(t) .. " {")
		sub_print_r(t, "  ")
		print("}")
	else
		sub_print_r(t, "  ")
	end
	print()
end


---监听器，提供一个函数，监听表的变化
---@param t table
---@param callback function
function TableListener(t, callback)
	local function NewListener()
		local __data = {}
		local deleteList = {}
		for k, v in pairs(t) do
			__data[k] = v
			deleteList[#deleteList + 1] = k
		end
		for _, v in pairs(deleteList) do
			t[v] = nil
		end
		local result = {
			__newindex = function(table, key, value)
				local temp = callback(key, value)
				value = temp or value
				rawset(__data, key, value)
				rawset(table, key, nil)
			end,
			__index = function(table, key)
				return rawget(__data, key)
			end,
			__call = function()
				return __data
			end
		}
		return result
	end
	setmetatable(t, NewListener())
end

---判断一个数是否为NaN
---@param num number
---@return boolean|nil
function IsNaN(num)
	if type(num) == "number" then
		return num ~= num
	end
end

---判断一个数是否为Inf
---@param num number
---@return boolean|nil
function IsINF(num)
	if IsNaN(num) then
		return false
	end
    return num == math.huge
end


---如果为空则返回v（默认值），不为空返回本身的函数
---@param arg any
---@param v any
---@return any
function Default(arg, v)
    if arg == nil then
        return v
    end
    return arg
end

---从str字符串中获取r g b的number值
---@param str string
---@return number|nil, number|nil, number|nil
function StrGetRGBNumber(str)
    if type(str) ~= "string" or #str ~= 6 then
        return nil
    end
    local r = tonumber(str:sub(1, 2), 16)
    local g = tonumber(str:sub(3, 4), 16)
    local b = tonumber(str:sub(5, 6), 16)
	return r,g,b
end


---从str字符串中获取r g b a的number值
---@param str string
---@return number|nil, number|nil, number|nil, number|nil
function StrGetRGBANumber(str)
    if type(str) ~= "string" or #str ~= 8 then
        return nil
    end
    local r = tonumber(str:sub(1, 2), 16)
    local g = tonumber(str:sub(3, 4), 16)
    local b = tonumber(str:sub(5, 6), 16)
    local a = tonumber(str:sub(7, 8), 16)
	return r,g,b,a
end

--- 序列化函数，将table转换成lua代码
---@param tbl table
---@param indent string? 缩进字符串，默认为""
---@return string
function SerializeTable(tbl, indent)
    indent = indent or ""
    local parts = {}
    local partsKey = 1
	local L_SerializeTable = SerializeTable

    local _tostr = tostring
	local _type = type
    local is_array = #tbl > 0 or tbl[0] ~= nil
    for k, v in pairs(tbl) do
        local key
        if is_array and _type(k) == "number" then
			key = fastConcatStr("[",_tostr(k),"] = ")
        else
			key = fastConcatStr("[\"",_tostr(k),"\"] = ")
        end

        if _type(v) == "table" then
			parts[partsKey] = fastConcatStr(indent,key,"{\n")
            parts[partsKey + 1] = L_SerializeTable(v, indent .. "    ")
            parts[partsKey + 2] = fastConcatStr(indent, "},\n")
			partsKey = partsKey + 3
        elseif _type(v) == "boolean" or _type(v) == "number" then
            parts[partsKey] = fastConcatStr(indent, key, _tostr(v), ",\n")
			partsKey = partsKey + 1
		elseif _type(v) ~= "function" then--不要序列化函数，因为无法序列化
            --parts[partsKey] = fastConcatStr(indent, key,'"',v,'",\n')
			parts[partsKey] = string.format("%s%s%q,\n", indent, key, v)
			partsKey = partsKey + 1
        end
    end
    return table.concat(parts)
end


---将一个number转换成字符串，并带有+/-符号
---@param num number
---@return string
function NumToWithSignStr(num)
	local result
	if num >= 0 then
		result = "+" .. tostring(num)
	else
		result = tostring(num)
	end
	return result
end

---让指定小数位之后的归零
---@param num number
---@param decimalPlaces integer
---@return number
function TruncateFloat(num, decimalPlaces)
	local mult = 10 ^ decimalPlaces
	return math.floor(num * mult) / mult
end

---让指定数字位数之后的数字归零
---@param number number
---@param position integer
---@return number
function TruncateNumber(number, position)
    local factor = 10 ^ position
    return math.floor(number / factor) * factor
end

---帧转秒
---@param num number
---@return string
function FrToSecondStr(num)
	local temp = num / 60
	local result = string.format("%.2f", temp)
	return result
end

---解析一个xml和Base的数据，解析出错就返回空
---@param file string
---@return table|nil
function ParseXmlAndBase(file)
    local text = ModTextFileGetContent(file)
	if text == "" or nil then
		return
	end
	local result = Nxml.parse(text)
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
            local NewXml = Nxml.parse(ModTextFileGetContent(base.attr.file))
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
	local flag = pcall(recursionBase, result)
	if not flag then
		return
	end
	return result
end

--- 移除前后空格，换行
---@param s string
---@return string
function strip(s)
	if s == nil then
		return ''
	end
	local result = s:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%c", "")
	return result
end

---转换成字节字符串，比如1B，1KB，1MB
---@param number integer
---@param format string?
---@return string
function ToBytesString(number, format)
    local KBSize = 1024
    local MBSize = 1024 ^ 2
    local GBSize = 1024 ^ 3
	format = format or "%.2f"
	local result
	if number < KBSize then
		result = tostring(number).. "B"
    elseif number >= KBSize and number < MBSize then
		result = string.format(format, number / KBSize) .. "KB"
    elseif number >= MBSize and number < GBSize then
		result = string.format(format, number / MBSize) .. "MB"
	elseif number >= GBSize then
		result = string.format(format, number / GBSize) .. "GB"
	end
	return result
end

---根据分隔符分割字符串
---@param s string
---@param delim string
---@return table
function split(s, delim)
	if string.find(s, delim) == nil then
		return {
			strip(s)
		}
	end
	local result = {}
	for ct in string.gmatch(s, '([^' .. delim .. ']+)') do
		ct = strip(ct)
		result[#result + 1] = ct
	end
	return result
end

---将[0,255]之间的整数转换成小数表示
---@param num number
---@return number
function ColorToDecimal(num)
	return num / 255
end

---不输小数，输入整数
---@param gui userdata
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
function GuiRGBAColorSetForNextWidget(gui, red, green, blue, alpha)
    red = math.min(red, 255)
    green = math.min(green, 255)
    blue = math.min(blue, 255)
	alpha = math.min(alpha,255)
	GuiColorSetForNextWidget(gui, ColorToDecimal(red), ColorToDecimal(green), ColorToDecimal(blue), ColorToDecimal(alpha))
end

---加载某路径的实体以子实体的形式加载到另一实体
---@param father integer EntityID
---@param path string EntityFile
---@return integer
function EntityLoadChild(father, path)
	local x, y = EntityGetTransform(father)
	local id = EntityLoad(path, x, y)
	EntityAddChild(father, id)
	return id
end

local L_EntityHasTag = EntityHasTag
---返回一个实体其子实体有对应标签的数组
---@param entity integer EntityID
---@param tag string
---@return integer[]|nil
function EntityGetChildWithTag(entity, tag)
	local result
	local child = EntityGetAllChildren(entity)
	if child ~= nil then
		result = {}
		local resultCount = 1
		for _, v in pairs(child) do
			if L_EntityHasTag(v, tag) then
				result[resultCount] = v
				resultCount = resultCount + 1
			end
		end
	end
	return result
end

---返回一个实体其子实体有对应名字的数据
---@param entity integer EntityID
---@param name string
---@return integer|nil
function EntityGetChildWithName(entity, name)
	local child = EntityGetAllChildren(entity)
	if child ~= nil then
		for _, v in pairs(child) do
			if EntityGetName(v) == name then
				return v
			end
		end
	end
end

---获取当前拿着的法杖
---@param entity integer EntityID
---@return integer|nil
function GetEntityHeldWand(entity)
	local result
	local inventory2 = EntityGetFirstComponent(entity, "Inventory2Component")
	if inventory2 ~= nil then
		local active = ComponentGetValue2(inventory2, "mActiveItem");
		if EntityHasTag(active, "wand") then --如果是魔杖
			result = active
		end
	end
	return result
end

---获得玩家id
---@return integer
function GetPlayer()
	return EntityGetWithTag("player_unit")[1]
end

---刷新玩家手持法杖以同步数据
function RefreshHeldWands(NextItemEquip)
	NextItemEquip = Default(NextItemEquip, true)
	local player = GetPlayer()
	local inventory2 = EntityGetFirstComponent(player, "Inventory2Component")
	if inventory2 ~= nil then
		ComponentSetValue2(inventory2, "mForceRefresh", true)
        ComponentSetValue2(inventory2, "mActualActiveItem", 0)
		ComponentSetValue2(inventory2, "mDontLogNextItemEquip", NextItemEquip)
	end
end

---返回玩家当前手持物品
---@return integer|nil
function GetActiveItem()
	local player = GetPlayer()
    local inventory2 = EntityGetFirstComponent(player, "Inventory2Component")
    if inventory2 ~= nil then
		return ComponentGetValue2(inventory2, "mActiveItem")
	end
end

---设置玩家手持物品
---@param id integer
function SetActiveItem(id, NoRefresh)
	if id == nil then
		return
	end
    local player = GetPlayer()
	if player == nil then
		return
	end
    local inventory2 = EntityGetFirstComponent(player, "Inventory2Component")
    if inventory2 ~= nil then
		if not NoRefresh then
			ComponentSetValue2(inventory2, "mForceRefresh", true)
		end
        ComponentSetValue2(inventory2, "mActiveItem", id)
	end
end

---屏蔽掉按键操作
function BlockAllInput()
    local player = GetPlayer()
	if player == nil then
		return
	end
    local Controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    if GlobalsGetValue(ModID .. "Blocked") == "1" or (not ComponentGetValue2(Controls, "enabled")) then --防止和其他模组冲突
        return
    end
    GlobalsSetValue(ModID .. "Blocked", "1")
    for k, v in pairs(ComponentGetMembers(Controls) or {}) do
        local HasMBtnDown = string.find(k, "mButtonDown")
        local HasMBtnDownDelay = string.find(k, "mButtonDownDelay")
        if HasMBtnDown and (not HasMBtnDownDelay) then
            ComponentSetValue2(Controls, k, false)
        end
    end
	
	ComponentSetValue2(Controls,"enabled", false)
end

---恢复按键操作
function RestoreInput()
	if GlobalsGetValue(ModID.."Blocked") == "1" then
        GlobalsSetValue(ModID .. "Blocked", "0")
		local player = GetPlayer()
		local Controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
		ComponentSetValue2(Controls, "enabled", true)
	end
end

---返回世界状态组件上特定的值
---@param key string
---@return any
function GetWorldValue(key)
    local world = GameGetWorldStateEntity()
    local worldComp = EntityGetFirstComponent(world, "WorldStateComponent")
	return ComponentGetValue2(worldComp, key)
end

---设置世界状态组件上特定的值
---@param key string
---@param ... any
function SetWorldValue(key, ...)
	local world = GameGetWorldStateEntity()
    local worldComp = EntityGetFirstComponent(world, "WorldStateComponent")
    ComponentSetValue2(worldComp, key, ...)
end

local TimeSize = 60 * 24

---返回当前世界的时间
---@return integer hour
---@return integer minute
function GetWorldTimePair()
	--0是12:00
    --0.5是24:00
	--1就是下一轮
    local value = GetWorldValue("time")
    local AllMinute = value * TimeSize
	local BaseHour = 12
    local hour = math.floor(AllMinute / 60)
    local minute = math.floor(AllMinute % 60)
    local resultHour = BaseHour + hour
    if resultHour >= 24 then--24小时制
        resultHour = resultHour - 24
    end
	return resultHour, minute
end

---返回总分钟数
---@return integer
function GetWorldTimeMinute()
    local h, m = GetWorldTimePair()
	return h * 60 + m
end

---设置世界时间，用分钟来确定
---@param minute number
function SetWorldTimeMinute(minute)
    local hour = math.floor(minute / 60)
    minute = math.floor(minute % 60)
	SetWorldTime(hour, minute)
end

---设置世界时间
---@param hour number
---@param minute number
function SetWorldTime(hour, minute)
    hour = Clamp(hour, 0, 24)
    hour = hour + 12
	if hour >= 24 then
		hour = hour - 24
	end
	minute = Clamp(minute, 0, 60)
    minute = math.min(hour * 60 + minute, TimeSize)
	SetWorldValue("time", minute / TimeSize)
end

---返回当前世界天数，从1开始记
---@return integer
function GetWorldDays()
    local value = GetWorldValue("day_count")
    local h = GetWorldTimePair()
    if h < 12 then
        value = value + 1
    end
	return value + 1
end

---@alias noita_vsc_type "value_string" | "value_int" | "value_bool" | "value_float"

---获得Storage组件和对应值
---@param entity integer EntityID
---@param VariableName string
---@param ValueType noita_vsc_type
---@return any|nil
---@return integer|nil
function GetStorageComp(entity, VariableName, ValueType)
	local comps = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
    if comps == nil then
		return
	end
	for _, comp in pairs(comps) do --遍历存储组件表
		local name = ComponentGetValue2(comp, "name")
		if name == VariableName then --如果是状态就取值
			local value = ComponentGetValue2(comp, ValueType)
			return value, comp
		end
	end
end

---增加并设置Storage
---@param entity integer
---@param i_name string
---@param i_value any
---@param ValueType noita_vsc_type
---@return integer|nil
function AddSetStorageComp(entity, i_name, i_value, ValueType)
	if entity == nil or not EntityGetIsAlive(entity) then
		return
	end
	return EntityAddComponent(entity, "VariableStorageComponent", { name = i_name, [ValueType] = i_value })
end

---设置Storage，并返回组件
---@param entity integer
---@param VariableName string
---@param i_value any
---@param ValueType noita_vsc_type
---@return integer|nil
function SetStorageComp(entity, VariableName, i_value, ValueType)
	local comps = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	if comps == nil then
		return
	end
	for _, comp in pairs(comps) do --遍历存储组件表
		local name = ComponentGetValue2(comp, "name")
		if name == VariableName then --如果是就取值
			ComponentSetValue2(comp, ValueType, i_value)
			return comp
		end
	end
end
