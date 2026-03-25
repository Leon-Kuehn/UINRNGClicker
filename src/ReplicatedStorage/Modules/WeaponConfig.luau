--!strict
-- Weapon definitions grouped by rarity name.
-- clickMultiplier : stacks on top of the rarity's base multiplier
-- description     : shown in RollUI after a successful roll

local WeaponConfig = {}

WeaponConfig.Weapons = {
	Common = {
		{ name = "Wooden Sword",  clickMultiplier = 1.00, description = "A basic training sword." },
		{ name = "Stone Dagger",  clickMultiplier = 1.08, description = "Sharp enough to scratch." },
		{ name = "Iron Spear",    clickMultiplier = 1.16, description = "Standard-issue infantry spear." },
	},
	Uncommon = {
		{ name = "Silver Blade",  clickMultiplier = 1.03, description = "Gleams in the light." },
		{ name = "Hunting Bow",   clickMultiplier = 1.12, description = "Quick and silent." },
		{ name = "Steel Mace",    clickMultiplier = 1.20, description = "Heavy and brutal." },
	},
	Rare = {
		{ name = "Enchanted Staff",  clickMultiplier = 1.06, description = "Hums with arcane energy." },
		{ name = "Shadow Katana",    clickMultiplier = 1.16, description = "Cuts through darkness itself." },
		{ name = "Runic Axe",        clickMultiplier = 1.28, description = "Ancient runes carved deep." },
	},
	Epic = {
		{ name = "Void Scythe",     clickMultiplier = 1.10, description = "Harvests power from the void." },
		{ name = "Thunder Lance",   clickMultiplier = 1.24, description = "Crackles with raw lightning." },
		{ name = "Cursed Grimoire", clickMultiplier = 1.40, description = "Forbidden knowledge made solid." },
	},
	Legendary = {
		{ name = "Dragon Slayer",    clickMultiplier = 1.18, description = "Forged in dragonfire." },
		{ name = "Astral Bow",       clickMultiplier = 1.35, description = "Fires arrows of pure starlight." },
		{ name = "Soul Eater Blade", clickMultiplier = 1.55, description = "Devours the essence of the fallen." },
	},
	Mythic = {
		{ name = "Celestial Hammer", clickMultiplier = 1.30, description = "Said to have fallen from the heavens." },
		{ name = "Abyss Trident",    clickMultiplier = 1.60, description = "Ruler of the deep." },
	},
	Divine = {
		{ name = "Godbreaker", clickMultiplier = 2.00, description = "No mortal was meant to wield this." },
	},
}

return WeaponConfig
