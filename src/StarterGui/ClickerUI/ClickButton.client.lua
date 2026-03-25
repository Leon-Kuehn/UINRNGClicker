local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PLAYER_CLICK_EVENT_NAME = "PlayerClick"
local CLICK_BUTTON_NAME = "ClickButton"

local localPlayer = Players.LocalPlayer
local playerClickEvent = ReplicatedStorage:FindFirstChild(PLAYER_CLICK_EVENT_NAME)

if not playerClickEvent or not playerClickEvent:IsA("RemoteEvent") then
	warn("[ClickButton] RemoteEvent '" .. PLAYER_CLICK_EVENT_NAME .. "' not found in ReplicatedStorage.")
	return
end

local screenGui = script.Parent
if not screenGui then
	warn("[ClickButton] Script has no parent ScreenGui.")
	return
end

local clickButton = screenGui:FindFirstChild(CLICK_BUTTON_NAME)
if not clickButton or not clickButton:IsA("TextButton") then
	warn("[ClickButton] TextButton '" .. CLICK_BUTTON_NAME .. "' not found under ClickerUI.")
	return
end

local originalSize = clickButton.Size
local shrinkSize = UDim2.new(
	originalSize.X.Scale * 0.93,
	math.floor(originalSize.X.Offset * 0.93),
	originalSize.Y.Scale * 0.93,
	math.floor(originalSize.Y.Offset * 0.93)
)

local shrinkTweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local expandTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function animateButtonPress()
	local shrinkTween = TweenService:Create(clickButton, shrinkTweenInfo, { Size = shrinkSize })
	local expandTween = TweenService:Create(clickButton, expandTweenInfo, { Size = originalSize })

	shrinkTween:Play()
	shrinkTween.Completed:Once(function()
		expandTween:Play()
	end)
end

local function spawnFloatingGainText(gain)
	if type(gain) ~= "number" then
		gain = 0
	end

	local floatingLabel = Instance.new("TextLabel")
	floatingLabel.Name = "FloatingGain"
	floatingLabel.BackgroundTransparency = 1
	floatingLabel.BorderSizePixel = 0
	floatingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	floatingLabel.Size = UDim2.new(0, 120, 0, 36)
	floatingLabel.Position = UDim2.new(0.5, 0, 0.5, -12)
	floatingLabel.Text = string.format("+%d", gain)
	floatingLabel.TextScaled = true
	floatingLabel.Font = Enum.Font.GothamBold
	floatingLabel.TextColor3 = Color3.fromRGB(255, 245, 140)
	floatingLabel.TextStrokeTransparency = 0.5
	floatingLabel.ZIndex = clickButton.ZIndex + 1
	floatingLabel.Parent = clickButton

	local riseTween = TweenService:Create(
		floatingLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = UDim2.new(0.5, 0, 0.15, 0),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)

	riseTween:Play()
	riseTween.Completed:Once(function()
		floatingLabel:Destroy()
	end)
end

clickButton.MouseButton1Click:Connect(function()
	animateButtonPress()
	playerClickEvent:FireServer()
end)

playerClickEvent.OnClientEvent:Connect(function(gain)
	if not localPlayer then
		return
	end

	spawnFloatingGainText(gain)
end)
