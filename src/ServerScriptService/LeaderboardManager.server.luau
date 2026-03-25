--!strict
-- LeaderboardManager.server.luau
-- Maintains a global "Most Coins" leaderboard backed by an OrderedDataStore.
--
-- Every UPDATE_INTERVAL seconds it:
--   1. Writes each online player's current coin total to the OrderedDataStore.
--   2. Reads the top LEADERBOARD_SIZE entries.
--   3. Fires UpdateLeaderboard to all clients with the ranked list.
--   4. Updates the SurfaceGui on any in-world part tagged "LeaderboardBoard".
--
-- To add a physical leaderboard board in Studio:
--   1. Place a Part/Model in the Workspace.
--   2. Tag it with "LeaderboardBoard" (front face will be used).
--   3. The manager auto-creates and refreshes the SurfaceGui.

local Players             = game:GetService("Players")
local DataStoreService    = game:GetService("DataStoreService")
local CollectionService   = game:GetService("CollectionService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData  = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData"))
local FormatUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FormatUtils"))

local Events                 = ReplicatedStorage:WaitForChild("Events")
local UpdateLeaderboardEvent = Events:WaitForChild("UpdateLeaderboard")

local LeaderboardStore = DataStoreService:GetOrderedDataStore("GlobalCoins_v1")

local LEADERBOARD_SIZE  = 10
local UPDATE_INTERVAL   = 60  -- seconds

type LeaderboardEntry = {
	rank   : number,
	name   : string,
	coins  : number,
	display: string,
}

-- ── Score submission ──────────────────────────────────────────────────────────

local function submitScore(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata or pdata.coins <= 0 then return end
	pcall(function()
		LeaderboardStore:SetAsync(tostring(player.UserId), pdata.coins)
	end)
end

-- ── Board refresh ─────────────────────────────────────────────────────────────

local function buildSurfaceGui(part: BasePart, entries: { LeaderboardEntry })
	-- Re-use or create a SurfaceGui on the front face of the part
	local surfaceGui = part:FindFirstChildWhichIsA("SurfaceGui")
	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 50
		surfaceGui.Parent = part
	end

	-- Clear previous children
	for _, child in ipairs(surfaceGui:GetChildren()) do
		child:Destroy()
	end

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = surfaceGui

	-- Title row
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1, 0.1)
	titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.Text = "🏆  TOP COLLECTORS"
	titleLabel.LayoutOrder = 0
	titleLabel.Parent = surfaceGui

	-- Entry rows (up to LEADERBOARD_SIZE)
	for i, entry in ipairs(entries) do
		local row = Instance.new("TextLabel")
		row.Size = UDim2.fromScale(1, 0.08)
		row.BackgroundColor3 = i % 2 == 0
			and Color3.fromRGB(35, 35, 50)
			or  Color3.fromRGB(45, 45, 60)
		row.TextColor3 = Color3.fromRGB(220, 220, 220)
		row.Font = Enum.Font.Gotham
		row.TextScaled = true
		row.Text = entry.display
		row.LayoutOrder = i
		row.Parent = surfaceGui
	end
end

local function refreshLeaderboard()
	-- Collect current scores from online players first
	for _, player in ipairs(Players:GetPlayers()) do
		submitScore(player)
	end

	-- Read the ordered top entries
	local ok, pages = pcall(function()
		return LeaderboardStore:GetSortedAsync(false, LEADERBOARD_SIZE)
	end)
	if not ok or not pages then return end

	local ok2, rawData = pcall(function() return pages:GetCurrentPage() end)
	if not ok2 or not rawData then return end

	local entries: { LeaderboardEntry } = {}
	for rank, entry in ipairs(rawData) do
		local displayName = "[unknown]"
		local ok3, resolvedName = pcall(function()
			return Players:GetNameFromUserIdAsync(tonumber(entry.key) or 0)
		end)
		if ok3 then displayName = resolvedName end

		local coins: number = entry.value
		local display = string.format("#%d  %s  %s", rank, displayName, FormatUtils.formatNumber(coins))
		table.insert(entries, {
			rank    = rank,
			name    = displayName,
			coins   = coins,
			display = display,
		})
	end

	-- Push to all clients
	UpdateLeaderboardEvent:FireAllClients(entries)

	-- Update in-world leaderboard boards
	for _, part in ipairs(CollectionService:GetTagged("LeaderboardBoard")) do
		if part:IsA("BasePart") then
			buildSurfaceGui(part, entries)
		end
	end
end

-- ── Lifecycle ─────────────────────────────────────────────────────────────────

Players.PlayerRemoving:Connect(submitScore)

-- Periodic refresh loop
task.spawn(function()
	while true do
		task.wait(UPDATE_INTERVAL)
		refreshLeaderboard()
	end
end)

-- Initial refresh after a short delay to let other managers initialise
task.delay(5, refreshLeaderboard)
