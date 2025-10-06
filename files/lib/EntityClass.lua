---v1.0.15.1

---@class ECList<V>: { [integer]: V }
local ECListMetatable = {}

--和标准table的列表行为一致，只是有成员方法
---@generic V
---@param t table<integer,V>
---@return ECList<V>
function NewECList(t)
	return setmetatable(t, { __index = ECListMetatable })
end

--返回新数组，筛选成员，pred返回false时移除对应元素
---@generic V
---@param self  ECList<V>
---@param pred fun(value:V): boolean
---@return  ECList<V>
function ECListMetatable.filter(self, pred)
	local result = {}
	for i, v in ipairs(self) do
		if pred(v) then
			result[#result + 1] = v
		end
	end
	return NewECList(result)
end

--返回一个新数组，数组中的元素为原始数组元素调用函数处理后的值。
---@generic V,FuncRetType
---@param self  ECList<V>
---@param newValue fun(value:V): FuncRetType
---@return  ECList<V>
function ECListMetatable.map(self, newValue)
	local result = {}
	for i, v in ipairs(self) do
		result[i] = newValue(v)
	end
	return NewECList(result)
end

--检测数组所有元素是否都符合指定条件，由函数提供
---@generic V
---@param self  ECList<V>
---@param pred fun(value:V): boolean
---@return  boolean
function ECListMetatable.every(self, pred)
	for i, v in ipairs(self) do
		if not pred(v) then --如果返回假，则代表不符合那么就返回假
			return false
		end
	end
	--都为真就返回真
	return true
end

--排序成员，修改自身，就像table.sort那样
---@generic V
---@param self  ECList<V>
---@param comp? fun(a:V,b:V): boolean
---@return  ECList<V> self
function ECListMetatable.sort(self, comp)
	if comp then
		table.sort(self, comp)
	else
		table.sort(self)
	end
	return self
end

---简单的for遍历
---@generic V
---@param self  ECList<V>
---@param callback fun(i:integer,v:V)
---@return  ECList<V> self
function ECListMetatable.forEach(self, callback)
	for i, v in ipairs(self) do
		callback(i, v)
	end
	return self
end

---如果为空则返回v（默认值），不为空返回本身的函数
---@param arg any
---@param v any
---@return any
local function Default(arg, v)
	if arg == nil then
		return v
	end
	return arg
end

---移除前后空格，换行
---@param s string
---@return string
local function strip(s)
	if s == nil then
		return ''
	end
	local result = s:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%c", "")
	return result
end

---根据分隔符分割字符串
---@param s string
---@param delim string
---@return table
local function split(s, delim)
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

---@class EntityComponent
local CompFuncs = {}

---以组件id返回一个组件封装
---@param comp_id integer
---@return EntityComponent
function EntityComponentObj(comp_id)
	---@class EntityComponent
	local compobj = {
		comp_id = comp_id,
		---@type boolean
		enable = nil,
		attr = {},
		---@type table
		set_attrs = nil,
		-- ---@type table
		-- vec = nil
	}

	local function NewCompVec2(field_name)
		local result = {}
		setmetatable(result, {
			__newindex = function(t, k, v)
				rawset(t, k, nil)
				if k == "x" then
					local _, y = compobj:GetValue(field_name)
					compobj:SetValue(field_name, v, y)
				elseif k == "y" then
					local x, _ = compobj:GetValue(field_name)
					compobj:SetValue(field_name, x, v)
				end
			end,
			__index = function(t, k)
				local x, y = compobj:GetValue(field_name)
				if k == "x" then
					return x
				elseif k == "y" then
					return y
				end
			end
		})
		return result
	end

	-- local function VecGetArray(field_type)
	-- 	local result = {}
	-- 	setmetatable(result, {
	--         __newindex = function(t, k)
	--             rawset(t, k, nil)
	--             print_error("EntityCompError:Vector attributes cannot be overridden")
	--         end,
	--         __index = function(t, k)
	-- 			return compobj:GetVector(k, field_type)
	-- 		end
	-- 	})
	-- 	return result
	-- end

	-- local function NewVecFieldObj()
	-- 	local result = {}
	-- 	setmetatable(result, {
	--         __newindex = function(t, k)
	--             rawset(t, k, nil)
	--             print_error("EntityCompError:Vector attributes cannot be overridden")
	--         end,
	--         __index = function(t, k)
	-- 			return VecGetArray(k)
	-- 		end
	-- 	})
	-- 	return result
	-- end

	---属性
	setmetatable(compobj, {
		__newindex = function(t, k, v)
			if k == "enable" then
				rawset(t, k, nil)
				compobj:SetEnable(v)
			elseif k == "set_attrs" then
				rawset(t, k, nil)
				for tk, tv in pairs(v) do
					if type(tv) == "table" and (tv.x ~= nil or tv.y ~= nil) then
						local src_x, src_y = compobj:GetValue(k)
						src_x = tv.x or src_x
						src_y = tv.y or src_y
						compobj:SetValue(tk, src_x, src_y)
					else
						compobj:SetValue(tk, tv)
					end
				end
				-- elseif k == "vec" then
				-- 	rawset(t, k, nil)
				--     print_error("EntityCompError:Vector attributes cannot be overridden")
			end
		end,
		__index = function(t, k)
			if k == "enable" then
				return compobj:GetEnable()
			elseif k == "set_attrs" then
				return compobj.attr
				-- elseif k == "vec" then
                --     return NewVecFieldObj()
            else
				return CompFuncs[k]
			end
		end,
		__eq = function(t1, t2)
			local t1ID = 0
			if type(t1) == "number" then
				t1ID = t1
			elseif type(t1) == "table" and type(t1.comp_id) == "number" then
				t1ID = t1.comp_id
			end
			local t2ID = 0
			if type(t2) == "number" then
				t2ID = t2
			elseif type(t2) == "table" and type(t2.comp_id) == "number" then
				t2ID = t2.comp_id
			end

			return t1ID == t2ID
		end
	})
	setmetatable(compobj.attr, {
		__newindex = function(t, k, v)
			rawset(t, k, nil)
			if type(v) == "table" and (v.x ~= nil or v.y ~= nil) then
				local src_x, src_y = compobj:GetValue(k)
				src_x = v.x or src_x
				src_y = v.y or src_y
				compobj:SetValue(k, src_x, src_y)
			else
				compobj:SetValue(k, v)
			end
		end,
		__index = function(t, k)
			local list = { compobj:GetValue(k) }
			if #list == 2 then
				return NewCompVec2(k)
			else
				return unpack(list)
			end
		end,
	})

	return compobj
end

---设置组件的值
---@param value_name string
---@param ... any
---@return EntityComponent self
function CompFuncs:SetValue(value_name, ...)
	ComponentSetValue2(self.comp_id, value_name, ...)
	return self
end

---获取组件的值
---@param field_name string
---@return any
function CompFuncs:GetValue(field_name)
	return ComponentGetValue2(self.comp_id, field_name)
end

---获得其对应实体
---@return number
function CompFuncs:GetEntity()
	return ComponentGetEntity(self.comp_id)
end

---移除自身
function CompFuncs:RemoveSelf()
	EntityRemoveComponent(self:GetEntity(), self.comp_id)
end

---获得其对应实体的封装对象
---@return NoitaEntity
function CompFuncs:GetEntityObj()
	return EntityObj(ComponentGetEntity(self.comp_id))
end

---获取组件启用状态
---@return boolean
function CompFuncs:GetEnable()
	return ComponentGetIsEnabled(self.comp_id)
end

---设置组件启用状态
---@param enable boolean
---@return EntityComponent self
function CompFuncs:SetEnable(enable)
	EntitySetComponentIsEnabled(self:GetEntity(), self.comp_id, enable)
	return self
end

---给组件增加tag
---@param tag string
function CompFuncs:AddTag(tag)
	ComponentAddTag(self.comp_id, tag)
	return self
end

---给组件移除tag
function CompFuncs:RemoveTag(tag)
	ComponentRemoveTag(self.comp_id, tag)
	return self
end

---获取组件名称
---@return string
function CompFuncs:GetName()
	return ComponentGetTypeName(self.comp_id)
end

---判断是否有tag
---@param tag string
---@return boolean
function CompFuncs:HasTag(tag)
	return ComponentHasTag(self.comp_id, tag)
end

---获取组件Tag字符串
---@return string|nil
function CompFuncs:GetTags()
	return ComponentGetTags(self.comp_id)
end

---获取组件Tag列表
---@return ECList<string>|nil
function CompFuncs:GetTagList()
	local tags = ComponentGetTags(self.comp_id)
	if tags == nil then
		return
	end
	return NewECList(split(tags, ","))
end

---获取组件的对象的指定值
---@param object_name string
---@param field_name string
function CompFuncs:ObjGetValue(object_name, field_name)
	return ComponentObjectGetValue2(self.comp_id, object_name, field_name)
end

---设置组件的对象的指定值
---@param object_name string
---@param field_name string
---@param ... any
---@return EntityComponent self
function CompFuncs:ObjSetValue(object_name, field_name, ...)
	ComponentObjectSetValue2(self.comp_id, object_name, field_name, ...)
	return self
end

---返回向量大小
---@param array_member_name string
---@param type_stored_in_vector type_stored_in_vector
---@return number
function CompFuncs:GetVecSize(array_member_name, type_stored_in_vector)
	return ComponentGetVectorSize(self.comp_id, array_member_name, type_stored_in_vector)
end

---返回向量指定的值
---@param array_name string
---@param type_stored_in_vector type_stored_in_vector
---@param index number
---@return number|number|string|nil
function CompFuncs:GetVecValue(array_name, type_stored_in_vector, index)
	return ComponentGetVectorValue(self.comp_id, array_name, type_stored_in_vector, index)
end

---返回列表作为向量
---@param array_name string
---@param type_stored_in_vector type_stored_in_vector
---@return ECList<integer>|ECList<number>|ECList<string>|nil
function CompFuncs:GetVector(array_name, type_stored_in_vector)
	local result = ComponentGetVector(self.comp_id, array_name, type_stored_in_vector)
	if result then
		---@diagnostic disable-next-line: param-type-mismatch
		return NewECList(result)
	end
end

---@return table<string, string>|nil
function CompFuncs:GetMembers()
	return ComponentGetMembers(self.comp_id)
end

---@param object_name string
---@return table<string, string>|nil
function CompFuncs:GetObjMembers(object_name)
	return ComponentObjectGetMembers(self.comp_id, object_name)
end

---@class NoitaEntity
local EntityFuncs = {}

---以实体id返回一个实体封装
---@param entity_id integer
---@return NoitaEntity
function EntityObj(entity_id)
	---@class NoitaEntity
	local Entity = {
		entity_id = entity_id,

		---@type NoitaCompTo
		---@diagnostic disable-next-line: missing-fields
		comp = {}, --不包括被关闭的组件

		---@type NoitaCompTo
		---@diagnostic disable-next-line: missing-fields
		comp_all = {}, --包括被关闭的组件

		---@type NewCompObj
		---@diagnostic disable-next-line: missing-fields
		NewComp = {},

		---VariableStorageComponent key是name字段
		---@type table<string, VariableStorageComponent>
		VSC = {},
		attr = {
			---@type number
			x = nil,
			---@type number
			y = nil,
			---@type number
			rotation = nil,
			---@type number
			scale_x = nil,
			---@type number
			scale_y = nil,

			---@type boolean
			is_alive = nil,
			---@type ECList<string>|nil
			tags = nil,
			---@type string
			name = nil
		},
	}
	setmetatable(Entity, {
		__eq = function(t1, t2)
			local t1ID = 0
			if type(t1) == "number" then
				t1ID = t1
			elseif type(t1) == "table" and type(t1.entity_id) == "number" then
				t1ID = t1.entity_id
			end
			local t2ID = 0
			if type(t2) == "number" then
				t2ID = t2
			elseif type(t2) == "table" and type(t2.entity_id) == "number" then
				t2ID = t2.entity_id
			end

			return t1ID == t2ID
		end,
		__index = EntityFuncs
	})
	setmetatable(Entity.comp, {
		__newindex = function(t, k, v)
			rawset(t, k, nil)
			print_error("EntityObjError:Component attributes cannot be overridden")
		end,
		__index = function(t, k)
			return Entity:GetComp(k)
		end
	})
	setmetatable(Entity.comp_all, {
		__newindex = function(t, k, v)
			rawset(t, k, nil)
			print_error("EntityObjError:Component attributes cannot be overridden")
		end,
		__index = function(t, k)
			return Entity:GetComp(k, nil, true)
		end
	})
	setmetatable(Entity.NewComp, {
		__newindex = function(t, k, v)
			rawset(t, k, nil)
			print_error("EntityObjError:New Component attributes cannot be overridden")
		end,
		__index = function(t, k)
			return function(inputs)
				local Vec2s = {}
				local NewInputs = {}
				for ik, iv in pairs(inputs) do
					if type(iv) == "table" and (iv.x ~= nil or iv.y ~= nil) then --分类出vec2
						Vec2s[ik] = iv
					else
						NewInputs[ik] = iv
					end
				end
				local NewComp = EntityAddComponent2(Entity.entity_id, k, NewInputs)
				for veck, vecv in pairs(Vec2s) do --赋值！
					local src_x, src_y = ComponentGetValue2(NewComp, veck)
					src_x = vecv.x or src_x
					src_y = vecv.y or src_y
					ComponentSetValue2(NewComp, veck, src_x, src_y)
				end
				return Entity, EntityComponentObj(NewComp)
			end
		end
	})
	setmetatable(Entity.VSC, {
		__newindex = function(t, k, v)
			rawset(t, k, nil)
			for _, cv in ipairs(Entity.comp_all.VariableStorageComponent or {}) do
				if cv.attr.name == k then
					cv.set_attrs = v
					return
				end
			end --没找到就新建
			local _, c = Entity.NewComp.VariableStorageComponent {
				name = k,
			}
			c.set_attrs = v
		end,
		__index = function(t, k)
			for _, v in ipairs(Entity.comp_all.VariableStorageComponent or {}) do
				if v.attr.name == k then
					return v.attr
				end
			end --没找到就新建
			local _, result = Entity.NewComp.VariableStorageComponent {
				name = k
			}
			return result.attr
		end
	})
	--其他属性
	setmetatable(Entity.attr, {
		__newindex = function(t, k, v)
			if k == "is_alive" and v == false and Entity:IsAlive() then --为假就杀死生物
				rawset(t, k, nil)
				Entity:Kill()
			elseif k == "tag" then --设置新Tag
				rawset(t, k, nil)
				for _, tv in ipairs(Entity:GetTagList() or {}) do
					Entity:RemoveTag(tv)
				end
				for _, tv in ipairs(v or {}) do
					Entity:AddTag(tv)
				end
			elseif k == "name" then
				rawset(t, k, nil)
				Entity:SetName(v)
			elseif k == "x" then
				rawset(t, k, nil)
				Entity:SetX(v)
			elseif k == "y" then
				rawset(t, k, nil)
				Entity:SetY(v)
			elseif k == "rotation" then
				rawset(t, k, nil)
				Entity:SetRotation(v)
			elseif k == "scale_x" then
				rawset(t, k, nil)
				Entity:SetScale_x(v)
			elseif k == "scale_y" then
				rawset(t, k, nil)
				Entity:SetScale_y(v)
			end
		end,
		__index = function(t, k)
			if k == "is_alive" then
				return Entity:IsAlive()
			elseif k == "tag" then
				return Entity:GetTagList()
			elseif k == "name" then
				return Entity:GetName()
			elseif k == "x" then
				return Entity:GetX()
			elseif k == "y" then
				return Entity:GetY()
			elseif k == "rotation" then
				return Entity:GetRotation()
			elseif k == "scale_x" then
				return Entity:GetScale_x()
			elseif k == "scale_y" then
				return Entity:GetScale_y()
			end
		end,
	})

	return Entity
end

---实体是否存活
---@return boolean
function EntityFuncs:IsAlive()
	return EntityGetIsAlive(self.entity_id)
end

---获取实体名字
---@return string
function EntityFuncs:GetName()
	return EntityGetName(self.entity_id)
end

---设置实体名字
---@param name string
function EntityFuncs:SetName(name)
	EntitySetName(self.entity_id, name)
	return self
end

---获取实体Tag字符串
---@return string|nil
function EntityFuncs:GetTags()
	return EntityGetTags(self.entity_id)
end

---获取实体Tag列表
---@return ECList<string>|nil
function EntityFuncs:GetTagList()
	local tags = EntityGetTags(self.entity_id)
	if tags == nil then
		return
	end
	return NewECList(split(tags, ","))
end

---是否存在tag
---@param tag string
---@return boolean
function EntityFuncs:HasTag(tag)
	return EntityHasTag(self.entity_id, tag)
end

---增加实体Tag
---@param tag string
---@return NoitaEntity self
function EntityFuncs:AddTag(tag)
	EntityAddTag(self.entity_id, tag)
	return self
end

---移除实体Tag
---@param tag string
---@return NoitaEntity self
function EntityFuncs:RemoveTag(tag)
	EntityRemoveTag(self.entity_id, tag)
	return self
end

---注意EntityKill有滞后性
function EntityFuncs:Kill()
	EntityKill(self.entity_id)
end

---@return number x, number y, number rotation, number scale_x, number scale_y
function EntityFuncs:GetTransform()
	return EntityGetTransform(self.entity_id)
end

---@param x number
---@param y number? y = 0
---@param rotation number? rotation = 0
---@param scale_x number? scale_x = 1
---@param scale_y number? scale_y = 1
---@return NoitaEntity self
function EntityFuncs:SetTransform(x, y, rotation, scale_x, scale_y)
	y = Default(y, 0)
	rotation = Default(rotation, 0)
	scale_x = Default(scale_x, 1)
	scale_y = Default(scale_y, 1)
	EntitySetTransform(self.entity_id, x, y, rotation, scale_x, scale_y)
	return self
end

---@param x number
---@param y number? y = 0
---@param rotation number? rotation = 0
---@param scale_x number? scale_x = 1
---@param scale_y number? scale_y = 1
---@return NoitaEntity self
function EntityFuncs:ApplyTransform(x, y, rotation, scale_x, scale_y)
	y = Default(y, 0)
	rotation = Default(rotation, 0)
	scale_x = Default(scale_x, 1)
	scale_y = Default(scale_y, 1)
	EntityApplyTransform(self.entity_id, x, y, rotation, scale_x, scale_y)
	return self
end

---@param x number
---@return NoitaEntity self
function EntityFuncs:SetX(x)
	local _, y, rotation, scale_x, scale_y = self:GetTransform()
	self:SetTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param y number
---@return NoitaEntity self
function EntityFuncs:SetY(y)
	local x, _, rotation, scale_x, scale_y = self:GetTransform()
	self:SetTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param rotation number
---@return NoitaEntity self
function EntityFuncs:SetRotation(rotation)
	local x, y, _, scale_x, scale_y = self:GetTransform()
	self:SetTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param scale_x number
---@return NoitaEntity self
function EntityFuncs:SetScale_x(scale_x)
	local x, y, rotation, _, scale_y = self:GetTransform()
	self:SetTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param scale_y number
---@return NoitaEntity self
function EntityFuncs:SetScale_y(scale_y)
	local x, y, rotation, scale_x, _ = self:GetTransform()
	self:SetTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param x number
---@return NoitaEntity self
function EntityFuncs:ApplyX(x)
	local _, y, rotation, scale_x, scale_y = self:GetTransform()
	self:ApplyTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param y number
---@return NoitaEntity self
function EntityFuncs:ApplyY(y)
	local x, _, rotation, scale_x, scale_y = self:GetTransform()
	self:ApplyTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param rotation number
---@return NoitaEntity self
function EntityFuncs:ApplyRotation(rotation)
	local x, y, _, scale_x, scale_y = self:GetTransform()
	self:ApplyTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param scale_x number
---@return NoitaEntity self
function EntityFuncs:ApplyScale_x(scale_x)
	local x, y, rotation, _, scale_y = self:GetTransform()
	self:ApplyTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@param scale_y number
---@return NoitaEntity self
function EntityFuncs:ApplyScale_y(scale_y)
	local x, y, rotation, scale_x, _ = self:GetTransform()
	self:ApplyTransform(x, y, rotation, scale_x, scale_y)
	return self
end

---@return number
function EntityFuncs:GetX()
	local x, y, rotation, scale_x, scale_y = self:GetTransform()
	return x
end

---@return number
function EntityFuncs:GetY()
	local x, y, rotation, scale_x, scale_y = self:GetTransform()
	return y
end

---@return number
function EntityFuncs:GetRotation()
	local x, y, rotation, scale_x, scale_y = self:GetTransform()
	return rotation
end

---@return number
function EntityFuncs:GetScale_x()
	local x, y, rotation, scale_x, scale_y = self:GetTransform()
	return scale_x
end

---@return number
function EntityFuncs:GetScale_y()
	local x, y, rotation, scale_x, scale_y = self:GetTransform()
	return scale_y
end

---@return string
function EntityFuncs:GetFilename()
	return EntityGetFilename(self.entity_id)
end

---增加子实体
---@param child integer|NoitaEntity
---@return NoitaEntity self
function EntityFuncs:AddChild(child)
	if type(child) == "number" then
		EntityAddChild(self.entity_id, child)
	elseif type(child) == "table" and child.entity_id then
		EntityAddChild(self.entity_id, child.entity_id)
	end
	return self
end

---新建子实体
---@param name string?
---@return NoitaEntity child
function EntityFuncs:NewChild(name)
	name = Default(name, "")
	local returnChild = EntityObjCreateNew(name)
	self:AddChild(returnChild)
	return returnChild
end

---获取所有子实体，或者根据tag筛选
---@param tag string? tag == ""
---@return ECList<integer>|nil
function EntityFuncs:GetAllChild(tag)
	local result
	if tag then
		result = EntityGetAllChildren(self.entity_id, tag)
	else
		result = EntityGetAllChildren(self.entity_id)
	end
	if result then
		return NewECList(result)
	end
end

---获取所有子实体的Obj封装，或者根据tag筛选
---@param tag string? tag == ""
---@return ECList<NoitaEntity>|nil
function EntityFuncs:GetAllChildObj(tag)
	local list = self:GetAllChild(tag)
	if list == nil then
		return
	end
	local result = {}
	for i, v in ipairs(list) do
		result[i] = EntityObj(v)
	end
	return NewECList(result)
end

---筛选出一个有指定名字的子实体
---@param name string
---@return NoitaEntity|nil
function EntityFuncs:GetChildWithName(name)
	local child = self:GetAllChildObj()
	for _, v in ipairs(child or {}) do
		if v.attr.name == name then
			return v
		end
	end
end

---载入新实体作为子实体
---@param filename string
---@return integer
function EntityFuncs:LoadChild(filename)
	local x, y = self:GetTransform()
	local child = EntityLoad(filename, x, y)
	self:AddChild(child)
	return child
end

---EntityLoadToEntity
---@param filename string
---@return NoitaEntity self
function EntityFuncs:LoadToEntity(filename)
	EntityLoadToEntity(filename, self.entity_id)
	return self
end

---Note: works only in dev builds.
---@param filename string
---@return NoitaEntity self
function EntityFuncs:Save(filename)
	EntitySave(self.entity_id, filename)
	return self
end

function EntityFuncs:RemoveFromParent()
	EntityRemoveFromParent(self.entity_id)
end

function EntityFuncs:GetParent()
	return EntityObj(EntityGetParent(self.entity_id))
end

function EntityFuncs:GetRoot()
	return EntityObj(EntityGetRootEntity(self.entity_id))
end

---增加组件
---@param type_name NoitaComponentNames
---@param table_of_component_values table<string, any>? nil
---@return NoitaEntity self, EntityComponent NewComponent
function EntityFuncs:AddComp(type_name, table_of_component_values)
	local comp = EntityComponentObj(EntityAddComponent2(self.entity_id, type_name, table_of_component_values or {}))
	return self, comp
end

---移除指定id组件
---@param id integer
---@return NoitaEntity self
function EntityFuncs:RemoveComp(id)
	EntityRemoveComponent(self.entity_id, id)
	return self
end

---获取第一个组件的id
---@param type_name NoitaComponentNames
---@param tag string? tag = ""
---@param including_disabled boolean? including_disabled = false
---@return integer|nil
function EntityFuncs:GetFirstCompID(type_name, tag, including_disabled)
	tag = Default(tag, "")
	including_disabled = Default(including_disabled, false)
	if including_disabled then
		if tag and tag ~= "" then
			return EntityGetFirstComponentIncludingDisabled(self.entity_id, type_name, tag)
		else
			return EntityGetFirstComponentIncludingDisabled(self.entity_id, type_name)
		end
	else
		if tag and tag ~= "" then
			return EntityGetFirstComponent(self.entity_id, type_name, tag)
		else
			return EntityGetFirstComponent(self.entity_id, type_name)
		end
	end
end

---获取指定名字的组件id列表
---@param type_name NoitaComponentNames
---@param tag string? tag = ""
---@param including_disabled boolean? including_disabled = false
---@return ECList<integer>|nil
function EntityFuncs:GetCompID(type_name, tag, including_disabled)
	tag = Default(tag, "")
	including_disabled = Default(including_disabled, false)
	local result
	if including_disabled then
		if tag and tag ~= "" then
			result = EntityGetComponentIncludingDisabled(self.entity_id, type_name, tag)
		else
			result = EntityGetComponentIncludingDisabled(self.entity_id, type_name)
		end
	else
		if tag and tag ~= "" then
			result = EntityGetComponent(self.entity_id, type_name, tag)
		else
			result = EntityGetComponent(self.entity_id, type_name)
		end
	end
	if result then
		return NewECList(result)
	end
end

---获取所有组件id
---@return ECList<integer>
function EntityFuncs:GetAllCompID()
	return NewECList(EntityGetAllComponents(self.entity_id))
end

---获取第一个组件的封装对象
---@param type_name NoitaComponentNames
---@param tag string? tag = ""
---@param including_disabled boolean? including_disabled = false
---@return EntityComponent|nil
function EntityFuncs:GetFirstComp(type_name, tag, including_disabled)
	local comp_id = self:GetFirstCompID(type_name, tag, including_disabled)
	if comp_id == nil then
		return
	end
	return EntityComponentObj(comp_id)
end

---获取指定名字的组件封装列表
---@param type_name NoitaComponentNames
---@param tag string? tag = ""
---@param including_disabled boolean? including_disabled = false
---@return ECList<EntityComponent>|nil
function EntityFuncs:GetComp(type_name, tag, including_disabled)
	tag = Default(tag, "")
	including_disabled = Default(including_disabled, false)
	local list = self:GetCompID(type_name, tag, including_disabled)

	if list == nil then --没有返回空
		return
	end

	local result = {}
	for i, v in ipairs(list) do
		result[i] = EntityComponentObj(v)
	end
	return NewECList(result)
end

---获取所有组件id
---@return ECList<EntityComponent>
function EntityFuncs:GetAllComp()
	local result = {}
	for i, v in ipairs(EntityGetAllComponents(self.entity_id)) do
		result[i] = EntityComponentObj(v)
	end
	return NewECList(result)
end

---根据组件标签设置组件启用状态
---@param tag string
---@param enable boolean
function EntityFuncs:SetCompEnableWithTag(tag, enable)
	EntitySetComponentsWithTagEnabled(self.entity_id, tag, enable)
end

---EntityRefreshSprite
---@param sprite_component integer|EntityComponent
---@return NoitaEntity self
function EntityFuncs:RefreshSprite(sprite_component)
	if type(sprite_component) == "number" then
		EntityRefreshSprite(self.entity_id, sprite_component)
	elseif type(sprite_component) == "table" and sprite_component.comp_id then
		EntityRefreshSprite(self.entity_id, sprite_component.comp_id)
	end
	return self
end

---模拟摄取材料
---@param material_type integer
---@param amount number
---@return NoitaEntity self
function EntityFuncs:IngestMaterial(material_type, amount)
	EntityIngestMaterial(self.entity_id, material_type, amount)
	return self
end

---移除沾湿状态
---@param status_type_id string
---@return NoitaEntity self
function EntityFuncs:RemoveIngestionEffect(status_type_id)
	EntityRemoveIngestionStatusEffect(self.entity_id, status_type_id)
	return self
end

---移除沾染状态
---@param status_type_id string
---@param status_cooldown number? 0
---@return NoitaEntity self
function EntityFuncs:RemoveStainEffect(status_type_id, status_cooldown)
	status_cooldown = Default(status_cooldown, 0)
	EntityRemoveStainStatusEffect(self.entity_id, status_type_id, status_cooldown)
	return self
end

---EntityAddRandomStains
---@param material_type integer
---@param amount number
---@return NoitaEntity self
function EntityFuncs:AddRandomStains(material_type, amount)
	EntityAddRandomStains(self.entity_id, material_type, amount)
	return self
end

---设置材料伤害
---@param material_name string
---@param damage number
---@return NoitaEntity self
function EntityFuncs:SetMaterialDamage(material_name, damage)
	EntitySetDamageFromMaterial(self.entity_id, material_name, damage)
	return self
end

---EntityGetWandCapacity
---@return integer
function EntityFuncs:GetWandCapacity()
	return EntityGetWandCapacity(self.entity_id)
end

---@param amount number
---@param damage_type noita_damage_type
---@param description string
---@param ragdoll_fx noita_ragdoll_fx
---@param impulse_x number
---@param impulse_y number
---@param entity_who_is_responsible number? 0
---@param world_pos_x number? entity_x
---@param world_pos_y number? entity_y
---@param knockback_force number? 0
---@return NoitaEntity self
function EntityFuncs:InflictDamage(amount, damage_type, description, ragdoll_fx, impulse_x, impulse_y,
								   entity_who_is_responsible, world_pos_x, world_pos_y, knockback_force)
	entity_who_is_responsible = Default(entity_who_is_responsible, 0)
	world_pos_x = Default(world_pos_x, self:GetX())
	world_pos_y = Default(world_pos_y, self:GetY())
	knockback_force = Default(knockback_force, 0)
	EntityInflictDamage(self.entity_id, amount, damage_type, description, ragdoll_fx, impulse_x, impulse_y,
		entity_who_is_responsible, world_pos_x, world_pos_y, knockback_force)
	return self
end

---@class DamageBuilder
local DamageBuilderFuncs = {}

---设置伤害量
---@param amount number
---@return DamageBuilder self
function DamageBuilderFuncs:SetAmount(amount)
	self.amount = amount
	return self
end

---设置伤害量，但是除以25
---@param amount number
---@return DamageBuilder self
function DamageBuilderFuncs:SetAmountDivided25(amount)
	self.amount = amount / 25
	return self
end

---设置伤害类型
---@param type noita_damage_type
---@return DamageBuilder self
function DamageBuilderFuncs:SetType(type)
	self.damage_type = type
	return self
end

---设置伤害描述
---@param description string
---@return DamageBuilder self
function DamageBuilderFuncs:SetDescription(description)
	self.description = description
	return self
end

---设置ragdoll_fx
---@param ragdoll_fx noita_ragdoll_fx
---@return DamageBuilder self
function DamageBuilderFuncs:SetRagdoll_fx(ragdoll_fx)
	self.ragdoll_fx = ragdoll_fx
	return self
end

---设置impulse_x
---@param impulse_x number
---@return DamageBuilder self
function DamageBuilderFuncs:SetImpulse_x(impulse_x)
	self.impulse_x = impulse_x
	return self
end

---设置impulse_y
---@param impulse_y number
---@return DamageBuilder self
function DamageBuilderFuncs:SetImpulse_y(impulse_y)
	self.impulse_y = impulse_y
	return self
end

---设置entity_who_is_responsible
---@param entity_who_is_responsible number
---@return DamageBuilder self
function DamageBuilderFuncs:SetEntity_who_is_responsible(entity_who_is_responsible)
	self.entity_who_is_responsible = entity_who_is_responsible
	return self
end

---设置world_pos_x
---@param world_pos_x number
---@return DamageBuilder self
function DamageBuilderFuncs:SetWorld_pos_x(world_pos_x)
	self.world_pos_x = world_pos_x
	return self
end

---设置world_pos_y
---@param world_pos_y number
---@return DamageBuilder self
function DamageBuilderFuncs:SetWorld_pos_y(world_pos_y)
	self.world_pos_y = world_pos_y
	return self
end

---设置knockback_force
---@param knockback_force number
---@return DamageBuilder self
function DamageBuilderFuncs:SetKnockback_force(knockback_force)
	self.knockback_force = knockback_force
	return self
end

---应用伤害
---@return DamageBuilder self
function DamageBuilderFuncs:InflictDamage()
	self.NoitaEntity:InflictDamage(self.amount, self.damage_type, self.description, self.ragdoll_fx,
		self.impulse_x, self.impulse_y, self.entity_who_is_responsible, self.world_pos_x, self.world_pos_y,
		self.knockback_force)
	return self
end

---伤害建造者模式
---@return DamageBuilder
function EntityFuncs:DamageBuilder()
	---@class DamageBuilder
	local result = {
		NoitaEntity = self,
		amount = 0.04,
		---@type noita_damage_type
		damage_type = "DAMAGE_PROJECTILE",
		description = "",
		---@type noita_ragdoll_fx
		ragdoll_fx = "NONE",
		---@type number|nil
		impulse_x = nil,
		---@type number|nil
		impulse_y = nil,
		entity_who_is_responsible = 0,
		---@type number|nil
		world_pos_x = nil,
		---@type number|nil
		world_pos_y = nil,
		knockback_force = 0,
	}
	return setmetatable(result, { __index = DamageBuilderFuncs })
end

---EntityGetHotspot
---@param hotspot_tag string
---@param transformed boolean
---@param include_disabled_components boolean? false
---@return number x, number y
function EntityFuncs:GetHotspot(hotspot_tag, transformed, include_disabled_components)
	include_disabled_components = Default(include_disabled_components, false)
	return EntityGetHotspot(self.entity_id, hotspot_tag, transformed, include_disabled_components)
end

---GameGetVelocityCompVelocity
---@return number x, number y
function EntityFuncs:GetVelocityCompVelocity()
	return GameGetVelocityCompVelocity(self.entity_id)
end

---GameGetGameEffect
---@param game_effect_name string
---@return integer component_id
function EntityFuncs:GetGameEffect(game_effect_name)
	return GameGetGameEffect(self.entity_id, game_effect_name)
end

---GameGetGameEffectCount
---@param game_effect_name string
---@return integer
function EntityFuncs:GetGameEffectCount(game_effect_name)
	return GameGetGameEffectCount(self.entity_id, game_effect_name)
end

---LoadGameEffectEntityTo
---@param game_effect_entity_file string
---@return number effect_entity_id
function EntityFuncs:LoadGameEffectEntityTo(game_effect_entity_file)
	return LoadGameEffectEntityTo(self.entity_id, game_effect_entity_file)
end

---GetGameEffectLoadTo
---@param game_effect_name string
---@param always_load_new boolean
---@return number effect_component_id, number effect_entity_id
function EntityFuncs:GetGameEffectLoadTo(game_effect_name, always_load_new)
	return GetGameEffectLoadTo(self.entity_id, game_effect_name, always_load_new)
end

---GameGetPotionColorUint
---@return integer
function EntityFuncs:GameGetPotionColorUint()
	return GameGetPotionColorUint(self.entity_id)
end

---EntityGetFirstHitboxCenter
---@return number (x, number)|nil y
function EntityFuncs:GetFirstHitboxCenter()
	return EntityGetFirstHitboxCenter(self.entity_id)
end

---IsPlayer
---@return boolean
function EntityFuncs:IsPlayer()
	return IsPlayer(self.entity_id)
end

---IsInvisible
---@return boolean
function EntityFuncs:IsInvisible()
	return IsInvisible(self.entity_id)
end

---GamePickUpInventoryItem
---@param item_entity_id number
---@param do_pick_up_effects boolean? do_pick_up_effects = true
function EntityFuncs:PickUpItem(item_entity_id, do_pick_up_effects)
	do_pick_up_effects = Default(do_pick_up_effects, true)
	return GamePickUpInventoryItem(self.entity_id, item_entity_id, do_pick_up_effects)
end

---GameDropAllItems
function EntityFuncs:DropAllItems()
	return GameDropAllItems(self.entity_id)
end

---返回一个闭包，专门用于接受一个字符串，调用HasTag方法返回布尔的谓词函数<br>可以用作filter方法里的谓词函数，方便tag筛选
---@param tag string
---@return fun(obj:any):boolean
function PredTag(tag)
	return function(obj)
		return obj:HasTag(tag)
	end
end

---返回一个闭包，专门用于接受一个字符串，调用GetName比较name是否相等返回布尔的谓词函数<br>可以用作filter方法里的谓词函数，方便tag筛选
---@param name string
---@return fun(obj:any):boolean
function PredName(name)
	return function (obj)
		return obj:GetName() == name
	end
end

---@param tag string
---@return ECList<integer>
function EntityObjGetWithTag(tag)
	return NewECList(EntityGetWithTag(tag))
end

---返回玩家实体封装
---@return NoitaEntity|nil
function GetPlayerObj()
	local player = EntityGetWithTag("player_unit")[1]
	if player then
		return EntityObj(player)
	end
end

---返回变形玩家实体封装
---@return NoitaEntity|nil
function GetPolyPlayerObj()
	local player = EntityGetWithTag("polymorphed_player")[1]
	if player then
		return EntityObj(player)
	end
end

---返回遁入虚空玩家实体封装
---@return NoitaEntity|nil
function GetCessationPlayerObj()
	local player = EntityGetWithTag("polymorphed_cessation")[1]
	if player then
		return EntityObj(player)
	end
end

---返回世界状态组件
---@return WorldStateComponentClass
function GetWorldStateComp()
	local world = EntityObj(GameGetWorldStateEntity())
	return world.comp.WorldStateComponent[1]
end

---GetUpdatedEntityID的封装版
---@return NoitaEntity
function GetUpdatedEntityObj()
	return EntityObj(GetUpdatedEntityID())
end

---EntityCreateNew
---@param name string?
---@return NoitaEntity
function EntityObjCreateNew(name)
	name = Default(name, "")
	return EntityObj(EntityCreateNew(name))
end

---@param pos_x number
---@param pos_y number
---@param radius number
---@param tag string?
---@return ECList<NoitaEntity>
function EntityObjGetInRadius(pos_x, pos_y, radius, tag)
	local result = {}
	local list
	if tag then
		list = EntityGetInRadiusWithTag(pos_x, pos_y, radius, tag)
	else
		list = EntityGetInRadius(pos_x, pos_y, radius)
	end

	for i, v in ipairs(list) do
		result[i] = EntityObj(v)
	end
	return NewECList(result)
end

---@param pos_x number
---@param pos_y number
---@param tag string?
---@return NoitaEntity
function EntityObjGetClosest(pos_x, pos_y, tag)
	if tag then
		return EntityObj(EntityGetClosestWithTag(pos_x, pos_y, tag))
	else
		return EntityObj(EntityGetClosest(pos_x, pos_y))
	end
end

---@param filename string
---@param pos_x number? 0
---@param pos_y number? 0
---@return NoitaEntity
function EntityObjLoad(filename, pos_x, pos_y)
	pos_x = Default(pos_x, 0)
	pos_y = Default(pos_y, 0)
	return EntityObj(EntityLoad(filename, pos_x, pos_y))
end

-----------------------------------------------------
---@alias noita_effect_enum  "NONE" | "ELECTROCUTION" | "FROZEN" | "ON_FIRE" | "POISON" | "BERSERK" | "CHARM" | "POLYMORPH" | "POLYMORPH_RANDOM" | "BLINDNESS" | "TELEPATHY" | "TELEPORTATION" | "REGENERATION" | "LEVITATION" | "MOVEMENT_SLOWER" | "FARTS" | "DRUNK" | "BREATH_UNDERWATER" | "RADIOACTIVE" | "WET" | "OILED" | "BLOODY" | "SLIMY" | "CRITICAL_HIT_BOOST" | "CONFUSION" | "MELEE_COUNTER" | "WORM_ATTRACTOR" | "WORM_DETRACTOR" | "FOOD_POISONING" | "FRIEND_THUNDERMAGE" | "FRIEND_FIREMAGE" | "INTERNAL_FIRE" | "INTERNAL_ICE" | "JARATE" | "KNOCKBACK" | "KNOCKBACK_IMMUNITY" | "MOVEMENT_SLOWER_2X" | "MOVEMENT_FASTER" | "STAINS_DROP_FASTER" | "SAVING_GRACE" | "DAMAGE_MULTIPLIER" | "HEALING_BLOOD" | "RESPAWN" | "PROTECTION_FIRE" | "PROTECTION_RADIOACTIVITY" | "PROTECTION_EXPLOSION" | "PROTECTION_MELEE" | "PROTECTION_ELECTRICITY" | "TELEPORTITIS" | "STAINLESS_ARMOUR" | "GLOBAL_GORE" | "EDIT_WANDS_EVERYWHERE" | "EXPLODING_CORPSE_SHOTS" | "EXPLODING_CORPSE" | "EXTRA_MONEY" | "EXTRA_MONEY_TRICK_KILL" | "HOVER_BOOST" | "PROJECTILE_HOMING" | "ABILITY_ACTIONS_MATERIALIZED" | "NO_DAMAGE_FLASH" | "NO_SLIME_SLOWDOWN" | "MOVEMENT_FASTER_2X" | "NO_WAND_EDITING" | "LOW_HP_DAMAGE_BOOST" | "FASTER_LEVITATION" | "STUN_PROTECTION_ELECTRICITY" | "STUN_PROTECTION_FREEZE" | "IRON_STOMACH" | "PROTECTION_ALL" | "INVISIBILITY" | "REMOVE_FOG_OF_WAR" | "MANA_REGENERATION" | "PROTECTION_DURING_TELEPORT" | "PROTECTION_POLYMORPH" | "PROTECTION_FREEZE" | "FROZEN_SPEED_UP" | "UNSTABLE_TELEPORTATION" | "POLYMORPH_UNSTABLE" | "CUSTOM" | "ALLERGY_RADIOACTIVE" | "RAINBOW_FARTS" | "POLYMORPH_CESSATION"

---@alias type_stored_in_vector "int" | "float" | "string"

---@alias noita_damage_type '"DAMAGE_MELEE"' | '"DAMAGE_PROJECTILE"' | '"DAMAGE_EXPLOSION"' | '"DAMAGE_BITE"' | '"DAMAGE_FIRE"' | '"DAMAGE_MATERIAL"' | '"DAMAGE_FALL"' | '"DAMAGE_ELECTRICITY"' | '"DAMAGE_DROWNING"' | '"DAMAGE_PHYSICS_BODY_DAMAGED"' | '"DAMAGE_DRILL"' | '"DAMAGE_SLICE"' | '"DAMAGE_ICE"' | '"DAMAGE_HEALING"' | '"DAMAGE_PHYSICS_HIT"' | '"DAMAGE_RADIOACTIVE"' | '"DAMAGE_POISON"' | '"DAMAGE_MATERIAL_WITH_FLASH"' | '"DAMAGE_OVEREATING"' | '"DAMAGE_CURSE"' | '"DAMAGE_HOLY"'

---@alias noita_ragdoll_fx '"NONE"' | '"NORMAL"' | '"BLOOD_EXPLOSION"' | '"BLOOD_SPRAY"' | '"FROZEN"' | '"CONVERT_TO_MATERIAL"' | '"CUSTOM_RAGDOLL_ENTITY"' | '"DISINTEGRATED"' | '"NO_RAGDOLL_FILE"' | '"PLAYER_RAGDOLL_CAMERA"'

---@class field_vec2
---@field x number
---@field y number

---@class field_ivec2
---@field x integer
---@field y integer

---@class unsupported unsupported type
