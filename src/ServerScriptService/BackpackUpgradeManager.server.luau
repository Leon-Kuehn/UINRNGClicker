--!strict
-- BackpackUpgradeManager.server.luau
-- Handles backpack capacity upgrades purchased with coins.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local Events = ReplicatedStorage:WaitForChild("Events")
local UpgradeBackpackEvent = Events:WaitForChild("UpgradeBackpack")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")

local function syncCurrency(player: Player, pdata: PlayerData.PlayerRecord)
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
end

UpgradeBackpackEvent.OnServerEvent:Connect(function(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then
		PlayerData.init(player)
		pdata = PlayerData.get(player)
	end
	if not pdata then return end

	local level = EconomyConfig.getBackpackLevelForCapacity(pdata.soulsCapacity)
	if level >= EconomyConfig.BACKPACK_UPGRADE_MAX_LEVEL then
		syncCurrency(player, pdata)
		return
	end

	local upgradeCost = EconomyConfig.getBackpackUpgradeCost(level)
	if pdata.coins < upgradeCost then
		syncCurrency(player, pdata)
		return
	end

	pdata.coins -= upgradeCost
	pdata.soulsCapacity = EconomyConfig.getSoulsCapacityForLevel(level + 1)

	syncCurrency(player, pdata)
end)
