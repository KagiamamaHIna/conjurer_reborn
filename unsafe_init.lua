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
--检查是否被强制启动
local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")
local ModConfigPath
if DebugGetIsDevBuild() then
    ModConfigPath = "save00/mod_config.xml"
else
    ModConfigPath = SavePath .. "save00/mod_config.xml"
end
local mod_config_text = ReadFileAll(ModConfigPath)
local mod_config = Nxml.parse(mod_config_text)
for _,v in pairs(mod_config.children) do
    if v.name == "Mod" and v.attr.name == "conjurer_reborn" then
        ModSettingSet("conjurer_reborn.force_open", v.attr.enabled == "1")
        break
    end
end

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
dofile_once("mods/conjurer_unsafe/csv.lua")
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

function OnPlayerSpawned(player)
    RestoreInput()
end

VisualFileSet = ModTextFileSetContent
SrcModMaterialsFileAdd = ModMaterialsFileAdd
SrcModImageMakeEditable = ModImageMakeEditable
local initFlag = false
local GUIDatas = nil
local GuiDofileError = nil
function OnWorldPostUpdate()
    if not initFlag then
        if ModSettingGet("conjurer_reborn.force_open") then
            GamePrint("$conjurer_reborn_force_open_message")
        end
        initFlag = true
        dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua") --确保数据收集
        dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/MatIconSpawn.lua")
        GUIDatas, GuiDofileError = dofile_once("mods/conjurer_reborn/files/unsafe_gui/update.lua")
        --加载流程
        ClearDofileOnceCache("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua") --清除缓存，将datawak的数据交给lua销毁
    end
    KeyListeningUpdate()
    if GUIDatas == nil then--获取失败就不获取了，打印错误
        print_error("conjurer_reborn:GUI Load Error!")
        if ModSettingGet("conjurer_reborn.game_print_gui_error") then
            GamePrint("conjurer_reborn:GUI Load Error!")
            GamePrint("conjurer_reborn:Error:", GuiDofileError)
        end
    else
        local flag, msg = pcall(GUIDatas[1])
        if not flag then
            GUIDatas[2]()--这里应该返回的是销毁函数，销毁GUI句柄
            print_error("conjurer_reborn:", "GUI Crashes!,\nError:", msg)
            print("conjurer_reborn:Gui Reload")

            if ModSettingGet("conjurer_reborn.game_print_gui_error") then
                GamePrint("conjurer_reborn:", "GUI Crashes!")
                GamePrint("Error:", msg)
                GamePrint("conjurer_reborn:Gui Reload")
            end
        
            ClearDofileOnceCache("mods/conjurer_reborn/files/unsafe_gui/update.lua")--清除缓存
            GUIDatas, GuiDofileError = dofile_once("mods/conjurer_reborn/files/unsafe_gui/update.lua")--重新加载
        end
    end
end

function OnModPreInit()--模组init执行完成之后首先调用的
    dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/TechStatusMat.lua") --优先生成
end
