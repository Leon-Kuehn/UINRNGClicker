--!strict
-- Server-side shared player state.
-- Because Roblox caches require() results, every server Script that requires
-- this module reads and writes the SAME `records` table, making it a simple
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
	inventory      : { WeaponData },
	equippedWeapon : WeaponData?,
	rebirths       : number,
	activeZones    : { [string]: boolean },
}

local PlayerData = {}

local records: { [number]: PlayerRecord } = {}

-- Create a fresh record for `player`.  Safe to call more than once; the
-- second call is a no-op so multiple scripts can call it without conflict.
function PlayerData.init(player: Player)
	if records[player.UserId] then return end
	records[player.UserId] = {
		coins           = 0,
		inventory       = {},
		equippedWeapon  = nil,
		rebirths        = 0,
		activeZones     = {},
	}
end

-- Returns the record for `player`, or nil if the player has not been
-- initialised (or has already left the game).
function PlayerData.get(player: Player): PlayerRecord?
	return records[player.UserId]
end

-- Remove the record when the player leaves.
function PlayerData.remove(player: Player)
	records[player.UserId] = nil
end

return PlayerData
