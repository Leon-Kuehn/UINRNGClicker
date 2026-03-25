-- RollUI.client.lua
-- Builds the Roll UI overlay inside the RollUI ScreenGui.
--
-- Panels created here:
--   • RollButton  – always visible; shows current roll cost.
--   • ResultPanel – briefly appears after a roll with weapon name, rarity, multiplier.
--   • InventoryPanel – scrollable list of recently obtained weapons.
--   • NotificationBar – fades in/out for lucky rolls ("You got a Legendary!").

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[RollUI] LocalPlayer not available.")
	return
end

local screenGui = script.Parent
if not screenGui then
	warn("[RollUI] No parent ScreenGui.")
	return
end

-- ===== Events =====
local eventsFolder     = ReplicatedStorage:WaitForChild("Events")
local rollRequestEvent = eventsFolder:WaitForChild("RollRequest")
local rollResultEvent  = eventsFolder:WaitForChild("RollResult")

-- ===== Constants =====
local RESULT_DISPLAY_TIME = 3.5   -- seconds the result card stays visible
local LUCKY_RARITIES = { Legendary = true, Mythic = true }

-- ===== Rarity colours =====
local RARITY_COLORS: { [string]: Color3 } = {
	Common    = Color3.fromRGB(200, 200, 200),
	Uncommon  = Color3.fromRGB(96,  230, 96),
	Rare      = Color3.fromRGB(100, 160, 255),
	Epic      = Color3.fromRGB(210, 120, 255),
	Legendary = Color3.fromRGB(255, 210, 30),
	Mythic    = Color3.fromRGB(255, 100, 80),
}

local RARITY_BG: { [string]: Color3 } = {
	Common    = Color3.fromRGB(50,  50,  50),
	Uncommon  = Color3.fromRGB(26,  60,  26),
	Rare      = Color3.fromRGB(20,  35,  75),
	Epic      = Color3.fromRGB(50,  18,  70),
	Legendary = Color3.fromRGB(70,  50,   5),
	Mythic    = Color3.fromRGB(75,  15,  15),
}

-- ===== UI helper =====
local function makeCorner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function makeStroke(parent: Instance, color: Color3, thickness: number?)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1.5
	s.Parent = parent
	return s
end

-- ===== Roll Button Panel =====

local rollPanel = Instance.new("Frame")
rollPanel.Name                = "RollPanel"
rollPanel.AnchorPoint         = Vector2.new(1, 0)
rollPanel.Position            = UDim2.fromScale(0.98, 0.06)
rollPanel.Size                = UDim2.fromOffset(220, 80)
rollPanel.BackgroundColor3    = Color3.fromRGB(20, 28, 40)
rollPanel.BackgroundTransparency = 0.15
rollPanel.BorderSizePixel     = 0
rollPanel.ZIndex               = 5
rollPanel.Parent              = screenGui
makeCorner(rollPanel, 12)
makeStroke(rollPanel, Color3.fromRGB(84, 157, 233))

do
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 55, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 30, 44)),
	})
	g.Rotation = 90
	g.Parent = rollPanel
end

-- Cost label ("100 Coins")
local costLabel = Instance.new("TextLabel")
costLabel.Name                = "CostLabel"
costLabel.BackgroundTransparency = 1
costLabel.Position            = UDim2.fromScale(0.05, 0.04)
costLabel.Size                = UDim2.fromScale(0.9, 0.28)
costLabel.Text                = "100 Coins per Roll"
costLabel.TextScaled          = true
costLabel.Font                = Enum.Font.Gotham
costLabel.TextColor3          = Color3.fromRGB(160, 190, 220)
costLabel.ZIndex               = 6
costLabel.Parent              = rollPanel

-- Roll button
local rollButton = Instance.new("TextButton")
rollButton.Name               = "RollButton"
rollButton.Position           = UDim2.fromScale(0.05, 0.38)
rollButton.Size               = UDim2.fromScale(0.9, 0.52)
rollButton.BackgroundColor3   = Color3.fromRGB(58, 108, 210)
rollButton.Text               = "🎲  Roll"
rollButton.TextColor3         = Color3.fromRGB(240, 248, 255)
rollButton.TextScaled         = true
rollButton.Font               = Enum.Font.GothamBold
rollButton.ZIndex              = 6
rollButton.Parent             = rollPanel
makeCorner(rollButton, 8)

-- ===== Result Card =====

local resultCard = Instance.new("Frame")
resultCard.Name                = "ResultCard"
resultCard.AnchorPoint         = Vector2.new(0.5, 0)
resultCard.Position            = UDim2.fromScale(0.5, 0.12)
resultCard.Size                = UDim2.fromOffset(300, 130)
resultCard.BackgroundColor3    = Color3.fromRGB(20, 28, 40)
resultCard.BackgroundTransparency = 1   -- hidden by default
resultCard.BorderSizePixel     = 0
resultCard.ZIndex               = 8
resultCard.Visible             = false
resultCard.Parent              = screenGui
makeCorner(resultCard, 14)

local rcStroke = makeStroke(resultCard, Color3.fromRGB(84, 157, 233), 2)

do
	local bg = Instance.new("UIGradient")
	bg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 50, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 28, 44)),
	})
	bg.Rotation = 90
	bg.Parent = resultCard
end

local rcTopLabel = Instance.new("TextLabel")
rcTopLabel.Name                = "TopLabel"
rcTopLabel.BackgroundTransparency = 1
rcTopLabel.Position            = UDim2.fromScale(0.05, 0.04)
rcTopLabel.Size                = UDim2.fromScale(0.9, 0.2)
rcTopLabel.Text                = "You rolled..."
rcTopLabel.TextScaled          = true
rcTopLabel.Font                = Enum.Font.Gotham
rcTopLabel.TextColor3          = Color3.fromRGB(160, 190, 220)
rcTopLabel.ZIndex               = 9
rcTopLabel.Parent              = resultCard

local rcName = Instance.new("TextLabel")
rcName.Name                    = "WeaponName"
rcName.BackgroundTransparency  = 1
rcName.Position                = UDim2.fromScale(0.05, 0.26)
rcName.Size                    = UDim2.fromScale(0.9, 0.32)
rcName.Text                    = "Rusty Dagger"
rcName.TextScaled              = true
rcName.Font                    = Enum.Font.GothamBold
rcName.TextColor3              = Color3.fromRGB(200, 200, 200)
rcName.ZIndex                  = 9
rcName.Parent                  = resultCard

local rcRarity = Instance.new("TextLabel")
rcRarity.Name                  = "RarityLabel"
rcRarity.BackgroundTransparency = 1
rcRarity.Position              = UDim2.fromScale(0.05, 0.6)
rcRarity.Size                  = UDim2.fromScale(0.55, 0.3)
rcRarity.Text                  = "Common"
rcRarity.TextScaled            = true
rcRarity.Font                  = Enum.Font.GothamBold
rcRarity.TextColor3            = Color3.fromRGB(200, 200, 200)
rcRarity.TextXAlignment        = Enum.TextXAlignment.Left
rcRarity.ZIndex                = 9
rcRarity.Parent                = resultCard

local rcMult = Instance.new("TextLabel")
rcMult.Name                    = "MultLabel"
rcMult.BackgroundTransparency  = 1
rcMult.Position                = UDim2.fromScale(0.6, 0.6)
rcMult.Size                    = UDim2.fromScale(0.38, 0.3)
rcMult.Text                    = "x1.0"
rcMult.TextScaled              = true
rcMult.Font                    = Enum.Font.GothamBold
rcMult.TextColor3              = Color3.fromRGB(255, 210, 50)
rcMult.TextXAlignment          = Enum.TextXAlignment.Right
rcMult.ZIndex                  = 9
rcMult.Parent                  = resultCard

-- ===== Notification Bar =====

local notifBar = Instance.new("TextLabel")
notifBar.Name                  = "NotifBar"
notifBar.AnchorPoint           = Vector2.new(0.5, 0)
notifBar.Position              = UDim2.fromScale(0.5, 0.01)
notifBar.Size                  = UDim2.fromOffset(420, 42)
notifBar.BackgroundColor3      = Color3.fromRGB(20, 28, 40)
notifBar.BackgroundTransparency = 1
notifBar.Text                  = ""
notifBar.TextScaled            = true
notifBar.Font                  = Enum.Font.GothamBold
notifBar.TextColor3            = Color3.fromRGB(255, 210, 30)
notifBar.ZIndex                = 10
notifBar.Visible               = false
notifBar.Parent                = screenGui
makeCorner(notifBar, 8)
makeStroke(notifBar, Color3.fromRGB(255, 210, 30), 1.5)

-- ===== Inventory Panel =====

local invPanel = Instance.new("Frame")
invPanel.Name                  = "InventoryPanel"
invPanel.AnchorPoint           = Vector2.new(1, 1)
invPanel.Position              = UDim2.fromScale(0.98, 0.94)
invPanel.Size                  = UDim2.fromOffset(220, 200)
invPanel.BackgroundColor3      = Color3.fromRGB(18, 25, 38)
invPanel.BackgroundTransparency = 0.15
invPanel.BorderSizePixel       = 0
invPanel.ZIndex                = 5
invPanel.Parent                = screenGui
makeCorner(invPanel, 10)
makeStroke(invPanel, Color3.fromRGB(66, 100, 160))

local invTitle = Instance.new("TextLabel")
invTitle.Name                  = "Title"
invTitle.BackgroundColor3      = Color3.fromRGB(30, 45, 68)
invTitle.BackgroundTransparency = 0
invTitle.Position              = UDim2.fromScale(0, 0)
invTitle.Size                  = UDim2.fromScale(1, 0.15)
invTitle.Text                  = "Recent Weapons"
invTitle.TextScaled            = true
invTitle.Font                  = Enum.Font.GothamBold
invTitle.TextColor3            = Color3.fromRGB(200, 220, 255)
invTitle.BorderSizePixel       = 0
invTitle.ZIndex                = 6
invTitle.Parent                = invPanel
makeCorner(invTitle, 10)

local invScroll = Instance.new("ScrollingFrame")
invScroll.Name                 = "Scroll"
invScroll.Position             = UDim2.fromScale(0, 0.16)
invScroll.Size                 = UDim2.fromScale(1, 0.84)
invScroll.BackgroundTransparency = 1
invScroll.BorderSizePixel      = 0
invScroll.ScrollBarThickness   = 4
invScroll.CanvasSize           = UDim2.fromOffset(0, 0)
invScroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
invScroll.ZIndex               = 6
invScroll.Parent               = invPanel

local invLayout = Instance.new("UIListLayout")
invLayout.Padding              = UDim.new(0, 4)
invLayout.SortOrder            = Enum.SortOrder.LayoutOrder
invLayout.Parent               = invScroll

local invPadding = Instance.new("UIPadding")
invPadding.PaddingLeft         = UDim.new(0, 6)
invPadding.PaddingRight        = UDim.new(0, 6)
invPadding.PaddingTop          = UDim.new(0, 4)
invPadding.Parent              = invScroll

local recentWeapons: { { name: string, rarity: string, mult: number } } = {}
local MAX_SHOWN = 10

-- ===== Show / hide result card =====

local resultHideTask: thread? = nil

local function showResultCard(weaponName: string, rarity: string, multiplier: number)
	local color  = RARITY_COLORS[rarity] or Color3.fromRGB(200, 200, 200)
	local bgColor = RARITY_BG[rarity]   or Color3.fromRGB(30, 30, 30)

	rcName.Text        = weaponName
	rcName.TextColor3  = color
	rcRarity.Text      = rarity
	rcRarity.TextColor3 = color
	rcMult.Text        = string.format("x%.1f", multiplier)
	rcStroke.Color     = color
	resultCard.BackgroundColor3 = bgColor

	resultCard.BackgroundTransparency = 1
	resultCard.Visible = true

	TweenService:Create(
		resultCard,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.1 }
	):Play()

	-- Auto-hide
	if resultHideTask then
		task.cancel(resultHideTask)
	end
	resultHideTask = task.delay(RESULT_DISPLAY_TIME, function()
		TweenService:Create(
			resultCard,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		):Play()
		task.wait(0.4)
		resultCard.Visible = false
	end)
end

-- ===== Show lucky notification =====

local notifHideTask: thread? = nil

local function showNotification(text: string, color: Color3)
	notifBar.Text = text
	notifBar.TextColor3 = color
	notifBar.BackgroundTransparency = 0.15
	notifBar.Visible = true

	TweenService:Create(
		notifBar,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.15 }
	):Play()

	if notifHideTask then
		task.cancel(notifHideTask)
	end
	notifHideTask = task.delay(3, function()
		TweenService:Create(
			notifBar,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		):Play()
		task.wait(0.5)
		notifBar.Visible = false
	end)
end

-- ===== Add row to inventory panel =====

local function addInventoryRow(weaponName: string, rarity: string, multiplier: number)
	local color = RARITY_COLORS[rarity] or Color3.fromRGB(200, 200, 200)

	local row = Instance.new("Frame")
	row.Name                  = "Row_" .. weaponName
	row.Size                  = UDim2.new(1, 0, 0, 28)
	row.BackgroundColor3      = RARITY_BG[rarity] or Color3.fromRGB(30, 30, 30)
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel       = 0
	row.LayoutOrder           = -os.clock()   -- newest rows sort to the top
	row.ZIndex                = 7
	row.Parent                = invScroll
	makeCorner(row, 5)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position   = UDim2.fromScale(0.03, 0)
	nameLabel.Size       = UDim2.fromScale(0.7, 1)
	nameLabel.Text       = weaponName
	nameLabel.TextScaled = true
	nameLabel.Font       = Enum.Font.GothamBold
	nameLabel.TextColor3 = color
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex     = 8
	nameLabel.Parent     = row

	local multLabel = Instance.new("TextLabel")
	multLabel.BackgroundTransparency = 1
	multLabel.Position   = UDim2.fromScale(0.72, 0)
	multLabel.Size       = UDim2.fromScale(0.26, 1)
	multLabel.Text       = string.format("x%.1f", multiplier)
	multLabel.TextScaled = true
	multLabel.Font       = Enum.Font.GothamBold
	multLabel.TextColor3 = Color3.fromRGB(255, 210, 50)
	multLabel.TextXAlignment = Enum.TextXAlignment.Right
	multLabel.ZIndex     = 8
	multLabel.Parent     = row

	-- Trim if too many rows
	local rows = invScroll:GetChildren()
	local frameRows = {}
	for _, c in rows do
		if c:IsA("Frame") then
			table.insert(frameRows, c)
		end
	end
	if #frameRows > MAX_SHOWN then
		table.sort(frameRows, function(a, b)
			return a.LayoutOrder > b.LayoutOrder  -- oldest = largest negative = destroy first
		end)
		frameRows[#frameRows]:Destroy()
	end
end

-- ===== Button press animation =====

local isRolling = false

rollButton.MouseButton1Down:Connect(function()
	TweenService:Create(
		rollButton,
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.fromScale(0.86, 0.48) }
	):Play()
end)

rollButton.MouseButton1Up:Connect(function()
	TweenService:Create(
		rollButton,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.fromScale(0.9, 0.52) }
	):Play()
end)

rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end
	isRolling = true
	rollButton.Text = "Rolling..."
	rollButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
	rollRequestEvent:FireServer()
end)

-- ===== Roll result handler =====

rollResultEvent.OnClientEvent:Connect(function(
	success: boolean,
	rollCost: number,
	weaponName: string?,
	rarity: string?,
	multiplier: number?,
	_description: string?
)
	isRolling = false
	rollButton.Text = "🎲  Roll"
	rollButton.BackgroundColor3 = Color3.fromRGB(58, 108, 210)

	-- Update cost label with the next roll cost (server already deducted; this
	-- is a best-effort display. The accurate cost will be recalculated next roll.)
	costLabel.Text = string.format("%d Coins per Roll", rollCost)

	if not success then
		-- Not enough coins: brief red flash on the button
		rollButton.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
		task.delay(0.6, function()
			rollButton.BackgroundColor3 = Color3.fromRGB(58, 108, 210)
		end)
		return
	end

	if not weaponName or not rarity or not multiplier then return end

	showResultCard(weaponName, rarity, multiplier)
	addInventoryRow(weaponName, rarity, multiplier)

	if LUCKY_RARITIES[rarity] then
		local color = RARITY_COLORS[rarity] or Color3.fromRGB(255, 210, 30)
		showNotification(string.format("✨  You got a %s weapon! — %s", rarity, weaponName), color)
	end
end)
