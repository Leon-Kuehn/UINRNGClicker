-- CurrencyManager.server.lua
-- Handles player Coins, click events, auto-click, and passive income.
-- Replaces ClickCurrencyHandler.server.lua.
--
-- Listens to:
--   ReplicatedStorage.PlayerClick          (legacy – keeps ClickButton.client.lua working)
--   ReplicatedStorage.Events.ClickRequest  (new click path)
--
-- Fires:
--   ReplicatedStorage.PlayerClick:FireClient(player, gain, isCrit)   (legacy feedback)
--   ReplicatedStorage.Events.CurrencyUpdated:FireClient(player, newTotal)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ===== Configuration =====
local BASE_COINS_PER_CLICK  = 1
local DEFAULT_CRIT_CHANCE   = 0.10
local DEFAULT_CRIT_MULT     = 3
-- Heartbeat fires every frame; only process auto-income once per this interval (seconds).
local AUTO_TICK_INTERVAL    = 1

-- ===== Events =====
local eventsFolder         = ReplicatedStorage:WaitForChild("Events")
local clickRequestEvent    = eventsFolder:WaitForChild("ClickRequest")
local currencyUpdatedEvent = eventsFolder:WaitForChild("CurrencyUpdated")
-- Legacy event kept for backward compat with ClickButton.client.lua
local playerClickLegacy    = ReplicatedStorage:WaitForChild("PlayerClick")

-- ===== Helpers =====

local function getCoinsValue(player: Player): IntValue?
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local v = ls:FindFirstChild("Coins")
	return (v and v:IsA("IntValue")) and v or nil
end

-- Keep the legacy "Currency" IntValue in sync so UpgradeSystem still works.
local function syncLegacyCurrency(player: Player, newValue: number)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return end
	local legacy = ls:FindFirstChild("Currency")
	if legacy and legacy:IsA("IntValue") then
		legacy.Value = newValue
	end
end

local function getWeaponMultiplier(player: Player): number
	local wd = player:FindFirstChild("WeaponData")
	if not wd then return 1.0 end
	local m = wd:FindFirstChild("Multiplier")
	return (m and m:IsA("NumberValue")) and math.max(1.0, m.Value) or 1.0
end

local function getBonusMultiplier(player: Player): number
	local wd = player:FindFirstChild("WeaponData")
	if not wd then return 1.0 end
	local b = wd:FindFirstChild("BonusMultiplier")
	return (b and b:IsA("NumberValue")) and math.max(1.0, b.Value) or 1.0
end

-- Add coins and broadcast update
local function addCoins(player: Player, amount: number)
	local coins = getCoinsValue(player)
	if not coins then return end
	coins.Value += math.max(0, math.floor(amount))
	syncLegacyCurrency(player, coins.Value)
	currencyUpdatedEvent:FireClient(player, coins.Value)
end

-- Calculate click gain (base × crit × weapon × bonus)
local function calculateGain(player: Player): (number, boolean)
	local clickStats = player:FindFirstChild("ClickStats")
	local baseValue  = BASE_COINS_PER_CLICK
	local critChance = DEFAULT_CRIT_CHANCE
	local critMult   = DEFAULT_CRIT_MULT

	if clickStats then
		local bv = clickStats:FindFirstChild("BaseValue")
		local cc = clickStats:FindFirstChild("CritChance")
		local cm = clickStats:FindFirstChild("CritMultiplier")
		baseValue  = (bv and bv:IsA("NumberValue")) and bv.Value or baseValue
		critChance = (cc and cc:IsA("NumberValue")) and cc.Value or critChance
		critMult   = (cm and cm:IsA("NumberValue")) and cm.Value or critMult
	end

	local weaponMult = getWeaponMultiplier(player)
	local bonusMult  = getBonusMultiplier(player)
	local isCrit     = math.random() < critChance

	local gain: number
	if isCrit then
		gain = math.max(1, math.floor(baseValue * critMult * weaponMult * bonusMult))
	else
		gain = math.max(1, math.floor(baseValue * weaponMult * bonusMult))
	end
	return gain, isCrit
end

-- ===== Player initialisation =====

local function ensurePlayerData(player: Player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = player
	end

	local function ensureInt(parent: Instance, name: string): IntValue
		local v = parent:FindFirstChild(name)
		if not v or not v:IsA("IntValue") then
			v = Instance.new("IntValue")
			v.Name = name
			v.Value = 0
			v.Parent = parent
		end
		return v
	end

	ensureInt(ls, "Coins")
	ensureInt(ls, "Currency")  -- legacy, kept in sync

	local clickStats = player:FindFirstChild("ClickStats")
	if not clickStats then
		clickStats = Instance.new("Folder")
		clickStats.Name = "ClickStats"
		clickStats.Parent = player
	end

	local function ensureNum(parent: Instance, name: string, default: number)
		local v = parent:FindFirstChild(name)
		if not v or not v:IsA("NumberValue") then
			v = Instance.new("NumberValue")
			v.Name = name
			v.Value = default
			v.Parent = parent
		end
	end

	ensureNum(clickStats, "BaseValue",           BASE_COINS_PER_CLICK)
	ensureNum(clickStats, "CritChance",          DEFAULT_CRIT_CHANCE)
	ensureNum(clickStats, "CritMultiplier",      DEFAULT_CRIT_MULT)
	ensureNum(clickStats, "AutoClicksPerSecond", 0)
	ensureNum(clickStats, "PassiveIncomePerSecond", 0)
end

Players.PlayerAdded:Connect(ensurePlayerData)
for _, p in Players:GetPlayers() do
	ensurePlayerData(p)
end

-- ===== Click handlers =====

-- New path: Events/ClickRequest
clickRequestEvent.OnServerEvent:Connect(function(player: Player)
	if not player or not player:IsDescendantOf(Players) then return end
	local gain, isCrit = calculateGain(player)
	addCoins(player, gain)
	clickRequestEvent:FireClient(player, gain, isCrit)
end)

-- Legacy path: ReplicatedStorage.PlayerClick (keeps old ClickButton.client.lua working)
playerClickLegacy.OnServerEvent:Connect(function(player: Player)
	if not player or not player:IsDescendantOf(Players) then return end
	local gain, isCrit = calculateGain(player)
	addCoins(player, gain)
	playerClickLegacy:FireClient(player, gain, isCrit)
end)

-- ===== Auto-click and passive income loop =====

local lastTick = tick()
RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - lastTick < AUTO_TICK_INTERVAL then return end
	lastTick = now

	for _, player in Players:GetPlayers() do
		if not player:IsDescendantOf(Players) then continue end
		local clickStats = player:FindFirstChild("ClickStats")
		if not clickStats then continue end

		local autoClicksObj = clickStats:FindFirstChild("AutoClicksPerSecond")
		local passiveObj    = clickStats:FindFirstChild("PassiveIncomePerSecond")

		if autoClicksObj and autoClicksObj.Value > 0 then
			local total = 0
			for _ = 1, math.floor(autoClicksObj.Value) do
				local g = calculateGain(player)
				total += g
			end
			addCoins(player, total)
		end

		if passiveObj and passiveObj.Value > 0 then
			addCoins(player, math.floor(passiveObj.Value))
		end
	end
end)

print("[CurrencyManager] Loaded ✓")
