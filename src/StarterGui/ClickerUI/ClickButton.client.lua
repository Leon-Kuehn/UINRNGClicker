local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local PLAYER_CLICK_EVENT_NAME = "PlayerClick"
local CLICK_BUTTON_NAME = "ClickButton"
local SCREEN_CLICK_SURFACE_NAME = "ScreenClickSurface"

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

local oldButton = screenGui:FindFirstChild(CLICK_BUTTON_NAME)
if oldButton and oldButton:IsA("GuiObject") then
	oldButton.Visible = false
	oldButton.Active = false
end

local clickSurface = screenGui:FindFirstChild(SCREEN_CLICK_SURFACE_NAME)
if not clickSurface or not clickSurface:IsA("TextButton") then
	clickSurface = Instance.new("TextButton")
	clickSurface.Name = SCREEN_CLICK_SURFACE_NAME
	clickSurface.Parent = screenGui
end

clickSurface.AnchorPoint = Vector2.new(0, 0)
clickSurface.Position = UDim2.fromScale(0, 0)
clickSurface.Size = UDim2.fromScale(1, 1)
clickSurface.BackgroundTransparency = 1
clickSurface.BorderSizePixel = 0
clickSurface.AutoButtonColor = false
clickSurface.Active = true
clickSurface.Modal = false
clickSurface.Text = ""
clickSurface.ZIndex = 0

local function spawnFloatingText(text: string, textColor: Color3, targetPosition: UDim2?)
	local floatingLabel = Instance.new("TextLabel")
	floatingLabel.Name = "FloatingClickFeedback"
	floatingLabel.BackgroundTransparency = 1
	floatingLabel.BorderSizePixel = 0
	floatingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	floatingLabel.Size = UDim2.fromOffset(140, 32)
	floatingLabel.Position = targetPosition or UDim2.fromScale(0.5, 0.48)
	floatingLabel.Text = text
	floatingLabel.TextScaled = true
	floatingLabel.Font = Enum.Font.GothamBold
	floatingLabel.TextColor3 = textColor
	floatingLabel.TextStrokeTransparency = 0.5
	floatingLabel.ZIndex = 12
	floatingLabel.Parent = screenGui

	local riseTween = TweenService:Create(
		floatingLabel,
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = UDim2.new(floatingLabel.Position.X.Scale, floatingLabel.Position.X.Offset, floatingLabel.Position.Y.Scale, floatingLabel.Position.Y.Offset - 48),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)

	riseTween:Play()
	riseTween.Completed:Once(function()
		if floatingLabel then
			floatingLabel:Destroy()
		end
	end)
end

clickSurface.MouseButton1Click:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	local x = math.clamp(mousePos.X, 32, math.max(32, screenGui.AbsoluteSize.X - 32))
	local y = math.clamp(mousePos.Y, 32, math.max(32, screenGui.AbsoluteSize.Y - 32))
	spawnFloatingText("+", Color3.fromRGB(210, 230, 255), UDim2.fromOffset(x, y))
	playerClickEvent:FireServer()
end)

-- Server replies with exact gain (+ crit info), so feedback matches real currency gain.
playerClickEvent.OnClientEvent:Connect(function(gain: number, isCrit: boolean)
	if not localPlayer then
		return
	end

	local numericGain = (type(gain) == "number") and gain or 0
	local mousePos = UserInputService:GetMouseLocation()
	local x = math.clamp(mousePos.X, 40, math.max(40, screenGui.AbsoluteSize.X - 40))
	local y = math.clamp(mousePos.Y, 40, math.max(40, screenGui.AbsoluteSize.Y - 40))
	local feedbackPos = UDim2.fromOffset(x, y)
	if isCrit then
		spawnFloatingText(string.format("CRIT +%s", formatCompact(numericGain)), Color3.fromRGB(255, 220, 90), feedbackPos)
	else
		spawnFloatingText(string.format("+%s", formatCompact(numericGain)), Color3.fromRGB(180, 255, 180), feedbackPos)
	end
end)
