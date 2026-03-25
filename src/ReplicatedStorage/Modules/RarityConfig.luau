--!strict
-- Rarity definitions for the weapon RNG system.
-- weight          : relative probability (higher = more common)
-- color           : Color3 used in UI
-- multiplier      : base coins-per-click multiplier for weapons of this rarity
-- chancePercent   : computed field (weight / totalWeight * 100)

local RarityConfig = {}

RarityConfig.Rarities = {
	-- Dummy test distribution (total weight 10,000):
	-- Common 55.0%, Uncommon 25.0%, Rare 12.0%, Epic 5.5%, Legendary 1.8%, Mythic 0.6%, Divine 0.1%
	{ name = "Common",    weight = 5500, color = Color3.fromRGB(180, 180, 180), multiplier = 1.00 },
	{ name = "Uncommon",  weight = 2500, color = Color3.fromRGB( 98, 218,  98), multiplier = 1.35 },
	{ name = "Rare",      weight = 1200, color = Color3.fromRGB( 85, 130, 255), multiplier = 1.85 },
	{ name = "Epic",      weight =  550, color = Color3.fromRGB(163,  53, 228), multiplier = 2.75 },
	{ name = "Legendary", weight =  180, color = Color3.fromRGB(255, 175,   0), multiplier = 4.20 },
	{ name = "Mythic",    weight =   60, color = Color3.fromRGB(255,  70,  70), multiplier = 6.50 },
	{ name = "Divine",    weight =   10, color = Color3.fromRGB(255, 255, 100), multiplier = 10.0 },
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
