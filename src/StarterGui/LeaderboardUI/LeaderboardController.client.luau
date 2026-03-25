--!strict
-- LeaderboardController.client.luau
-- Left-side panel showing the top-10 global leaderboard.
-- Data is pushed from the server via the UpdateLeaderboard RemoteEvent
-- (fired every ~60 seconds by LeaderboardManager).
-- All UI is created in code.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events                 = ReplicatedStorage:WaitForChild("Events")
local UpdateLeaderboardEvent = Events:WaitForChild("UpdateLeaderboard")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("LeaderboardUI")

-- Temporarily disabled by design request.
screenGui.Enabled = false
return

-- ── Panel ─────────────────────────────────────────────────────────────────────

local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.24, 0.52)
panel.Position = UDim2.fromScale(0.01, 0.22)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
panel.BackgroundTransparency = 0.18
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = panel

local panelPad = Instance.new("UIPadding")
panelPad.PaddingTop    = UDim.new(0, 8)
panelPad.PaddingBottom = UDim.new(0, 8)
panelPad.PaddingLeft   = UDim.new(0, 8)
panelPad.PaddingRight  = UDim.new(0, 8)
panelPad.Parent = panel

-- ── Title ─────────────────────────────────────────────────────────────────────

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.fromScale(1, 0)
titleLabel.AutomaticSize = Enum.AutomaticSize.Y
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 17
titleLabel.Text = "🏆  TOP COLLECTORS"
titleLabel.LayoutOrder = 0
titleLabel.Parent = panel

-- ── Placeholder rows ──────────────────────────────────────────────────────────

local LEADERBOARD_SIZE = 10
local rows: { TextLabel } = {}

for i = 1, LEADERBOARD_SIZE do
	local row = Instance.new("TextLabel")
	row.Size = UDim2.fromScale(1, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 1
	row.TextColor3 = Color3.fromRGB(200, 200, 200)
	row.Font = Enum.Font.Gotham
	row.TextSize = 13
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.Text = string.format("  #%d  —", i)
	row.LayoutOrder = i
	row.Parent = panel
	rows[i] = row
end

-- ── Server event ──────────────────────────────────────────────────────────────

type LeaderboardEntry = { rank: number, name: string, coins: number, display: string }

UpdateLeaderboardEvent.OnClientEvent:Connect(function(entries: { LeaderboardEntry })
	for i, row in ipairs(rows) do
		local entry = entries[i]
		if entry then
			row.Text = "  " .. entry.display
		else
			row.Text = string.format("  #%d  —", i)
		end
	end
end)
