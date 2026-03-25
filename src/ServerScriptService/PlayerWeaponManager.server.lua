-- PlayerWeaponManager.server.lua
-- Initialises each player's WeaponData folder on join (starter weapon).
-- Provides EquipWeapon / AddToInventory helpers used by WeaponRNGManager.
-- Exposes itself via _G.PlayerWeaponManager for cross-script access.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== Configuration =====
local INVENTORY_LIMIT = 20        -- Maximum weapons kept in WeaponInventory
local AUTO_EQUIP_IF_BETTER = true -- Auto-equip a rolled weapon when its multiplier exceeds the current one

-- Delay (seconds) before sending the initial WeaponEquipped event to a newly joined
-- player, giving the client GUI time to finish loading and connect its listeners.
local INITIAL_WEAPON_SYNC_DELAY = 2

local DEFAULT_WEAPON = {
	name = "Rusty Dagger",
	rarity = "Common",
	multiplier = 1.0,
	description = "A dull blade. Better than nothing.",
}

-- ===== Events =====
local eventsFolder       = ReplicatedStorage:WaitForChild("Events")
local weaponEquippedEvent = eventsFolder:WaitForChild("WeaponEquipped")

-- ===== Internal helpers =====

local function getOrCreateFolder(parent: Instance, name: string): Folder
	local f = parent:FindFirstChild(name)
	if f and f:IsA("Folder") then
		return f
	end
	f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

-- Write weapon fields into a Folder as typed Value instances.
-- Uses "WeaponName" (not "Name") to avoid shadowing Instance.Name.
local function writeWeaponToFolder(folder: Folder, weapon: { name: string, rarity: string, multiplier: number, description: string })
	local function sv(valueName: string, className: string, value: any)
		local obj = folder:FindFirstChild(valueName)
		if not obj or not obj:IsA(className) then
			obj = Instance.new(className)
			obj.Name = valueName
			obj.Parent = folder
		end
		obj.Value = value
	end
	sv("WeaponName",   "StringValue", weapon.name)
	sv("Rarity",       "StringValue", weapon.rarity)
	sv("Multiplier",   "NumberValue", weapon.multiplier)
	sv("Description",  "StringValue", weapon.description)
end

-- Read a WeaponData folder back into a plain table.
local function folderToTable(folder: Folder): { name: string, rarity: string, multiplier: number, description: string }
	local function gv(n: string): any
		local o = folder:FindFirstChild(n)
		return o and o.Value
	end
	return {
		name        = gv("WeaponName") or "Unknown",
		rarity      = gv("Rarity") or "Common",
		multiplier  = gv("Multiplier") or 1.0,
		description = gv("Description") or "",
	}
end

-- ===== Public API =====

local PlayerWeaponManager = {}

-- Equip a weapon for a player immediately (overwrites WeaponData, fires event).
function PlayerWeaponManager.EquipWeapon(player: Player, weapon: { name: string, rarity: string, multiplier: number, description: string })
	if not player or not player:IsDescendantOf(Players) then
		return
	end
	local weaponData = getOrCreateFolder(player, "WeaponData")
	writeWeaponToFolder(weaponData, weapon)
	weaponEquippedEvent:FireClient(player, weapon.name, weapon.rarity, weapon.multiplier, weapon.description)
end

-- Add a weapon to the player's inventory.
-- If AUTO_EQUIP_IF_BETTER is true and the new weapon has a higher multiplier, it is auto-equipped.
function PlayerWeaponManager.AddToInventory(player: Player, weapon: { name: string, rarity: string, multiplier: number, description: string })
	if not player or not player:IsDescendantOf(Players) then
		return
	end

	-- Decide whether to auto-equip
	local currentMult = 1.0
	local weaponData = player:FindFirstChild("WeaponData")
	if weaponData then
		local m = weaponData:FindFirstChild("Multiplier")
		currentMult = (m and m:IsA("NumberValue")) and m.Value or 1.0
	end

	if AUTO_EQUIP_IF_BETTER and weapon.multiplier > currentMult then
		PlayerWeaponManager.EquipWeapon(player, weapon)
	end

	-- Write to inventory
	local inventory = getOrCreateFolder(player, "WeaponInventory")
	local count = #inventory:GetChildren()
	local slot = Instance.new("Folder")
	slot.Name = string.format("Weapon_%05d", count + 1)
	slot.Parent = inventory
	writeWeaponToFolder(slot, weapon)

	-- Trim oldest entry when over the limit
	local children = inventory:GetChildren()
	if #children > INVENTORY_LIMIT then
		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)
		children[1]:Destroy()
	end
end

-- ===== Player initialisation =====

local function onPlayerAdded(player: Player)
	-- Weapon data
	local weaponData = getOrCreateFolder(player, "WeaponData")
	if not weaponData:FindFirstChild("WeaponName") then
		writeWeaponToFolder(weaponData, DEFAULT_WEAPON)

		-- Optional extra stats
		local function ensureNum(name: string, default: number)
			if not weaponData:FindFirstChild(name) then
				local v = Instance.new("NumberValue")
				v.Name = name
				v.Value = default
				v.Parent = weaponData
			end
		end
		ensureNum("BonusMultiplier", 1.0)  -- Temporary bonus from BonusZone
		ensureNum("LuckMultiplier",  1.0)  -- Affects rare drop rates
	end

	-- Inventory folder
	getOrCreateFolder(player, "WeaponInventory")

	-- Send initial weapon to the client once it has loaded
	task.delay(INITIAL_WEAPON_SYNC_DELAY, function()
		if player and player:IsDescendantOf(Players) then
			local wd = player:FindFirstChild("WeaponData")
			if wd then
				local w = folderToTable(wd)
				weaponEquippedEvent:FireClient(player, w.name, w.rarity, w.multiplier, w.description)
			end
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end

-- Make available to WeaponRNGManager
_G.PlayerWeaponManager = PlayerWeaponManager

print("[PlayerWeaponManager] Loaded ✓")
