dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
local datawak,_errorText,_errorPos = Cpp.DataWak("data/data.wak")
if datawak == nil then
    print_error("Conjurer-Reborn-Unsafe: Fatal Error in GetDataWak.lua! data wak load failure")
    print_error(_errorText, " in pos:", _errorPos)
    return
end

return datawak
