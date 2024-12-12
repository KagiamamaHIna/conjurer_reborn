dofile_once("mods/conjurer_reborn/files/wandhelper/ent_list_pre.lua")

for _, t in pairs(ALL_ENTITIES) do
	t.conjurer_reborn_index_table = {}
	for k,v in pairs(t.entities)do
		t.conjurer_reborn_index_table[v] = k
	end
end
