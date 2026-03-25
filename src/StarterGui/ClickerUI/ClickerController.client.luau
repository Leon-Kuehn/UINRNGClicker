--!strict
-- ClickerController.client.luau
-- HUD for core click loop:
--   • Souls (tap resource)
--   • Coins (spend/sell currency)
--   • Total clicks stat
--   • Sell Souls button
--   • Global tap feedback

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local FormatUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FormatUtils"))
local ClickerUXConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClickerUXConfig"))
local EconomyConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EconomyConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RarityConfig"))

local Events = ReplicatedStorage:WaitForChild("Events")
local PlayerClickEvent = Events:WaitForChild("PlayerClick")
local SellSoulsEvent = Events:WaitForChild("SellSouls")
local UpgradeBackpackEvent = Events:FindFirstChild("UpgradeBackpack")
local EquipWeaponEvent = Events:WaitForChild("EquipWeapon")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")
local UpdateInventoryEvent = Events:WaitForChild("UpdateInventory")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ClickerUI")

local DEFAULT_TAP_FEEDBACK_POS = Vector2.new(0.5, 0.55)
local TAP_FEEDBACK_LIFETIME = 0.5
local TAP_FEEDBACK_RISE = 46
local TAP_FEEDBACK_MAX_QUEUE = 30
local PANEL_ATTR = "OpenOverlayPanel"
local SELL_BUTTON_COLOR = Color3.fromRGB(60, 160, 90)
local SELL_BUTTON_DISABLED_COLOR = Color3.fromRGB(90, 90, 90)
local UPGRADE_BUTTON_COLOR = Color3.fromRGB(70, 120, 190)
local UPGRADE_BUTTON_DISABLED_COLOR = Color3.fromRGB(90, 90, 90)
local SLOT_COLOR = Color3.fromRGB(35, 35, 52)
local SLOT_EQUIPPED_COLOR = Color3.fromRGB(45, 120, 80)

local statsBar = Instance.new("Frame")
statsBar.Size = UDim2.fromScale(0.52, 0.075)
statsBar.Position = UDim2.fromScale(0.24, 0.02)
statsBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statsBar.BackgroundTransparency = 0.25
statsBar.BorderSizePixel = 0
statsBar.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsBar

local soulsLabel = Instance.new("TextLabel")
soulsLabel.Size = UDim2.fromScale(0.34, 1)
soulsLabel.Position = UDim2.fromScale(0, 0)
soulsLabel.BackgroundTransparency = 1
soulsLabel.TextColor3 = Color3.fromRGB(120, 255, 220)
soulsLabel.Font = Enum.Font.GothamBold
soulsLabel.TextScaled = true
soulsLabel.Text = "Souls: 0"
soulsLabel.Parent = statsBar

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.fromScale(0.34, 1)
coinsLabel.Position = UDim2.fromScale(0.33, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextScaled = true
coinsLabel.Text = "Coins: 0"
coinsLabel.Parent = statsBar

local clicksLabel = Instance.new("TextLabel")
clicksLabel.Name = "TotalClicksLabel"
clicksLabel.Size = UDim2.fromScale(0.33, 1)
clicksLabel.Position = UDim2.fromScale(0.67, 0)
clicksLabel.BackgroundTransparency = 1
clicksLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
clicksLabel.Font = Enum.Font.GothamBold
clicksLabel.TextScaled = true
clicksLabel.Text = "Clicks: 0"
clicksLabel.Visible = ClickerUXConfig.showTapCounter
clicksLabel.Parent = statsBar

local sellButton = Instance.new("TextButton")
sellButton.Name = "SellButton"
sellButton.Size = UDim2.fromScale(0.20, 0.06)
sellButton.Position = UDim2.fromScale(0.79, 0.11)
sellButton.BackgroundColor3 = SELL_BUTTON_DISABLED_COLOR
sellButton.BorderSizePixel = 0
sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sellButton.Font = Enum.Font.GothamBold
sellButton.TextScaled = true
sellButton.Text = "SELL SOULS"
sellButton.Parent = screenGui

local sellCorner = Instance.new("UICorner")
sellCorner.CornerRadius = UDim.new(0, 8)
sellCorner.Parent = sellButton

local upgradeButton = Instance.new("TextButton")
upgradeButton.Name = "UpgradeBackpackButton"
upgradeButton.Size = UDim2.fromScale(0.20, 0.06)
upgradeButton.Position = UDim2.fromScale(0.79, 0.18)
upgradeButton.BackgroundColor3 = UPGRADE_BUTTON_DISABLED_COLOR
upgradeButton.BorderSizePixel = 0
upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upgradeButton.Font = Enum.Font.GothamBold
upgradeButton.TextScaled = true
upgradeButton.Text = "UPGRADE BAG"
upgradeButton.Parent = screenGui

local upgradeCorner = Instance.new("UICorner")
upgradeCorner.CornerRadius = UDim.new(0, 8)
upgradeCorner.Parent = upgradeButton

local backpackToggleButton = Instance.new("TextButton")
backpackToggleButton.Name = "BackpackToggleButton"
backpackToggleButton.Size = UDim2.fromScale(0.16, 0.062)
backpackToggleButton.Position = UDim2.fromScale(0.50, 0.965)
backpackToggleButton.AnchorPoint = Vector2.new(0.5, 1)
backpackToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 110)
backpackToggleButton.BorderSizePixel = 0
backpackToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backpackToggleButton.Font = Enum.Font.GothamBold
backpackToggleButton.TextScaled = true
backpackToggleButton.Text = "BAG"
backpackToggleButton.Parent = screenGui

local backpackToggleCorner = Instance.new("UICorner")
backpackToggleCorner.CornerRadius = UDim.new(0, 8)
backpackToggleCorner.Parent = backpackToggleButton

local backpackOverlay = Instance.new("Frame")
backpackOverlay.Name = "BackpackOverlay"
backpackOverlay.Size = UDim2.fromScale(1, 1)
backpackOverlay.Position = UDim2.fromScale(0, 0)
backpackOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
backpackOverlay.BackgroundTransparency = 0.35
backpackOverlay.BorderSizePixel = 0
backpackOverlay.Visible = false
backpackOverlay.ZIndex = 30
backpackOverlay.Active = true
backpackOverlay.Parent = screenGui

local backpackPanel = Instance.new("Frame")
backpackPanel.Name = "BackpackPanel"
backpackPanel.Size = UDim2.fromScale(0.90, 0.82)
backpackPanel.Position = UDim2.fromScale(0.05, 0.09)
backpackPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
backpackPanel.BackgroundTransparency = 0.08
backpackPanel.BorderSizePixel = 0
backpackPanel.ZIndex = 31
backpackPanel.Parent = backpackOverlay

local backpackPanelCorner = Instance.new("UICorner")
backpackPanelCorner.CornerRadius = UDim.new(0, 14)
backpackPanelCorner.Parent = backpackPanel

local backpackTitle = Instance.new("TextLabel")
backpackTitle.Size = UDim2.fromScale(0.72, 0.12)
backpackTitle.Position = UDim2.fromScale(0.03, 0.02)
backpackTitle.BackgroundTransparency = 1
backpackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
backpackTitle.Font = Enum.Font.GothamBold
backpackTitle.TextScaled = true
backpackTitle.TextXAlignment = Enum.TextXAlignment.Left
backpackTitle.Text = "BACKPACK"
backpackTitle.ZIndex = 32
backpackTitle.Parent = backpackPanel

local backpackSubtitle = Instance.new("TextLabel")
backpackSubtitle.Size = UDim2.fromScale(0.72, 0.07)
backpackSubtitle.Position = UDim2.fromScale(0.03, 0.11)
backpackSubtitle.BackgroundTransparency = 1
backpackSubtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
backpackSubtitle.Font = Enum.Font.Gotham
backpackSubtitle.TextScaled = true
backpackSubtitle.TextXAlignment = Enum.TextXAlignment.Left
backpackSubtitle.Text = "Tap a slot to equip. Duplicates are stacked."
backpackSubtitle.ZIndex = 32
backpackSubtitle.Parent = backpackPanel

local backpackClose = Instance.new("TextButton")
backpackClose.Size = UDim2.fromScale(0.20, 0.12)
backpackClose.Position = UDim2.fromScale(0.77, 0.02)
backpackClose.BackgroundColor3 = Color3.fromRGB(80, 55, 55)
backpackClose.BorderSizePixel = 0
backpackClose.TextColor3 = Color3.fromRGB(255, 255, 255)
backpackClose.Font = Enum.Font.GothamBold
backpackClose.TextScaled = true
backpackClose.Text = "X"
backpackClose.ZIndex = 32
backpackClose.Parent = backpackPanel

local backpackCloseCorner = Instance.new("UICorner")
backpackCloseCorner.CornerRadius = UDim.new(0, 8)
backpackCloseCorner.Parent = backpackClose

local backpackScroll = Instance.new("ScrollingFrame")
backpackScroll.Name = "BackpackScroll"
backpackScroll.Size = UDim2.fromScale(0.94, 0.74)
backpackScroll.Position = UDim2.fromScale(0.03, 0.22)
backpackScroll.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
backpackScroll.BackgroundTransparency = 0.2
backpackScroll.BorderSizePixel = 0
backpackScroll.ScrollBarThickness = 6
backpackScroll.CanvasSize = UDim2.fromOffset(0, 0)
backpackScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
backpackScroll.ZIndex = 32
backpackScroll.Parent = backpackPanel

local backpackScrollCorner = Instance.new("UICorner")
backpackScrollCorner.CornerRadius = UDim.new(0, 8)
backpackScrollCorner.Parent = backpackScroll

local backpackLayout = Instance.new("UIGridLayout")
backpackLayout.SortOrder = Enum.SortOrder.LayoutOrder
backpackLayout.CellPadding = UDim2.fromOffset(8, 8)
backpackLayout.CellSize = UDim2.fromOffset(200, 92)
backpackLayout.Parent = backpackScroll

local backpackPadding = Instance.new("UIPadding")
backpackPadding.PaddingTop = UDim.new(0, 6)
backpackPadding.PaddingBottom = UDim.new(0, 6)
backpackPadding.PaddingLeft = UDim.new(0, 6)
backpackPadding.PaddingRight = UDim.new(0, 6)
backpackPadding.Parent = backpackScroll

local feedbackLayer = Instance.new("Frame")
feedbackLayer.Name = "TapFeedbackLayer"
feedbackLayer.Size = UDim2.fromScale(1, 1)
feedbackLayer.Position = UDim2.fromScale(0, 0)
feedbackLayer.BackgroundTransparency = 1
feedbackLayer.BorderSizePixel = 0
feedbackLayer.Active = false
feedbackLayer.ZIndex = 20
feedbackLayer.Parent = screenGui

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

local eqCorner = Instance.new("UICorner")
eqCorner.CornerRadius = UDim.new(0, 8)
eqCorner.Parent = equippedLabel

local pendingTapPositions: { Vector2 } = {}
local currentSouls = 0
local currentCoins = 0
local currentSoulsCapacity = EconomyConfig.SOULS_CAPACITY_BASE
local lastTapAt = 0
local inventoryState: { any } = {}
local equippedWeaponState: any? = nil
local inventoryCountByKey: { [string]: number } = {}

local function getOpenOverlayPanel(): string
	local value = playerGui:GetAttribute(PANEL_ATTR)
	if type(value) == "string" then
		return value
	end
	return ""
end

local function setOpenOverlayPanel(value: string)
	playerGui:SetAttribute(PANEL_ATTR, value)
end

local backpackNotice = Instance.new("TextLabel")
backpackNotice.Name = "BackpackNotice"
backpackNotice.Size = UDim2.fromScale(0.42, 0.06)
backpackNotice.Position = UDim2.fromScale(0.29, 0.10)
backpackNotice.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
backpackNotice.BackgroundTransparency = 0.2
backpackNotice.BorderSizePixel = 0
backpackNotice.TextColor3 = Color3.fromRGB(255, 225, 120)
backpackNotice.Font = Enum.Font.GothamBold
backpackNotice.TextScaled = true
backpackNotice.Text = ""
backpackNotice.Visible = false
backpackNotice.ZIndex = 40
backpackNotice.Parent = screenGui

local backpackNoticeCorner = Instance.new("UICorner")
backpackNoticeCorner.CornerRadius = UDim.new(0, 10)
backpackNoticeCorner.Parent = backpackNotice

local function weaponKey(weapon: any): string
	return string.format("%s|%s|%.4f|%.4f", weapon.rarity, weapon.name, weapon.rarityMultiplier, weapon.clickMultiplier)
end

local function showBackpackNotice(text: string)
	backpackNotice.Text = text
	backpackNotice.TextTransparency = 0
	backpackNotice.Visible = true
	TweenService:Create(backpackNotice, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
	}):Play()
	task.delay(1.0, function()
		backpackNotice.Visible = false
	end)
end

local function weaponsEqual(a: any?, b: any?): boolean
	if not a or not b then return false end
	return a.name == b.name
		and a.rarity == b.rarity
		and a.clickMultiplier == b.clickMultiplier
		and a.rarityMultiplier == b.rarityMultiplier
end

local function clearBackpackRows()
	for _, child in ipairs(backpackScroll:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function refreshBackpackList()
	clearBackpackRows()

	local uniqueWeapons: { [string]: any } = {}
	for _, weapon in ipairs(inventoryState) do
		local key = weaponKey(weapon)
		if not uniqueWeapons[key] then
			uniqueWeapons[key] = weapon
		end
	end

	local uniqueList: { any } = {}
	for _, weapon in pairs(uniqueWeapons) do
		table.insert(uniqueList, weapon)
	end

	table.sort(uniqueList, function(a, b)
		local av = a.rarityMultiplier * a.clickMultiplier
		local bv = b.rarityMultiplier * b.clickMultiplier
		if av == bv then
			return a.name < b.name
		end
		return av > bv
	end)

	if #uniqueList == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.fromOffset(0, 48)
		emptyLabel.AutomaticSize = Enum.AutomaticSize.XY
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.TextSize = 14
		emptyLabel.Text = "No weapons yet. Roll to get one."
		emptyLabel.ZIndex = 33
		emptyLabel.Parent = backpackScroll
		return
	end

	for _, weapon in ipairs(uniqueList) do
		local rarityData = RarityConfig.ByName[weapon.rarity]
		local rarityColor = rarityData and rarityData.color or Color3.fromRGB(220, 220, 220)
		local key = weaponKey(weapon)
		local copies = inventoryCountByKey[key] or 1

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(0, 200, 0, 92)
		row.BackgroundColor3 = SLOT_COLOR
		row.BorderSizePixel = 0
		row.AutoButtonColor = true
		row.Text = ""
		row.ZIndex = 33
		row.Parent = backpackScroll

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row

		local equipped = weaponsEqual(weapon, equippedWeaponState)
		if equipped then
			row.BackgroundColor3 = SLOT_EQUIPPED_COLOR
		end

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.fromScale(0.96, 0.42)
		nameLabel.Position = UDim2.fromScale(0.02, 0.04)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = rarityColor
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextScaled = true
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = string.format("[%s] %s", weapon.rarity, weapon.name)
		nameLabel.ZIndex = 34
		nameLabel.Parent = row

		local multLabel = Instance.new("TextLabel")
		multLabel.Size = UDim2.fromScale(0.96, 0.28)
		multLabel.Position = UDim2.fromScale(0.02, 0.48)
		multLabel.BackgroundTransparency = 1
		multLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
		multLabel.Font = Enum.Font.Gotham
		multLabel.TextScaled = true
		multLabel.TextXAlignment = Enum.TextXAlignment.Left
		multLabel.Text = string.format("x%.2f total", weapon.rarityMultiplier * weapon.clickMultiplier)
		multLabel.ZIndex = 34
		multLabel.Parent = row

		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.fromScale(0.96, 0.22)
		statusLabel.Position = UDim2.fromScale(0.02, 0.76)
		statusLabel.BackgroundTransparency = 1
		statusLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
		statusLabel.Font = Enum.Font.GothamBold
		statusLabel.TextScaled = true
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.ZIndex = 34
		if equipped then
			statusLabel.Text = copies > 1 and string.format("SELECTED  x%d", copies) or "SELECTED"
		else
			statusLabel.Text = copies > 1 and string.format("TAP TO EQUIP  x%d", copies) or "TAP TO EQUIP"
		end
		statusLabel.Parent = row

		row.MouseButton1Click:Connect(function()
			if equipped then
				return
			end

			for idx, invWeapon in ipairs(inventoryState) do
				if weaponKey(invWeapon) == key then
					EquipWeaponEvent:FireServer(idx)
					break
				end
			end
		end)
	end
end

local function setBackpackOpen(open: boolean)
	backpackOverlay.Visible = open
	if open then
		refreshBackpackList()
	end
end

local function updateStatsHud(coins: number, souls: number, totalClicks: number, isFull: boolean)
	currentCoins = coins
	currentSouls = souls

	coinsLabel.Text = "Coins: " .. FormatUtils.formatNumber(coins)
	local baseSoulsText = string.format(
		"Souls: %s/%s",
		FormatUtils.formatNumber(souls),
		FormatUtils.formatNumber(currentSoulsCapacity)
	)
	soulsLabel.Text = isFull and (baseSoulsText .. " FULL") or baseSoulsText
	clicksLabel.Text = "Clicks: " .. FormatUtils.formatNumber(totalClicks)

	local currentLevel = EconomyConfig.getBackpackLevelForCapacity(currentSoulsCapacity)
	local maxLevel = EconomyConfig.BACKPACK_UPGRADE_MAX_LEVEL
	local isMaxLevel = currentLevel >= maxLevel
	if isMaxLevel then
		upgradeButton.AutoButtonColor = false
		upgradeButton.BackgroundColor3 = UPGRADE_BUTTON_DISABLED_COLOR
		upgradeButton.Text = "BAG MAX"
	else
		local nextCost = EconomyConfig.getBackpackUpgradeCost(currentLevel)
		local canUpgrade = coins >= nextCost
		upgradeButton.AutoButtonColor = canUpgrade
		upgradeButton.BackgroundColor3 = canUpgrade and UPGRADE_BUTTON_COLOR or UPGRADE_BUTTON_DISABLED_COLOR
		upgradeButton.Text = string.format("BAG L%d -> L%d (%s)", currentLevel, currentLevel + 1, FormatUtils.formatNumber(nextCost))
	end

	local canSell = souls > 0
	sellButton.AutoButtonColor = canSell
	sellButton.BackgroundColor3 = canSell and SELL_BUTTON_COLOR or SELL_BUTTON_DISABLED_COLOR
	if canSell then
		sellButton.Text = string.format("SELL SOULS (+%s)", FormatUtils.formatNumber(souls))
	else
		sellButton.Text = "SELL SOULS"
	end
end

local function toFeedbackPosition(screenPos: Vector2): UDim2
	local viewSize = feedbackLayer.AbsoluteSize
	if viewSize.X <= 0 or viewSize.Y <= 0 then
		return UDim2.fromScale(DEFAULT_TAP_FEEDBACK_POS.X, DEFAULT_TAP_FEEDBACK_POS.Y)
	end

	local x = math.clamp(screenPos.X, 28, viewSize.X - 28)
	local y = math.clamp(screenPos.Y, 28, viewSize.Y - 28)
	return UDim2.fromOffset(x, y)
end

local function spawnTapPulse(screenPos: Vector2)
	if not ClickerUXConfig.enableTapFeedback then return end

	local pulse = Instance.new("Frame")
	pulse.Size = UDim2.fromOffset(24, 24)
	pulse.AnchorPoint = Vector2.new(0.5, 0.5)
	pulse.Position = toFeedbackPosition(screenPos)
	pulse.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	pulse.BackgroundTransparency = 0.45
	pulse.BorderSizePixel = 0
	pulse.ZIndex = 20
	pulse.Parent = feedbackLayer

	local pulseCorner = Instance.new("UICorner")
	pulseCorner.CornerRadius = UDim.new(1, 0)
	pulseCorner.Parent = pulse

	TweenService:Create(pulse, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(70, 70),
		BackgroundTransparency = 1,
	}):Play()

	task.delay(0.27, function()
		pulse:Destroy()
	end)
end

local function spawnFloatingTextAt(text: string, color: Color3, screenPos: Vector2)
	if not ClickerUXConfig.enableTapFeedback then return end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.14, 0.07)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = toFeedbackPosition(screenPos)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.ZIndex = 21
	label.Parent = feedbackLayer

	TweenService:Create(label, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = label.Position - UDim2.fromOffset(0, TAP_FEEDBACK_RISE),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	task.delay(TAP_FEEDBACK_LIFETIME, function()
		label:Destroy()
	end)
end

local function pushPendingTapPosition(pos: Vector2)
	table.insert(pendingTapPositions, pos)
	if #pendingTapPositions > TAP_FEEDBACK_MAX_QUEUE then
		table.remove(pendingTapPositions, 1)
	end
end

local function getTapInputScreenPosition(inputObject: InputObject?): Vector2
	if inputObject and inputObject.Position then
		return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
	end

	local mousePos = UserInputService:GetMouseLocation()
	return Vector2.new(mousePos.X, mousePos.Y)
end

local function isGlobalTapBlocked(screenPos: Vector2): boolean
	if UserInputService:GetFocusedTextBox() then
		return true
	end

	local guiObjects = playerGui:GetGuiObjectsAtPosition(screenPos.X, screenPos.Y)
	if getOpenOverlayPanel() ~= "" then
		return true
	end

	for _, guiObj in ipairs(guiObjects) do
		if guiObj:IsA("TextBox") then
			return true
		end

		if guiObj:IsA("GuiButton") then
			if guiObj == sellButton or guiObj == upgradeButton or guiObj == backpackToggleButton then
				return true
			end

			return true
		end
	end

	return false
end

local debounce = false

local function onTap(screenPos: Vector2?)
	local now = os.clock()
	if now - lastTapAt < 0.04 then return end
	lastTapAt = now

	if debounce then return end
	debounce = true
	task.delay(0.08, function() debounce = false end)

	local tapPos = screenPos or getTapInputScreenPosition(nil)
	pushPendingTapPosition(tapPos)
	spawnTapPulse(tapPos)

	PlayerClickEvent:FireServer()
end

sellButton.MouseButton1Click:Connect(function()
	if currentSouls <= 0 then return end
	SellSoulsEvent:FireServer()
end)

backpackToggleButton.MouseButton1Click:Connect(function()
	if getOpenOverlayPanel() == "Backpack" then
		setOpenOverlayPanel("")
	else
		setOpenOverlayPanel("Backpack")
	end
end)

backpackClose.MouseButton1Click:Connect(function()
	setOpenOverlayPanel("")
end)

upgradeButton.MouseButton1Click:Connect(function()
	if not UpgradeBackpackEvent then
		return
	end

	local currentLevel = EconomyConfig.getBackpackLevelForCapacity(currentSoulsCapacity)
	if currentLevel >= EconomyConfig.BACKPACK_UPGRADE_MAX_LEVEL then
		return
	end

	local nextCost = EconomyConfig.getBackpackUpgradeCost(currentLevel)
	if currentCoins < nextCost then
		return
	end

	UpgradeBackpackEvent:FireServer()
end)

if ClickerUXConfig.enableGlobalTapToClick then
	UserInputService.InputBegan:Connect(function(inputObject: InputObject, _gameProcessedEvent: boolean)
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local tapPos = getTapInputScreenPosition(inputObject)
		if isGlobalTapBlocked(tapPos) then
			return
		end

		onTap(tapPos)
	end)
end

playerGui:GetAttributeChangedSignal(PANEL_ATTR):Connect(function()
	setBackpackOpen(getOpenOverlayPanel() == "Backpack")
end)

setBackpackOpen(getOpenOverlayPanel() == "Backpack")

UpdateCurrencyEvent.OnClientEvent:Connect(function(
	coins: number,
	souls: number,
	totalClicks: number,
	_nextRollCost: number?,
	soulsGained: number?,
	critSouls: number?,
	soulsCapacity: number?,
	isFull: boolean?
)
	if soulsCapacity ~= nil then
		currentSoulsCapacity = math.max(1, soulsCapacity)
	end

	updateStatsHud(coins, souls, totalClicks, isFull == true)

	local gained = soulsGained or 0
	if gained > 0 and #pendingTapPositions > 0 then
		local feedbackPos = table.remove(pendingTapPositions, 1)
		if critSouls then
			spawnFloatingTextAt("+" .. FormatUtils.formatNumber(gained) .. " SOULS CRIT!", Color3.fromRGB(255, 200, 0), feedbackPos)
		else
			spawnFloatingTextAt("+" .. FormatUtils.formatNumber(gained) .. " SOULS", Color3.fromRGB(120, 255, 220), feedbackPos)
		end
	end
end)

UpdateInventoryEvent.OnClientEvent:Connect(function(_inventory: { any }, equippedWeapon: any?)
	local oldCounts: { [string]: number } = inventoryCountByKey
	inventoryCountByKey = {}
	for _, weapon in ipairs(_inventory) do
		local key = weaponKey(weapon)
		inventoryCountByKey[key] = (inventoryCountByKey[key] or 0) + 1
	end

	for key, newCount in pairs(inventoryCountByKey) do
		local oldCount = oldCounts[key] or 0
		if newCount > oldCount and oldCount > 0 then
			showBackpackNotice("Duplicate weapon received. Stacked in backpack.")
			break
		end
	end

	inventoryState = _inventory
	equippedWeaponState = equippedWeapon
	if backpackOverlay.Visible then
		refreshBackpackList()
	end

	if equippedWeapon then
		equippedLabel.Text = string.format("[%s] %s", equippedWeapon.rarity, equippedWeapon.name)
	else
		equippedLabel.Text = "No weapon equipped"
	end
end)
