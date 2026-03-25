--!strict
-- Server-side shared player state.
-- Because Roblox caches require() results, every server Script that requires
-- this module reads and writes the SAME records table, making it a simple
-- in-process data store for the current session.

export type WeaponData = {
	name            : string,
	rarity          : string,
	clickMultiplier : number,
	rarityMultiplier: number,
	description     : string,
}

export type PlayerRecord = {
	coins          : number,
	souls          : number,
	soulsCapacity  : number,
	totalClicks    : number,
	totalRolls     : number,
	inventory      : { WeaponData },
	equippedWeapon : WeaponData?,
	rebirths       : number,
	activeZones    : { [string]: boolean },
	rankIndex      : number,
}

local PlayerData = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EconomyConfig")
)

local records: { [number]: PlayerRecord } = {}

-- Create a fresh record for player. Safe to call more than once; the
-- second call is a no-op so multiple scripts can call it without conflict.
function PlayerData.init(player: Player)
	if records[player.UserId] then return end
	records[player.UserId] = {
		coins           = 0,
		souls           = 0,
		soulsCapacity   = EconomyConfig.SOULS_CAPACITY_BASE,
		totalClicks     = 0,
		totalRolls      = 0,
		inventory       = {},
		equippedWeapon  = nil,
		rebirths        = 0,
		activeZones     = {},
		rankIndex       = 1,
	}
end

-- Returns the record for player, or nil if the player has not been
-- initialised (or has already left the game).
function PlayerData.get(player: Player): PlayerRecord?
	return records[player.UserId]
end

-- Remove the record when the player leaves.
function PlayerData.remove(player: Player)
	records[player.UserId] = nil
end

return PlayerData
