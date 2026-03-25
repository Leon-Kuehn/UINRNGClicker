-- ClickerUI.client.lua
-- Adds a weapon information panel to the ClickerUI ScreenGui.
-- Listens to Events/WeaponEquipped and updates the display whenever
-- the player equips a new weapon.
-- Also watches the local WeaponData folder for real-time property changes.

local Players       = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService  = game:GetService("TweenService")

-- Delay before trying to read WeaponData children after the folder has been
-- detected; gives the server time to replicate all child Value instances.
local REPLICATION_WAIT_DELAY = 0.1

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[ClickerUI] LocalPlayer not available.")
	return
end

local screenGui = script.Parent
if not screenGui then
	warn("[ClickerUI] No parent ScreenGui.")
	return
end

-- ===== Events =====
local eventsFolder        = ReplicatedStorage:WaitForChild("Events")
local weaponEquippedEvent = eventsFolder:WaitForChild("WeaponEquipped")

-- ===== Rarity colours (mirrors RarityConfig.lua) =====
local RARITY_COLORS: { [string]: Color3 } = {
	Common    = Color3.fromRGB(200, 200, 200),
	Uncommon  = Color3.fromRGB(96,  230, 96),
	Rare      = Color3.fromRGB(100, 160, 255),
	Epic      = Color3.fromRGB(210, 120, 255),
	Legendary = Color3.fromRGB(255, 210, 30),
	Mythic    = Color3.fromRGB(255, 100, 80),
}

-- ===== Build the Weapon Info Panel =====

local weaponPanel = Instance.new("Frame")
weaponPanel.Name                = "WeaponPanel"
weaponPanel.AnchorPoint         = Vector2.new(0, 0)
weaponPanel.Position            = UDim2.fromScale(0.02, 0.17)
weaponPanel.Size                = UDim2.fromOffset(280, 88)
weaponPanel.BackgroundColor3    = Color3.fromRGB(22, 34, 49)
weaponPanel.BackgroundTransparency = 0.2
weaponPanel.BorderSizePixel     = 0
weaponPanel.ZIndex               = 5
weaponPanel.Parent              = screenGui

local wpCorner = Instance.new("UICorner")
wpCorner.CornerRadius = UDim.new(0, 10)
wpCorner.Parent = weaponPanel

local wpStroke = Instance.new("UIStroke")
wpStroke.Thickness = 1.5
wpStroke.Color = Color3.fromRGB(84, 157, 233)
wpStroke.Parent = weaponPanel

do
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 58, 82)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(23, 35, 50)),
	})
	g.Rotation = 90
	g.Parent = weaponPanel
end

-- Sword icon
local wpIcon = Instance.new("TextLabel")
wpIcon.Name                = "Icon"
wpIcon.BackgroundTransparency = 1
wpIcon.Position            = UDim2.fromScale(0.03, 0.08)
wpIcon.Size                = UDim2.fromOffset(28, 28)
wpIcon.Text                = "⚔"
wpIcon.TextScaled          = true
wpIcon.Font                = Enum.Font.GothamBold
wpIcon.TextColor3          = Color3.fromRGB(240, 248, 255)
wpIcon.ZIndex              = 6
wpIcon.Parent              = weaponPanel

-- Small caption
local wpTitle = Instance.new("TextLabel")
wpTitle.Name                = "Title"
wpTitle.BackgroundTransparency = 1
wpTitle.Position            = UDim2.fromScale(0.14, 0.04)
wpTitle.Size                = UDim2.fromScale(0.84, 0.24)
wpTitle.Text                = "Equipped Weapon"
wpTitle.TextScaled          = true
wpTitle.Font                = Enum.Font.Gotham
wpTitle.TextColor3          = Color3.fromRGB(160, 190, 220)
wpTitle.TextXAlignment      = Enum.TextXAlignment.Left
wpTitle.ZIndex              = 6
wpTitle.Parent              = weaponPanel

-- Weapon name (large, rarity-coloured)
local wpName = Instance.new("TextLabel")
wpName.Name                = "WeaponName"
wpName.BackgroundTransparency = 1
wpName.Position            = UDim2.fromScale(0.05, 0.32)
wpName.Size                = UDim2.fromScale(0.9, 0.3)
wpName.Text                = "Rusty Dagger"
wpName.TextScaled          = true
wpName.Font                = Enum.Font.GothamBold
wpName.TextColor3          = Color3.fromRGB(200, 200, 200)
wpName.TextXAlignment      = Enum.TextXAlignment.Left
wpName.ZIndex              = 6
wpName.Parent              = weaponPanel

-- Rarity label (left-aligned, bottom row)
local wpRarity = Instance.new("TextLabel")
wpRarity.Name                = "WeaponRarity"
wpRarity.BackgroundTransparency = 1
wpRarity.Position            = UDim2.fromScale(0.05, 0.66)
wpRarity.Size                = UDim2.fromScale(0.55, 0.28)
wpRarity.Text                = "Common"
wpRarity.TextScaled          = true
wpRarity.Font                = Enum.Font.GothamBold
wpRarity.TextColor3          = Color3.fromRGB(200, 200, 200)
wpRarity.TextXAlignment      = Enum.TextXAlignment.Left
wpRarity.ZIndex              = 6
wpRarity.Parent              = weaponPanel

-- Multiplier label (right-aligned, bottom row)
local wpMult = Instance.new("TextLabel")
wpMult.Name                = "WeaponMult"
wpMult.BackgroundTransparency = 1
wpMult.Position            = UDim2.fromScale(0.6, 0.66)
wpMult.Size                = UDim2.fromScale(0.38, 0.28)
wpMult.Text                = "x1.0"
wpMult.TextScaled          = true
wpMult.Font                = Enum.Font.GothamBold
wpMult.TextColor3          = Color3.fromRGB(255, 210, 50)
wpMult.TextXAlignment      = Enum.TextXAlignment.Right
wpMult.ZIndex              = 6
wpMult.Parent              = weaponPanel

-- ===== Update function =====

local function updateWeaponDisplay(name: string, rarity: string, multiplier: number)
	wpName.Text   = name
	wpRarity.Text = rarity
	wpMult.Text   = string.format("x%.1f", multiplier)

	local color = RARITY_COLORS[rarity] or Color3.fromRGB(200, 200, 200)
	wpName.TextColor3   = color
	wpRarity.TextColor3 = color
	wpStroke.Color      = color

	-- Brief "flash" animation to signal a new weapon
	local flashIn = TweenService:Create(
		weaponPanel,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.0 }
	)
	flashIn:Play()
	flashIn.Completed:Once(function()
		TweenService:Create(
			weaponPanel,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.2 }
		):Play()
	end)
end

-- ===== Remote event listener =====

weaponEquippedEvent.OnClientEvent:Connect(function(
	name: string, rarity: string, multiplier: number, _description: string
)
	updateWeaponDisplay(name, rarity, multiplier)
end)

-- ===== Read initial weapon from player data =====
-- Weapon data may arrive before or after this script loads; handle both.

local function tryReadInitialWeapon(weaponData: Folder)
	local n = weaponData:FindFirstChild("WeaponName")
	local r = weaponData:FindFirstChild("Rarity")
	local m = weaponData:FindFirstChild("Multiplier")
	if n and r and m then
		updateWeaponDisplay(n.Value, r.Value, m.Value)
	end
end

local existingWD = localPlayer:FindFirstChild("WeaponData")
if existingWD then
	tryReadInitialWeapon(existingWD)

	-- Stay in sync if the weapon is swapped later via direct folder writes
	local nameObj = existingWD:FindFirstChild("WeaponName")
	if nameObj then
		nameObj:GetPropertyChangedSignal("Value"):Connect(function()
			local rObj = existingWD:FindFirstChild("Rarity")
			local mObj = existingWD:FindFirstChild("Multiplier")
			updateWeaponDisplay(
				nameObj.Value,
				rObj and rObj.Value or "Common",
				mObj and mObj.Value or 1.0
			)
		end)
	end
else
	-- WeaponData not yet replicated — wait for it
	localPlayer.ChildAdded:Connect(function(child)
		if child.Name == "WeaponData" then
			task.wait(REPLICATION_WAIT_DELAY)   -- allow children to replicate
			tryReadInitialWeapon(child)
		end
	end)
end
