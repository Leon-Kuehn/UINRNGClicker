-- WeaponConfig.lua
-- Weapon definitions grouped by rarity key.
-- Each entry has a name, its rarity, and a short flavour description.
-- NOTE: The click multiplier is NOT stored here – it is derived from
--       RarityConfig.Rarities[rarity].multiplier at roll-time.

export type WeaponData = {
	name: string,
	rarity: string,
	description: string,
	-- multiplier is intentionally omitted; looked up from RarityConfig at roll-time
}

local WeaponConfig: { [string]: { WeaponData } } = {
	Common = {
		{ name = "Rusty Dagger",   rarity = "Common", description = "A dull blade. Better than nothing." },
		{ name = "Wooden Club",    rarity = "Common", description = "A sturdy branch from an oak tree." },
		{ name = "Pebble Thrower", rarity = "Common", description = "It is just a rock, really." },
	},
	Uncommon = {
		{ name = "Iron Sword",   rarity = "Uncommon", description = "A reliable blade for aspiring warriors." },
		{ name = "Copper Axe",   rarity = "Uncommon", description = "Heavy but effective against most foes." },
		{ name = "Bronze Mace",  rarity = "Uncommon", description = "Crushes with satisfying efficiency." },
	},
	Rare = {
		{ name = "Enchanted Blade", rarity = "Rare", description = "Glows faintly in the dark." },
		{ name = "Shadow Bow",      rarity = "Rare", description = "Arrows fired from this rarely miss." },
		{ name = "Storm Hammer",    rarity = "Rare", description = "Sparks fly with every swing." },
	},
	Epic = {
		{ name = "Void Katana",  rarity = "Epic", description = "Slices through reality itself." },
		{ name = "Dragon Fang",  rarity = "Epic", description = "Crafted from a real dragon's tooth." },
		{ name = "Thunder Edge", rarity = "Epic", description = "A blade charged with raw lightning." },
	},
	Legendary = {
		{ name = "Excalibur",      rarity = "Legendary", description = "The sword of kings. Only the worthy may wield it." },
		{ name = "Inferno Scythe", rarity = "Legendary", description = "Reaps souls and sets them ablaze." },
		{ name = "Celestial Wand", rarity = "Legendary", description = "A wand blessed by the stars above." },
	},
	Mythic = {
		{ name = "Oblivion Blade",  rarity = "Mythic", description = "A weapon that existed before time itself." },
		{ name = "Nexus Destroyer", rarity = "Mythic", description = "Tears apart the fabric of the universe." },
		{ name = "Eternal Scepter", rarity = "Mythic", description = "Channelling infinite power since creation." },
	},
}

return WeaponConfig
