-- RNGUtils.lua
-- Clean weighted-random utilities used by WeaponRNGManager.
-- All functions are pure (no Roblox service calls) so they can be required
-- on both the server and the client.

local RNGUtils = {}

-- Picks one item from a weighted list.
-- @param items  Array of { item: any, weight: number }
-- @returns  The selected item, or nil if the list is empty / all weights are zero.
function RNGUtils.WeightedRandom(items: { { item: any, weight: number } }): any
	if #items == 0 then
		return nil
	end

	local totalWeight = 0
	for _, entry in ipairs(items) do
		totalWeight += entry.weight
	end

	if totalWeight <= 0 then
		return items[1].item
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, entry in ipairs(items) do
		cumulative += entry.weight
		if roll < cumulative then
			return entry.item
		end
	end

	-- Safety fallback for floating-point edge cases
	return items[#items].item
end

-- Rolls a rarity name using the weights in RarityConfig.
-- @param rarityConfig     The RarityConfig module table
-- @param luckMultiplier   Optional luck boost (> 1.0 improves rare chances).  Default 1.0
-- @returns  A rarity key string, e.g. "Rare"
function RNGUtils.RollRarity(rarityConfig: any, luckMultiplier: number?): string
	local luck = math.max(0.01, luckMultiplier or 1.0)
	local weightedList: { { item: string, weight: number } } = {}

	for rarityName, data in pairs(rarityConfig.Rarities) do
		local adjustedWeight: number
		if data.multiplier > 1.0 then
			-- Non-common rarities benefit from luck
			adjustedWeight = data.weight * luck
		else
			-- Common gets inversely reduced so rarer items fill the gap
			adjustedWeight = data.weight / luck
		end
		adjustedWeight = math.max(0.01, adjustedWeight)
		table.insert(weightedList, { item = rarityName, weight = adjustedWeight })
	end

	return RNGUtils.WeightedRandom(weightedList)
end

-- Picks a random weapon entry from a specific rarity pool.
-- @param weaponConfig  The WeaponConfig module table
-- @param rarity        Rarity key string, e.g. "Rare"
-- @returns  A WeaponData table, or nil if the pool is empty
function RNGUtils.RollWeaponFromRarity(weaponConfig: any, rarity: string): any?
	local pool = weaponConfig[rarity]
	if not pool or #pool == 0 then
		return nil
	end
	return pool[math.random(1, #pool)]
end

return RNGUtils
