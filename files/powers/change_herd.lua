--轻量化本文件，顺带兼容可能的模组更改
local function icon(name)
	return "data/ui_gfx/animal_icons/" .. name .. ".png"
end

HERD_ROWS = 5

-- A list of herds, as defined in `data/genome_relations.csv`
HERDS = {
	{ display = "Player",       name = "player",     image = "mods/conjurer_reborn/files/gfx/power_icons/herd_player.png" },
	{ display = "Slimes",       name = "slimes",     image = icon("slimeshooter") },
	{ display = "Ant",          name = "ant",        image = icon("ant") },
	{ display = "Robot",        name = "robot",      image = icon("roboguard") },
	{ display = "Fly",          name = "fly",        image = icon("fly") },
	{ display = "Boss dragon",  name = "boss_dragon", image = icon("boss_dragon") },
	-- Apparently not used by any entity, so no point including it it.
	--{ name="crawler", image="mods/conjurer_reborn/files/gfx/power_icons/herd_player.png" },
	{ display = "Helpless",     name = "helpless",   image = icon("sheep") },
	{ display = "Eel",          name = "eel",        image = icon("eel") },
	{ display = "Fireskull",    name = "fire",       image = icon("fireskull") },
	{ display = "Fungus",       name = "fungus",     image = icon("fungus") },
	{ display = "Ghoul",        name = "ghoul",      image = icon("ghoul") },
	{ display = "Giant",        name = "giant",      image = icon("giant") },
	{ display = "Iceskull",     name = "ice",        image = icon("iceskull") },
	{ display = "Spider & Lukki", name = "spider",   image = icon("longleg") },
	{ display = "Hiisi",        name = "orcs",       image = icon("shotgunner_weak") },
	{ display = "Rat",          name = "rat",        image = icon("rat") },
	-- Apparently not used by any entity, so no point including it it.
	--{ name="electricity", image=icon("") },
	{ display = "Wolf",         name = "wolf",       image = icon("wolf") },
	{ display = "Worm",         name = "worm",       image = icon("worm_tiny") },
	{ display = "Zombie",       name = "zombie",     image = icon("zombie") },
	{ display = "Nest",         name = "nest",       image = "mods/conjurer_reborn/files/gfx/animal_icons/nest_yellow.png" },
	{ display = "Wizard",       name = "mage",       image = icon("wizard_neutral") },
	{ display = "Flower",       name = "flower",     image = icon("bloom") },
	{ display = "Wand ghost",   name = "ghost",      image = icon("wand_ghost") },
	{ display = "Boss limbs",   name = "boss_limbs", image = icon("boss_limbs") },
	{ display = "Healer",       name = "healer",     image = icon("scavenger_heal") },
	{ display = "Player ghost", name = "apparition", image = icon("playerghost") },
	{ display = "Bat",          name = "bat",        image = icon("bat") },
    { display = "Wizard swapper", name = "mage_swapper", image = icon("wizard_swapper") },
    { display = "Ghost boss",     name = "ghost_boss",   image = icon("boss_ghost_polyp") },
	{ display = "Target", name = "target", image = "mods/conjurer_reborn/files/gfx/target_herd_icon.png" },
	-- Used by a single entity we haven't included yet.
	--{ name="curse", image=icon("") },
	--
	-- Used by *some* traps, and we're not including those yet either.
	--{ name="trap", image=icon("") },
}
local unknown_herd_png = "mods/conjurer_reborn/files/gfx/animal_icons/unknown.png"

function change_player_herd(herd_name)
    local player = EntityGetWithTag("player_unit")[1]
    if player == nil then
        return
    end
	ComponentSetValue2(EntityGetFirstComponentIncludingDisabled(player, "GenomeDataComponent"), "herd_id", StringToHerdId(herd_name))
	GamePrint(GameTextGet("$conjurer_reborn_power_change_herd_tip",herd_name))
end

function get_active_herd(herd_id)
	local name = HerdIdToString(herd_id)
	for i, herd in ipairs(HERDS) do
		if herd.name == name then
			return herd
		end
	end
end

---获取玩家阵营字符串数字id
---@return number|nil
function GetPlayerHerd()
    local player = EntityGetWithTag("player_unit")[1]
    if player == nil then
        return
    end
	local comp = EntityGetFirstComponentIncludingDisabled(player, "GenomeDataComponent")
    if comp == nil then
        return
    end
	return ComponentGetValue2(comp, "herd_id")
end

local LastHerd
local LastImg

---返回玩家阵营图标
---@return string
function GetPlayerHerdImg()
    local herdnum = GetPlayerHerd()
	if herdnum == nil then
		return unknown_herd_png
	end
	if herdnum == LastHerd then
		return LastImg
	end
	local herd = HerdIdToString(herdnum)
    for _, v in ipairs(HERDS) do
        if v.name == herd then
            LastHerd = herdnum
            LastImg = v.image
			IsNoHasHerd = false
            return LastImg
        end
    end
	LastHerd = herd
    LastImg = unknown_herd_png
	return LastImg
end
