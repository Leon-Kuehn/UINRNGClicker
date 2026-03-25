--!strict
-- Dummy/test tuning for RNG rolls.

local RollConfig = {
	BaseCost = 50,
	CostIncreasePerRoll = 15,
	MaxCost = 10_000,
}

function RollConfig.getRollCost(totalRolls: number): number
	local rolls = math.max(0, totalRolls)
	local cost = RollConfig.BaseCost + (rolls * RollConfig.CostIncreasePerRoll)
	return math.min(RollConfig.MaxCost, math.floor(cost))
end

return RollConfig