local AutoUpdateSetting = {}
if not ModIsEnabled("conjurer_reborn") then--为了顺序无关
    dofile_once("mods/conjurer_reborn/files/lib/SandBox.lua")
    local fn, env = NewSandBoxFile("mods/conjurer_reborn/settings.lua")
    fn()
    local function parseSetting(settings)
        for _, s in pairs(settings) do
            if s.id ~= nil then
                local key = "conjurer_reborn." .. s.id
                local value = ModSettingGetNextValue(key)
                if value ~= nil then
                    ModSettingSet(key, value)
                end
                if s.scope == env.MOD_SETTING_SCOPE_RUNTIME then
                    AutoUpdateSetting[s.id] = true
                end
            elseif s.settings ~= nil then
                parseSetting(s.settings)
            end
        end
    end
    parseSetting(env.mod_settings)
end

function CurSettingGet(key)
    local getkey = "conjurer_reborn." .. key
    local result = ModSettingGet(getkey)
    if AutoUpdateSetting[key] then
        local value = ModSettingGetNextValue(getkey)
        if value ~= nil and value ~= result then
            ModSettingSet(getkey, value)
        end
    end
    return ModSettingGet(getkey)
end
