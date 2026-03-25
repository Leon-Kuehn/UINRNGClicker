--!strict
-- WorldUIController.client.luau
-- Responds to world-zone events fired by WorldInteractionManager on the server
-- and shows toast notifications to the player.
--
-- Handled zones:
--   BonusZone    – "⚡ 2× Coins Active!" (green) / "Bonus Zone left." (grey)
--   RollStation  – "Roll Station – use the Roll panel →" (blue, entry only)

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local Events         = ReplicatedStorage:WaitForChild("Events")
local EnterZoneEvent = Events:WaitForChild("EnterZone")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Toast helper ──────────────────────────────────────────────────────────────

-- Creates a short-lived toast notification at the bottom of the screen.
local function showToast(message: string, color: Color3)
	-- Lazy-create a dedicated ScreenGui for toasts (avoids cluttering other GUIs)
	local toastGui = playerGui:FindFirstChild("_WorldToastGui")
	if not toastGui then
		local gui = Instance.new("ScreenGui")
		gui.Name = "_WorldToastGui"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 20
		gui.Parent = playerGui
		toastGui = gui
	end

	local toast = Instance.new("TextLabel")
	toast.Size = UDim2.fromScale(0.30, 0.06)
	toast.Position = UDim2.fromScale(0.50, 0.86)
	toast.AnchorPoint = Vector2.new(0.5, 0.5)
	toast.BackgroundColor3 = color
	toast.BackgroundTransparency = 1   -- start invisible
	toast.TextColor3 = Color3.fromRGB(255, 255, 255)
	toast.TextTransparency = 1          -- start invisible
	toast.Font = Enum.Font.GothamBold
	toast.TextScaled = true
	toast.Text = message
	toast.BorderSizePixel = 0
	toast.Parent = toastGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = toast

	-- Fade in
	TweenService:Create(toast, TweenInfo.new(0.3), {
		BackgroundTransparency = 0.15,
		TextTransparency       = 0,
	}):Play()

	-- Hold, then fade out and destroy
	task.delay(2.2, function()
		TweenService:Create(toast, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
			TextTransparency       = 1,
		}):Play()
		task.delay(0.55, function() toast:Destroy() end)
	end)
end

-- ── Zone reactions ────────────────────────────────────────────────────────────

EnterZoneEvent.OnClientEvent:Connect(function(zoneName: string, entering: boolean)
	if zoneName == "BonusZone" then
		if entering then
			showToast("⚡  2× Coins Active!", Color3.fromRGB(60, 190, 60))
		else
			showToast("Left Bonus Zone.", Color3.fromRGB(100, 100, 100))
		end

	elseif zoneName == "RollStation" then
		if entering then
			showToast("Roll Station nearby – use the Roll panel →", Color3.fromRGB(70, 120, 255))
		end
	end
end)
