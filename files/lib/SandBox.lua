local function NewSandBox(fn)
	local loadonce = {}
	local loaded = {}
    local env = {
        __loadonce = loadonce,
        __loaded = loaded,
        ModTextFileSetContent = function()

        end,
		ModLuaFileSetAppends = function ()
			
        end,
		ModLuaFileAppend = function ()
			
		end
    }
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
            do_mod_appends(filename)
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
        do_mod_appends(filename)
        return result
    end
	
    setmetatable(env, { __index = _G })
	
    return setfenv(fn, env), env
end

return NewSandBox
