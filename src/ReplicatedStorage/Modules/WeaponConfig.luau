--!strict
-- Weapon definitions grouped by rarity name.
-- clickMultiplier : stacks on top of the rarity's base multiplier
-- description     : shown in RollUI after a successful roll

local WeaponConfig = {}

WeaponConfig.Weapons = {
	Common = {
		{ name = "Wooden Sword",  clickMultiplier = 1.0, description = "A basic training sword." },
		{ name = "Stone Dagger",  clickMultiplier = 1.1, description = "Sharp enough to scratch." },
		{ name = "Iron Spear",    clickMultiplier = 1.2, description = "Standard-issue infantry spear." },
	},
	Uncommon = {
		{ name = "Silver Blade",  clickMultiplier = 1.0, description = "Gleams in the light." },
		{ name = "Hunting Bow",   clickMultiplier = 1.1, description = "Quick and silent." },
		{ name = "Steel Mace",    clickMultiplier = 1.2, description = "Heavy and brutal." },
	},
	Rare = {
		{ name = "Enchanted Staff",  clickMultiplier = 1.0, description = "Hums with arcane energy." },
		{ name = "Shadow Katana",    clickMultiplier = 1.1, description = "Cuts through darkness itself." },
		{ name = "Runic Axe",        clickMultiplier = 1.2, description = "Ancient runes carved deep." },
	},
	Epic = {
		{ name = "Void Scythe",     clickMultiplier = 1.0, description = "Harvests power from the void." },
		{ name = "Thunder Lance",   clickMultiplier = 1.1, description = "Crackles with raw lightning." },
		{ name = "Cursed Grimoire", clickMultiplier = 1.2, description = "Forbidden knowledge made solid." },
	},
	Legendary = {
		{ name = "Dragon Slayer",    clickMultiplier = 1.0, description = "Forged in dragonfire." },
		{ name = "Astral Bow",       clickMultiplier = 1.1, description = "Fires arrows of pure starlight." },
		{ name = "Soul Eater Blade", clickMultiplier = 1.2, description = "Devours the essence of the fallen." },
	},
	Mythic = {
		{ name = "Celestial Hammer", clickMultiplier = 1.0, description = "Said to have fallen from the heavens." },
		{ name = "Abyss Trident",    clickMultiplier = 1.1, description = "Ruler of the deep." },
	},
	Divine = {
		{ name = "Godbreaker", clickMultiplier = 1.0, description = "No mortal was meant to wield this." },
	},
}

return WeaponConfig
