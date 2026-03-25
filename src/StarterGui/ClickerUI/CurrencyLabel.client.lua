local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local CURRENCY_LABEL_NAME = "CurrencyLabel"
local CURRENCY_STAT_NAME = "Currency"

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[CurrencyLabel] LocalPlayer is not available.")
	return
end

local screenGui = script.Parent
if not screenGui then
	warn("[CurrencyLabel] Script has no parent ScreenGui.")
	return
end

local function formatCompact(value: number): string
	local absValue = math.abs(value)
	if absValue >= 1e12 then
		return string.format("%.2fT", value / 1e12)
	elseif absValue >= 1e9 then
		return string.format("%.2fB", value / 1e9)
	elseif absValue >= 1e6 then
		return string.format("%.2fM", value / 1e6)
	elseif absValue >= 1e3 then
		return string.format("%.2fK", value / 1e3)
	end

	return string.format("%d", math.floor(value))
end

local currencyLabel = screenGui:FindFirstChild(CURRENCY_LABEL_NAME)
if not currencyLabel or not currencyLabel:IsA("TextLabel") then
	warn("[CurrencyLabel] TextLabel '" .. CURRENCY_LABEL_NAME .. "' not found under ClickerUI.")
	return
end

currencyLabel.AnchorPoint = Vector2.new(0, 0)
currencyLabel.Position = UDim2.fromScale(0.02, 0.06)
currencyLabel.Size = UDim2.fromOffset(330, 56)
currencyLabel.BackgroundTransparency = 0.2
currencyLabel.BackgroundColor3 = Color3.fromRGB(22, 34, 49)
currencyLabel.BorderSizePixel = 0
currencyLabel.TextColor3 = Color3.fromRGB(240, 248, 255)
currencyLabel.TextStrokeTransparency = 0.7
currencyLabel.TextScaled = true
currencyLabel.Font = Enum.Font.GothamBlack

local corner = currencyLabel:FindFirstChild("CurrencyCorner")
if not corner then
	corner = Instance.new("UICorner")
	corner.Name = "CurrencyCorner"
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = currencyLabel
end

local stroke = currencyLabel:FindFirstChild("CurrencyStroke")
if not stroke then
	stroke = Instance.new("UIStroke")
	stroke.Name = "CurrencyStroke"
	stroke.Thickness = 1.5
	stroke.Color = Color3.fromRGB(84, 157, 233)
	stroke.Parent = currencyLabel
end

local gradient = currencyLabel:FindFirstChild("CurrencyGradient")
if not gradient then
	gradient = Instance.new("UIGradient")
	gradient.Name = "CurrencyGradient"
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 58, 82)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(23, 35, 50)),
	})
	gradient.Rotation = 90
	gradient.Parent = currencyLabel
end

local leaderstats = localPlayer:WaitForChild("leaderstats", 10)
if not leaderstats then
	warn("[CurrencyLabel] leaderstats not found for local player.")
	return
end

local currencyValue = leaderstats:WaitForChild(CURRENCY_STAT_NAME, 10)
if not currencyValue or not currencyValue:IsA("IntValue") then
	warn("[CurrencyLabel] IntValue '" .. CURRENCY_STAT_NAME .. "' not found in leaderstats.")
	return
end

local lastSeenValue = currencyValue.Value
local normalColor = Color3.fromRGB(240, 248, 255)
local gainColor = Color3.fromRGB(255, 239, 169)

local function updateCurrencyText(newValue: number)
	currencyLabel.Text = string.format("$ %s", formatCompact(newValue))
end

local function playGainFlash()
	local flashIn = TweenService:Create(
		currencyLabel,
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ TextColor3 = gainColor }
	)
	local flashOut = TweenService:Create(
		currencyLabel,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ TextColor3 = normalColor }
	)

	flashIn:Play()
	flashIn.Completed:Once(function()
		flashOut:Play()
	end)
end

updateCurrencyText(currencyValue.Value)

currencyValue:GetPropertyChangedSignal("Value"):Connect(function()
	local newValue = currencyValue.Value
	updateCurrencyText(newValue)

	if newValue > lastSeenValue then
		playGainFlash()
	end

	lastSeenValue = newValue
end)
