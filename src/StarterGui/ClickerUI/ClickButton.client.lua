local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PLAYER_CLICK_EVENT_NAME = "PlayerClick"
local CLICK_BUTTON_NAME = "ClickButton"

local localPlayer = Players.LocalPlayer
local playerClickEvent = ReplicatedStorage:WaitForChild(PLAYER_CLICK_EVENT_NAME)

if not playerClickEvent:IsA("RemoteEvent") then
	warn("[ClickButton] ReplicatedStorage.PlayerClick is not a RemoteEvent.")
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

-- Runtime styling keeps the UI readable even if Studio defaults are plain.
clickButton.AnchorPoint = Vector2.new(0.5, 0.5)
clickButton.Position = UDim2.fromScale(0.5, 0.6)
clickButton.Size = UDim2.fromOffset(250, 250)
clickButton.AutoButtonColor = true
clickButton.Active = true
clickButton.BackgroundColor3 = Color3.fromRGB(38, 166, 91)
clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButton.TextStrokeTransparency = 0.7
clickButton.Font = Enum.Font.GothamBlack
clickButton.Text = "TAP!"
clickButton.TextScaled = true

local buttonCorner = clickButton:FindFirstChild("ButtonCorner")
if not buttonCorner then
	buttonCorner = Instance.new("UICorner")
	buttonCorner.Name = "ButtonCorner"
	buttonCorner.CornerRadius = UDim.new(1, 0)
	buttonCorner.Parent = clickButton
end

local buttonStroke = clickButton:FindFirstChild("ButtonStroke")
if not buttonStroke then
	buttonStroke = Instance.new("UIStroke")
	buttonStroke.Name = "ButtonStroke"
	buttonStroke.Thickness = 3
	buttonStroke.Color = Color3.fromRGB(210, 255, 220)
	buttonStroke.Parent = clickButton
end

local originalSize = clickButton.Size
local pressedSize = UDim2.fromOffset(math.floor(originalSize.X.Offset * 0.94), math.floor(originalSize.Y.Offset * 0.94))

local shrinkTweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local expandTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function animateButtonPress()
	local shrinkTween = TweenService:Create(clickButton, shrinkTweenInfo, { Size = pressedSize })
	local expandTween = TweenService:Create(clickButton, expandTweenInfo, { Size = originalSize })

	shrinkTween:Play()
	shrinkTween.Completed:Once(function()
		expandTween:Play()
	end)
end

local function spawnFloatingText(text: string, textColor: Color3)
	local floatingLabel = Instance.new("TextLabel")
	floatingLabel.Name = "FloatingClickFeedback"
	floatingLabel.BackgroundTransparency = 1
	floatingLabel.BorderSizePixel = 0
	floatingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	floatingLabel.Size = UDim2.fromOffset(180, 42)
	floatingLabel.Position = UDim2.fromScale(0.5, 0.48)
	floatingLabel.Text = text
	floatingLabel.TextScaled = true
	floatingLabel.Font = Enum.Font.GothamBold
	floatingLabel.TextColor3 = textColor
	floatingLabel.TextStrokeTransparency = 0.5
	floatingLabel.ZIndex = clickButton.ZIndex + 2
	floatingLabel.Parent = clickButton

	local riseTween = TweenService:Create(
		floatingLabel,
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = UDim2.fromScale(0.5, 0.2),
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
	spawnFloatingText("Click!", Color3.fromRGB(230, 240, 255))
	playerClickEvent:FireServer()
end)

-- Server replies with exact gain (+ crit info), so feedback matches real currency gain.
playerClickEvent.OnClientEvent:Connect(function(gain: number, isCrit: boolean)
	if not localPlayer then
		return
	end

	local numericGain = (type(gain) == "number") and gain or 0
	if isCrit then
		spawnFloatingText(string.format("CRIT +%d", numericGain), Color3.fromRGB(255, 220, 90))
	else
		spawnFloatingText(string.format("+%d", numericGain), Color3.fromRGB(180, 255, 180))
	end
end)
