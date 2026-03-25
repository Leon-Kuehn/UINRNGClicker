--!strict
-- PlayerWeaponManager.server.luau
-- Handles inventory management:
--   EquipWeapon  – equip a weapon from inventory by 1-based index
--   SellWeapon   – sell a weapon for coins and remove it from inventory

local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(
	ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData")
)
local RollConfig = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RollConfig")
)

local Events               = ReplicatedStorage:WaitForChild("Events")
local EquipWeaponEvent     = Events:WaitForChild("EquipWeapon")
local SellWeaponEvent      = Events:WaitForChild("SellWeapon")
local UpdateCurrencyEvent  = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")

-- Flat sell value per rarity tier
local SELL_VALUE: { [string]: number } = {
	Common    =     10,
	Uncommon  =     25,
	Rare      =     75,
	Epic      =    250,
	Legendary =  1_000,
	Mythic    =  5_000,
	Divine    = 25_000,
}

-- ── Equip ─────────────────────────────────────────────────────────────────────

EquipWeaponEvent.OnServerEvent:Connect(function(player: Player, index: number)
	local pdata = PlayerData.get(player)
	if not pdata then return end
	if type(index) ~= "number" then return end

	local weapon = pdata.inventory[index]
	if not weapon then return end

	pdata.equippedWeapon = weapon
	UpdateInventoryEvent:FireClient(player, pdata.inventory, pdata.equippedWeapon)
end)

-- ── Sell ──────────────────────────────────────────────────────────────────────

SellWeaponEvent.OnServerEvent:Connect(function(player: Player, index: number)
	local pdata = PlayerData.get(player)
	if not pdata then return end
	if type(index) ~= "number" then return end

	local weapon = pdata.inventory[index]
	if not weapon then return end

	-- Automatically unequip if selling the currently equipped weapon
	if pdata.equippedWeapon == weapon then
		pdata.equippedWeapon = nil
	end

	local coins = SELL_VALUE[weapon.rarity] or 10
	pdata.coins += coins
	table.remove(pdata.inventory, index)

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
end)
