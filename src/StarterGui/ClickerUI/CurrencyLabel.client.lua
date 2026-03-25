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

local currencyLabel = screenGui:FindFirstChild(CURRENCY_LABEL_NAME)
if not currencyLabel or not currencyLabel:IsA("TextLabel") then
	warn("[CurrencyLabel] TextLabel '" .. CURRENCY_LABEL_NAME .. "' not found under ClickerUI.")
	return
end

currencyLabel.AnchorPoint = Vector2.new(0.5, 0)
currencyLabel.Position = UDim2.fromScale(0.5, 0.06)
currencyLabel.Size = UDim2.fromOffset(400, 68)
currencyLabel.BackgroundTransparency = 1
currencyLabel.TextColor3 = Color3.fromRGB(240, 248, 255)
currencyLabel.TextStrokeTransparency = 0.45
currencyLabel.TextScaled = true
currencyLabel.Font = Enum.Font.GothamBold

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
local gainColor = Color3.fromRGB(255, 236, 164)

local function updateCurrencyText(newValue: number)
	currencyLabel.Text = string.format("Currency: %d", newValue)
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
