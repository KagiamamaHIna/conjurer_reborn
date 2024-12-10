dofile_once("mods/conjurer_reborn/files/unsafe/DataGenerator/GetAllData.lua")
--dofile_once("mods/conjurer_reborn/files/scripts/lists/animals.lua")
dofile_once("mods/conjurer_reborn/files/scripts/lists/props.lua")
dofile_once("mods/conjurer_reborn/files/scripts/lists/pickups.lua")
--dofile_once("mods/conjurer_reborn/files/scripts/lists/perks.lua")
--dofile_once("mods/conjurer_reborn/files/scripts/lists/spells.lua")
dofile_once("mods/conjurer_reborn/files/scripts/lists/backgrounds.lua")
dofile_once("mods/conjurer_reborn/files/scripts/lists/foregrounds.lua")
dofile_once("mods/conjurer_reborn/files/scripts/lists/custom_entities.lua")

EntityType = {
	Enemy = "Enemy",
	Spell = "Spell",
	Perk = "Perk",
	Other = "Other"
}

local Enemies = GetEnemyList()
local Perks = GetPerkList()
local Spells = GetSpellList()

ALL_ENTITIES = {
	{
		name = "$conjurer_reborn_entwand_creatures_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_animals.png",
		icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_animals_off.png",
		Type = EntityType.Enemy,
		entities = Enemies,
	},
	{
		name = "$conjurer_reborn_entwand_props_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_props.png",
		icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_props_off.png",
		Type = EntityType.Other,
		entities = PROPS,
	},
	{
		name = "$conjurer_reborn_entwand_pickups_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_pickups.png",
        icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_pickups_off.png",
		Type = EntityType.Other,
		entities = PICKUPS,
	},
	{
		name = "$conjurer_reborn_entwand_perks_tab",
		desc = "$conjurer_reborn_entwand_perks_tab_desc",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_perks.png",
		icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_perks_off.png",
		Type = EntityType.Perk,
		entities = Perks,
	},
	{
		name = "$conjurer_reborn_entwand_spells_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_spells.png",
		icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_spells_off.png",
		Type = EntityType.Spell,
		entities = Spells,
		grid_size = 32,
	},
	{
		name = "$conjurer_reborn_entwand_backgrounds_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_backgrounds.png",
        icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_backgrounds_off.png",
		Type = EntityType.Other,
		entities = BACKGROUNDS,
	},
	{
		name = "conjurer_reborn_entwand_foregrounds_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_foregrounds.png",
        icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_foregrounds_off.png",
		Type = EntityType.Other,
		entities = FOREGROUNDS,
		grid_size = 14,
	},
	{
		name = "$conjurer_reborn_entwand_custom_tab",
		icon = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_custom.png",
        icon_off = "mods/conjurer_reborn/files/gfx/entwand_icons/icon_custom_off.png",
		Type = EntityType.Other,
		entities = CUSTOM_ENTITIES,
	},
};
