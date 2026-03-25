-- WorldInteractionManager.server.lua
-- Watches CollectionService-tagged Parts and wires interactions to the game systems.
--
-- Supported tags  (apply in Roblox Studio via CollectionService / Tag Editor plugin):
--
--   "RollStation"    – Adds a ProximityPrompt that opens the Roll UI on the client.
--   "WeaponShowcase" – Adds a ProximityPrompt that fires a WeaponShowcase event (client handles display).
--   "SellZone"       – Adds a ProximityPrompt placeholder for a future sell mechanic.
--   "BonusZone"      – Touched event: grants a temporary click-multiplier boost to the player.
--
-- All interactions fire Events/WorldInteraction to the relevant client(s).
-- Signature: (interactionType: string, action: string, partName: string)

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- ===== Configuration =====
local BONUS_ZONE_MULTIPLIER = 2.0   -- Temporary BonusMultiplier value applied to WeaponData
local BONUS_ZONE_DURATION   = 15    -- Seconds before the bonus expires

-- ===== Events =====
local eventsFolder           = ReplicatedStorage:WaitForChild("Events")
local worldInteractionEvent  = eventsFolder:WaitForChild("WorldInteraction")

-- ===== Shared helper =====

-- Adds a ProximityPrompt to a BasePart only if one does not already exist.
local function addProximityPrompt(part: BasePart, actionText: string, objectText: string, holdDuration: number?): ProximityPrompt?
	if part:FindFirstChildWhichIsA("ProximityPrompt") then
		return nil  -- Already equipped
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText            = actionText
	prompt.ObjectText            = objectText
	prompt.HoldDuration          = holdDuration or 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight   = false
	prompt.Parent                = part
	return prompt
end

-- ===== ROLL STATION =====

local function setupRollStation(part: Instance)
	if not part:IsA("BasePart") then return end
	local prompt = addProximityPrompt(part, "Roll", "Roll Station", 0)
	if not prompt then return end
	prompt.Triggered:Connect(function(player: Player)
		worldInteractionEvent:FireClient(player, "RollStation", "open", part.Name)
	end)
end

for _, part in CollectionService:GetTagged("RollStation") do
	setupRollStation(part)
end
CollectionService:GetInstanceAddedSignal("RollStation"):Connect(setupRollStation)

-- ===== WEAPON SHOWCASE =====

local function setupWeaponShowcase(part: Instance)
	if not part:IsA("BasePart") then return end
	local prompt = addProximityPrompt(part, "Inspect", "Weapon Showcase", 0)
	if not prompt then return end
	prompt.Triggered:Connect(function(player: Player)
		worldInteractionEvent:FireClient(player, "WeaponShowcase", "open", part.Name)
	end)
end

for _, part in CollectionService:GetTagged("WeaponShowcase") do
	setupWeaponShowcase(part)
end
CollectionService:GetInstanceAddedSignal("WeaponShowcase"):Connect(setupWeaponShowcase)

-- ===== SELL ZONE =====

local function setupSellZone(part: Instance)
	if not part:IsA("BasePart") then return end
	local prompt = addProximityPrompt(part, "Sell", "Sell Zone", 0.5)
	if not prompt then return end
	prompt.Triggered:Connect(function(player: Player)
		-- Placeholder: fires WorldInteraction so the client can open a sell UI
		worldInteractionEvent:FireClient(player, "SellZone", "open", part.Name)
	end)
end

for _, part in CollectionService:GetTagged("SellZone") do
	setupSellZone(part)
end
CollectionService:GetInstanceAddedSignal("SellZone"):Connect(setupSellZone)

-- ===== BONUS ZONE =====
-- Uses Touched so the player simply walks into the zone.
-- The bonus expires automatically after BONUS_ZONE_DURATION seconds.

local activeBonuses: { [Player]: boolean } = {}

local function applyBonus(player: Player)
	if activeBonuses[player] then return end  -- Bonus already active
	activeBonuses[player] = true

	local wd = player:FindFirstChild("WeaponData")
	if wd then
		local b = wd:FindFirstChild("BonusMultiplier")
		if b and b:IsA("NumberValue") then
			b.Value = BONUS_ZONE_MULTIPLIER
		end
	end

	worldInteractionEvent:FireClient(player, "BonusZone", "enter", "")

	task.delay(BONUS_ZONE_DURATION, function()
		if not (player and player:IsDescendantOf(Players)) then
			activeBonuses[player] = nil
			return
		end
		local wdNow = player:FindFirstChild("WeaponData")
		if wdNow then
			local b = wdNow:FindFirstChild("BonusMultiplier")
			if b and b:IsA("NumberValue") then
				b.Value = 1.0
			end
		end
		worldInteractionEvent:FireClient(player, "BonusZone", "exit", "")
		activeBonuses[player] = nil
	end)
end

local function setupBonusZone(part: Instance)
	if not part:IsA("BasePart") then return end
	part.Touched:Connect(function(hit: BasePart)
		local character = hit.Parent
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			applyBonus(player)
		end
	end)
end

for _, part in CollectionService:GetTagged("BonusZone") do
	setupBonusZone(part)
end
CollectionService:GetInstanceAddedSignal("BonusZone"):Connect(setupBonusZone)

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	activeBonuses[player] = nil
end)

print("[WorldInteractionManager] Loaded ✓")
