local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[Stats] LocalPlayer is not available.")
	return
end

local screenGui = script.Parent
if not screenGui then
	warn("[Stats] Script has no parent ScreenGui.")
	return
end

-- Create Stats Frame (top right)
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statsFrame.BorderSizePixel = 0
statsFrame.AnchorPoint = Vector2.new(1, 0)
statsFrame.Position = UDim2.fromScale(0.98, 0.06)
statsFrame.Size = UDim2.fromScale(0.22, 0.3)
statsFrame.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 10)
statsCorner.Parent = statsFrame

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = Color3.fromRGB(100, 180, 255)
statsStroke.Thickness = 2
statsStroke.Parent = statsFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = "⚡ Stats"
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 70, 120)
titleLabel.TextColor3 = Color3.fromRGB(200, 240, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.Position = UDim2.fromScale(0, 0)
titleLabel.Size = UDim2.fromScale(1, 0.2)
titleLabel.BorderSizePixel = 0
titleLabel.Parent = statsFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Stats Container
local statsContainer = Instance.new("Frame")
statsContainer.Name = "Container"
statsContainer.BackgroundTransparency = 1
statsContainer.BorderSizePixel = 0
statsContainer.Position = UDim2.fromScale(0, 0.2)
statsContainer.Size = UDim2.fromScale(1, 0.8)
statsContainer.Parent = statsFrame

local containerPadding = Instance.new("UIPadding")
containerPadding.PaddingLeft = UDim.new(0, 10)
containerPadding.PaddingRight = UDim.new(0, 10)
containerPadding.PaddingTop = UDim.new(0, 8)
containerPadding.PaddingBottom = UDim.new(0, 8)
containerPadding.Parent = statsContainer

local containerLayout = Instance.new("UIListLayout")
containerLayout.FillDirection = Enum.FillDirection.Vertical
containerLayout.Padding = UDim.new(0, 6)
containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
containerLayout.Parent = statsContainer

-- Function to create a stat row
local function createStatRow(statName, statValue)
	local rowFrame = Instance.new("Frame")
	rowFrame.Name = statName
	rowFrame.BackgroundTransparency = 1
	rowFrame.BorderSizePixel = 0
	rowFrame.Size = UDim2.fromScale(1, 0.2)
	rowFrame.Parent = statsContainer
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Text = statName .. ":"
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextScaled = true
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Size = UDim2.fromScale(0.6, 1)
	nameLabel.Parent = rowFrame
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Text = tostring(statValue)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextScaled = true
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Position = UDim2.fromScale(0.4, 0)
	valueLabel.Size = UDim2.fromScale(0.6, 1)
	valueLabel.Parent = rowFrame
	
	return rowFrame, valueLabel
end

-- Wait for player stats and update
local clickStats = localPlayer:WaitForChild("ClickStats", 10)
if clickStats then
	local baseValueObj = clickStats:WaitForChild("BaseValue", 5)
	local critChanceObj = clickStats:WaitForChild("CritChance", 5)
	local critMultObj = clickStats:WaitForChild("CritMultiplier", 5)
	
	if baseValueObj and baseValueObj:IsA("NumberValue") then
		local _, valueLabel = createStatRow("Base DMG", baseValueObj.Value)
		baseValueObj:GetPropertyChangedSignal("Value"):Connect(function()
			valueLabel.Text = string.format("%.1f", baseValueObj.Value)
		end)
	end
	
	if critChanceObj and critChanceObj:IsA("NumberValue") then
		local _, valueLabel = createStatRow("Crit %", math.floor(critChanceObj.Value * 100))
		critChanceObj:GetPropertyChangedSignal("Value"):Connect(function()
			valueLabel.Text = string.format("%d%%", math.floor(critChanceObj.Value * 100))
		end)
	end
	
	if critMultObj and critMultObj:IsA("NumberValue") then
		local _, valueLabel = createStatRow("Crit Mult", string.format("x%.1f", critMultObj.Value))
		critMultObj:GetPropertyChangedSignal("Value"):Connect(function()
			valueLabel.Text = string.format("x%.1f", critMultObj.Value)
		end)
	end
end
