local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PRICE_GROWTH = 1.35

-- ===== UPGRADE SYSTEM =====
-- Manage all player upgrades and apply effects

local UPGRADE_DEFINITIONS = {
	double_tap = {
		name = "Double Tap",
		baseCost = 100,
		apply = function(player, count)
			local clickStats = player:FindFirstChild("ClickStats")
			if clickStats then
				local baseValue = clickStats:FindFirstChild("BaseValue")
				if baseValue then
					baseValue.Value = baseValue.Value * 2
					print(string.format("[Upgrades] %s: Base Value now %.1f", player.Name, baseValue.Value))
				end
			end
		end
	},
	crit_chance = {
		name = "Crit Chance +10%",
		baseCost = 250,
		apply = function(player, count)
			local clickStats = player:FindFirstChild("ClickStats")
			if clickStats then
				local critChance = clickStats:FindFirstChild("CritChance")
				if critChance then
					critChance.Value = critChance.Value + 0.1
					print(string.format("[Upgrades] %s: Crit Chance now %.0f%%", player.Name, critChance.Value * 100))
				end
			end
		end
	},
	crit_mult = {
		name = "Crit Multiplier x2",
		baseCost = 500,
		apply = function(player, count)
			local clickStats = player:FindFirstChild("ClickStats")
			if clickStats then
				local critMult = clickStats:FindFirstChild("CritMultiplier")
				if critMult then
					critMult.Value = critMult.Value * 2
					print(string.format("[Upgrades] %s: Crit Mult now %.1f", player.Name, critMult.Value))
				end
			end
		end
	},
	auto_click = {
		name = "Auto Clicker",
		baseCost = 1000,
		apply = function(player, count)
			local clickStats = player:FindFirstChild("ClickStats")
			if clickStats then
				local autoClicks = clickStats:FindFirstChild("AutoClicksPerSecond")
				if not autoClicks then
					autoClicks = Instance.new("NumberValue")
					autoClicks.Name = "AutoClicksPerSecond"
					autoClicks.Value = 0
					autoClicks.Parent = clickStats
				end
				autoClicks.Value = autoClicks.Value + 1
				print(string.format("[Upgrades] %s: Auto Clicker level %d", player.Name, autoClicks.Value))
			end
		end
	},
	passive_income = {
		name = "Passive Generator",
		baseCost = 2000,
		apply = function(player, count)
			local clickStats = player:FindFirstChild("ClickStats")
			if clickStats then
				local passiveIncome = clickStats:FindFirstChild("PassiveIncomePerSecond")
				if not passiveIncome then
					passiveIncome = Instance.new("NumberValue")
					passiveIncome.Name = "PassiveIncomePerSecond"
					passiveIncome.Value = 0
					passiveIncome.Parent = clickStats
				end
				passiveIncome.Value = passiveIncome.Value + 1
				print(string.format("[Upgrades] %s: Passive Income level %d", player.Name, passiveIncome.Value))
			end
		end
	}
}

-- Create BuyUpgrade RemoteEvent if it doesn't exist
local buyUpgradeEvent = ReplicatedStorage:FindFirstChild("BuyUpgrade")
if not buyUpgradeEvent then
	buyUpgradeEvent = Instance.new("RemoteEvent")
	buyUpgradeEvent.Name = "BuyUpgrade"
	buyUpgradeEvent.Parent = ReplicatedStorage
end

local buyUpgradeRequest = ReplicatedStorage:FindFirstChild("BuyUpgradeRequest")
if not buyUpgradeRequest then
	buyUpgradeRequest = Instance.new("BindableEvent")
	buyUpgradeRequest.Name = "BuyUpgradeRequest"
	buyUpgradeRequest.Parent = ReplicatedStorage
end

local function getOrCreateUpgradesFolder(player)
	local upgrades = player:FindFirstChild("Upgrades")
	if upgrades and upgrades:IsA("Folder") then
		return upgrades
	end

	upgrades = Instance.new("Folder")
	upgrades.Name = "Upgrades"
	upgrades.Parent = player
	return upgrades
end

local function getOrCreateUpgradeCount(player, upgradeId)
	local upgrades = getOrCreateUpgradesFolder(player)
	local value = upgrades:FindFirstChild(upgradeId)
	if value and value:IsA("IntValue") then
		return value
	end

	value = Instance.new("IntValue")
	value.Name = upgradeId
	value.Value = 0
	value.Parent = upgrades
	return value
end

local function ensureUpgradeData(player)
	for upgradeId, _ in pairs(UPGRADE_DEFINITIONS) do
		getOrCreateUpgradeCount(player, upgradeId)
	end
end

local function getScaledCost(baseCost, level)
	local scaled = math.floor(baseCost * (PRICE_GROWTH ^ level))
	return math.max(baseCost, scaled)
end

local function getUpgradeCost(player, upgradeId)
	local def = UPGRADE_DEFINITIONS[upgradeId]
	if not def then
		return nil
	end

	local ownedLevel = getOrCreateUpgradeCount(player, upgradeId).Value
	return getScaledCost(def.baseCost, ownedLevel), ownedLevel
end

Players.PlayerAdded:Connect(function(player)
	ensureUpgradeData(player)
end)

for _, player in Players:GetPlayers() do
	ensureUpgradeData(player)
end

local purchaseResultEvent = ReplicatedStorage:FindFirstChild("UpgradePurchaseResult")
if not purchaseResultEvent then
	purchaseResultEvent = Instance.new("RemoteEvent")
	purchaseResultEvent.Name = "UpgradePurchaseResult"
	purchaseResultEvent.Parent = ReplicatedStorage
end

local function attemptPurchase(player, upgradeId)
	if not player or not player:IsDescendantOf(Players) then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("[Upgrades] No leaderstats for " .. player.Name)
		return
	end

	local currencyValue = leaderstats:FindFirstChild("Currency")
	if not currencyValue or not currencyValue:IsA("IntValue") then
		warn("[Upgrades] No Currency value for " .. player.Name)
		purchaseResultEvent:FireClient(player, false, "Currency konnte nicht geladen werden.")
		return
	end

	local upgradeDef = UPGRADE_DEFINITIONS[upgradeId]
	if not upgradeDef then
		warn("[Upgrades] Unknown upgrade: " .. tostring(upgradeId))
		purchaseResultEvent:FireClient(player, false, "Unbekanntes Upgrade.")
		return
	end

	local cost = getUpgradeCost(player, upgradeId)
	if not cost then
		purchaseResultEvent:FireClient(player, false, "Upgrade konnte nicht geladen werden.")
		return
	end

	-- Check if player has enough currency
	if currencyValue.Value < cost then
		warn(string.format("[Upgrades] %s tried to buy %s but only has %d (needs %d)", 
			player.Name, upgradeId, currencyValue.Value, cost))
		purchaseResultEvent:FireClient(player, false, "Nicht genug Currency.")
		return
	end

	-- Deduct currency
	currencyValue.Value -= cost

	-- Apply upgrade
	upgradeDef.apply(player, 1)

	-- Track upgrades count
	local upgradeCount = getOrCreateUpgradeCount(player, upgradeId)
	upgradeCount.Value += 1
	local nextCost = getScaledCost(upgradeDef.baseCost, upgradeCount.Value)
	purchaseResultEvent:FireClient(
		player,
		true,
		string.format("%s Lv.%d gekauft. Neuer Preis: $%d", upgradeDef.name, upgradeCount.Value, nextCost)
	)

	print(string.format("[Upgrades] ✓ %s bought %s (%d) for $%d", 
		player.Name, upgradeDef.name, upgradeCount.Value, cost))
end

-- Handle upgrade purchases from UI and in-world interactions.
buyUpgradeEvent.OnServerEvent:Connect(function(player, upgradeId)
	attemptPurchase(player, upgradeId)
end)

buyUpgradeRequest.Event:Connect(function(player, upgradeId)
	attemptPurchase(player, upgradeId)
end)

-- ===== AUTO-CLICK & PASSIVE INCOME SYSTEM =====
-- Every second, apply auto-clicks and passive income

local playerClickEvent = ReplicatedStorage:WaitForChild("PlayerClick")

local function calculateGain(player)
	local clickStats = player:FindFirstChild("ClickStats")
	if not clickStats then
		return 1
	end

	local baseValueObj = clickStats:FindFirstChild("BaseValue")
	local critChanceObj = clickStats:FindFirstChild("CritChance")
	local critMultiplierObj = clickStats:FindFirstChild("CritMultiplier")

	local baseValue = (baseValueObj and baseValueObj:IsA("NumberValue")) and baseValueObj.Value or 1
	local critChance = (critChanceObj and critChanceObj:IsA("NumberValue")) and critChanceObj.Value or 0.1
	local critMultiplier = (critMultiplierObj and critMultiplierObj:IsA("NumberValue")) and critMultiplierObj.Value or 10

	if math.random() < critChance then
		return math.max(1, math.floor(baseValue * critMultiplier))
	end

	return math.max(1, math.floor(baseValue))
end

local lastAutoClickTick = tick()
local autoClickInterval = 1 -- 1 second per auto-click

RunService.Heartbeat:Connect(function()
	local currentTick = tick()
	if currentTick - lastAutoClickTick < autoClickInterval then
		return
	end
	lastAutoClickTick = currentTick

	-- Apply auto-clicks and passive income for all players
	for _, player in Players:GetPlayers() do
		if not player:IsDescendantOf(Players) then
			continue
		end

		local clickStats = player:FindFirstChild("ClickStats")
		if not clickStats then
			continue
		end

		local autoClicks = clickStats:FindFirstChild("AutoClicksPerSecond")
		local passiveIncome = clickStats:FindFirstChild("PassiveIncomePerSecond")

		-- Apply auto-clicks
		if autoClicks and autoClicks.Value > 0 then
			local leaderstats = player:FindFirstChild("leaderstats")
			local currencyValue = leaderstats and leaderstats:FindFirstChild("Currency")
			if currencyValue and currencyValue:IsA("IntValue") then
				local totalGain = 0
			for _ = 1, math.floor(autoClicks.Value) do
				local gain = calculateGain(player)
				totalGain += gain
				playerClickEvent:FireClient(player, gain, false)
			end
				currencyValue.Value += totalGain
			end
		end

		-- Apply passive income
		if passiveIncome and passiveIncome.Value > 0 then
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local currencyValue = leaderstats:FindFirstChild("Currency")
				if currencyValue then
					currencyValue.Value += math.floor(passiveIncome.Value)
				end
			end
		end
	end
end)

print("[Upgrades] System loaded ✓")
