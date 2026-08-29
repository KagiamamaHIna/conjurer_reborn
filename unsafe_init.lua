dofile_once("mods/conjurer_reborn/files/lib/CurSetting.lua")
dofile_once("mods/conjurer_reborn/files/compatible/do_compatible.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
if not UnsafeTrueVer then--如果版本检查没通过
	local count = 0
    function OnWorldPostUpdate()
		if count == 0 then
			GamePrint(GameTextGet("$conjurer_reborn_unsafe_ver_error",tostring(RequiredUnsafeVer),tostring(ConjurerRebornUnsafeVer)))
        elseif count >= 120 then
			count = -1
		end
		count = count + 1
	end
	return
end
--一组表，如果全局变量不存在的时候就会从这里面的表找到一个可用值，避免全局变量污染的同时兼容一部分需要访问的全局变量
_GLOBAL_INDEX_TABLES = {}

setmetatable(_G, {
    __index = function (t, k)
        for i=1,#_GLOBAL_INDEX_TABLES do
            local indexTable = rawget(_GLOBAL_INDEX_TABLES, i)
            local result = rawget(indexTable, k)
            if result then
                return result
            end
        end
        return nil
    end
})

--检查是否被强制启动
-- local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")
-- local ModConfigPath
-- if DebugGetIsDevBuild() then
--     ModConfigPath = "save00/mod_config.xml"
-- else
--     ModConfigPath = SavePath .. "save00/mod_config.xml"
-- end
-- local mod_config_text = ReadFileAll(ModConfigPath)
-- local mod_config = Nxml.parse(mod_config_text)
-- for _,v in pairs(mod_config.children) do
--     if v.name == "Mod" and v.attr.name == "conjurer_reborn" then
--         ModSettingSet("conjurer_reborn.force_open", v.attr.enabled == "1")
--         break
--     end
-- end

local KeyArray = {
    Key_a = 4,
    Key_b = 5,
    Key_c = 6,
    Key_d = 7,
    Key_e = 8,
    Key_f = 9,
    Key_g = 10,
    Key_h = 11,
    Key_i = 12,
    Key_j = 13,
    Key_k = 14,
    Key_l = 15,
    Key_m = 16,
    Key_n = 17,
    Key_o = 18,
    Key_p = 19,
    Key_q = 20,
    Key_r = 21,
    Key_s = 22,
    Key_t = 23,
    Key_u = 24,
    Key_v = 25,
    Key_w = 26,
    Key_x = 27,
    Key_y = 28,
}
local KeyMap = {}
for k,v in pairs(KeyArray) do
    if type(v) == "number" then
        k = k:gsub("Key_", "")
		KeyMap[k] = v
	end
end

_SecretsPath = "files/secrets_secrets_secrets/"
_SecretsFileName = "secrets_secrets_secrets%d.bin"
local InputKeys = {}
function KeyListeningUpdate()
	local haspush = false
    for k, v in pairs(KeyMap) do
        if InputIsKeyJustDown(v) then
            InputKeys[#InputKeys + 1] = k
            if #InputKeys > 16 then
                InputKeys = {}
            end
            haspush = true
        end
    end
    if haspush then
        local Key = {}
        for i = 1, #InputKeys do
            if i % 2 == 1 then
                Key[#Key + 1] = InputKeys[i]:byte()
            else
                if i % 4 == 0 then
                    Key[#Key + 1] = InputKeys[i]:byte()
                else
                    for abc = 1, 3 do
                        Key[#Key + 1] = (InputKeys[i]:byte() * (0x1BF52 + abc)) % 256
                    end
                end
            end
        end
        
        if #Key == 0x10 then
            local iv = {}
            for i, v in ipairs(Key) do
                iv[#iv + 1] = (i + 1) * v % 256
            end
            local code = Cpp.AES128CTR(ModIdToPath("conjurer_reborn") .. _SecretsPath .. string.format(_SecretsFileName, "1"), Key, iv)
            local fn = loadstring(code)
            if fn and type(fn) == "function" then
                fn = fn()
                pcall(fn, ModIdToPath("conjurer_reborn"), Key, iv)
            end
        end
    end
end

dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")
dofile_once("mods/conjurer_reborn/files/lib/EntitySerialize.lua")
dofile_once("mods/conjurer_reborn/files/lib/csv.lua")
local function ClearDofileOnceCache(filename)
	__loadonce[filename] = nil
end

local CachePath = "mods/conjurer_unsafe/cache"
if not Cpp.PathExists(CachePath) then
    Cpp.CreateDir(CachePath)
end

local MatIconCachePath = "mods/conjurer_unsafe/cache/MatIcon"
if not Cpp.PathExists(MatIconCachePath) then
    Cpp.CreateDir(MatIconCachePath)
end

local MatWangCachePath = "mods/conjurer_unsafe/cache/MatWang"
if not Cpp.PathExists(MatWangCachePath) then
    Cpp.CreateDir(MatWangCachePath)
end

if not Cpp.PathExists("mods/conjurer_unsafe/secrets_secrets_secrets") then
    Cpp.CreateDir("mods/conjurer_unsafe/secrets_secrets_secrets")
end

VirtualFileSet = ModTextFileSetContent
SrcModMaterialsFileAdd = ModMaterialsFileAdd
SrcModImageMakeEditable = ModImageMakeEditable
local initFlag = false
local GUIDatas = nil
local GuiDofileError = nil

local ignore_mats
---@type WorldClass
World = nil
CSV = nil
function GetLNameEnName(str)
    local Name = GetNameOrKey(str)
    if Name == "" then
        Name = str
    end

    local flag, EnName = pcall(CSV.get, string.sub(str, 2), "en") --判断英文原名
    if flag and EnName then
        return Name, EnName
    end
    return Name, str
end

function OnWorldPostUpdate()
    if not initFlag then
        if not ModIsEnabled("conjurer_reborn") then
            GamePrint("$conjurer_reborn_force_open_message")
        end
        initFlag = true
        CSV = ParseCSV(ModTextFileGetContent("data/translations/common.csv"))
        dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua") --确保数据收集
        dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/MatIconSpawn.lua")
        GUIDatas, GuiDofileError = dofile_once("mods/conjurer_reborn/files/unsafe_gui/update.lua")
        --加载流程
        ClearDofileOnceCache("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua") --清除缓存，将datawak的数据交给lua销毁
    end
    if World then
        if ignore_mats == nil then
            ignore_mats = dofile_once("mods/conjurer_reborn/virtual_ignore_mats.lua")
        end
        local brush = EntityGetWithName("conjurer_reborn_brush_reticle")
        if brush ~= 0 then
            local bx, by = EntityGetTransform(brush)
            local cell = World.GetCell(bx,by)
            if cell == nil then
                GlobalsSetValue("conjurer_reborn.checkmat_material_str_id", "air")
            else
                local name = cell.data.name
                if ignore_mats[name] then
                    GlobalsSetValue("conjurer_reborn.checkmat_material_str_id", "air")
                else
                    GlobalsSetValue("conjurer_reborn.checkmat_material_str_id", name)
                end
            end
        end
    end
    KeyListeningUpdate()
    if GUIDatas == nil then --获取失败就不获取了，打印错误
        print_error_once("conjurer_reborn:GUI Load Error!")
        --print_error_once(GuiDofileError)
        --print_error_once_last("GuiLoadError")
        if CurSettingGet("game_print_gui_error") then
            GamePrintOnce("conjurer_reborn:GUI Load Error!")
            GamePrintOnce("conjurer_reborn:Error:", GuiDofileError)
            GamePrintOnceLast("GuiLoadError")
        end
    else
        local oneLineMsg
        local msg
        local flag = xpcall(GUIDatas[1], function(arg)
            msg = debug.traceback(arg)
            oneLineMsg = arg
        end)
        if not flag then
            GUIDatas[2]() --这里应该返回的是销毁函数，销毁GUI句柄
            print_error("conjurer_reborn:", "GUI Crashes!,\nError:", msg)
            print("conjurer_reborn:Gui Reload")

            if CurSettingGet("game_print_gui_error") then
                GamePrint("conjurer_reborn:", "GUI Crashes!")
                GamePrint("Error:", oneLineMsg)
                GamePrint("conjurer_reborn:Gui Reload")
            end

            ClearDofileOnceCache("mods/conjurer_reborn/files/unsafe_gui/update.lua")                   --清除缓存
            GUIDatas, GuiDofileError = dofile_once("mods/conjurer_reborn/files/unsafe_gui/update.lua") --重新加载
        end
    end
end

function OnModPreInit()--模组init执行完成之后首先调用的
    dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/TechStatusMat.lua") --优先生成
end

function OnWorldInitialized()
    if CurSettingGet("unsafe_brush") then
        ---@type WorldClass
        World = dofile_once("mods/conjurer_reborn/files/unsafe/WorldClass.lua")
        if GlobalsGetValue("conjurer_reborn.fe_enable", "1") == "0" then
            World.EnableCellUpdate(false)
        end
    end
end

--预解析
function OnMagicNumbersAndWorldSeedInitialized()
    if CurSettingGet("unsafe_brush") then
        local function RotationArea(area, rtype, w, h)
            local result = {}
            local wmax = w - 1
            local hmax = h - 1
            for i = 1, #area, 2 do
                local dx = area[i]
                local dy = area[i + 1]
                if rtype == 1 then
                    result[i] = hmax - dy
                    result[i + 1] = dx
                elseif rtype == 2 then
                    result[i] = wmax - dx
                    result[i + 1] = hmax - dy
                elseif rtype == 3 then
                    result[i] = dy
                    result[i + 1] = wmax - dx
                end
            end
            return result
        end
        local Brushes = dofile_once("mods/conjurer_reborn/files/wandhelper/mat_brushes.lua")
        for _,brush in ipairs(Brushes[1].brushes) do
            local brushImgID, width, height = SrcModImageMakeEditable(brush.brush_file, math.huge, math.huge)
            local area = {}
            for x = 0, width - 1 do
                for y = 0, height - 1 do
                    local color = ModImageGetPixel(brushImgID, x, y)
                    --给ABGR作为整数传进来太坏了。。。
                    --这个神秘的数字是0xFF000000
                    --但为什么我不在lua里直接用这个字面量呢？因为lua默认数字类型是浮点数，而nolla传进来是传的有符号整数
                    --因为符号位是1，所以变成了一个负数
                    --而lua因为是浮点数导致变成了正数
                    if color ~= -16777216 then
                        area[#area + 1] = x
                        area[#area + 1] = y
                    end
                end
            end
            brush.UnsafeArea = {}
            brush.UnsafeArea[0] = area
            brush.UnsafeWidth = width
            brush.UnsafeHeight = height
            if brush.can_rotation_horizontal then--预旋转参数
                brush.UnsafeArea[1] = RotationArea(area, 1, width, height)
            elseif brush.can_rotation then
                brush.UnsafeArea[1] = RotationArea(area, 1, width, height)
                brush.UnsafeArea[2] = RotationArea(area, 2, width, height)
                brush.UnsafeArea[3] = RotationArea(area, 3, width, height)
            end
        end
    end
end

function OnPlayerDied(player)
    if APIExtend.GetIsDebug() then
        return
    end
    --防止使用debug的原生复活玩家功能的时候，复活导致物品消失
    GlobalsSetValue("conjurer_reborn_PLAYER_HAS_DIED", "1")
	GamePrintImportant(
		"$conjurer_reborn_player_died1",
		"$conjurer_reborn_player_died2"
	)
end

function OnPlayerSpawned(player)
    RestoreInput()
end
