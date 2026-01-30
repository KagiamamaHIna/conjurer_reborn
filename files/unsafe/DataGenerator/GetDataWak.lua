dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
local datawak, _errorText, _errorPos
if not Cpp.PathExists("data/data.wak") then --本地路径模式
    datawak = {--模拟一个data wak对象出来
        At = function(self, path)
            if not Cpp.PathExists(path) then
                return nil
            end
            return ReadFileAll(path)
        end,
        GetFileList = function (self)--data wak是不存在空路径这个概念的，所以只返回文件列表即可
            return Cpp.GetDirectoryPathAll("data/").File
        end,
        HasFile = function(self, path)
            return Cpp.PathExists(path)
        end,
        GetImgToScale = function(self, key, ToFile, Width, Height)
            return Cpp.PngScaleToFile(key, ToFile, Width, Height)
        end,
        GetImgFlatAndCropping = function (self, key, ToFile, Width, Height)
            return Cpp.PngFlatAndCroppingToFile(key, ToFile, Width, Height)
        end
    }
else
    datawak, _errorText, _errorPos = Cpp.DataWak("data/data.wak")
    if datawak == nil then
        print_error("Conjurer-Reborn-Unsafe: Fatal Error in GetDataWak.lua! data wak load failure")
        print_error(_errorText, " in pos:", _errorPos)
        return
    end
end

return datawak
