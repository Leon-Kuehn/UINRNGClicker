-- RarityConfig.lua
-- Defines all weapon rarities: display name, UI colors, click multiplier, and RNG weight.
-- Higher weight = more likely to be rolled.  All weights are relative to one another.

export type RarityData = {
	name: string,
	color: Color3,       -- background / badge color
	textColor: Color3,   -- label text color
	multiplier: number,  -- Coins-per-click multiplier granted by weapons of this rarity
	weight: number,      -- relative RNG weight (higher = more common)
}

local RarityConfig = {

	Rarities = {
		Common = {
			name = "Common",
			color = Color3.fromRGB(180, 180, 180),
			textColor = Color3.fromRGB(200, 200, 200),
			multiplier = 1.0,
			weight = 500,
		},
		Uncommon = {
			name = "Uncommon",
			color = Color3.fromRGB(96, 200, 96),
			textColor = Color3.fromRGB(96, 230, 96),
			multiplier = 1.5,
			weight = 250,
		},
		Rare = {
			name = "Rare",
			color = Color3.fromRGB(66, 135, 245),
			textColor = Color3.fromRGB(100, 160, 255),
			multiplier = 3.0,
			weight = 100,
		},
		Epic = {
			name = "Epic",
			color = Color3.fromRGB(180, 80, 230),
			textColor = Color3.fromRGB(210, 120, 255),
			multiplier = 6.0,
			weight = 40,
		},
		Legendary = {
			name = "Legendary",
			color = Color3.fromRGB(255, 180, 0),
			textColor = Color3.fromRGB(255, 210, 30),
			multiplier = 12.0,
			weight = 8,
		},
		Mythic = {
			name = "Mythic",
			color = Color3.fromRGB(255, 60, 60),
			textColor = Color3.fromRGB(255, 100, 80),
			multiplier = 25.0,
			weight = 2,
		},
	},

	-- Display order: worst → best (used by UI lists and comparisons)
	Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" },
}

return RarityConfig
