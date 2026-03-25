local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CURRENCY_STAT_NAME = "Currency"
local PRICE_GROWTH = 1.35

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[Shop] LocalPlayer is not available.")
	return
end

local screenGui = script.Parent
if not screenGui then
	warn("[Shop] Script has no parent ScreenGui.")
	return
end

local function formatCompact(value)
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

local function getScaledCost(baseCost, level)
	local scaled = math.floor(baseCost * (PRICE_GROWTH ^ level))
	return math.max(baseCost, scaled)
end

local SHOP_ITEMS = {
	{
		id = "double_tap",
		name = "Double Tap",
		description = "Double your base click value",
		baseCost = 100,
		category = "upgrades",
		multiplier = 2
	},
	{
		id = "crit_chance",
		name = "Crit Chance +10%",
		description = "Increase critical hit chance by 10%",
		baseCost = 250,
		category = "upgrades",
		amount = 0.1
	},
	{
		id = "crit_mult",
		name = "Crit Multiplier x2",
		description = "Increase critical multiplier by 2x",
		baseCost = 500,
		category = "upgrades",
		multiplier = 2
	},
	{
		id = "auto_click",
		name = "Auto Clicker (Lvl 1)",
		description = "Clicks: 1 per second",
		baseCost = 1000,
		category = "perks",
		clicksPerSecond = 1
	},
	{
		id = "passive_income",
		name = "Passive Generator (Lvl 1)",
		description = "Earn: 1 per second",
		baseCost = 2000,
		category = "perks",
		incomePerSecond = 1
	}
}

local itemById = {}
for _, item in ipairs(SHOP_ITEMS) do
	itemById[item.id] = item
end

-- Create Shop Frame
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.BackgroundColor3 = Color3.fromRGB(19, 25, 34)
shopFrame.BorderSizePixel = 0
shopFrame.AnchorPoint = Vector2.new(0.5, 1)
shopFrame.Position = UDim2.fromScale(0.5, 0.98)
shopFrame.Size = UDim2.fromScale(0.9, 0.22)
shopFrame.ZIndex = 5
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopFrame

local shopStroke = Instance.new("UIStroke")
shopStroke.Color = Color3.fromRGB(77, 154, 232)
shopStroke.Thickness = 2
shopStroke.Parent = shopFrame

local shopGradient = Instance.new("UIGradient")
shopGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 45, 63)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 27, 38)),
})
shopGradient.Rotation = 90
shopGradient.Parent = shopFrame

-- Create Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.Size = UDim2.fromScale(1, 0.22)
tabBar.Parent = shopFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "ShopTitle"
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Shop"
titleLabel.TextColor3 = Color3.fromRGB(220, 235, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextScaled = true
titleLabel.AnchorPoint = Vector2.new(1, 0)
titleLabel.Position = UDim2.fromScale(0.98, 0.08)
titleLabel.Size = UDim2.fromScale(0.2, 0.8)
titleLabel.ZIndex = 6
titleLabel.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabBar

local tabs = {}
local currentTab = "upgrades"

-- Create Tab Buttons
for _, category in ipairs({"upgrades", "perks"}) do
	local tabButton = Instance.new("TextButton")
	tabButton.Name = category .. "Tab"
	tabButton.Text = category:sub(1, 1):upper() .. category:sub(2)
	tabButton.BackgroundColor3 = Color3.fromRGB(45, 58, 79)
	tabButton.TextColor3 = Color3.fromRGB(200, 200, 220)
	tabButton.Font = Enum.Font.GothamBold
	tabButton.TextScaled = true
	tabButton.Size = UDim2.new(0, 120, 0.85, 0)
	tabButton.ZIndex = 6
	tabButton.Parent = tabBar
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = tabButton

	local tabStroke = Instance.new("UIStroke")
	tabStroke.Thickness = 1
	tabStroke.Color = Color3.fromRGB(87, 111, 145)
	tabStroke.Parent = tabButton
	
	tabs[category] = tabButton
end

-- Create Items Container
local itemsContainer = Instance.new("Frame")
itemsContainer.Name = "ItemsContainer"
itemsContainer.BackgroundTransparency = 1
itemsContainer.BorderSizePixel = 0
itemsContainer.Position = UDim2.fromScale(0, 0.22)
itemsContainer.Size = UDim2.fromScale(1, 0.78)
itemsContainer.ZIndex = 6
itemsContainer.Parent = shopFrame

local itemsLayout = Instance.new("UIListLayout")
itemsLayout.FillDirection = Enum.FillDirection.Horizontal
itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
itemsLayout.Padding = UDim.new(0, 8)
itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemsLayout.Parent = itemsContainer

local itemsPadding = Instance.new("UIPadding")
itemsPadding.PaddingLeft = UDim.new(0, 8)
itemsPadding.PaddingRight = UDim.new(0, 8)
itemsPadding.PaddingTop = UDim.new(0, 4)
itemsPadding.PaddingBottom = UDim.new(0, 4)
itemsPadding.Parent = itemsContainer

-- Wait for Upgrade RemoteEvent
local upgradeEvent = ReplicatedStorage:WaitForChild("BuyUpgrade", 5)
if not upgradeEvent or not upgradeEvent:IsA("RemoteEvent") then
	warn("[Shop] BuyUpgrade RemoteEvent not found!")
end

local purchaseResultEvent = ReplicatedStorage:WaitForChild("UpgradePurchaseResult", 5)

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "ShopFeedback"
feedbackLabel.BackgroundColor3 = Color3.fromRGB(20, 37, 49)
feedbackLabel.BackgroundTransparency = 0.1
feedbackLabel.TextColor3 = Color3.fromRGB(210, 245, 220)
feedbackLabel.Font = Enum.Font.GothamMedium
feedbackLabel.TextScaled = true
feedbackLabel.Text = ""
feedbackLabel.Visible = false
feedbackLabel.AnchorPoint = Vector2.new(0.5, 1)
feedbackLabel.Position = UDim2.fromScale(0.5, 0.72)
feedbackLabel.Size = UDim2.fromOffset(300, 34)
feedbackLabel.ZIndex = 9
feedbackLabel.Parent = screenGui

local feedbackCorner = Instance.new("UICorner")
feedbackCorner.CornerRadius = UDim.new(0, 8)
feedbackCorner.Parent = feedbackLabel

local feedbackStroke = Instance.new("UIStroke")
feedbackStroke.Thickness = 1
feedbackStroke.Color = Color3.fromRGB(120, 190, 220)
feedbackStroke.Parent = feedbackLabel

local leaderstats = localPlayer:FindFirstChild("leaderstats") or localPlayer:WaitForChild("leaderstats", 10)
local currencyValue = leaderstats and leaderstats:FindFirstChild(CURRENCY_STAT_NAME)
local upgradesFolder = localPlayer:FindFirstChild("Upgrades")

local itemCards = {}

local hideFeedbackTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local showFeedbackTween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function showFeedback(text, isSuccess)
	feedbackLabel.Text = text
	feedbackLabel.TextColor3 = isSuccess and Color3.fromRGB(210, 245, 220) or Color3.fromRGB(255, 198, 198)
	feedbackLabel.BackgroundTransparency = 0.1
	feedbackLabel.Visible = true

	local fadeIn = TweenService:Create(feedbackLabel, showFeedbackTween, { BackgroundTransparency = 0.1 })
	fadeIn:Play()

	task.delay(1.2, function()
		if not feedbackLabel.Parent then
			return
		end
		local fadeOut = TweenService:Create(feedbackLabel, hideFeedbackTween, { BackgroundTransparency = 1 })
		fadeOut:Play()
		fadeOut.Completed:Once(function()
			if feedbackLabel then
				feedbackLabel.Visible = false
			end
		end)
	end)
end

if purchaseResultEvent and purchaseResultEvent:IsA("RemoteEvent") then
	purchaseResultEvent.OnClientEvent:Connect(function(success, message)
		showFeedback((type(message) == "string" and message or "Status aktualisiert"), success == true)
		for itemId in pairs(itemCards) do
			local card = itemCards[itemId]
			if card then
				local item = itemById[itemId]
				if item then
					local levelValue = upgradesFolder and upgradesFolder:FindFirstChild(itemId)
					local level = (levelValue and levelValue:IsA("IntValue")) and levelValue.Value or 0
					local cost = getScaledCost(item.baseCost, level)
					card.levelLabel.Text = string.format("Lv. %d", level)
					card.costButton.Text = string.format("Buy  $%s", formatCompact(cost))

					local currentCurrency = (currencyValue and currencyValue:IsA("IntValue")) and currencyValue.Value or 0
					local affordable = currentCurrency >= cost
					card.costButton.BackgroundColor3 = affordable and Color3.fromRGB(39, 169, 98) or Color3.fromRGB(145, 79, 79)
				end
			end
		end
	end)
end

local function createShopItem(item)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = item.id
	itemFrame.BackgroundColor3 = Color3.fromRGB(33, 42, 59)
	itemFrame.BorderSizePixel = 0
	itemFrame.Size = UDim2.new(0, 190, 1, -8)
	itemFrame.ZIndex = 6
	itemFrame.Parent = itemsContainer
	
	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 8)
	itemCorner.Parent = itemFrame
	
	local itemStroke = Instance.new("UIStroke")
	itemStroke.Color = Color3.fromRGB(99, 154, 223)
	itemStroke.Thickness = 1
	itemStroke.Parent = itemFrame

	local itemGradient = Instance.new("UIGradient")
	itemGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 59, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 41, 57)),
	})
	itemGradient.Rotation = 70
	itemGradient.Parent = itemFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = item.name
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(200, 240, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.Position = UDim2.fromScale(0.05, 0.05)
	titleLabel.Size = UDim2.fromScale(0.9, 0.25)
	titleLabel.ZIndex = 7
	titleLabel.Parent = itemFrame

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "Level"
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Lv. 0"
	levelLabel.TextColor3 = Color3.fromRGB(148, 213, 255)
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextScaled = true
	levelLabel.TextXAlignment = Enum.TextXAlignment.Right
	levelLabel.Position = UDim2.fromScale(0.55, 0.06)
	levelLabel.Size = UDim2.fromScale(0.4, 0.18)
	levelLabel.ZIndex = 7
	levelLabel.Parent = itemFrame
	
	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Text = item.description
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextScaled = true
	descLabel.TextWrapped = true
	descLabel.Position = UDim2.fromScale(0.05, 0.3)
	descLabel.Size = UDim2.fromScale(0.9, 0.35)
	descLabel.ZIndex = 7
	descLabel.Parent = itemFrame
	
	-- Cost Button
	local costButton = Instance.new("TextButton")
	costButton.Name = "CostButton"
	costButton.Text = string.format("Buy  $%s", formatCompact(item.baseCost))
	costButton.BackgroundColor3 = Color3.fromRGB(38, 166, 91)
	costButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	costButton.Font = Enum.Font.GothamBold
	costButton.TextScaled = true
	costButton.Position = UDim2.fromScale(0.05, 0.7)
	costButton.Size = UDim2.fromScale(0.9, 0.25)
	costButton.ZIndex = 7
	costButton.Parent = itemFrame
	
	local costCorner = Instance.new("UICorner")
	costCorner.CornerRadius = UDim.new(0, 6)
	costCorner.Parent = costButton
	
	-- BUY FUNCTIONALITY
	costButton.MouseButton1Click:Connect(function()
		if upgradeEvent then
			print("[Shop] Buying: " .. item.id)
			upgradeEvent:FireServer(item.id)
		else
			warn("[Shop] BuyUpgrade event not available")
			showFeedback("Upgrade-Service nicht erreichbar.", false)
		end
	end)

	itemCards[item.id] = {
		item = item,
		itemFrame = itemFrame,
		costButton = costButton,
		levelLabel = levelLabel,
	}
	
	return itemFrame
end

local function refreshItemVisual(itemId)
	local card = itemCards[itemId]
	if not card then
		return
	end

	local item = card.item
	local levelValue = upgradesFolder and upgradesFolder:FindFirstChild(itemId)
	local level = (levelValue and levelValue:IsA("IntValue")) and levelValue.Value or 0
	local cost = getScaledCost(item.baseCost, level)

	card.levelLabel.Text = string.format("Lv. %d", level)
	card.costButton.Text = string.format("Buy  $%s", formatCompact(cost))

	local currentCurrency = (currencyValue and currencyValue:IsA("IntValue")) and currencyValue.Value or 0
	local affordable = currentCurrency >= cost
	card.costButton.BackgroundColor3 = affordable and Color3.fromRGB(39, 169, 98) or Color3.fromRGB(145, 79, 79)
	card.costButton.AutoButtonColor = affordable
end

local function refreshAllVisibleItems()
	for itemId in pairs(itemCards) do
		refreshItemVisual(itemId)
	end
end

local function updateShop(category)
	table.clear(itemCards)

	-- Clear items
	for _, child in itemsContainer:GetChildren() do
		if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
			child:Destroy()
		end
	end
	
	-- Add items for category
	local count = 0
	for _, item in ipairs(SHOP_ITEMS) do
		if item.category == category then
			createShopItem(item)
			count += 1
		end
	end

	refreshAllVisibleItems()
end

-- Tab switching
for category, tabButton in tabs do
	tabButton.MouseButton1Click:Connect(function()
		currentTab = category
		updateShop(category)
		
		-- Update tab appearance
		for cat, btn in tabs do
			if cat == category then
				btn.BackgroundColor3 = Color3.fromRGB(71, 127, 205)
			else
				btn.BackgroundColor3 = Color3.fromRGB(45, 58, 79)
			end
		end
	end)
end

local function bindUpgradesFolder(folder)
	upgradesFolder = folder
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("IntValue") then
			child:GetPropertyChangedSignal("Value"):Connect(refreshAllVisibleItems)
		end
	end

	folder.ChildAdded:Connect(function(child)
		if child:IsA("IntValue") then
			child:GetPropertyChangedSignal("Value"):Connect(refreshAllVisibleItems)
			refreshAllVisibleItems()
		end
	end)
end

if currencyValue and currencyValue:IsA("IntValue") then
	currencyValue:GetPropertyChangedSignal("Value"):Connect(refreshAllVisibleItems)
end

if upgradesFolder and upgradesFolder:IsA("Folder") then
	bindUpgradesFolder(upgradesFolder)
else
	localPlayer.ChildAdded:Connect(function(child)
		if child.Name == "Upgrades" and child:IsA("Folder") then
			bindUpgradesFolder(child)
			refreshAllVisibleItems()
		end
	end)
end

-- Initial setup
updateShop("upgrades")
tabs["upgrades"].BackgroundColor3 = Color3.fromRGB(71, 127, 205)
