dofile_once("mods/conjurer_reborn/files/lib/EntityClass.lua")

local update = GetUpdatedEntityID()
local x, y = EntityGetTransform(update)

local hamis = EntityObj(EntityLoad("data/entities/animals/longleg.xml",x,y))
hamis:NewChild("pet_effect").NewComp.GameEffectComponent {
    effect = "CHARM",
    frames = -1,
}
    .NewComp.InheritTransformComponent {}

for _, v in ipairs(hamis.comp_all.DamageModelComponent or {}) do
    v:RemoveSelf()
end
for _, v in ipairs(hamis.comp_all.CameraBoundComponent or {}) do
    v:RemoveSelf()
end
hamis.comp.AnimalAIComponent[1].set_attrs = {
    aggressiveness_min = 0,
    aggressiveness_max = 0,
    mAggression = 0
}

hamis.NewComp.LuaComponent {
    script_source_file = "mods/conjurer_reborn/files/custom_entities/hamis/move.lua",
    execute_every_n_frame = 1
}
.NewComp.StreamingKeepAliveComponent{}
