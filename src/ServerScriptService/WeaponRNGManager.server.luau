--!strict
-- WeaponRNGManager.server.luau
-- Processes RollWeapon requests from clients:
--   1. Validates the player has enough coins (ROLL_COST).
--   2. Performs a two-step weighted RNG: pick rarity → pick weapon.
--   3. Adds the new weapon to the player's inventory.
--   4. Syncs updated coins + inventory back to the client.

local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData   = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RarityConfig"))
local WeaponConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponConfig"))
local RNGUtils     = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RNGUtils"))
local RollConfig   = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RollConfig"))

local Events               = ReplicatedStorage:WaitForChild("Events")
local RollWeaponEvent      = Events:WaitForChild("RollWeapon")
local UpdateCurrencyEvent  = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")

RollWeaponEvent.OnServerEvent:Connect(function(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then return end

	local rollCost = RollConfig.getRollCost(pdata.totalRolls)

	-- Insufficient funds — fire UpdateCurrency so the UI stays in sync
	if pdata.coins < rollCost then
		UpdateCurrencyEvent:FireClient(
			player,
			pdata.coins,
			pdata.souls,
			pdata.totalClicks,
			rollCost,
			0,
			nil,
			pdata.soulsCapacity,
			pdata.souls >= pdata.soulsCapacity
		)
		return
	end

	pdata.coins -= rollCost
	pdata.totalRolls += 1

	-- Step 1: pick a rarity by weight
	local rarity = RNGUtils.weightedRandom(RarityConfig.Rarities)

	-- Step 2: pick a random weapon template for that rarity
	local pool = WeaponConfig.Weapons[rarity.name]
	if not pool or #pool == 0 then
		-- Safety fallback
		pool = WeaponConfig.Weapons["Common"]
	end
	local template = pool[math.random(1, #pool)]

	-- Build the weapon record that gets stored in the inventory
	local newWeapon: PlayerData.WeaponData = {
		name             = template.name,
		rarity           = rarity.name,
		clickMultiplier  = template.clickMultiplier,
		rarityMultiplier = rarity.multiplier,
		description      = template.description,
	}

	table.insert(pdata.inventory, newWeapon)

	local nextRollCost = RollConfig.getRollCost(pdata.totalRolls)
	UpdateCurrencyEvent:FireClient(
		player,
		pdata.coins,
		pdata.souls,
		pdata.totalClicks,
		nextRollCost,
		0,
		nil,
		pdata.soulsCapacity,
		pdata.souls >= pdata.soulsCapacity
	)
	UpdateInventoryEvent:FireClient(player, pdata.inventory, pdata.equippedWeapon)
end)
