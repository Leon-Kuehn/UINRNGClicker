--!strict
-- RollController.client.luau
-- Right-side panel for rolling new weapons.
--   • Displays each rarity's name, colour, and drop chance.
--   • ROLL button fires RollWeapon to the server (costs 50 coins).
--   • Shows the rolled weapon name/rarity/description after each roll.
--   • Highlights the panel border when the player enters a RollStation zone.
-- All UI is created in code.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local FormatUtils  = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FormatUtils"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RarityConfig"))

local Events               = ReplicatedStorage:WaitForChild("Events")
local RollWeaponEvent      = Events:WaitForChild("RollWeapon")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")
local EnterZoneEvent       = Events:WaitForChild("EnterZone")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("RollUI")

-- ── Panel ─────────────────────────────────────────────────────────────────────

local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.26, 0.60)
panel.Position = UDim2.fromScale(0.73, 0.20)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
panel.BackgroundTransparency = 0.10
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = panel

local panelPad = Instance.new("UIPadding")
panelPad.PaddingTop    = UDim.new(0, 10)
panelPad.PaddingBottom = UDim.new(0, 10)
panelPad.PaddingLeft   = UDim.new(0, 10)
panelPad.PaddingRight  = UDim.new(0, 10)
panelPad.Parent = panel

-- ── Title ─────────────────────────────────────────────────────────────────────

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.fromScale(1, 0)
titleLabel.AutomaticSize = Enum.AutomaticSize.Y
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Text = "⚔  WEAPON ROLL"
titleLabel.LayoutOrder = 1
titleLabel.Parent = panel

-- ── Rarity chances ────────────────────────────────────────────────────────────

for _, rarity in ipairs(RarityConfig.Rarities) do
	local row = Instance.new("TextLabel")
	row.Size = UDim2.fromScale(1, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 1
	row.TextColor3 = rarity.color
	row.Font = Enum.Font.Gotham
	row.TextSize = 13
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.Text = string.format("  %s: %s", rarity.name, FormatUtils.formatPercent(rarity.chancePercent))
	row.LayoutOrder = 2
	row.Parent = panel
end

-- ── Roll result label ─────────────────────────────────────────────────────────

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.fromScale(1, 0)
resultLabel.AutomaticSize = Enum.AutomaticSize.Y
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextSize = 15
resultLabel.TextWrapped = true
resultLabel.Text = ""
resultLabel.LayoutOrder = 3
resultLabel.Parent = panel

-- ── Roll button ───────────────────────────────────────────────────────────────

local rollButton = Instance.new("TextButton")
rollButton.Size = UDim2.fromScale(1, 0)
rollButton.AutomaticSize = Enum.AutomaticSize.Y
rollButton.BackgroundColor3 = Color3.fromRGB(70, 170, 70)
rollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rollButton.Font = Enum.Font.GothamBold
rollButton.TextSize = 17
rollButton.Text = "ROLL  (50 🪙)"
rollButton.BorderSizePixel = 0
rollButton.LayoutOrder = 4
rollButton.Parent = panel

local rollCorner = Instance.new("UICorner")
rollCorner.CornerRadius = UDim.new(0, 8)
rollCorner.Parent = rollButton

-- ── State ─────────────────────────────────────────────────────────────────────

local lastInventoryCount = 0

-- ── Events ────────────────────────────────────────────────────────────────────

local rollDebounce = false

rollButton.MouseButton1Click:Connect(function()
	if rollDebounce then return end
	rollDebounce = true
	task.delay(0.5, function() rollDebounce = false end)

	resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	resultLabel.Text = "Rolling…"
	RollWeaponEvent:FireServer()
end)

UpdateInventoryEvent.OnClientEvent:Connect(function(inventory: { any }, _equippedWeapon: any?)
	local count = #inventory
	if count > lastInventoryCount then
		local newest = inventory[count]
		local rarityData = RarityConfig.ByName[newest.rarity]
		local color = rarityData and rarityData.color or Color3.fromRGB(255, 255, 255)
		resultLabel.TextColor3 = color
		resultLabel.Text = string.format(
			"[%s]  %s\n%s",
			newest.rarity, newest.name, newest.description
		)
	elseif count == lastInventoryCount then
		-- Roll failed (insufficient coins)
		resultLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		resultLabel.Text = "Not enough coins! (need 50 🪙)"
	end
	lastInventoryCount = count
end)

-- Highlight panel when near a RollStation
EnterZoneEvent.OnClientEvent:Connect(function(zoneName: string, entering: boolean)
	if zoneName ~= "RollStation" then return end
	TweenService:Create(panel, TweenInfo.new(0.3), {
		BackgroundColor3 = entering
			and Color3.fromRGB(35, 35, 65)
			or  Color3.fromRGB(22, 22, 34),
	}):Play()
end)
