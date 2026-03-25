--!strict
-- RankUtils.luau
-- Utility functions for rank lookups and next-rank info.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RankConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RankConfig"))

local RankUtils = {}

-- Returns the name and multiplier for the current rank.
function RankUtils.getRankInfo(rankIndex: number): { name: string, multiplier: number }?
	local rank = RankConfig.getRankByIndex(rankIndex)
	if not rank then return nil end
	return { name = rank.name, multiplier = rank.multiplier }
end

-- Returns info about the next rank (name, cost) or nil if already max rank.
function RankUtils.getNextRankInfo(rankIndex: number): { name: string, cost: number }?
	if RankConfig.isMaxRank(rankIndex) then return nil end
	local nextRank = RankConfig.getRankByIndex(rankIndex + 1)
	if not nextRank then return nil end
	return { name = nextRank.name, cost = nextRank.cost }
end

-- Returns the multiplier for a given rank index. Defaults to 1.0 if invalid.
function RankUtils.getMultiplier(rankIndex: number): number
	local rank = RankConfig.getRankByIndex(rankIndex)
	if not rank then return 1.0 end
	return rank.multiplier
end

return RankUtils
