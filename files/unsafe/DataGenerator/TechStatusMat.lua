dofile_once("data/scripts/status_effects/status_list.lua")
local Nxml = dofile_once("mods/conjurer_reborn/files/lib/nxml.lua")
local TechMat = Nxml.new_element("Materials")

StatusIconTable = {}
local IgnoreTechTable = {}
local HasStatus = {}
for i, v in ipairs(status_effects) do
    if v.effect_entity == nil then
        goto continue
    end
    if HasStatus[v.id] then
        goto continue
    end
    if v.ui_icon and ModDoesFileExist(v.ui_icon) then
        local ImageId, w, h = SrcModImageMakeEditable(v.ui_icon, math.huge, math.huge)
        if w ~= 16 and h ~= 16 then
            local path = "mods/conjurer_reborn/visual_status_icon_" .. v.id:lower() .. ".png"
            StatusIconTable[v.id] = path
            local VisualImageId = SrcModImageMakeEditable(path, 16, 16)
            local posw = math.floor(8 - w / 2)
            local posh = math.floor(8 - h / 2)
            for x=0,w-1 do
                for y = 0, h - 1 do
                    local newX = x + posw
                    local newY = y + posh
                    if not (newX >= 16 or newY >= 16 or newX < 0 or newY < 0) then
                        ModImageSetPixel(VisualImageId, newX, newY, ModImageGetPixel(ImageId, x, y))
                    end
                end
            end
        else
            StatusIconTable[v.id] = v.ui_icon
        end
    else
        StatusIconTable[v.id] = "mods/conjurer_reborn/files/gfx/unknown_status.png"
    end

    HasStatus[v.id] = true
    local matXml = Nxml.new_element("CellData")
    matXml.attr.name = "conjurer_reborn_tech_" .. v.id
    IgnoreTechTable[matXml.attr.name] = true

    matXml.attr.ui_name = v.ui_name
    matXml.attr.wang_color = tostring(-i)
    matXml.attr.cell_type = "liquid"
    matXml.attr.lifetime = "1"
    matXml.attr.liquid_stains = "1"
    matXml.attr.status_effects = v.id--沾湿
    matXml.attr.conjurer_reborn_tech_mat = "1" --特殊标记
    
    --摄取
    local StatusEffects = Nxml.new_element("StatusEffects")
    local Ingestion = Nxml.new_element("Ingestion")
    Ingestion:add_child(Nxml.new_element("StatusEffect", {
        type = v.id,
        amount = "-0.01"
    }))
    StatusEffects:add_child(Ingestion)
    matXml:add_child(StatusEffects)

    local Graphics = Nxml.new_element("Graphics")--材料颜色
    Graphics.attr.color = "FFE6A3C6"
    matXml:add_child(Graphics)

    TechMat:add_child(matXml)
    ::continue::
end
VisualFileSet("mods/conjurer_reborn/visual_materials.xml", tostring(TechMat))
VisualFileSet("mods/conjurer_reborn/visual_ingore_mats.lua", "return {"..SerializeTable(IgnoreTechTable).."}")
SrcModMaterialsFileAdd("mods/conjurer_reborn/visual_materials.xml")
