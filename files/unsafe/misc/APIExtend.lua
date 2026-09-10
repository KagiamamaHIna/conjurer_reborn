---@module 'APIExtend'
dofile_once("mods/conjurer_unsafe/files/YNPCommon.lua")

---@module 'MemoryPattern'
local mp = dofile_once("mods/conjurer_reborn/files/unsafe/MemoryPattern.lua")
local ffi = require("ffi")
ffi.cdef[[
void free(void *ptr);
void *malloc(size_t size);

struct DevEntity{
    void* vtable;//+0
    int id;//+4
    char unk[8];//+8
    int kill_flag;//+16
    //unknown...
};

struct NormalEntity{
    int id;
    char unk[8];
    int kill_flag;
    //unknown...
};

struct EntityPtrVec{
    void* begin_;
    void* end_;
    void* capacity_end_;
};

struct DeathMatch{
    void* application_vtable;//+0
    void* mouse_listener_vtable;//+4
    void* keyboard_listener_vtable;//+8
    char unk;//+12
    char padding1[3];//+13
    void* joystick_listener_vtable;//+16
    void* simple_ui_listener_vtable;//+20
    void* event_listener_vtable;//+24
    bool is_camera_free;//+28
    char unknown2[3];//+29
    int unkfield;//+32
    char unknown3[52];//+36
    struct EntityPtrVec player_entities;//+88
    char unknown3[44];//+100
    bool is_player_death;//+144
    //unk...
};

struct CSerializerSaver{
    void* unkptr;
    struct std_string buffer;
    char unk[20];// +44? 
};

struct CSerializerLoader{
    void* unkptr;
    struct std_string buffer;
    char unk[20];
};

void* FindPlatformWin();

typedef int __fastcall StatsGetKeyValue(struct std_string* key, bool* out_exists);
typedef int* __thiscall MapGetValuePtr(void* this, struct std_string* key);
typedef struct DeathMatch* __thiscall GetDeathMatch(void* PlatformWinPtr);

typedef int __thiscall KeyboardListern(void* DeathMatchOffset8, int keycode1, int keycode2);

typedef void* __thiscall EntityGetPtr(void* EntityManager, int EntityID);

typedef void __fastcall SerializeEntity(void* entity_ptr, void* saver);
typedef void __fastcall DeserializeEntity(void* entity_ptr, void* loader, float* vec2);

typedef struct CSerializerSaver* __thiscall CSerializerSaverInit(struct CSerializerSaver* data, void* entity_ptr);
typedef struct CSerializerLoader* __thiscall CSerializerLoaderInit(struct CSerializerLoader* data, struct std_string* str, size_t str_size);
]]
local YNP = ffi.load("YNoitaPatcher")
local PlatformWinPtr = YNP.FindPlatformWin()
local DeathMatch
if PlatformWinPtr ~= nil then
    local Vftable = ffi.cast("char**", PlatformWinPtr)[0]
    DeathMatch = ffi.cast("GetDeathMatch*", ffi.cast("char**", (Vftable + 24))[0])(PlatformWinPtr)
end

local function ToStdString(str)
    local stdstrPtr = ffi.new("struct std_string[1]")
	local stdstr = stdstrPtr[0]
    stdstr.size = str:len()
    if str:len() >= 16 then
        stdstr.data.buffer = ffi.new("char[?]", str:len() + 1)
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

local extend = {}

local StatsGetKeyValueCode = mp.FindPatternInModule(nil, "8D ? ? E8 ? ? ? ? 8D ? ? ? ? ? 8B F0 8D ? ? E8")
if StatsGetKeyValueCode ~= nil then
    local StatsGetKeyValue = ffi.cast("StatsGetKeyValue*", mp.ResolveRelativeAddress(StatsGetKeyValueCode + 3, 1, 5))

    local out_exists = ffi.new("bool[1]")--由于不能并行，这是安全的
    ---获取_stats里KEY_VALUE_STATS，key所对应的value
    ---@param key string
    ---@return integer
    ---@return boolean
    function extend.StatsGetKeyValue(key)
        local value = StatsGetKeyValue(ToStdString(key), out_exists)
        return value, out_exists[0]
    end
else
    print_error("StatsGetKeyValueCode is nullptr")
end

local StatsSetKeyValueCode = mp.FindPatternInModule(nil, "8D 45 C0 B9 ? ? ? ? 50 74 ? E8 ? ? ? ? 8B 10")
if StatsSetKeyValueCode ~= nil then
    local statsPtr = ffi.cast("char**", StatsSetKeyValueCode + 4)[0]
    local MapGetValuePtr = ffi.cast("MapGetValuePtr*", mp.ResolveRelativeAddress(StatsSetKeyValueCode + 11, 1, 5))
    ---设置_stats里KEY_VALUE_STATS，key所对应的value
    ---@param key string
    ---@param value integer
    function extend.StatsSetKeyValue(key, value)
        local valuePtr = MapGetValuePtr(statsPtr, ToStdString(key))
        valuePtr[0] = value
    end
else
    print_error("StatsSetKeyValueCode is nullptr")
end

local KeyboardListernCode = mp.FindPatternInModule(nil, "83 ? 24 00 0F ? ? ? ? ? 80 3D ? ? ? ? 00 0F")
if DeathMatch ~= nil and KeyboardListernCode ~= nil then
    local KeyboardListern = ffi.cast("KeyboardListern*", mp.FindFuncStart(KeyboardListernCode))
    local isDebugPtr = ffi.cast("bool**", KeyboardListernCode + 12)[0]
    local ToKeyboardListernDM = ffi.cast("void*", ffi.cast("uint32_t", DeathMatch) + 8)
    --让玩家重生
    function extend.PlayerRespawn()
        if not DeathMatch.is_player_death then
            return
        end
        local lastCameraFree = DeathMatch.is_camera_free
        local lastDebug = isDebugPtr[0]
        isDebugPtr[0] = true
        DeathMatch.is_camera_free = true
        KeyboardListern(ToKeyboardListernDM, 40, 13) --模拟按下enter，触发玩家复活
        isDebugPtr[0] = lastDebug
        DeathMatch.is_camera_free = lastCameraFree
    end

    --实际上是控制是否显示结算页面的字段
    ---@return boolean
    function extend.PlayerIsDied()
        return DeathMatch.is_player_death
    end

    ---@return boolean
    function extend.GetIsDebug()
        return isDebugPtr[0]
    end
else
    print_error("KeyboardListernCode is nullptr")
end

local EntityType = "struct NormalEntity*"
if DebugGetIsDevBuild() then
    EntityType = "struct DevEntity*"
end

local EntityKillCode = mp.FindPatternInModule(nil, "8B 0D ? ? ? ? ? ? ? ? E8 ? ? ? ? 85 c0 74 e0 8b c8 e8")
if EntityKillCode ~= nil then
    local EntityManager = ffi.cast("char***", EntityKillCode + 2)[0][0]
    local EntityGetPtr = ffi.cast("EntityGetPtr*", mp.ResolveRelativeAddress(EntityKillCode + 10, 1, 5))
    ---获取实体指针
    ---@param entity_id integer
    ---@return ffi.cdata*
    function extend.EntityGetPtr(entity_id)
        return EntityGetPtr(EntityManager, entity_id)
    end

    ---取消实体死亡
    ---@param entity_id integer
    function extend.EntityUnKill(entity_id)
        local ptr = ffi.cast(EntityType, EntityGetPtr(EntityManager, entity_id))
        ptr.kill_flag = 0
        for _, v in ipairs(EntityGetAllChildren(entity_id) or {}) do
            extend.EntityUnKill(v)
        end
    end
    
    ---实体是否即将死亡
    ---@param entity_id integer
    ---@return boolean
    function extend.EntityWillDie(entity_id)
        local ptr = ffi.cast(EntityType, EntityGetPtr(EntityManager, entity_id))
        return ptr.kill_flag ~= 0
    end
else
    print_error("EntityKillCode is nullptr")
end

if DeathMatch ~= nil and EntityKillCode ~= nil then
    ---设置引擎认为的玩家实体，即摄像头跟随的
    ---@param entity_id integer
    ---@param index integer? =0
    function extend.SetPlayerEntity(entity_id, index)
        index = index or 0
        local playersSize = (ffi.cast("size_t", DeathMatch.player_entities.end_) - ffi.cast("size_t", DeathMatch.player_entities.begin_)) / 4
        if index >= playersSize then
            print_error("SetPlayerEntity: index out of range")
            return
        end
        if not EntityGetIsAlive(entity_id) then
            return
        end
        local ptr = extend.EntityGetPtr(entity_id)
        local begin = ffi.cast("void**", DeathMatch.player_entities.begin_)
        begin[index] = ptr
    end

    ---获取引擎认为的玩家实体，即摄像头跟随的
    ---@param index integer? =0
    ---@return integer? id
    function extend.GetPlayerEntity(index)
        index = index or 0
        local playersSize = (ffi.cast("size_t", DeathMatch.player_entities.end_) - ffi.cast("size_t", DeathMatch.player_entities.begin_)) / 4
        if index >= playersSize then
            print_error("SetPlayerEntity: index out of range")
            return
        end
        local begin = ffi.cast("void**", DeathMatch.player_entities.begin_)
        local entity = ffi.cast(EntityType, begin[0])
        return entity.id
    end
end

local SerializeEntityCode = mp.FindPatternInModule(nil, "e8 ? ? ? ? c7 45 fc 01 00 00 00 8d 4d ? 8b ? 51 8b ? ff 50 10")
local HasCSerialSaverCode = mp.FindPatternInModule(nil, "C7 ? ? ? ? ? C7 ? ? ? ? ? ? 8B ? 8D ? ? C7")
local DeserializeEntityCode = mp.FindPatternInModule(nil, "c6 ? ? 00 c7 45 fc 01 00 00 00 8d 4d ? 8b ? 51 8b ? ff 50 10")
local HasCSerialLoaderCode = mp.FindPatternInModule(nil, "C7 ? ? ? ? ? C7 ? ? ? ? ? ? 8B ? C7")

if SerializeEntityCode == nil or HasCSerialSaverCode == nil or DeserializeEntityCode == nil or HasCSerialLoaderCode == nil then
    print_error("nullptr?:")
    print_error("SerializeEntityCode: ", tostring(SerializeEntityCode))
    print_error("HasCSerialSaverCode: ", tostring(HasCSerialSaverCode))
    print_error("DeserializeEntityCode: ", tostring(DeserializeEntityCode))
    print_error("HasCSerialLoaderCode: ", tostring(HasCSerialLoaderCode))
else
    local SerializeEntityPtr = ffi.cast("SerializeEntity*", mp.FindFuncStart(SerializeEntityCode))
    local DeserializeEntityPtr = ffi.cast("DeserializeEntity*", mp.FindFuncStart(DeserializeEntityCode))
    local CSerialSaverInit = ffi.cast("CSerializerSaverInit*", mp.FindFuncStart(HasCSerialSaverCode))
    local CSerialLoaderInit = ffi.cast("CSerializerLoaderInit*", mp.FindFuncStart(HasCSerialLoaderCode))

    ---序列化为内部二进制格式
    ---@param entity_id integer
    ---@return string
    function extend.SerializeEntity(entity_id)
        local EntityPtr = extend.EntityGetPtr(entity_id)
        if EntityPtr == nil then
            return ""
        end
        local data = ffi.new("struct CSerializerSaver[1]")
        CSerialSaverInit(data, EntityPtr)
        local CSerialSaver = ffi.cast("void*", ffi.cast("uint32_t", data) + 44)
        SerializeEntityPtr(EntityPtr, CSerialSaver)
        local result = StdStringToStr(data[0].buffer)
        if data[0].buffer.size >= 16 then
            ffi.C.free(data[0].buffer.data.buffer)
        end
        return result
    end

    ---反序列化内部二进制格式为实体
    ---@param entity_id integer
    ---@param serialized_data string
    ---@param x number?
    ---@param y number?
    ---@return integer
    function extend.DeserializeEntity(entity_id, serialized_data, x, y)
        local EntityPtr = extend.EntityGetPtr(entity_id)
        if EntityPtr == nil then
            return 0
        end
        local length = #serialized_data
        if length < 40 then
            return 0
        end
        local data = ffi.new("struct CSerializerLoader[1]")
        CSerialLoaderInit(data, ToStdString(serialized_data), #serialized_data)
        local CSerialLoader = ffi.cast("void*", ffi.cast("uint32_t", data) + 44)
        local position = nil
        if x ~= nil and y ~= nil then
            position = ffi.new("float[2]")
            position[0] = x
            position[1] = y
        end
        DeserializeEntityPtr(EntityPtr, CSerialLoader, position)
        if data[0].buffer.size >= 16 then
            ffi.C.free(data[0].buffer.data.buffer)
        end
        return entity_id
    end
end
return extend
