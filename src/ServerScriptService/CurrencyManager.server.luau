--!strict
-- CurrencyManager.server.luau
-- Handles the PlayerClick RemoteEvent and awards coins with:
--   • Weapon rarity × weapon clickMultiplier stacking
--   • Rebirth bonus  (+50 % per rebirth tier)
--   • BonusZone multiplier (2×)
--   • Critical hits  (5 % chance for 3× payout)

local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(
	ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData")
)

local Events              = ReplicatedStorage:WaitForChild("Events")
local PlayerClickEvent    = Events:WaitForChild("PlayerClick")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")

local BASE_COINS      = 1
local CRIT_CHANCE     = 0.05   -- 5 %
local CRIT_MULTIPLIER = 3
local BONUS_ZONE_MULT = 2      -- while inside a BonusZone part

PlayerClickEvent.OnServerEvent:Connect(function(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then return end

	local amount: number = BASE_COINS

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
		amount = amount * BONUS_ZONE_MULT
	end

	-- Critical hit
	local critAmount: number? = nil
	if math.random() < CRIT_CHANCE then
		amount = amount * CRIT_MULTIPLIER
		critAmount = math.floor(amount)
	end

	pdata.coins += math.floor(amount)
	UpdateCurrencyEvent:FireClient(player, pdata.coins, critAmount)
end)
