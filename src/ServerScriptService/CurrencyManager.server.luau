--!strict
-- CurrencyManager.server.luau
-- Handles the PlayerClick RemoteEvent and awards souls with:
--   • Weapon rarity × weapon clickMultiplier stacking
--   • Rebirth bonus  (+50 % per rebirth tier)
--   • BonusZone multiplier (2×)
--   • Critical hits  (5 % chance for 3× payout)

local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(
	ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData")
)
local RollConfig = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RollConfig")
)
local EconomyConfig = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EconomyConfig")
)

local Events              = ReplicatedStorage:WaitForChild("Events")
local PlayerClickEvent    = Events:WaitForChild("PlayerClick")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")

PlayerClickEvent.OnServerEvent:Connect(function(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then
		PlayerData.init(player)
		pdata = PlayerData.get(player)
	end
	if not pdata then return end

	pdata.totalClicks += 1

	local amount: number = EconomyConfig.SOULS_PER_TAP_BASE

	-- Equipped weapon bonus
	if pdata.equippedWeapon then
		amount = amount
			* pdata.equippedWeapon.rarityMultiplier
			* pdata.equippedWeapon.clickMultiplier
	end

	-- Rebirth bonus: each rebirth adds +50 % to the base payout.
	-- Formula: amount × (1 + rebirths × 0.5)
	-- Examples: 1 rebirth → 1.5×, 2 → 2.0×, 4 → 3.0×
	if pdata.rebirths > 0 then
		amount = amount * (1 + pdata.rebirths * 0.5)
	end

	-- BonusZone multiplier
	if pdata.activeZones["BonusZone"] then
		amount = amount * EconomyConfig.BONUS_ZONE_SOULS_MULT
	end

	-- Critical hit
	local critSouls: number? = nil
	if math.random() < EconomyConfig.CRIT_CHANCE then
		amount = amount * EconomyConfig.CRIT_MULTIPLIER
		critSouls = math.floor(amount)
	end

	local soulsGained = math.max(0, math.floor(amount))
	local freeCapacity = math.max(0, pdata.soulsCapacity - pdata.souls)
	soulsGained = math.clamp(soulsGained, 0, freeCapacity)
	pdata.souls += soulsGained

	if soulsGained <= 0 then
		critSouls = nil
	elseif critSouls then
		critSouls = soulsGained
	end

	UpdateCurrencyEvent:FireClient(
		player,
		pdata.coins,
		pdata.souls,
		pdata.totalClicks,
		RollConfig.getRollCost(pdata.totalRolls),
		soulsGained,
		critSouls,
		pdata.soulsCapacity,
		pdata.souls >= pdata.soulsCapacity
	)
end)
