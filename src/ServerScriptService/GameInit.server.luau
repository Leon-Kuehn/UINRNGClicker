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

local Events               = ReplicatedStorage:WaitForChild("Events")
local UpdateCurrencyEvent  = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")

-- Auto-save interval in seconds (change to 60 for faster iteration during testing)
local AUTO_SAVE_INTERVAL = 300

local CoinsStore     = DataStoreService:GetDataStore("Coins_v1")
local InventoryStore = DataStoreService:GetDataStore("Inventory_v1")

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
	end

	-- Inventory
	local ok2, invVal = pcall(function()
		return InventoryStore:GetAsync(tostring(player.UserId))
	end)
	if ok2 and type(invVal) == "table" then
		pdata.inventory = invVal
	end

	-- Sync initial state to client
	UpdateCurrencyEvent:FireClient(player, pdata.coins, nil)
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
		InventoryStore:SetAsync(tostring(player.UserId), pdata.inventory)
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
					InventoryStore:SetAsync(tostring(player.UserId), pdata.inventory)
				end)
			end
		end
	end
end)
