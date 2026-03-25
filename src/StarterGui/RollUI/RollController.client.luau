--!strict
-- RollController.client.luau
-- Right-side panel for rolling new weapons.
--   • Displays each rarity's name, colour, and drop chance.
--   • ROLL button fires RollWeapon to the server (cost increases per roll).
--   • Shows the rolled weapon name/rarity/description after each roll.
--   • Highlights the panel border when the player enters a RollStation zone.
-- All UI is created in code.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local FormatUtils  = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FormatUtils"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RarityConfig"))
local RollConfig   = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RollConfig"))

local Events               = ReplicatedStorage:WaitForChild("Events")
local RollWeaponEvent      = Events:WaitForChild("RollWeapon")
local UpdateCurrencyEvent  = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")
local EnterZoneEvent       = Events:WaitForChild("EnterZone")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("RollUI")
local PANEL_ATTR = "OpenOverlayPanel"

local function getOpenOverlayPanel(): string
	local value = playerGui:GetAttribute(PANEL_ATTR)
	if type(value) == "string" then
		return value
	end
	return ""
end

local function setOpenOverlayPanel(value: string)
	playerGui:SetAttribute(PANEL_ATTR, value)
end

-- ── Panel ─────────────────────────────────────────────────────────────────────

local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.26, 0.60)
panel.Position = UDim2.fromScale(0.73, 0.20)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
panel.BackgroundTransparency = 0.10
panel.BorderSizePixel = 0
panel.Parent = screenGui

local OPEN_POS = UDim2.fromScale(0.73, 0.20)
local CLOSED_POS = UDim2.fromScale(1.01, 0.20)
panel.Position = CLOSED_POS

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local openRollButton = Instance.new("TextButton")
openRollButton.Name = "RollToggleButton"
openRollButton.Size = UDim2.fromScale(0.12, 0.06)
openRollButton.Position = UDim2.fromScale(0.94, 0.50)
openRollButton.AnchorPoint = Vector2.new(1, 0.5)
openRollButton.BackgroundColor3 = Color3.fromRGB(60, 80, 140)
openRollButton.BorderSizePixel = 0
openRollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openRollButton.Font = Enum.Font.GothamBold
openRollButton.TextScaled = true
openRollButton.Text = "ROLL"
openRollButton.Parent = screenGui

local openRollCorner = Instance.new("UICorner")
openRollCorner.CornerRadius = UDim.new(0, 8)
openRollCorner.Parent = openRollButton

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

local closeRollButton = Instance.new("TextButton")
closeRollButton.Size = UDim2.fromScale(0.045, 0.05)
closeRollButton.Position = UDim2.fromScale(0.952, 0.22)
closeRollButton.BackgroundColor3 = Color3.fromRGB(85, 55, 55)
closeRollButton.BorderSizePixel = 0
closeRollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeRollButton.Font = Enum.Font.GothamBold
closeRollButton.TextScaled = true
closeRollButton.Text = "X"
closeRollButton.Visible = false
closeRollButton.Parent = screenGui

local closeRollCorner = Instance.new("UICorner")
closeRollCorner.CornerRadius = UDim.new(0, 8)
closeRollCorner.Parent = closeRollButton

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

local resultScale = Instance.new("UIScale")
resultScale.Scale = 1
resultScale.Parent = resultLabel

-- ── Roll button ───────────────────────────────────────────────────────────────

local rollButton = Instance.new("TextButton")
rollButton.Size = UDim2.fromScale(1, 0)
rollButton.AutomaticSize = Enum.AutomaticSize.Y
rollButton.BackgroundColor3 = Color3.fromRGB(70, 170, 70)
rollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rollButton.Font = Enum.Font.GothamBold
rollButton.TextSize = 17
rollButton.Text = "ROLL"
rollButton.BorderSizePixel = 0
rollButton.LayoutOrder = 4
rollButton.Parent = panel

local rollCorner = Instance.new("UICorner")
rollCorner.CornerRadius = UDim.new(0, 8)
rollCorner.Parent = rollButton

-- ── State ─────────────────────────────────────────────────────────────────────

local lastInventoryCount = 0
local currentCoins = 0
local currentRollCost = RollConfig.getRollCost(0)
local rollAnimToken = 0
local rollPanelOpen = false

local function setRollPanelOpen(open: boolean)
	if rollPanelOpen == open then return end
	rollPanelOpen = open

	openRollButton.Visible = not open
	closeRollButton.Visible = open
	TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = open and OPEN_POS or CLOSED_POS,
	}):Play()
end

local function updateRollButtonText()
	rollButton.Text = string.format("ROLL  (%s 🪙)", FormatUtils.formatNumber(currentRollCost))
	if currentCoins >= currentRollCost then
		rollButton.BackgroundColor3 = Color3.fromRGB(70, 170, 70)
	else
		rollButton.BackgroundColor3 = Color3.fromRGB(150, 70, 70)
	end
end

updateRollButtonText()

-- ── Events ────────────────────────────────────────────────────────────────────

local rollDebounce = false

local function playResultReveal(color: Color3)
	resultLabel.TextColor3 = color
	resultScale.Scale = 0.88
	TweenService:Create(resultScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
end

local function startRollingTextAnimation(token: number)
	task.spawn(function()
		local rarityNames = {}
		for _, rarity in ipairs(RarityConfig.Rarities) do
			table.insert(rarityNames, rarity.name)
		end

		local startAt = os.clock()
		while rollAnimToken == token and os.clock() - startAt < 1.1 do
			local rarity = rarityNames[math.random(1, #rarityNames)]
			local suffix = string.rep(".", math.random(1, 3))
			resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			resultLabel.Text = string.format("Rolling %s%s", rarity, suffix)
			task.wait(0.08)
		end
	end)
end

rollButton.MouseButton1Click:Connect(function()
	if rollDebounce then return end
	if currentCoins < currentRollCost then
		resultLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		resultLabel.Text = string.format("Not enough coins! (need %s 🪙)", FormatUtils.formatNumber(currentRollCost))
		return
	end

	rollDebounce = true
	task.delay(0.5, function() rollDebounce = false end)
	rollAnimToken += 1

	resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	resultLabel.Text = "Rolling…"
	startRollingTextAnimation(rollAnimToken)
	RollWeaponEvent:FireServer()
end)

openRollButton.MouseButton1Click:Connect(function()
	if getOpenOverlayPanel() == "Roll" then
		setOpenOverlayPanel("")
	else
		setOpenOverlayPanel("Roll")
	end
end)

closeRollButton.MouseButton1Click:Connect(function()
	setOpenOverlayPanel("")
end)

UpdateCurrencyEvent.OnClientEvent:Connect(function(
	coins: number,
	_souls: number,
	_totalClicks: number,
	nextRollCost: number?,
	_soulsGained: number?,
	_critSouls: number?,
	_soulsCapacity: number?,
	_isFull: boolean?
)
	currentCoins = coins
	if nextRollCost ~= nil then
		currentRollCost = nextRollCost
	end
	updateRollButtonText()
end)

UpdateInventoryEvent.OnClientEvent:Connect(function(inventory: { any }, _equippedWeapon: any?)
	local count = #inventory
	if count > lastInventoryCount then
		rollAnimToken += 1
		local newest = inventory[count]
		local rarityData = RarityConfig.ByName[newest.rarity]
		local color = rarityData and rarityData.color or Color3.fromRGB(255, 255, 255)
		resultLabel.Text = string.format(
			"[%s]  %s\n%s",
			newest.rarity, newest.name, newest.description
		)
		playResultReveal(color)
	elseif count == lastInventoryCount then
		rollAnimToken += 1
		-- Roll failed (insufficient coins)
		resultLabel.Text = string.format("Not enough coins! (need %s 🪙)", FormatUtils.formatNumber(currentRollCost))
		playResultReveal(Color3.fromRGB(255, 80, 80))
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

playerGui:GetAttributeChangedSignal(PANEL_ATTR):Connect(function()
	setRollPanelOpen(getOpenOverlayPanel() == "Roll")
end)

setRollPanelOpen(getOpenOverlayPanel() == "Roll")
