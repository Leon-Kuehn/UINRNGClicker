--!strict
-- RankConfig.luau
-- Hardcoded rank progression with costs and multipliers.

export type Rank = {
	name: string,
	cost: number,       -- Cost in Coins to upgrade to this rank
	multiplier: number, -- Global multiplier for souls/coins
}

local RankConfig = {
	RANKS = {
		{ name = "Novice", cost = 0, multiplier = 1.0 },
		{ name = "Adept", cost = 100, multiplier = 1.5 },
		{ name = "Expert", cost = 300, multiplier = 2.0 },
		{ name = "Master", cost = 800, multiplier = 2.5 },
		{ name = "Legend", cost = 2000, multiplier = 3.0 },
	},
}

-- Returns the rank at the given index (1-indexed). Returns nil if out of bounds.
function RankConfig.getRankByIndex(index: number): Rank?
	if index < 1 or index > #RankConfig.RANKS then return nil end
	return RankConfig.RANKS[index]
end

-- Returns the number of available ranks.
function RankConfig.getRankCount(): number
	return #RankConfig.RANKS
end

-- Returns true if the given rank index is the last rank.
function RankConfig.isMaxRank(rankIndex: number): boolean
	return rankIndex >= #RankConfig.RANKS
end

return RankConfig
