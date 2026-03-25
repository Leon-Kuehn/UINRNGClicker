-- WeaponRNGManager.server.lua
-- Handles weapon roll requests from the client.
-- Validates Coins, deducts the roll cost, rolls a rarity + weapon,
-- updates the player's weapon (via PlayerWeaponManager), then fires the result.
--
-- Roll cost = BASE_ROLL_COST + (floor(currentMult - 1) * ROLL_COST_PER_MULT_TIER)
-- This makes rolls progressively costlier as the player grows stronger.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== Configuration =====
local BASE_ROLL_COST           = 100  -- Base Coins per roll
local ROLL_COST_PER_MULT_TIER  = 50   -- Extra cost per full multiplier point above 1.0

-- ===== Events =====
local eventsFolder         = ReplicatedStorage:WaitForChild("Events")
local rollRequestEvent     = eventsFolder:WaitForChild("RollRequest")
local rollResultEvent      = eventsFolder:WaitForChild("RollResult")
local currencyUpdatedEvent = eventsFolder:WaitForChild("CurrencyUpdated")

-- ===== Modules =====
local modulesFolder = ReplicatedStorage:WaitForChild("Modules")
local RarityConfig  = require(modulesFolder:WaitForChild("RarityConfig"))
local WeaponConfig  = require(modulesFolder:WaitForChild("WeaponConfig"))
local RNGUtils      = require(modulesFolder:WaitForChild("RNGUtils"))

-- ===== Wait for PlayerWeaponManager (_G set by PlayerWeaponManager.server.lua) =====
local PlayerWeaponManager
task.defer(function()
	local deadline = tick() + 10
	while not _G.PlayerWeaponManager do
		if tick() > deadline then
			warn("[WeaponRNGManager] Timed out waiting for PlayerWeaponManager")
			break
		end
		task.wait(0.1)
	end
	PlayerWeaponManager = _G.PlayerWeaponManager
end)

-- ===== Helpers =====

local function getCoinsValue(player: Player): IntValue?
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local v = ls:FindFirstChild("Coins")
	return (v and v:IsA("IntValue")) and v or nil
end

-- Deduct coins, sync legacy Currency, fire CurrencyUpdated.  Returns true on success.
local function deductCoins(player: Player, amount: number): boolean
	local coins = getCoinsValue(player)
	if not coins or coins.Value < amount then
		return false
	end
	coins.Value -= amount

	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local legacy = ls:FindFirstChild("Currency")
		if legacy and legacy:IsA("IntValue") then
			legacy.Value = coins.Value
		end
	end

	currencyUpdatedEvent:FireClient(player, coins.Value)
	return true
end

local function getRollCost(player: Player): number
	local wd = player:FindFirstChild("WeaponData")
	if not wd then return BASE_ROLL_COST end
	local m = wd:FindFirstChild("Multiplier")
	local currentMult = (m and m:IsA("NumberValue")) and m.Value or 1.0
	local tierBonus = math.floor(math.max(0, currentMult - 1.0)) * ROLL_COST_PER_MULT_TIER
	return BASE_ROLL_COST + tierBonus
end

local function getLuckMultiplier(player: Player): number
	local wd = player:FindFirstChild("WeaponData")
	if not wd then return 1.0 end
	local lm = wd:FindFirstChild("LuckMultiplier")
	return (lm and lm:IsA("NumberValue")) and math.max(1.0, lm.Value) or 1.0
end

-- Minimal fallback: write weapon directly without PlayerWeaponManager
local function fallbackEquipWeapon(player: Player, weapon: { name: string, rarity: string, multiplier: number, description: string })
	local wd = player:FindFirstChild("WeaponData")
	if not wd then return end

	local currentMult = 1.0
	local cm = wd:FindFirstChild("Multiplier")
	if cm and cm:IsA("NumberValue") then
		currentMult = cm.Value
	end

	if weapon.multiplier <= currentMult then return end  -- Only equip if better

	local function sv(n: string, cn: string, val: any)
		local o = wd:FindFirstChild(n)
		if not o then
			o = Instance.new(cn)
			o.Name = n
			o.Parent = wd
		end
		o.Value = val
	end
	sv("WeaponName",  "StringValue", weapon.name)
	sv("Rarity",      "StringValue", weapon.rarity)
	sv("Multiplier",  "NumberValue", weapon.multiplier)
	sv("Description", "StringValue", weapon.description)
end

-- ===== Roll request handler =====

rollRequestEvent.OnServerEvent:Connect(function(player: Player)
	if not player or not player:IsDescendantOf(Players) then return end

	local rollCost = getRollCost(player)
	local coins    = getCoinsValue(player)

	-- Insufficient funds
	if not coins or coins.Value < rollCost then
		rollResultEvent:FireClient(player, false, rollCost, nil, nil, nil, nil)
		return
	end

	-- Deduct cost
	if not deductCoins(player, rollCost) then
		rollResultEvent:FireClient(player, false, rollCost, nil, nil, nil, nil)
		return
	end

	-- Roll rarity then weapon
	local luckMult = getLuckMultiplier(player)
	local rarity   = RNGUtils.RollRarity(RarityConfig, luckMult)
	local weapon   = RNGUtils.RollWeaponFromRarity(WeaponConfig, rarity)

	-- Fallback to first Common weapon if something went wrong
	if not weapon then
		weapon = WeaponConfig.Common[1]
		rarity = "Common"
	end

	local rarityData = RarityConfig.Rarities[rarity]
	local fullWeapon = {
		name        = weapon.name,
		rarity      = rarity,
		multiplier  = rarityData and rarityData.multiplier or 1.0,
		description = weapon.description,
	}

	-- Update inventory and possibly equip
	if PlayerWeaponManager then
		PlayerWeaponManager.AddToInventory(player, fullWeapon)
	else
		fallbackEquipWeapon(player, fullWeapon)
	end

	-- Fire result to client
	-- Signature: (success, rollCost, weaponName, rarity, multiplier, description)
	rollResultEvent:FireClient(
		player, true, rollCost,
		fullWeapon.name, fullWeapon.rarity, fullWeapon.multiplier, fullWeapon.description
	)

	print(string.format(
		"[WeaponRNGManager] %s rolled: %s [%s] x%.1f  (cost: %d)",
		player.Name, fullWeapon.name, fullWeapon.rarity, fullWeapon.multiplier, rollCost
	))
end)

print("[WeaponRNGManager] Loaded ✓")
