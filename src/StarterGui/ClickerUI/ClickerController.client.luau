--!strict
-- ClickerController.client.luau
-- Builds and manages the main click interface:
--   • Currency bar (top-centre)
--   • Round TAP button (centre)
--   • Equipped weapon label (bottom-left)
--   • Floating "+N CRIT!" feedback on critical hits
-- All UI is created in code; no UI objects are needed in the project file.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local FormatUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FormatUtils"))

local Events              = ReplicatedStorage:WaitForChild("Events")
local PlayerClickEvent    = Events:WaitForChild("PlayerClick")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ClickerUI")

-- ── Constants ─────────────────────────────────────────────────────────────────

local BTN_SIZE_NORMAL = UDim2.fromScale(0.22, 0.22)
local BTN_SIZE_PRESS  = UDim2.fromScale(0.19, 0.19)

-- ── Currency bar ──────────────────────────────────────────────────────────────

local currencyBar = Instance.new("Frame")
currencyBar.Size = UDim2.fromScale(0.40, 0.07)
currencyBar.Position = UDim2.fromScale(0.30, 0.02)
currencyBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
currencyBar.BackgroundTransparency = 0.25
currencyBar.BorderSizePixel = 0
currencyBar.Parent = screenGui

local _cb_corner = Instance.new("UICorner")
_cb_corner.CornerRadius = UDim.new(0, 12)
_cb_corner.Parent = currencyBar

local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.fromScale(1, 1)
coinLabel.BackgroundTransparency = 1
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.Font = Enum.Font.GothamBold
coinLabel.TextScaled = true
coinLabel.Text = "🪙  0"
coinLabel.Parent = currencyBar

-- ── Click button ──────────────────────────────────────────────────────────────

local clickButton = Instance.new("TextButton")
clickButton.Size = BTN_SIZE_NORMAL
clickButton.Position = UDim2.fromScale(0.50, 0.60)
clickButton.AnchorPoint = Vector2.new(0.5, 0.5)
clickButton.BackgroundColor3 = Color3.fromRGB(255, 80, 50)
clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButton.Font = Enum.Font.GothamBold
clickButton.TextScaled = true
clickButton.Text = "TAP!"
clickButton.BorderSizePixel = 0
clickButton.Parent = screenGui

local _btn_corner = Instance.new("UICorner")
_btn_corner.CornerRadius = UDim.new(1, 0)
_btn_corner.Parent = clickButton

-- ── Equipped weapon label ─────────────────────────────────────────────────────

local equippedLabel = Instance.new("TextLabel")
equippedLabel.Size = UDim2.fromScale(0.32, 0.06)
equippedLabel.Position = UDim2.fromScale(0.01, 0.92)
equippedLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
equippedLabel.BackgroundTransparency = 0.30
equippedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
equippedLabel.Font = Enum.Font.Gotham
equippedLabel.TextScaled = true
equippedLabel.Text = "No weapon equipped"
equippedLabel.BorderSizePixel = 0
equippedLabel.Parent = screenGui

local _eq_corner = Instance.new("UICorner")
_eq_corner.CornerRadius = UDim.new(0, 8)
_eq_corner.Parent = equippedLabel

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function spawnFloatingText(text: string, color: Color3)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.14, 0.07)
	label.Position = UDim2.fromScale(0.43, 0.48)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.ZIndex = 10
	label.Parent = screenGui

	TweenService:Create(label, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.43, 0.30),
		TextTransparency = 1,
	}):Play()
	task.delay(0.95, function() label:Destroy() end)
end

-- ── Click logic ───────────────────────────────────────────────────────────────

local debounce = false

local function onTap()
	if debounce then return end
	debounce = true
	task.delay(0.08, function() debounce = false end)

	-- Press animation
	TweenService:Create(clickButton, TweenInfo.new(0.05), { Size = BTN_SIZE_PRESS }):Play()
	task.delay(0.05, function()
		TweenService:Create(clickButton, TweenInfo.new(0.08), { Size = BTN_SIZE_NORMAL }):Play()
	end)

	PlayerClickEvent:FireServer()
end

clickButton.MouseButton1Click:Connect(onTap)
clickButton.TouchTap:Connect(onTap)

-- ── Server events ─────────────────────────────────────────────────────────────

UpdateCurrencyEvent.OnClientEvent:Connect(function(coins: number, critAmount: number?)
	coinLabel.Text = "🪙  " .. FormatUtils.formatNumber(coins)
	if critAmount then
		spawnFloatingText("CRIT! +" .. FormatUtils.formatNumber(critAmount), Color3.fromRGB(255, 200, 0))
	end
end)

UpdateInventoryEvent.OnClientEvent:Connect(function(_inventory: { any }, equippedWeapon: any?)
	if equippedWeapon then
		equippedLabel.Text = string.format("[%s] %s", equippedWeapon.rarity, equippedWeapon.name)
	else
		equippedLabel.Text = "No weapon equipped"
	end
end)
