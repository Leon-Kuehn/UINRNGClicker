local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PLAYER_CLICK_EVENT_NAME = "PlayerClick"
local CURRENCY_STAT_NAME = "Currency"

local DEFAULT_BASE_VALUE = 1
local DEFAULT_CRIT_CHANCE = 0.1
local DEFAULT_CRIT_MULTIPLIER = 10

local playerClickEvent = ReplicatedStorage:WaitForChild(PLAYER_CLICK_EVENT_NAME)
if not playerClickEvent:IsA("RemoteEvent") then
	warn("[ClickCurrencyHandler] ReplicatedStorage.PlayerClick is not a RemoteEvent.")
	return
end

local function getOrCreateNumberValue(parent: Instance, name: string, defaultValue: number): NumberValue
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("NumberValue") then
		return existing
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Name = name
	numberValue.Value = defaultValue
	numberValue.Parent = parent
	return numberValue
end

local function createPlayerData(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local currencyValue = leaderstats:FindFirstChild(CURRENCY_STAT_NAME)
	if not currencyValue or not currencyValue:IsA("IntValue") then
		currencyValue = Instance.new("IntValue")
		currencyValue.Name = CURRENCY_STAT_NAME
		currencyValue.Value = 0
		currencyValue.Parent = leaderstats
	end

	-- Upgrade-ready player settings (easy to hook into shop/buttons later).
	local clickStats = player:FindFirstChild("ClickStats")
	if not clickStats then
		clickStats = Instance.new("Folder")
		clickStats.Name = "ClickStats"
		clickStats.Parent = player
	end

	getOrCreateNumberValue(clickStats, "BaseValue", DEFAULT_BASE_VALUE)
	getOrCreateNumberValue(clickStats, "CritChance", DEFAULT_CRIT_CHANCE)
	getOrCreateNumberValue(clickStats, "CritMultiplier", DEFAULT_CRIT_MULTIPLIER)
end

local function calculateGain(player: Player): (number, boolean)
	local clickStats = player:FindFirstChild("ClickStats")
	if not clickStats then
		return DEFAULT_BASE_VALUE, false
	end

	local baseValueObj = clickStats:FindFirstChild("BaseValue")
	local critChanceObj = clickStats:FindFirstChild("CritChance")
	local critMultiplierObj = clickStats:FindFirstChild("CritMultiplier")

	local baseValue = (baseValueObj and baseValueObj:IsA("NumberValue")) and baseValueObj.Value or DEFAULT_BASE_VALUE
	local critChance = (critChanceObj and critChanceObj:IsA("NumberValue")) and critChanceObj.Value or DEFAULT_CRIT_CHANCE
	local critMultiplier = (critMultiplierObj and critMultiplierObj:IsA("NumberValue")) and critMultiplierObj.Value or DEFAULT_CRIT_MULTIPLIER

	local isCrit = math.random() < critChance
	if isCrit then
		return math.max(1, math.floor(baseValue * critMultiplier)), true
	end

	return math.max(1, math.floor(baseValue)), false
end

Players.PlayerAdded:Connect(createPlayerData)

for _, player in Players:GetPlayers() do
	createPlayerData(player)
end

playerClickEvent.OnServerEvent:Connect(function(player: Player)
	if not player or not player:IsDescendantOf(Players) then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("[ClickCurrencyHandler] Missing leaderstats for " .. player.Name)
		return
	end

	local currencyValue = leaderstats:FindFirstChild(CURRENCY_STAT_NAME)
	if not currencyValue or not currencyValue:IsA("IntValue") then
		warn("[ClickCurrencyHandler] Missing Currency IntValue for " .. player.Name)
		return
	end

	local gain, isCrit = calculateGain(player)
	currencyValue.Value += gain

	print(string.format("[ClickCurrencyHandler] %s gained %d%s", player.Name, gain, isCrit and " (CRIT)" or ""))

	-- Send gain + crit flag so client can show matching floating text.
	playerClickEvent:FireClient(player, gain, isCrit)
end)
