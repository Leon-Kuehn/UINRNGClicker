--!strict
-- Weighted random selection utilities used by WeaponRNGManager.

local RNGUtils = {}

-- Pick one item from `items` using each item's `.weight` field.
-- Returns the chosen item; falls back to the last item if the loop
-- completes without a match (unreachable with positive integer weights).
--
-- Distribution: roll is drawn from [0, total-1].  A weight of W means the
-- item "owns" W consecutive values, so every unit of weight is equally likely.
function RNGUtils.weightedRandom(items: { { weight: number, [string]: any } }): { weight: number, [string]: any }
	local total = 0
	for _, item in ipairs(items) do
		total += item.weight
	end

	-- Use [0, total-1] so that each weight unit maps to exactly one value,
	-- avoiding any ambiguity at the upper boundary.
	local roll = math.random(0, total - 1)
	local cumulative = 0
	for _, item in ipairs(items) do
		cumulative += item.weight
		if roll < cumulative then
			return item
		end
	end

	-- Fallback (unreachable with positive integer weights)
	return items[#items]
end

-- Returns a random integer in [min, max] inclusive.
function RNGUtils.randomInt(min: number, max: number): number
	return math.random(min, max)
end

return RNGUtils
