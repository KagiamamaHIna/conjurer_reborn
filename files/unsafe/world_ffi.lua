---@diagnostic disable: assign-type-mismatch
dofile_once("mods/conjurer_unsafe/files/YNPCommon.lua")

---@class ynpWorldFFI
local world_ffi = {}

local ffi = require("ffi")
ffi.cdef[[
int SetDllDirectoryA(const char* lpPathName);
void YNPMHInit();

uint32_t FindGetCell();
uint32_t FindRemoveCell();
uint32_t FindConstructCell();
uint32_t FindIsChunkLoaded();
uint32_t FindGetGameGlobal();

bool EnableCellUpdate(bool enabled);

typedef int __cdecl get_game_global();

//by NoitaPatcher
typedef void* __thiscall placeholder_memfn(void*);

struct Position {
    int x;
    int y;
};

struct Colour {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
};

struct AABB {
    struct Position top_left;
    struct Position bottom_right;
};

struct std_vector_string {
    struct std_string* start;
    struct std_string* end;
    struct std_string* capacity;
};

typedef enum cell_type {
    none=0,
    liquid=1,
    gas=2,
    solid=3,
    fire=4,
    invalid=4294967295
} cell_type;

struct CellData {
    struct std_string name; // +0
    struct std_string ui_name; // +24
    int material_type; // +48
    int id_2; // +52
    enum cell_type cell_type; // +56
    int platform_type; // +60
    unsigned int wang_color; // +64
    int gfx_glow; // +68
    unsigned int gfx_glow_color;// +72
    char unknown1[24];// +76
    unsigned int default_primary_colour;// +100
    char unknown2[36];// +104
    bool cell_holes_in_texture;// +140
    bool stainable;// +141
    bool burnable;// +142
    bool on_fire;// +143
    int fire_hp;// +144
    int autoignition_temperature;// +148
    int _100_minus_autoignition_temp;// +152
    int temperature_of_fire;// +156
    int generates_smoke;// +160
    int generates_flames;// +164
    bool requires_oxygen;// +168
    char padding1[3];// +169
    struct std_string on_fire_convert_to_material;// +172
    int on_fire_convert_to_material_id;// +196
    struct std_string on_fire_flame_material;// +200
    int on_fire_flame_material_id;// +224
    struct std_string on_fire_smoke_material;// +228
    int on_fire_smoke_material_id;// +252
    struct ConfigExplosion *explosion_config;// +256
    int durability;// +260
    int crackability;// +264
    bool electrical_conductivity;// +268
    bool slippery;// +269
    char padding2[2];// +270
    float stickyness;// +272
    struct std_string cold_freezes_to_material;// +276
    struct std_string warmth_melts_to_material;// +300
    int warmth_melts_to_material_id;// +324
    int cold_freezes_to_material_id;// +328
    int16_t cold_freezes_chance_rev;// +332
    int16_t warmth_melts_chance_rev;// +334
    bool cold_freezes_to_dont_do_reverse_reaction;// +336
    char padding3[3];// +337
    int lifetime;// +340
    int hp;// +344
    float density;// +348
    bool liquid_sand;// +352
    bool liquid_slime;// +353
    bool liquid_static;// +354
    bool liquid_stains_self;// +355
    int liquid_sticks_to_ceiling;// + 356
    float liquid_gravity;// +360
    int liquid_viscosity;// +364
    int liquid_stains;// +368
    unsigned int liquid_stains_custom_color;// +372
    float liquid_sprite_stain_shaken_drop_chance;// +376
    float liquid_sprite_stain_ignited_drop_chance;// +380
    int8_t liquid_sprite_stains_check_offset;// +384
    char padding4[3];// +385
    float liquid_sprite_stains_status_threshold;// +388
    float liquid_damping;// +392
    float liquid_flow_speed;// +396
    bool liquid_sand_never_box2d;// +400
    char unknown7[3];//+401
    int8_t gas_speed;//+404
    int8_t gas_upwards_speed;//+405
    int8_t gas_horizontal_speed;//+406
    int8_t gas_downwards_speed;//+407
    float solid_friction;//+408
    float solid_restitution;//+412
    float solid_gravity_scale;//+416
    int solid_static_type;//+420
    float solid_on_collision_splash_power;//+424
    bool solid_on_collision_explode;//+428
    bool solid_on_sleep_convert;//+429
    bool solid_on_collision_convert;//+430
    bool solid_on_break_explode;//+431
    bool solid_go_through_sand;//+432
    bool solid_collide_with_self;//+433
    char padding5[2];//+434
    struct std_string solid_on_collision_material;//+436
    int solid_on_collision_material_id;//+460
    struct std_string solid_break_to_type;//+464
    int solid_break_to_type_id;//+488
    struct std_string convert_to_box2d_material;//+492
    int convert_to_box2d_material_id;//+516
    int vegetation_full_lifetime_growth;//+520
    struct std_string vegetation_sprite;//+524
    bool vegetation_random_flip_x_scale;//+548
    char padding6[3];//+549
    char unknown11[12];//+552
    float wang_noise_percent;//+564
    float wang_curvature;//+568
    int wang_noise_type;//+572
    struct std_vector_string tags;//+576
    bool danger_fire;//+588
    bool danger_radioactive;//+589
    bool danger_poison;//+590
    bool danger_water;//+591
    char unknown13[24];//+592
    bool always_ignites_damagemodel;//+616
    bool ignore_self_reaction_warning;//+617
    char padding7[2];//+618
    char unknown14[12];//+620
    float audio_size_multiplier;//+632
    bool audio_is_soft;//+636
    char padding8[3];//+637
    char unknown15[8];//+640
    bool show_in_creative_mode;//+648
    bool is_just_particle_fx;//+649
    bool is_transformed;//+650
    char padding9[1];
    // struct grid_CosmeticParticleConfig *ParticleEffect;
};

enum CellType {
    CELL_TYPE_NONE = 0,
    CELL_TYPE_LIQUID = 1,
    CELL_TYPE_GAS = 2,
    CELL_TYPE_SOLID = 3,
    CELL_TYPE_FIRE = 4,
};

/*逆向分析结果，但为了性能不使用它
struct Cell_vtable {
    void (__thiscall *destroy)(struct Cell*, char dealloc);//+0
    enum CellType (__thiscall *get_cell_type)(struct Cell*);//+4
    int (__thiscall *get_material_type)(struct Cell*);//+8
    int (__thiscall *get_id2)(struct Cell*);//+12
    int (__thiscall *is_visibility)(struct Cell*);//+16 会有 [0,1,2,3,4] 作为返回值，4代表不可见，其他参数未知，0出现在ICellBurnable，但似乎无法获取
    struct Colour (__thiscall *get_colour)(struct Cell*);//+20
    struct Colour (__thiscall *get_liquid_stains_custom_color)(struct Cell*);//+24
    struct Colour (__thiscall *set_colour)(void*, struct Colour);//+28
    struct Colour (__thiscall *get_not_colour)(void*);//+32
    struct Colour (__thiscall *set_colour_pairs)(struct Cell*, struct Colour);//+36 将not_colour和colour都设为参数2，并返回提供的颜色
    struct std_string* (__thiscall *get_name)(struct Cell*);//+40
    bool (__thiscall *can_stand_on)(struct Cell*);//+44
    struct CellData* (__thiscall *get_material)(void *);//+48
    struct Colour (__thiscall *cell_conversion)(struct Cell*, struct GridWorld*, struct CellData*);//+52 单元转换，这不会让box2d失效
    void* (__thiscall *get_physics_bridge)(struct Cell*);//+56 box2d之外的材料返回空指针，很有可能和box2d有关
    int (__thiscall *field15_0x3c)(struct Cell*, int frame, int unk10000);//+60 根据第三个参数更改为静态的神秘函数，第二个参数似乎是帧，和liquid_sticks_to_ceiling有关，应该没用
    void* field16_0x40;//+64 可能和上个函数有关，未知用途
    void* field17_0x44;//+68
    char (__thiscall *cell_swap)(struct Cell*, struct GridWorld*, int nx, int ny);//+72 将单元交换，不支持box2d
    bool (__thiscall *set_position)(struct Cell*, int x, int y);//+76 设置坐标？但不知道怎么用(似乎容易导致单元更新时崩溃)，给box2d用会报错并返回false
    struct Position * (__thiscall *get_position)(void *, struct Position *);//+80
    void* CellUpdate;//+84 参数大约是：(cell, unk, bool, grid_world, cell2)，返回material_ptr
    void* field22_0x58;//CLiquidCell返回1
    void* field23_0x5c;//CLiquidCell返回0
    void* field24_0x60;//CLiquidCell返回0
    bool (__thiscall *is_liquid_sand)(struct Cell*);
    void* field26_0x68;
    void* field27_0x6c;
    bool (__thiscall *is_burnable)(struct Cell*);
    bool (__thiscall *is_burning)(struct Cell*);
    char (__thiscall *make_burning)(struct Cell*, struct GridWorld*, uint8_t set_temperature_of_fire);
    void (__thiscall *make_burning_everything)(struct Cell*, struct GridWorld*, uint8_t set_temperature_of_fire);
    uint8_t (__thiscall *get_temperature_of_fire)(struct Cell*);
    void (__thiscall *stop_burning)(struct Cell*);
    void* field34_0x88;//全部都返回0
    int (__thiscall *material_reaction)(struct Cell*, struct GridWorld*, int x, int y);//可直接使用的材料反应相关函数
    struct std_string* (__thiscall *field36_0x90_reaction)(struct Cell*, struct GridWorld*, int x, int y);//猜测
    void* field37_0x94_directional_reaction;//猜测
    int  (__thiscall *cell_overwrite)(struct Cell*, struct GridWorld*, int id);//单元覆写，这会让box2d失效
    void (__thiscall *remove)(struct Cell*);
    void* field40_0xa0;
};*/
//对一些签名做了无害的修改，可以提升lua端调用时的性能
struct Cell_vtable {
    void (__thiscall *destroy)(struct Cell*, char dealloc);//+0
    enum CellType (__thiscall *get_cell_type)(struct Cell*);//+4
    int (__thiscall *get_material_type)(struct Cell*);//+8
    int (__thiscall *get_id2)(struct Cell*);//+12
    int (__thiscall *is_visibility)(struct Cell*);//+16 会有 [0,1,2,3,4] 作为返回值，4代表不可见，其他参数未知，0出现在ICellBurnable，但似乎无法获取
    uint32_t (__thiscall *get_colour)(struct Cell*);//+20
    uint32_t (__thiscall *get_liquid_stains_custom_color)(struct Cell*);//+24
    void (__thiscall *set_colour)(void*, uint32_t);//+28
    uint32_t (__thiscall *get_not_colour)(void*);//+32
    void (__thiscall *set_colour_pairs)(struct Cell*, uint32_t);//+36 将not_colour和colour都设为参数2，并返回提供的颜色
    struct std_string* (__thiscall *get_name)(struct Cell*);//+40
    bool (__thiscall *can_stand_on)(struct Cell*);//+44
    struct CellData* (__thiscall *get_material)(void *);//+48
    void (__thiscall *cell_conversion)(struct Cell*, struct GridWorld*, struct CellData*);//+52 单元转换，这不会让box2d失效
    void* (__thiscall *get_physics_bridge)(struct Cell*);//+56 box2d之外的材料返回空指针，很有可能和box2d有关
    int (__thiscall *field15_0x3c)(struct Cell*, int frame, int unk10000);//+60 根据第三个参数更改为静态的神秘函数，第二个参数似乎是帧，和liquid_sticks_to_ceiling有关，应该没用
    void* field16_0x40;//+64 可能和上个函数有关，未知用途
    void* field17_0x44;//+68
    char (__thiscall *cell_swap)(struct Cell*, struct GridWorld*, int nx, int ny);//+72 将单元交换，不支持box2d
    bool (__thiscall *set_position)(struct Cell*, int x, int y);//+76 设置坐标？但不知道怎么用(似乎容易导致单元更新时崩溃)，给box2d用会报错并返回false
    struct Position * (__thiscall *get_position)(void *, struct Position *);//+80
    void* CellUpdate;//+84 参数大约是：(cell, unk, bool, grid_world, cell2)，返回material_ptr
    void* field22_0x58;//CLiquidCell返回1
    void* field23_0x5c;//CLiquidCell返回0
    void* field24_0x60;//CLiquidCell返回0
    bool (__thiscall *is_liquid_sand)(struct Cell*);
    void* field26_0x68;
    void* field27_0x6c;
    bool (__thiscall *is_burnable)(struct Cell*);
    bool (__thiscall *is_burning)(struct Cell*);
    char (__thiscall *make_burning)(struct Cell*, struct GridWorld*, uint8_t set_temperature_of_fire);
    void (__thiscall *make_burning_everything)(struct Cell*, struct GridWorld*, uint8_t set_temperature_of_fire);
    uint8_t (__thiscall *get_temperature_of_fire)(struct Cell*);
    void (__thiscall *stop_burning)(struct Cell*);
    void* field34_0x88;//全部都返回0
    int (__thiscall *material_reaction)(struct Cell*, struct GridWorld*, int x, int y);//可直接使用的材料反应相关函数
    struct std_string* (__thiscall *field36_0x90_reaction)(struct Cell*, struct GridWorld*, int x, int y);//猜测
    void* field37_0x94_directional_reaction;//猜测
    int  (__thiscall *cell_overwrite)(struct Cell*, struct GridWorld*, int id);//单元覆写，这会让box2d失效
    void (__thiscall *remove)(struct Cell*);
    void* field40_0xa0;
};

// In the Noita code this would be the ICellBurnable class
struct Cell {//基类 24
    struct Cell_vtable* vtable;

    int hp;//+4
    int start_frame_or_lightning_end_frame;//+8 默认-1000
    bool draw_create_light;//+12 配合上面的参数可以做到新建材料时的发光效果，结束会自动设为false
    char padding1[3];//+13
    bool is_burning;//+16
    uint8_t temperature_of_fire;//+17
    char padding2[2];//+18
    struct CellData* material_ptr;//+20
};

struct CLiquidCell {//64
    struct Cell cell;
    int x;//+24
    int y;//+28
    
    char visibility;//+32 [1,2,3,4] 4代表不可见
    uint8_t liquid_sticks_to_ceiling_count;//+33 一个计数器，当 >=50 且 visibility == 3 会满足liquid_sticks_to_ceiling条件
    bool is_static;//+34
    char unknown3;//+35

    float unk_float1;//+36 似乎和速度有关
    float unk_float2;//+40 似乎和速度有关
    int frame;//+44 会一直更新
    uint32_t colour;//+48
    uint32_t not_colour;//+52
    int lifetime_end_frame;//+56 和lifetime相关，看起来像终止帧
    void* unknown6;//+60
};

struct CFireCell {//40
    struct Cell cell;
    char unknown1[16];
};

//无内置is_static
struct CGasCell {//60
    struct Cell cell;
    int unknown1;//+24
    int frame;//+28 会一直更新
    int x;//+32
    int y;//+36
    char unknown2[8];//+40
    struct Colour colour;//+48
    char unknown3[8];//+52
};

struct CSolidCell {//104
    struct Cell cell;
    char unknown1[80];
};

typedef struct Cell (*cell_array)[0x40000];

struct ChunkMap {
    int unknown[2];//+0
    cell_array* (*cells)[0x40000];//+8
    int unknown2[8];
};

struct GridWorld_vtable {
    placeholder_memfn* unknown[3];
    struct ChunkMap* (__thiscall *get_chunk_map)(struct GridWorld* this);//+12
    placeholder_memfn* unknown2[18];//+16
    void* GetCellFactory;
    placeholder_memfn* unknown2[11];
};

struct GridWorld {
    struct GridWorld_vtable* vtable;
    int unknown[318];
    int world_update_count;
    struct ChunkMap chunk_map;//+1280
    int unknown2[41];
    struct GridWorldThreadImpl* mThreadImpl;
};

struct GridWorldThreaded_vtable;

struct GridWorldThreaded {
    struct GridWorldThreaded_vtable* vtable;
    int unknown[287];
    struct AABB update_region;
};

struct vec_pGridWorldThreaded {
    struct GridWorldThreaded** begin;
    struct GridWorldThreaded** end_;
    struct GridWorldThreaded** capacity_end;
};

struct WorldUpdateParams {
    struct AABB update_region;
    int unknown;
    struct GridWorldThreaded* grid_world_threaded;
};

struct vec_WorldUpdateParams {
    struct WorldUpdateParams* begin;
    struct WorldUpdateParams* end_;
    struct WorldUpdateParams* capacity_end;
};

struct GridWorldThreadImpl {
    int chunk_update_count;
    struct vec_pGridWorldThreaded updated_grid_worlds;

    int world_update_params_count;
    struct vec_WorldUpdateParams world_update_params;

    int grid_with_area_count;
    struct vec_pGridWorldThreaded with_area_grid_worlds;

    int another_count;
    int another_vec[3];

    int some_kind_of_ptr;
    int some_kind_of_counter;

    int last_vec[3];
};

typedef struct Cell** __thiscall get_cell_f(struct ChunkMap*, int x, int y);
typedef bool __thiscall chunk_loaded_f(struct ChunkMap*, int x, int y);//IsSafe

typedef void __thiscall remove_cell_f(struct GridWorld*, void* cell, int x, int y, bool);
typedef struct Cell* __thiscall construct_cell_f(struct GridWorld*, int x, int y, void* material_ptr, void* memory);
]]

ffi.C.SetDllDirectoryA("mods/conjurer_unsafe/files/module/")
local YNP = ffi.load("YNoitaPatcher")
local function CheckNullptr(ptr, name)
	if ptr == 0 then
		error(name .. " is nullptr")
	end
end

local pGetCell = YNP.FindGetCell()
CheckNullptr(pGetCell, "GetCell")
local pRemoveCell = YNP.FindRemoveCell()
CheckNullptr(pRemoveCell, "RemoveCell")
local pConstructCell = YNP.FindConstructCell()
CheckNullptr(pConstructCell, "ConstructCell")
local pIsChunkLoaded = YNP.FindIsChunkLoaded()
CheckNullptr(pIsChunkLoaded, "IsChunkLoaded")
local pGetGameGlobal = YNP.FindGetGameGlobal()
CheckNullptr(pGetGameGlobal, "GetGameGlobal")

YNP.YNPMHInit()

---@param enabled boolean
---@return boolean success
function world_ffi.EnableCellUpdate(enabled)
    return YNP.EnableCellUpdate(enabled)
end

local gg_ptr = ffi.cast("get_game_global*", pGetGameGlobal)()
--by NoitaPatcher

---@class ChunkMap pointer type
---@class GridWorld pointer type
---@class CellData pointer type
---@class Cell pointer type

---Access a pixel in the world.
---You can write a cell created from world_ffi.construct_cell to this pointer to add a cell into the world.
---If there's already a cell at this position, make sure to call world_ffi.remove_cell first.
---@type fun(chunk_map: ChunkMap, x: integer, y: integer): Cell
world_ffi.get_cell = ffi.cast("get_cell_f*", pGetCell)

---Remove a cell from the world. bool return has unknown meaning.
---@type fun(grid_world: GridWorld, cell: Cell, x: integer, y: integer, flag:boolean): boolean
world_ffi.remove_cell = ffi.cast("remove_cell_f*", pRemoveCell)

---Create a new cell. If memory is null pointer it will allocate its own memory.
---@type fun(grid_world: GridWorld, x: integer, y: integer, material: CellData, memory: ffi.cdata*)
world_ffi.construct_cell = ffi.cast("construct_cell_f*", pConstructCell)

---Check if a chunk is loaded. x and y are world coordinates.
---```lua
---if world_ffi.chunk_loaded(chunk_map, x, y) then
---  local cell = world_ffi.get_cell(chunk_map, x, y)
---  ..
---```
---@type fun(chunk_map: ChunkMap, x: integer, y: integer): boolean
world_ffi.chunk_loaded = ffi.cast("chunk_loaded_f*", pIsChunkLoaded)

world_ffi.Position = ffi.typeof("struct Position")
world_ffi.Colour = ffi.typeof("struct Colour")
world_ffi.AABB = ffi.typeof("struct AABB")
world_ffi.CellType = ffi.typeof("enum CellType")
world_ffi.Cell = ffi.typeof("struct Cell")
-- world_ffi.CLiquidCell = ffi.typeof("struct CLiquidCell")
world_ffi.ChunkMap = ffi.typeof("struct ChunkMap")
world_ffi.GridWorld = ffi.typeof("struct GridWorld")
world_ffi.GridWorldThreaded = ffi.typeof("struct GridWorldThreaded")
world_ffi.WorldUpdateParams = ffi.typeof("struct WorldUpdateParams")
world_ffi.GridWorldThreadImpl = ffi.typeof("struct GridWorldThreadImpl")

---Get the grid world.
---@return GridWorld
function world_ffi.get_grid_world()
    local game_global = ffi.cast("void*", gg_ptr)
    local world_data = ffi.cast("void**", ffi.cast("char*", game_global) + 0xc)[0]
    local grid_world = ffi.cast("struct GridWorld**", ffi.cast("char*", world_data) + 0x44)[0]
    return grid_world
end

local cell_begin_offset = DebugGetIsDevBuild() and 0x1C or 0x18
local celldata_size = 0x290
local CellData_ptr = ffi.typeof("struct CellData*")

---Turn a standard material id into a material pointer.
---@param id integer material id that is used in the standard Noita functions
---@return CellData material to internal material data (aka cell data).
---```lua
---local gold_ptr = world_ffi.get_material_ptr(CellFactory_GetType("gold"))
---```
function world_ffi.get_material_ptr(id)
    local game_global = ffi.cast("char*", gg_ptr)
    local cell_factory = ffi.cast('char**', (game_global + 0x18))[0]
    local begin = ffi.cast('char**', cell_factory + cell_begin_offset)[0]
    local ptr = begin + celldata_size * id
    return ffi.cast(CellData_ptr, ptr) --[[@as CellData]]
end

---Turn a material pointer into a standard material id.
---@param material CellData to a material (aka cell data)
---@return integer material id that is accepted by standard Noita functions such as `CellFactory_GetUIName` and `ConvertMaterialOnAreaInstantly`.
---```lua
---local mat_id = world_ffi.get_material_id(cell.vtable.get_material(cell))
---```
---See: `world_ffi.get_material_ptr`
function world_ffi.get_material_id(material)
    local game_global = ffi.cast("char*", gg_ptr)
    local cell_factory = ffi.cast('char**', (game_global + 0x18))[0]
    local begin = ffi.cast('char**', cell_factory + cell_begin_offset)[0]
    local offset = ffi.cast('char*', material) - begin
    return offset / celldata_size
end
-- cell_factory + 40是mCellDataSize
return world_ffi
