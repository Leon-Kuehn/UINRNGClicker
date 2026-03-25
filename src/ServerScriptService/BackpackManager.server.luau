--!strict
-- BackpackManager.server.luau
-- Handles selling current souls into spendable coins with rank multiplier.

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
local RankUtils = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RankUtils")
)

local Events              = ReplicatedStorage:WaitForChild("Events")
local SellSoulsEvent      = Events:WaitForChild("SellSouls")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")

SellSoulsEvent.OnServerEvent:Connect(function(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then
		PlayerData.init(player)
		pdata = PlayerData.get(player)
	end
	if not pdata then return end

	if pdata.souls <= 0 then
		UpdateCurrencyEvent:FireClient(
			player,
			pdata.coins,
			pdata.souls,
			pdata.totalClicks,
			RollConfig.getRollCost(pdata.totalRolls),
			0,
			nil,
			pdata.soulsCapacity,
			pdata.souls >= pdata.soulsCapacity
		)
		return
	end

	-- Apply rank multiplier to coin conversion
	local rankMultiplier = RankUtils.getMultiplier(pdata.rankIndex)
	local coinsFromSouls = math.floor(pdata.souls * EconomyConfig.COINS_PER_SOUL * rankMultiplier)
	pdata.coins += coinsFromSouls
	pdata.souls = 0

	UpdateCurrencyEvent:FireClient(
		player,
		pdata.coins,
		pdata.souls,
		pdata.totalClicks,
		RollConfig.getRollCost(pdata.totalRolls),
		0,
		nil,
		pdata.soulsCapacity,
		false
	)
end)
