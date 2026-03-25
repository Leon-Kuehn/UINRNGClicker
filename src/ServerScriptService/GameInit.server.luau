--!strict
-- GameInit.server.luau
-- Single source of truth for player lifecycle:
--   • Creates the PlayerData record on join
--   • Loads persisted coins + inventory from DataStore
--   • Syncs initial state to the client
--   • Saves data on leave (and every 5 minutes for safety)

local Players             = game:GetService("Players")
local DataStoreService    = game:GetService("DataStoreService")
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

local Events               = ReplicatedStorage:WaitForChild("Events")
local UpdateCurrencyEvent  = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")

-- Auto-save interval in seconds (change to 60 for faster iteration during testing)
local AUTO_SAVE_INTERVAL = 300

local CoinsStore     = DataStoreService:GetDataStore("Coins_v1")
local InventoryStore = DataStoreService:GetDataStore("Inventory_v1")
local SoulsStore     = DataStoreService:GetDataStore("Souls_v1")
local ClicksStore    = DataStoreService:GetDataStore("TotalClicks_v1")
local SoulsCapacityStore = DataStoreService:GetDataStore("SoulsCapacity_v1")
local RankStore      = DataStoreService:GetDataStore("Rank_v1")

-- ── Load ──────────────────────────────────────────────────────────────────────

local function loadPlayer(player: Player)
	PlayerData.init(player)
	local pdata = PlayerData.get(player)
	if not pdata then return end

	-- Coins
	local ok1, coinsVal = pcall(function()
		return CoinsStore:GetAsync(tostring(player.UserId))
	end)
	if ok1 and type(coinsVal) == "number" then
		pdata.coins = coinsVal
	else
		pdata.coins = EconomyConfig.STARTING_COINS
	end

	-- Souls
	local ok3, soulsVal = pcall(function()
		return SoulsStore:GetAsync(tostring(player.UserId))
	end)
	if ok3 and type(soulsVal) == "number" then
		pdata.souls = soulsVal
	end

	-- Total clicks
	local ok4, clicksVal = pcall(function()
		return ClicksStore:GetAsync(tostring(player.UserId))
	end)
	if ok4 and type(clicksVal) == "number" then
		pdata.totalClicks = clicksVal
	end

	-- Souls capacity
	local ok5, capVal = pcall(function()
		return SoulsCapacityStore:GetAsync(tostring(player.UserId))
	end)
	if ok5 and type(capVal) == "number" then
		pdata.soulsCapacity = math.max(1, math.floor(capVal))
	end

	-- Inventory
	local ok2, invVal = pcall(function()
		return InventoryStore:GetAsync(tostring(player.UserId))
	end)
	if ok2 and type(invVal) == "table" then
		pdata.inventory = invVal
	end

	-- Rank
	local ok6, rankVal = pcall(function()
		return RankStore:GetAsync(tostring(player.UserId))
	end)
	if ok6 and type(rankVal) == "number" then
		pdata.rankIndex = math.max(1, math.floor(rankVal))
	end

	-- Sync initial state to client
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
	UpdateInventoryEvent:FireClient(player, pdata.inventory, pdata.equippedWeapon)
end

-- ── Save ──────────────────────────────────────────────────────────────────────

local function savePlayer(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then return end

	pcall(function()
		CoinsStore:SetAsync(tostring(player.UserId), pdata.coins)
	end)
	pcall(function()
		SoulsStore:SetAsync(tostring(player.UserId), pdata.souls)
	end)
	pcall(function()
		ClicksStore:SetAsync(tostring(player.UserId), pdata.totalClicks)
	end)
	pcall(function()
		SoulsCapacityStore:SetAsync(tostring(player.UserId), pdata.soulsCapacity)
	end)
	pcall(function()
		InventoryStore:SetAsync(tostring(player.UserId), pdata.inventory)
	end)
	pcall(function()
		RankStore:SetAsync(tostring(player.UserId), pdata.rankIndex)
	end)

	PlayerData.remove(player)
end

-- ── Hooks ─────────────────────────────────────────────────────────────────────

Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(savePlayer)

-- Handle players already in the server (e.g. hot-reload in Studio)
for _, player in ipairs(Players:GetPlayers()) do
	task.defer(loadPlayer, player)
end

-- Auto-save every 5 minutes to reduce data loss on server crash
task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			local pdata = PlayerData.get(player)
			if pdata then
				pcall(function()
					CoinsStore:SetAsync(tostring(player.UserId), pdata.coins)
				end)
				pcall(function()
					SoulsStore:SetAsync(tostring(player.UserId), pdata.souls)
				end)
				pcall(function()
					ClicksStore:SetAsync(tostring(player.UserId), pdata.totalClicks)
				end)
				pcall(function()
					SoulsCapacityStore:SetAsync(tostring(player.UserId), pdata.soulsCapacity)
				end)
				pcall(function()
					InventoryStore:SetAsync(tostring(player.UserId), pdata.inventory)
				end)
				pcall(function()
					RankStore:SetAsync(tostring(player.UserId), pdata.rankIndex)
				end)
			end
		end
	end
end)
