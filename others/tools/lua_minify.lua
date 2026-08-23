-- by AI
-- lua_minify.lua
-- 功能：将 Lua 源码压缩成单行（去掉注释、多余空格和换行）
-- 用法：lua lua_minify.lua input.lua output.lua

local function read_file(path)
    local file, err = io.open(path, "r")
    if not file then
        error("无法打开文件: " .. err)
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function write_file(path, content)
    local file, err = io.open(path, "w")
    if not file then
        error("无法写入文件: " .. err)
    end
    file:write(content)
    file:close()
end

local function minify_lua(code)
    -- 去掉多行注释 --[[ ... ]]
    code = code:gsub("%-%-%[%[.-%]%]", "")
    -- 去掉单行注释 -- ...
    code = code:gsub("%-%-[^\n]*", "")
    -- 去掉多余的换行和空格
    code = code:gsub("[\r\n]+", " ")
    code = code:gsub("%s+", " ")
    -- 去掉行首行尾空格
    code = code:gsub("^%s+", ""):gsub("%s+$", "")
    return code
end

-- 主程序
local input_file = arg[1]
local output_file = arg[2]

if not input_file or not output_file then
    print("用法: lua lua_minify.lua <输入文件> <输出文件>")
    os.exit(1)
end

local ok, result = pcall(function()
    local code = read_file(input_file)
    local minified = minify_lua(code)
    write_file(output_file, minified)
end)

if not ok then
    print("压行失败: " .. result)
else
    print("压行完成，结果已保存到 " .. output_file)
end
