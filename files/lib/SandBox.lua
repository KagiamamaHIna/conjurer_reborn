---输入函数，返回沙盒环境下的函数和环境
---@param fn function
---@return function
---@return table env
function NewSandBoxFn(fn)
    local loadonce = {}
    local loaded = {}
    local env = {
        __loadonce = loadonce,
        __loaded = loaded,
        ModTextFileSetContent = function()

        end,
        ModLuaFileSetAppends = function()

        end,
        ModLuaFileAppend = function()

        end
    }
    env.do_mod_appends = function(filename)
        for _,v in ipairs(ModLuaFileGetAppends(filename) or {}) do
            env.dofile(v)
        end
    end

    env.dofile_once = function(filename)
        local result = nil
        local cached = loadonce[filename]
        if cached ~= nil then
            result = cached[1]
        else
            local f, err = loadfile(filename)
            if f == nil then return f, err end
            result = setfenv(f, env)()
            loadonce[filename] = { result }
            env.do_mod_appends(filename)
        end
        return result
    end

    env.dofile = function(filename)
        local f = loaded[filename]
        if f == nil then
            f, err = loadfile(filename)
            if f == nil then return f, err end
            loaded[filename] = setfenv(f, env)
        end
        local result = f()
        env.do_mod_appends(filename)
        return result
    end

    setmetatable(env, { __index = _G })

    return setfenv(fn, env), env
end

---输入路径，返回沙盒环境下的函数和环境
---@param path string
---@return function?
---@return table env
function NewSandBoxFile(path)
    local fn = loadfile(path)
    if fn == nil then
        return nil,{}
    end
    local resultFn = function(...)
        local result = setfenv(fn, getfenv())(...)
        do_mod_appends(path)
        return result
    end
    return NewSandBoxFn(resultFn)
end

return NewSandBoxFn
