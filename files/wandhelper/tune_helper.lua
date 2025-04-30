dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")

---拼接成技术性材料id
---@param id string
---@return integer
function GetStatusMat(id)
    return CellFactory_GetType("conjurer_reborn_tech_" .. id)
end

---把饱腹度设置为0
---@param entity NoitaEntity
function SetZeroIngestSize(entity)
    if entity.comp_all.IngestionComponent == nil then
        return
    end
    for _, v in ipairs(entity.comp_all.IngestionComponent) do --摄取相应的减少
        v.attr.ingestion_size = 0
    end
end

---沾湿状态增加
---@param entity NoitaEntity
---@param effect string
function EntityAddStains(entity, effect)
    entity:AddRandomStains(GetStatusMat(effect), 1000)
end

---摄取状态增删
---@param entity NoitaEntity
---@param effect string
---@param amount number
function EntityAddEffect(entity, effect, amount)
    if entity.comp.StatusEffectDataComponent == nil then
        return
    end
    if entity.comp_all.IngestionComponent == nil then
        return
    end

    local statusComp = entity.comp.StatusEffectDataComponent[1]
    local lastAmount = statusComp:GetVecValue("ingestion_effects", "float", StatusTable[effect][1].conjurer_reborn_status_num_id)

    if amount * 0.01 + lastAmount < 0 then --技术性材料我填写的都是0.01倍率。这里是为了兜底，防止效果时长变成负数
        if lastAmount == 0 then            --没时间了还减什么？
            return
        end
        --amount = -lastAmount * 100 + 1--+1是为了能够让游戏触发状态卸载
        entity:RemoveIngestionEffect(effect) --不如直接用这个remove
        return
    end
    local CompIDToField = {}
    for _, v in ipairs(entity.comp_all.IngestionComponent) do
        CompIDToField[v] = v.attr.m_ingestion_cooldown_frames
    end
    amount = -amount--摄入负数材料，让饱腹感负增长，不触发爆炸之类的
    entity:IngestMaterial(GetStatusMat(effect), amount)

    for v, cooldown in pairs(CompIDToField) do --摄取相应的减少
        v.attr.m_ingestion_cooldown_frames = cooldown--重置冷却时间
        v.attr.ingestion_size = math.max(0, v.attr.ingestion_size - amount * 6)
    end
end

---删除实体的所有摄取状态
---@param entity NoitaEntity
function RemoveAllIngest(entity)
    if entity.comp.StatusEffectDataComponent == nil then
        return
    end
    local statusComp = entity.comp.StatusEffectDataComponent[1]
    for i=1,statusComp:GetVecSize("ingestion_effects", "float") do
        local amount = statusComp:GetVecValue("ingestion_effects", "float", i) or 0
        if amount > 0 then
            entity:RemoveIngestionEffect(StatusNumIDToTables[i][1].id)
        end
    end
end

---删除实体的所有摄取状态
---@param entity NoitaEntity
function RemoveAllStain(entity)
    if entity.comp.StatusEffectDataComponent == nil then
        return
    end
    local statusComp = entity.comp.StatusEffectDataComponent[1]
    for i=1,statusComp:GetVecSize("stain_effects", "float") do
        local amount = statusComp:GetVecValue("stain_effects", "float", i) or 0
        if amount > 0 then
            entity:RemoveStainEffect(StatusNumIDToTables[i][1].id)
        end
    end
end
