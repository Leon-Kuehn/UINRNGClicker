local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PLAYER_CLICK_EVENT_NAME = "PlayerClick"
local CURRENCY_STAT_NAME = "Currency"

local BASE_VALUE = 1
local CRIT_CHANCE = 0.1
local CRIT_MULTIPLIER = 10

local playerClickEvent = ReplicatedStorage:FindFirstChild(PLAYER_CLICK_EVENT_NAME)
if not playerClickEvent or not playerClickEvent:IsA("RemoteEvent") then
	warn("[ClickCurrencyHandler] RemoteEvent '" .. PLAYER_CLICK_EVENT_NAME .. "' not found in ReplicatedStorage.")
	return
end

local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local currencyValue = Instance.new("IntValue")
	currencyValue.Name = CURRENCY_STAT_NAME
	currencyValue.Value = 0
	currencyValue.Parent = leaderstats
end

Players.PlayerAdded:Connect(createLeaderstats)

-- Fallback for Studio edge cases where players exist before script is connected.
for _, player in Players:GetPlayers() do
	if not player:FindFirstChild("leaderstats") then
		createLeaderstats(player)
	end
end

local function calculateGain()
	local roll = math.random()
	if roll < CRIT_CHANCE then
		return BASE_VALUE * CRIT_MULTIPLIER
	end

	return BASE_VALUE
end

playerClickEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("[ClickCurrencyHandler] Missing leaderstats for player: " .. player.Name)
		return
	end

	local currencyValue = leaderstats:FindFirstChild(CURRENCY_STAT_NAME)
	if not currencyValue or not currencyValue:IsA("IntValue") then
		warn("[ClickCurrencyHandler] Missing IntValue '" .. CURRENCY_STAT_NAME .. "' for player: " .. player.Name)
		return
	end

	local gain = calculateGain()
	currencyValue.Value += gain

	-- Send the computed gain back so the client can show accurate floating feedback.
	playerClickEvent:FireClient(player, gain)
end)
