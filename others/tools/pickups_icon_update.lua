--万恶的gbk编码
local data = "D:/新建文件夹/解包/备份/原版"
package.path = package.path .. ";../../files/scripts/lists/?.lua"

Cpp = require("ConjurerExtensions")
local xml = require("xml")
require("pickups")

for _,p in ipairs(PICKUPS) do
    local pxml = xml.ParseXmlAndBase(data, p.path)
    for _,c in ipairs(pxml.children)do
        if c.name == "ItemComponent" then
            if c.attr.ui_sprite ~= nil and c.attr.ui_sprite ~= "" and c.attr.ui_sprite ~= "data/ui_gfx/items/goldnugget.png" then
                local img = Cpp.ImageCreate(data .. c.attr.ui_sprite)
                if img:GetWidth() == 16 and img:GetHeight() == 16 then
                    p.image = c.attr.ui_sprite
                else
                    print(c.attr.ui_sprite)
                end
            end
            break
        end
    end
end

function serialize_table(tbl, indent)
    local result = ""
    local is_array = #tbl > 0
    for k, v in pairs(tbl) do
        local key
        if is_array and type(k) == "number" then
            key = ""
        else
            key = k .. " = "
        end

        if type(v) == "table" then
            result = result .. string.format("%s%s{\n", indent, key)
            result = result .. serialize_table(v, indent .. "    ")
            result = result .. string.format("%s},\n", indent)
        else
            result = result .. string.format("%s%s%q,\n", indent, key, v)
        end
    end
    return result
end

--table.print(StatusIDTable)

local r_file = io.open("respawn_result.lua", "w")--写入文件
r_file:write("PICKUPS = {\n"..serialize_table(PICKUPS,"").."}")
r_file:close()
