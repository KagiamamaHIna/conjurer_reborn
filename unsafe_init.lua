dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
if not UnsafeTrueVer then--如果版本检查没通过
	function OnWorldPostUpdate()
		GamePrint(GameTextGet("$conjurer_reborn_unsafe_ver_error",tostring(RequiredUnsafeVer),tostring(ConjurerRebornUnsafeVer)))
	end
	return
end
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
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

function OnPlayerSpawned(player)
    RestoreInput()
end

local initFlag = false
GuiUpdate = nil
function OnWorldPostUpdate()
    if not initFlag then
        initFlag = true
        dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua") --确保数据收集
        dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/MatIconSpawn.lua")
        GuiUpdate = dofile_once("mods/conjurer_reborn/files/unsafe_gui/update.lua")
        --加载流程
        ClearDofileOnceCache("mods/conjurer_reborn/files/unsafe/DataGenerator/GetDataWak.lua") --清除缓存，将datawak的数据交给lua销毁
    end
	GuiUpdate()
end
