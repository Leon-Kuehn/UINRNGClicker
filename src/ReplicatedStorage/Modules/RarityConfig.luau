--!strict
-- Rarity definitions for the weapon RNG system.
-- weight          : relative probability (higher = more common)
-- color           : Color3 used in UI
-- multiplier      : base coins-per-click multiplier for weapons of this rarity
-- chancePercent   : computed field (weight / totalWeight * 100)

local RarityConfig = {}

RarityConfig.Rarities = {
	{ name = "Common",    weight = 5000, color = Color3.fromRGB(180, 180, 180), multiplier = 1   },
	{ name = "Uncommon",  weight = 2500, color = Color3.fromRGB( 98, 218,  98), multiplier = 2   },
	{ name = "Rare",      weight = 1000, color = Color3.fromRGB( 85, 130, 255), multiplier = 5   },
	{ name = "Epic",      weight =  300, color = Color3.fromRGB(163,  53, 228), multiplier = 15  },
	{ name = "Legendary", weight =  150, color = Color3.fromRGB(255, 175,   0), multiplier = 50  },
	{ name = "Mythic",    weight =   45, color = Color3.fromRGB(255,  70,  70), multiplier = 150 },
	{ name = "Divine",    weight =    5, color = Color3.fromRGB(255, 255, 100), multiplier = 500 },
}

-- Compute total weight and per-rarity chance percentage
local totalWeight = 0
for _, rarity in ipairs(RarityConfig.Rarities) do
	totalWeight += rarity.weight
end
RarityConfig.TotalWeight = totalWeight

-- Build name → rarity lookup and annotate chancePercent
RarityConfig.ByName = {}
for _, rarity in ipairs(RarityConfig.Rarities) do
	rarity.chancePercent = (rarity.weight / totalWeight) * 100
	RarityConfig.ByName[rarity.name] = rarity
end

return RarityConfig
