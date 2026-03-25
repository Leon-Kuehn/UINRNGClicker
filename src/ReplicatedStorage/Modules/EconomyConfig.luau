--!strict
-- Core economy tuning for tap, sell, and starter progression.

local EconomyConfig = {
	SOULS_PER_TAP_BASE = 1,
	SOULS_CAPACITY_BASE = 100,
	SOULS_CAPACITY_PER_UPGRADE = 50,
	BACKPACK_UPGRADE_BASE_COST = 120,
	BACKPACK_UPGRADE_COST_MULTIPLIER = 1.35,
	BACKPACK_UPGRADE_MAX_LEVEL = 20,
	BONUS_ZONE_SOULS_MULT = 2,
	CRIT_CHANCE = 0.05,
	CRIT_MULTIPLIER = 3,
	COINS_PER_SOUL = 1,
	STARTING_COINS = 50,
}

function EconomyConfig.getBackpackLevelForCapacity(capacity: number): number
	local delta = math.max(0, capacity - EconomyConfig.SOULS_CAPACITY_BASE)
	return math.max(0, math.floor(delta / EconomyConfig.SOULS_CAPACITY_PER_UPGRADE))
end

function EconomyConfig.getSoulsCapacityForLevel(level: number): number
	local safeLevel = math.max(0, math.floor(level))
	return EconomyConfig.SOULS_CAPACITY_BASE + (safeLevel * EconomyConfig.SOULS_CAPACITY_PER_UPGRADE)
end

function EconomyConfig.getBackpackUpgradeCost(level: number): number
	local safeLevel = math.max(0, math.floor(level))
	local raw = EconomyConfig.BACKPACK_UPGRADE_BASE_COST * (EconomyConfig.BACKPACK_UPGRADE_COST_MULTIPLIER ^ safeLevel)
	return math.max(1, math.floor(raw))
end

return EconomyConfig