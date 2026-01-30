dofile_once("mods/conjurer_reborn/files/lib/define.lua")
dofile_once("mods/conjurer_reborn/unsafeFn.lua")

SavePath = "%userprofile%/AppData/LocalLow/Nolla_Games_Noita/"

if DebugMode then
	package.cpath = package.cpath..";./mods/conjurer_unsafe/files/module/debug/?.dll"
else
	package.cpath = package.cpath..";./mods/conjurer_unsafe/files/module/?.dll"
end

Cpp = require("ConjurerExtensions") --加载模块

SavePath = Cpp.GetAbsPath(SavePath)

---@module 'PinInLua'
-- PinInLua = dofile("mods/conjurer_reborn/files/unsafe/PinInLua.lua")
