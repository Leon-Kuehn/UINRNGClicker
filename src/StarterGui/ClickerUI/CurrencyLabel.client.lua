local Players = game:GetService("Players")

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

local function updateCurrencyText()
	currencyLabel.Text = string.format("Currency: %d", currencyValue.Value)
end

updateCurrencyText()
currencyValue:GetPropertyChangedSignal("Value"):Connect(updateCurrencyText)
