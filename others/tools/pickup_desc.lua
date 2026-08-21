local data = "D:/�½��ļ���/���/����/ԭ��"
package.path = package.path .. ";../../files/scripts/lists/?.lua"

Cpp = require("ConjurerExtensions")
local xml = require("xml")
require("pickups")

local result = {}
for index, p in ipairs(PICKUPS) do
    if p.desc ~= nil then
        goto continue
    end
    local pxml = xml.ParseXmlAndBase(data, p.path)
    for _, c in ipairs(pxml.children) do
        if c.name == "ItemComponent" then
            if c.attr.ui_description ~= nil and c.attr.ui_description ~= "" then
                result[index] = c.attr.ui_description
            end
            break
        end
    end
    ::continue::
end
--WIP
