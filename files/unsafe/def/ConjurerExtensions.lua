---@diagnostic disable: missing-return
---返回软件本身的绝对路径
---@return string
function Cpp.CurrentPath()end

---返回某一绝对路径下的所有文件夹和文件
---@param path string
---@return table
function Cpp.GetDirectoryPath(path)end

---返回某一绝对路径下的所有文件夹和文件以及其子文件夹和子文件
---@param path string
---@return table
function Cpp.GetDirectoryPathAll(path)end

---返回路径下的文件名
---@param path string
---@return string|nil
function Cpp.PathGetFileName(path)end

---返回路径下的文件名的后缀名，不包括 '.'
---@param path string
---@return string|nil
function Cpp.PathGetFileType(path)end

---返回绝对路径下是否存在文件或文件夹
---@param path string
---@return boolean
function Cpp.PathExists(path)end

---创建一个路径，返回的是 是否创建成功
---@param path string
---@return boolean
function Cpp.CreateDir(path)end

---递归的创建一个路径，返回的是 是否创建成功。这个可以创建嵌套路径
---@param path string
---@return boolean
function Cpp.CreateDirs(path)end

---可以通过解析系统变量，返回一个绝对路径
---@param path string
---@return string
function Cpp.GetAbsPath(path)end

---计算两个字符串的相似程度。区间[0,100]
---@param s1 string
---@param s2 string
---@return number
function Cpp.Ratio(s1,s2)end

---计算一个字符串和另一个字符串的部分相似程度，比如"ab"和"abc"返回100。区间[0,100]
---@param s1 string
---@param s2 string
---@return number
function Cpp.PartialRatio(s1,s2)end

---用于计算拼音或原始字符串的匹配相似度。区间[0,100]，s1为输入的带中文的字符串，s2为输入的拼音字符串，s2不会进行转拼音匹配
---@param s1 string
---@param s2 string
---@return number
function Cpp.PinyinRatio(s1,s2)end

---用于计算拼音或原始字符串的匹配相似度。区间[0,100]，s1为输入的带中文的字符串，s2为输入的拼音字符串，s2不会进行转拼音匹配，如果s2为s1(或拼音)的子串，则返回值才会>0，否则是0，因此它返回值大于0都是绝对包含的
---@param s1 string
---@param s2 string
---@return number
function Cpp.AbsPartialPinyinRatio(s1,s2)end

---返回utf8编码格式的字符串的长度
---@param s1 string
---@return integer
function Cpp.UTF8StringSize(s1)end

---类似string.sub，区别是根据utf8编码进行分割操作
---@param str string
---@param pos1 integer
---@param pos2 integer
---@return string
function Cpp.UTF8StringSub(str,pos1,pos2)end

--返回一个按utf8字符分割的字符串数组，比如"ABC"，返回{"A", "B", "C"}
---@param str string
---@return table
function Cpp.UTF8StringChars(str)end

---设置剪切板的新内容，返回的为 是否设置成功
---@param str string
---@return boolean
function Cpp.SetClipboard(str)end

---获得剪切板的内容，如果不存在之类的为一个""
---@return string
function Cpp.GetClipboard()end

---同windows api SetDllDirectoryA
---@param str string
---@return boolean
function Cpp.SetDllDirectory(str) end

---std::rename的封装，返回0是成功，理论上还可用于移动文件
---@param old_filename string
---@param new_filename string
---@return integer
function Cpp.Rename(old_filename, new_filename)end

---std::filesystem::remove的封装
---@param path string
---@return boolean
function Cpp.Remove(path)end

---std::filesystem::remove_all的封装
---@param path string
---@return number
function Cpp.RemoveAll(path)end

---拼接字符串
---@param ... string
---@return string
function Cpp.ConcatStr(...)end

---读取图片垂直翻转和水平翻转后再写入到指定路径
---@param FileStr string
---@param WritePath string
function Cpp.FlipImageLoadAndWrite(FileStr,WritePath)end

---同windows api int system(const char* command)
---@param command string
---@return integer
function Cpp.System(command)end

---解压文件到指定路径，返回的是：是否解压成功
---@param zip string
---@param outputPath string
---@return boolean
function Cpp.Uncompress(zip, outputPath)end

---@class BoolPTR lightuserdata

---@class IntPTR lightuserdata

---new一个bool指针，以lightuserdata的形式返回出来，如果不填写参数就不会初始化
---@param value boolean?
---@return BoolPTR
function Cpp.NewBoolPtr(value)end

---获取bool指针所指向的值
---@param ptr BoolPTR
---@return boolean
function Cpp.GetBoolPtrV(ptr)end

---设置bool指针所指向的值
---@param ptr BoolPTR
---@param value boolean
function Cpp.SetBoolPtrV(ptr,value)end

---new一个int指针，以lightuserdata的形式返回出来，如果不填写参数就不会初始化
---@param value integer?
---@return IntPTR
function Cpp.NewIntPtr(value)end

---获取int指针所指向的值
---@param ptr IntPTR
---@return integer
function Cpp.GetIntPtrV(ptr)end

---设置int指针所指向的值
---@param ptr IntPTR
---@param value integer
function Cpp.SetIntPtrV(ptr,value)end

---释放内存
---@param ptr IntPTR|BoolPTR
function Cpp.Free(ptr)end

---把ANSI编码转成utf8
---@param str string
---@return string
function Cpp.ANSIToUTF8(str)end

---解包data并返回gun_actions.lua的内容
---@return string
function Cpp.GetOriginalGunActionsLua()end

---从HKEY_LOCAL_MACHINE前缀的注册表的 key + valueKey 的内容中获取数据，如果获取失败或值为空则返回nil
---@param key string
---@param valueKey string
---@return string|nil
function Cpp.RegLMGetValue(key, valueKey)end

---@class DataWak userdata
local DataWak = {}

---获取指定路径下的数据，用字符串返回，不存在的话返回nil
---@param path string
---@return string|nil
function DataWak:At(path)end

---获取所有文件列表
---@return table<string>
function DataWak:GetFileList()end

---判断文件是否存在
---@param path string
---@return boolean
function DataWak:HasFile(path)end

---从datawak中读取一个数据并尝试构造成png，然后根据给定参数缩放完成后写入给定的路径
---@param key string
---@param ToFile string
---@param Width integer
---@param Height integer
---@return boolean
function DataWak:GetImgToScale(key, ToFile, Width, Height)end

---从datawak中读取一个数据并尝试构造成png，然后根据给定参数平铺切割完成后写入给定的路径
---@param key string
---@param ToFile string
---@param Width integer
---@param Height integer
---@return boolean
function DataWak:GetImgFlatAndCropping(key, ToFile, Width, Height)end

---从文件路径构造一个DataWak对象并返回，是userdata,如果构造失败第一个参数返回nil，后面两个为错误信息
---@param path string
---@return DataWak|nil, string|nil, integer|nil
function Cpp.DataWak(path)end

---从真实路径中读取一个数据并尝试构造成png，然后根据给定参数缩放完成后写入给定的路径
---@param PngPath string
---@param ToFile string
---@param Width integer
---@param Height integer
---@return boolean
function Cpp.PngScaleToFile(PngPath, ToFile, Width, Height)end

---从真实路径中读取一个数据并尝试构造成png，然后根据给定参数平铺切割完成后写入给定的路径
---@param PngPath string
---@param ToFile string
---@param Width integer
---@param Height integer
---@return boolean
function Cpp.PngFlatAndCroppingToFile(PngPath, ToFile, Width, Height)end

---给定写入到的文件，高宽和rgba，创建一个纯色图片
---@param ToFile string
---@param Width integer
---@param Height integer
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return boolean
function Cpp.RGBAPng(ToFile, Width, Height, r, g, b, a)end

---来自底层的神秘优化()
---@param size integer
---@param len integer
---@param str string
---@return string
function Cpp.SameElemListStr(size, len, str)end

---@class Image userdata
local Image = {}

---返回图片通道数
---@return integer
function Image:GetChannels()end

---返回图片宽度
---@return integer
function Image:GetWidth()end

---返回图片高度
---@return integer
function Image:GetHeight()end

---从给定坐标上获取图片像素，返回r, g, b ,a如果是其他通道，则少返回后面的数值
---@return integer r,integer|nil g,integer|nil b,integer|nil a
function Image:GetPixel(x, y)end

---从给定坐标上获取图片像素，返回十六进制字符串
---@return string
function Image:GetPixelHex(x, y)end

---根据通道数动态请求rgba的数量，设置指定位置上的像素
---@param x integer
---@param y integer
---@param color integer
---@param ... integer?
function Image:SetPixel(x, y, color, ...)end

---给定路径，写入文件
---@param path string
function Image:WritePng(path)end

---从给定的真实路径里面构造一个图片
---@param path string
---@return Image
function Cpp.ImageCreate(path)end

---创建一个透明图片
---@param Width integer
---@param Height integer
---@param channels integer
---@return Image
function Cpp.NullImageCreate(Width, Height, channels)end

---给定路径读取文件用AES128CTR解密/加密文件
---@param str string
---@param key table<integer, 16>
---@param iv table<integer, 16>
---@return string
function Cpp.AES128CTR(str, key, iv)end

---给定一个字符串，找到里面的芬兰语字母并将其转换为英文字母
---@param str any
---@return string
function Cpp.FinnishToEnLower(str)end

--[[
---返回Steam api是否成功初始化
---@return boolean
function Cpp.GetSteamAPIInit()end

---输入字符串组成的数字id，返回模组路径
---@param strid string
---@return string path
function Cpp.GetModPath(strid)end
]]
