--!strict
-- WorldInteractionManager.server.luau
-- Detects players entering / leaving CollectionService-tagged world parts
-- and fires the EnterZone RemoteEvent so clients can react.
--
-- Expected CollectionService tags on BasePart instances in the Workspace:
--   "RollStation"   – touch to receive a hint that the Roll panel is available
--   "BonusZone"     – doubles coins per click while the player is inside
--
-- To tag a part in Studio:
--   1. Select the part.
--   2. Open the Tag Editor plugin (or use the Properties panel).
--   3. Add the tag name exactly as listed above.

local Players             = game:GetService("Players")
local CollectionService   = game:GetService("CollectionService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(
	ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData")
)

local Events         = ReplicatedStorage:WaitForChild("Events")
local EnterZoneEvent = Events:WaitForChild("EnterZone")

-- Per-player zone-entry guard to prevent rapid repeated fires
local inZone: { [Player]: { [string]: boolean } } = {}

local function getPlayerFromHit(hit: BasePart): Player?
	local character = hit.Parent
	if not character then return nil end
	return Players:GetPlayerFromCharacter(character)
end

local function setupZonePart(tagName: string, part: BasePart)
	part.Touched:Connect(function(hit: BasePart)
		local player = getPlayerFromHit(hit)
		if not player then return end

		local pdata = PlayerData.get(player)
		if not pdata then return end

		if not inZone[player] then inZone[player] = {} end
		if inZone[player][tagName] then return end  -- already inside

		inZone[player][tagName] = true
		pdata.activeZones[tagName] = true
		EnterZoneEvent:FireClient(player, tagName, true)
	end)

	part.TouchEnded:Connect(function(hit: BasePart)
		local player = getPlayerFromHit(hit)
		if not player then return end

		local pdata = PlayerData.get(player)
		if not pdata then return end

		if not inZone[player] then return end
		inZone[player][tagName] = nil
		pdata.activeZones[tagName] = nil
		EnterZoneEvent:FireClient(player, tagName, false)
	end)
end

-- Register both currently tagged parts and any tagged in the future
for _, tagName in ipairs({ "RollStation", "BonusZone" }) do
	for _, part in ipairs(CollectionService:GetTagged(tagName)) do
		if part:IsA("BasePart") then
			setupZonePart(tagName, part)
		end
	end

	CollectionService:GetInstanceAddedSignal(tagName):Connect(function(instance: Instance)
		if instance:IsA("BasePart") then
			setupZonePart(tagName, instance)
		end
	end)
end

-- Clean up tracking when player leaves to prevent memory leaks
Players.PlayerRemoving:Connect(function(player: Player)
	inZone[player] = nil
end)
