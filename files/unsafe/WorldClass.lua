---@class WorldClass
local world = {}

---@type ynpWorldFFI
local world_ffi = dofile_once("mods/conjurer_reborn/files/unsafe/world_ffi.lua")
---@type World
local cworld = dofile_once("mods/conjurer_reborn/files/unsafe/world.lua")
local ffi = require("ffi")
ffi.cdef[[
void free(void *ptr);
void *malloc(size_t size);
]]
world.capi = world_ffi
world.cw = cworld

---申请一个非托管的StdString
local function ToUnmanagedStdString(str)
    local stdstrPtr = ffi.new("struct std_string[1]")
	local stdstr = stdstrPtr[0]
    stdstr.size = str:len()
    if str:len() >= 16 then
        stdstr.data.buffer = ffi.C.malloc(str:len() + 1)
        for i = 0, str:len() - 1 do
            stdstr.data.buffer[i] = str:byte(i + 1, i + 1)
        end
        stdstr.data.buffer[str:len()] = 0
        stdstr.capacity = str:len()
    else
        stdstr.capacity = 15
		if str:len() == 0 then
            stdstr.size = 0
            stdstr.data.sso_buffer[0] = 0
			return stdstrPtr
		end
        for i = 0, str:len() - 1 do
            stdstr.data.sso_buffer[i] = str:byte(i + 1, i + 1)
        end
        stdstr.data.sso_buffer[str:len()] = 0
    end
    return stdstrPtr
end

local function StdStringToStr(stdstr)
    if stdstr.size >= 16 then
        return ffi.string(stdstr.data.buffer, stdstr.size)
    end
	return ffi.string(stdstr.data.sso_buffer, stdstr.size)
end

---@class CellType
CellType = {
    NONE = 0,
    LIQUID = 1,
    GAS = 2,
    SOLID = 3,
    FIRE = 4,
}

---@class CellDataObj
---@field name string str id
---@field ui_name string
---@field material_type integer id
---@field id_2 integer id_2
---@field cell_type CellType
---@field wang_color integer
---@field gfx_glow integer
---@field gfx_glow_color integer
---@field default_primary_colour integer
---@field cell_holes_in_texture boolean
---@field stainable boolean
---@field burnable boolean
---@field on_fire boolean
---@field fire_hp integer
---@field autoignition_temperature integer
---@field _100_minus_autoignition_temp integer
---@field temperature_of_fire integer
---@field generates_smoke integer
---@field generates_flames integer
---@field requires_oxygen boolean
---@field on_fire_convert_to_material string
---@field on_fire_convert_to_material_id integer
---@field on_fire_flame_material string
---@field on_fire_flame_material_id integer
---@field on_fire_smoke_material string
---@field on_fire_smoke_material_id integer
---@field durability integer
---@field crackability integer
---@field electrical_conductivity boolean
---@field slippery boolean
---@field stickyness number
---@field cold_freezes_to_material string
---@field warmth_melts_to_material string
---@field warmth_melts_to_material_id integer
---@field cold_freezes_to_material_id integer
---@field cold_freezes_chance_rev integer
---@field warmth_melts_chance_rev integer
---@field cold_freezes_to_dont_do_reverse_reaction boolean
---@field lifetime integer
---@field hp integer
---@field density number
---@field liquid_sand boolean
---@field liquid_slime boolean
---@field liquid_static boolean
---@field liquid_stains_self boolean
---@field liquid_sticks_to_ceiling integer
---@field liquid_gravity number
---@field liquid_viscosity integer
---@field liquid_stains integer
---@field liquid_stains_custom_color integer
---@field liquid_sprite_stain_shaken_drop_chance number
---@field liquid_sprite_stain_ignited_drop_chance number
---@field liquid_sprite_stains_check_offset integer
---@field liquid_sprite_stains_status_threshold number
---@field liquid_damping number
---@field liquid_flow_speed number
---@field liquid_sand_never_box2d boolean
---@field gas_speed integer
---@field gas_upwards_speed integer
---@field gas_horizontal_speed integer
---@field gas_downwards_speed integer
---@field solid_friction number
---@field solid_restitution number
---@field solid_gravity_scale number
---@field solid_static_type integer
---@field solid_on_collision_splash_power number
---@field solid_on_collision_explode boolean
---@field solid_on_sleep_convert boolean
---@field solid_on_collision_convert boolean
---@field solid_on_break_explode boolean
---@field solid_go_through_sand boolean
---@field solid_collide_with_self boolean
---@field solid_on_collision_material string
---@field solid_on_collision_material_id integer
---@field solid_break_to_type string
---@field solid_break_to_type_id integer
---@field convert_to_box2d_material string
---@field convert_to_box2d_material_id integer
---@field vegetation_full_lifetime_growth integer
---@field vegetation_sprite string
---@field vegetation_random_flip_x_scale boolean
---@field wang_noise_percent number
---@field wang_curvature number
---@field wang_noise_type integer
---@field danger_fire boolean
---@field danger_radioactive boolean
---@field danger_poison boolean
---@field danger_water boolean
---@field always_ignites_damagemodel boolean
---@field ignore_self_reaction_warning boolean
---@field audio_size_multiplier number
---@field audio_is_soft boolean
---@field show_in_creative_mode boolean
---@field is_just_particle_fx boolean
---@field is_transformed boolean

---@return CellDataObj
local function NewCelldataObj(celldata)
    local result = {
        celldata = celldata
    }
    return setmetatable(result, {
        __index = function(t, k)
            if ffi.istype("struct std_string", celldata[k]) then --如果为字符串
                return StdStringToStr(celldata[k])
            end
            return celldata[k]
        end,
        __newindex = function (t, k, v)
            if ffi.istype("struct std_string", celldata[k]) then --如果为字符串
                if celldata[k].size >= 16 then
                    ffi.C.free(celldata[k].data.buffer)
                end
                celldata[k] = ToUnmanagedStdString(v)[0]
                return
            end
            celldata[k] = v
        end
    })
end

--cell是观察者指针，不应该持有
---@class CellObj
local CellObjFuncs = {}

---@return CellObj
function NewCellObj(ptr)
    ---@class CellObj
    local result = {
        ---@type Cell
        cell = ptr,
        ---@type CellDataObj
        data = NewCelldataObj(ptr.vtable.get_material(ptr)),
    }
	return setmetatable(result, { __index = CellObjFuncs })
end

---@return CellType
function CellObjFuncs:GetCellType()
    return self.cell.vtable.get_cell_type(self.cell)
end

---获取材料颜色
---@return integer rgba
function CellObjFuncs:GetColor()
    return self.cell.vtable.get_colour(self.cell)
end

---获取材料原色
---@return integer r
---@return integer g
---@return integer b
---@return integer a
function CellObjFuncs:GetNotColor()
    return self.cell.vtable.get_not_colour(self.cell)
end

---设置材料颜色
---@param rgba integer
function CellObjFuncs:SetColor(rgba)
    self.cell.vtable.set_colour(self.cell, rgba)
end

---清洗！将材料变回原色
function CellObjFuncs:Wash()
    self.cell.vtable.set_colour(self.cell, self.cell.vtable.get_not_colour(self.cell))
end

---@return boolean
function CellObjFuncs:IsBurning()
    return self.cell.is_burning
end

---强行设置燃烧状态，这可以让所有材料燃烧
---@param enabled boolean
function CellObjFuncs:SetBurning(enabled)
    self.cell.is_burning = enabled
end

---让材料燃烧，如果材料无法燃烧则不会燃烧
---@param set_temperature_of_fire integer?
function CellObjFuncs:MakeBurning(set_temperature_of_fire)
    if set_temperature_of_fire == nil then
        set_temperature_of_fire = self.cell.vtable.get_temperature_of_fire(self.cell)
    end
    self.cell.vtable.make_burning(self.cell, world_ffi.get_grid_world(), set_temperature_of_fire)
end

---使用游戏自带的灭火函数
function CellObjFuncs:StopBurning()
    self.cell.vtable.stop_burning(self.cell)
end

function CellObjFuncs:GetTags()
    return CellFactory_GetTags(self.data.material_type)
end

---@param tag string
---@return boolean
function CellObjFuncs:HasTag(tag)
    return CellFactory_HasTag(self.data.material_type, tag)
end

---设置材料通电时长
---@param frame integer
function CellObjFuncs:SetLightingTime(frame)
    self.cell.start_frame_or_lightning_end_frame = GameGetFrameNum() + frame
end

---让材料绘制新建时光效，和通电互斥
function CellObjFuncs:DrawCreateLight()
    self.cell.start_frame_or_lightning_end_frame = GameGetFrameNum()
    self.cell.draw_create_light = true
end

---仅对 CLiquidCell (CellType.LIQUID) 材料可用，其他类型的无效果
---@param enabled boolean
function CellObjFuncs:SetStatic(enabled)
    if self:GetCellType() == CellType.LIQUID then
        ffi.cast("struct CLiquidCell*",self.cell).is_static = enabled
    end
end

---@return boolean
function CellObjFuncs:GetStatic()
    if self:GetCellType() == CellType.LIQUID then
        return ffi.cast("struct CLiquidCell*", self.cell).is_static
    end
    return self.data.liquid_static
end

---@return integer
function CellObjFuncs:GetHP()
    return self.cell.hp
end

---@param hp integer
function CellObjFuncs:SetHP(hp)
    self.cell.hp = hp
end

---@return integer x
---@return integer y
function CellObjFuncs:GetPos()
    local pos = self.cell.vtable.get_position(self.cell, world_ffi.Position())
    return pos.x, pos.y
end

--单元转换，这不会让box2d失效
--<br>而且只是数据变了，甚至类型都没变，如果两种材料类型不一致的话，那么行为也会不一致
---@param celldata CellDataObj|string celldata/strid
function CellObjFuncs:Conversion(celldata)
    local grid = world_ffi.get_grid_world()
    if type(celldata) == "string" then
        local id = world_ffi.get_material_ptr(CellFactory_GetType(celldata))
        self.cell.vtable.cell_conversion(self.cell, grid, id)
    else
        self.cell.vtable.cell_conversion(self.cell, grid, celldata.celldata)
    end
end

--单元覆写
---@param id integer|string celldata/strid
function CellObjFuncs:Overwrite(id)
    local grid = world_ffi.get_grid_world()
    if type(id) == "string" then
        self.cell.vtable.cell_overwrite(self.cell, grid, CellFactory_GetType(id))
    else
        self.cell.vtable.cell_overwrite(self.cell, grid, id)
    end
end

---在给定的坐标处发生反应
---@param x any
---@param y any
function CellObjFuncs:MaterialReaction(x,y)
    self.cell.vtable.material_reaction(self.cell, world_ffi.get_grid_world(), x, y)
end

---与给定坐标的单元进行交换
---@param x any
---@param y any
function CellObjFuncs:Swap(x,y)
    self.cell.vtable.cell_swap(self.cell, world_ffi.get_grid_world(), x, y)
end

--获取网格中的单元(地图里的材料)
---@param x integer
---@param y integer
---@return CellObj?
function world.GetCell(x, y)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    local pcell = world_ffi.get_cell(chunkMap, x, y)
    if pcell[0] ~= nil then
        return NewCellObj(pcell[0])
    end
    return nil
end

--获取材料全局共享的数据
---@param strid string
function world.GetCellData(strid)
    return NewCelldataObj(world_ffi.get_material_ptr(CellFactory_GetType(strid)))
end

local function GetCreateCell()
    if DebugGetIsDevBuild() then
        return world_ffi.construct_cell
    end
    local matptr = world_ffi.get_material_ptr(CellFactory_GetType("sand_static"))
    return function (grid_world, x, y, material, memory)
        if material.cell_holes_in_texture then
            local cell = world_ffi.construct_cell(grid_world, x, y, matptr, memory)
            cell.vtable.cell_overwrite(cell, grid_world, material.material_type)
            return cell
        else
            return world_ffi.construct_cell(grid_world, x, y, material, memory)
        end
    end
end

---@type fun(grid_world: GridWorld, x: integer, y: integer, material: CellData, memory: ffi.cdata*)
CreateCell = GetCreateCell()

--在网格中创建一个材料
---@param x integer
---@param y integer
---@param celldata CellDataObj|string celldata/strid
---@return CellObj? NewCell
function world.CreateCell(celldata, x, y)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    if not world_ffi.chunk_loaded(chunkMap,x,y) then
        return
    end
    local pcell = world_ffi.get_cell(chunkMap, x, y)
    if pcell[0] ~= nil then
        return
    end
    if type(celldata) == "string" then
        local id = world_ffi.get_material_ptr(CellFactory_GetType(celldata))
        pcell[0] = CreateCell(grid, x, y, id, nil)
    else
        pcell[0] = CreateCell(grid, x, y, celldata.celldata, nil)
    end
    return NewCellObj(pcell[0])
end

--给定一个列表，通过这个列表中的参数创建材料
---@param list integer[] [xoffset, yoffset, ...]
---@param matid integer
---@param x integer
---@param y integer
---@param drawLight boolean? drawLight=false
function world.CreateCellsInArea(list, matid, x, y, drawLight)
    local grid = world_ffi.get_grid_world()
    local matptr = world_ffi.get_material_ptr(matid)
    local chunkMap = grid.vtable.get_chunk_map(grid)
    if drawLight then
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            if not world_ffi.chunk_loaded(chunkMap, cx, cy) then
                goto continue
            end
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] ~= nil then
                goto continue
            end
            pcell[0] = CreateCell(grid, cx, cy, matptr, nil)
            pcell[0].draw_create_light = true
            pcell[0].start_frame_or_lightning_end_frame = GameGetFrameNum()
            ::continue::
        end
    else
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            if not world_ffi.chunk_loaded(chunkMap, cx, cy) then
                goto continue
            end
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] ~= nil then
                goto continue
            end
            pcell[0] = CreateCell(grid, cx, cy, matptr, nil)
            ::continue::
        end
    end
end

--给定一个列表，通过这个列表中的参数覆写材料
---@param list integer[] [xoffset, yoffset, ...]
---@param matid integer
---@param x integer
---@param y integer
---@param construct boolean? construct=false
---@param drawLight boolean? drawLight=false
function world.OverwriteCellsInArea(list, matid, x, y, construct, drawLight)
    local grid = world_ffi.get_grid_world()
    local matptr = world_ffi.get_material_ptr(matid)
    local chunkMap = grid.vtable.get_chunk_map(grid)
    if construct then --构造分支
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] ~= nil then
                pcell[0].vtable.cell_overwrite(pcell[0], grid, matid)
                goto continue
            end
            if not world_ffi.chunk_loaded(chunkMap, cx, cy) then
                goto continue
            end
            pcell[0] = CreateCell(grid, cx, cy, matptr, nil)
            if drawLight then--新建材料时的光
                pcell[0].draw_create_light = true
                pcell[0].start_frame_or_lightning_end_frame = GameGetFrameNum()
            end
            ::continue::
        end
    else
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] ~= nil then --如果未加载是获取不到材料的，所以无需检查区块加载
                local cell = pcell[0]
                cell.vtable.cell_overwrite(cell, grid, matid)
            end
        end
    end
end

--给定一个列表，通过这个列表中的参数转换材料
---@param list integer[] [xoffset, yoffset, ...]
---@param matid integer
---@param x integer
---@param y integer
---@param construct boolean? construct=false
function world.ConversionCellsInArea(list, matid, x, y, construct)
    local grid = world_ffi.get_grid_world()
    local matptr = world_ffi.get_material_ptr(matid)
    local chunkMap = grid.vtable.get_chunk_map(grid)
    if construct then  --构造分支
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] ~= nil then --如果有材料则可用快速失败
                local cell = pcell[0]
                if cell.material_ptr.material_type ~= matid then
                    cell.vtable.cell_conversion(cell, grid, matptr)
                end
                goto continue
            end
            if not world_ffi.chunk_loaded(chunkMap, cx, cy) then --没有需要先判断区块加载
                goto continue
            end
            pcell[0] = CreateCell(grid, cx, cy, matptr, nil)
            ::continue::
        end
    else --不构造分支
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] ~= nil then --如果未加载是获取不到材料的，所以无需检查区块加载
                local cell = pcell[0]
                if cell.material_ptr.material_type ~= matid then
                    cell.vtable.cell_conversion(cell, grid, matptr)
                end
            end
        end
    end
end

--给定一个列表，通过这个列表中的参数移除
---@param list integer[] [xoffset, yoffset, ...]
---@param x integer
---@param y integer
---@param pred (fun(cell:ffi.cdata*):boolean)? cell是原始指针，为了性能
function world.RemoveCellsInArea(list, x, y, pred)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    if pred then --谓词分支
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] == nil then --如果未加载是获取不到材料的，所以无需检查区块加载
                goto continue
            end
            if pred(pcell[0]) then
                world_ffi.remove_cell(grid, pcell[0], cx, cy, true)
            end
            ::continue::
        end
    else
        for i = 1, #list, 2 do
            local cx = x + list[i]
            local cy = y + list[i + 1]
            local pcell = world_ffi.get_cell(chunkMap, cx, cy)
            if pcell[0] == nil then --如果未加载是获取不到材料的，所以无需检查区块加载
                goto continue
            end
            world_ffi.remove_cell(grid, pcell[0], cx, cy, true)
            ::continue::
        end
    end
end

--给定一个列表，将获取到的cell作为参数调用implement
---@param list integer[] [xoffset, yoffset, ...]
---@param x integer
---@param y integer
---@param implement fun(cell:ffi.cdata*, x:integer, y:integer) cell是原始指针，为了性能
function world.GetCellsInArea(list, x, y, implement)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    for i = 1, #list, 2 do
        local cx = x + list[i]
        local cy = y + list[i + 1]
        local pcell = world_ffi.get_cell(chunkMap, cx, cy)
        if pcell[0] ~= nil then     --如果未加载是获取不到材料的，所以无需检查区块加载
            implement(pcell[0], cx, cy)
        end
    end
end

--在网格中移除一个材料
---@param x integer
---@param y integer
function world.RemoveCell(x, y)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    local pcell = world_ffi.get_cell(chunkMap, x, y)
    if pcell[0] == nil then
        return
    end
    world_ffi.remove_cell(grid, pcell[0], x, y, true)
end

--覆盖一个网格中的材料，为了性能会对相同id材料快速失败
---@param x integer
---@param y integer
---@param celldata CellDataObj|string celldata/strid
---@return CellObj? NewCell
function world.OverwriteCell(celldata, x, y)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    if not world_ffi.chunk_loaded(chunkMap, x, y) then
        return
    end
    local pcell = world_ffi.get_cell(chunkMap, x, y)
    --如果有则调用覆盖函数
    if pcell[0] ~= nil then
        local cell = pcell[0]
        local gid = cell.vtable.get_material_type(cell)
        if (type(celldata) == "string" and gid == CellFactory_GetType(celldata)) or
            (gid == celldata.material_type) then
            return NewCellObj(cell)
        end
        if type(celldata) == "string" then
            cell.vtable.cell_overwrite(cell, grid, CellFactory_GetType(celldata))
        else
            cell.vtable.cell_overwrite(cell, grid, celldata.material_type)
        end
        return NewCellObj(pcell[0])
    end

    --没有则新建材料
    if type(celldata) == "string" then
        local id = world_ffi.get_material_ptr(CellFactory_GetType(celldata))
        pcell[0] = CreateCell(grid, x, y, id, nil)
    else
        pcell[0] = CreateCell(grid, x, y, celldata.celldata, nil)
    end
    return NewCellObj(pcell[0])
end

--区块是否加载
---@param x integer
---@param y integer
---@return boolean
function world.IsChunkLoaded(x, y)
    local grid = world_ffi.get_grid_world()
    local chunkMap = grid.vtable.get_chunk_map(grid)
    return world_ffi.chunk_loaded(chunkMap, x, y)
end

---@param enabled boolean
---@return boolean success
function world.EnableCellUpdate(enabled)
    return world_ffi.EnableCellUpdate(enabled)
end

return world
