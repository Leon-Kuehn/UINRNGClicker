-- WorldUIController.client.lua
-- Listens to Events/WorldInteraction and reacts to zone interactions.
--
--   RollStation  "open"   → highlights the Roll UI so the player notices it
--   WeaponShowcase "open" → shows the player's current weapon in a popup
--   BonusZone "enter"     → shows a timed bonus notification
--   BonusZone "exit"      → clears the bonus notification
--   SellZone "open"       → placeholder sell UI notification

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[WorldUIController] LocalPlayer not available.")
	return
end

local eventsFolder           = ReplicatedStorage:WaitForChild("Events")
local worldInteractionEvent  = eventsFolder:WaitForChild("WorldInteraction")
local weaponEquippedEvent    = eventsFolder:WaitForChild("WeaponEquipped")

-- ===== Track latest weapon info (updated by WeaponEquipped event) =====
local currentWeapon = {
	name        = "Rusty Dagger",
	rarity      = "Common",
	multiplier  = 1.0,
	description = "A dull blade. Better than nothing.",
}

weaponEquippedEvent.OnClientEvent:Connect(function(
	name: string, rarity: string, multiplier: number, description: string
)
	currentWeapon = { name = name, rarity = rarity, multiplier = multiplier, description = description or "" }
end)

-- ===== Rarity colours =====
local RARITY_COLORS: { [string]: Color3 } = {
	Common    = Color3.fromRGB(200, 200, 200),
	Uncommon  = Color3.fromRGB(96,  230, 96),
	Rare      = Color3.fromRGB(100, 160, 255),
	Epic      = Color3.fromRGB(210, 120, 255),
	Legendary = Color3.fromRGB(255, 210, 30),
	Mythic    = Color3.fromRGB(255, 100, 80),
}

-- ===== Helper: find the RollUI ScreenGui =====
local function getRollUI(): ScreenGui?
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return nil end
	return playerGui:FindFirstChild("RollUI") :: ScreenGui?
end

-- ===== Helper: create a temporary floating toast banner =====
local function showToast(text: string, color: Color3, duration: number?)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end

	local banner = Instance.new("ScreenGui")
	banner.Name             = "ToastBanner"
	banner.ResetOnSpawn     = false
	banner.IgnoreGuiInset   = true
	banner.DisplayOrder     = 20
	banner.Parent           = playerGui

	local label = Instance.new("TextLabel")
	label.AnchorPoint       = Vector2.new(0.5, 0.5)
	label.Position          = UDim2.fromScale(0.5, 0.45)
	label.Size              = UDim2.fromOffset(480, 52)
	label.BackgroundColor3  = Color3.fromRGB(18, 25, 38)
	label.BackgroundTransparency = 0.1
	label.Text              = text
	label.TextScaled        = true
	label.Font              = Enum.Font.GothamBold
	label.TextColor3        = color
	label.BorderSizePixel   = 0
	label.ZIndex            = 21
	label.Parent            = banner

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent       = label

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color     = color
	stroke.Parent    = label

	-- Fade in
	label.BackgroundTransparency = 1
	label.TextTransparency       = 1
	TweenService:Create(label, TweenInfo.new(0.25), {
		BackgroundTransparency = 0.1,
		TextTransparency       = 0,
	}):Play()

	local d = duration or 2.5
	task.delay(d, function()
		if not label.Parent then return end
		TweenService:Create(label, TweenInfo.new(0.4), {
			BackgroundTransparency = 1,
			TextTransparency       = 1,
		}):Play()
		task.wait(0.4)
		banner:Destroy()
	end)
end

-- ===== Bonus Zone Timer =====
-- We keep a small on-screen countdown label while a bonus is active.
local bonusTimerGui: ScreenGui? = nil
local bonusTimerTask: thread?   = nil

local function startBonusTimer(seconds: number)
	-- Remove existing timer if any
	if bonusTimerGui then
		bonusTimerGui:Destroy()
		bonusTimerGui = nil
	end
	if bonusTimerTask then
		task.cancel(bonusTimerTask)
		bonusTimerTask = nil
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end

	local gui = Instance.new("ScreenGui")
	gui.Name           = "BonusTimerGui"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder   = 15
	gui.Parent         = playerGui
	bonusTimerGui      = gui

	local label = Instance.new("TextLabel")
	label.AnchorPoint       = Vector2.new(0, 1)
	label.Position          = UDim2.fromScale(0.02, 0.95)
	label.Size              = UDim2.fromOffset(240, 38)
	label.BackgroundColor3  = Color3.fromRGB(70, 50, 5)
	label.BackgroundTransparency = 0.15
	label.Text              = string.format("⚡ Bonus x2 — %ds", seconds)
	label.TextScaled        = true
	label.Font              = Enum.Font.GothamBold
	label.TextColor3        = Color3.fromRGB(255, 210, 30)
	label.BorderSizePixel   = 0
	label.ZIndex            = 16
	label.Parent            = gui

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent       = label

	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Color     = Color3.fromRGB(255, 210, 30)
	s.Parent    = label

	bonusTimerTask = task.spawn(function()
		local remaining = seconds
		while remaining > 0 do
			task.wait(1)
			remaining -= 1
			if label.Parent then
				label.Text = string.format("⚡ Bonus x2 — %ds", remaining)
			end
		end
		if gui.Parent then
			gui:Destroy()
		end
		bonusTimerGui  = nil
		bonusTimerTask = nil
	end)
end

local function clearBonusTimer()
	if bonusTimerGui then
		bonusTimerGui:Destroy()
		bonusTimerGui = nil
	end
	if bonusTimerTask then
		task.cancel(bonusTimerTask)
		bonusTimerTask = nil
	end
end

-- ===== Highlight the Roll button to draw attention =====
local highlightTask: thread? = nil

local function highlightRollButton()
	if highlightTask then
		task.cancel(highlightTask)
	end
	highlightTask = task.spawn(function()
		local rollUI = getRollUI()
		if not rollUI then return end
		local panel      = rollUI:FindFirstChild("RollPanel")
		local rollButton = panel and panel:FindFirstChild("RollButton")
		if not rollButton then return end

		for _ = 1, 3 do
			TweenService:Create(
				rollButton,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundColor3 = Color3.fromRGB(255, 180, 0) }
			):Play()
			task.wait(0.3)
			TweenService:Create(
				rollButton,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundColor3 = Color3.fromRGB(58, 108, 210) }
			):Play()
			task.wait(0.3)
		end
		highlightTask = nil
	end)
end

-- ===== Show weapon showcase popup =====

local showcaseGui: ScreenGui? = nil

local function showWeaponShowcase()
	if showcaseGui then
		showcaseGui:Destroy()
		showcaseGui = nil
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end

	local gui = Instance.new("ScreenGui")
	gui.Name           = "WeaponShowcaseGui"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder   = 18
	gui.Parent         = playerGui
	showcaseGui        = gui

	local color = RARITY_COLORS[currentWeapon.rarity] or Color3.fromRGB(200, 200, 200)

	local panel = Instance.new("Frame")
	panel.AnchorPoint       = Vector2.new(0.5, 0.5)
	panel.Position          = UDim2.fromScale(0.5, 0.45)
	panel.Size              = UDim2.fromOffset(340, 160)
	panel.BackgroundColor3  = Color3.fromRGB(18, 25, 38)
	panel.BackgroundTransparency = 0.05
	panel.BorderSizePixel   = 0
	panel.ZIndex            = 19
	panel.Parent            = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent       = panel

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color     = color
	stroke.Parent    = panel

	local function makeLabel(text: string, pos: UDim2, size: UDim2, font: Enum.Font, tcolor: Color3, zIndex: number?): TextLabel
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position    = pos
		lbl.Size        = size
		lbl.Text        = text
		lbl.TextScaled  = true
		lbl.Font        = font
		lbl.TextColor3  = tcolor
		lbl.ZIndex      = zIndex or 20
		lbl.Parent      = panel
		return lbl
	end

	makeLabel("⚔  Your Weapon", UDim2.fromScale(0.05, 0.04), UDim2.fromScale(0.9, 0.2),
		Enum.Font.Gotham, Color3.fromRGB(160, 190, 220))
	makeLabel(currentWeapon.name, UDim2.fromScale(0.05, 0.26), UDim2.fromScale(0.9, 0.3),
		Enum.Font.GothamBold, color)
	makeLabel(currentWeapon.rarity, UDim2.fromScale(0.05, 0.58), UDim2.fromScale(0.55, 0.22),
		Enum.Font.GothamBold, color)
	makeLabel(string.format("x%.1f", currentWeapon.multiplier),
		UDim2.fromScale(0.6, 0.58), UDim2.fromScale(0.38, 0.22),
		Enum.Font.GothamBold, Color3.fromRGB(255, 210, 50))
	makeLabel(currentWeapon.description, UDim2.fromScale(0.05, 0.8), UDim2.fromScale(0.9, 0.18),
		Enum.Font.Gotham, Color3.fromRGB(160, 180, 200))

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint       = Vector2.new(1, 0)
	closeBtn.Position          = UDim2.fromScale(0.98, 0.03)
	closeBtn.Size              = UDim2.fromOffset(28, 28)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text              = "✕"
	closeBtn.TextScaled        = true
	closeBtn.Font              = Enum.Font.GothamBold
	closeBtn.TextColor3        = Color3.fromRGB(200, 200, 200)
	closeBtn.ZIndex            = 21
	closeBtn.Parent            = panel
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
		showcaseGui = nil
	end)

	-- Auto-close after 6 seconds
	task.delay(6, function()
		if gui.Parent then
			gui:Destroy()
		end
		showcaseGui = nil
	end)
end

-- ===== World interaction event handler =====

worldInteractionEvent.OnClientEvent:Connect(function(
	interactionType: string,
	action: string,
	_partName: string
)
	if interactionType == "RollStation" and action == "open" then
		showToast("🎲  Roll Station nearby! Use the Roll button to get a weapon.", Color3.fromRGB(100, 180, 255), 2.5)
		highlightRollButton()

	elseif interactionType == "WeaponShowcase" and action == "open" then
		showWeaponShowcase()

	elseif interactionType == "BonusZone" and action == "enter" then
		showToast("⚡  Bonus Zone! Click multiplier x2 for 15 seconds!", Color3.fromRGB(255, 210, 30), 2)
		startBonusTimer(15)

	elseif interactionType == "BonusZone" and action == "exit" then
		clearBonusTimer()
		showToast("Bonus expired.", Color3.fromRGB(180, 180, 180), 1.5)

	elseif interactionType == "SellZone" and action == "open" then
		showToast("💰  Sell Zone — sell mechanic coming soon!", Color3.fromRGB(120, 220, 120), 2)
	end
end)
