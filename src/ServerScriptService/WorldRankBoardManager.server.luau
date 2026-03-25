--!strict
-- WorldRankBoardManager.server.luau
-- Detects parts tagged "RankBoard" and attaches a SurfaceGui with rank board UI.
-- The client script is instantiated on the SurfaceGui and handles all interactivity.

local CollectionService   = game:GetService("CollectionService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")

local function createRankBoardGui(part: BasePart)
	-- Create a SurfaceGui on the part
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "RankBoardSurfaceGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = part

	-- Main container with dark background
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	mainContainer.BackgroundTransparency = 0.05
	mainContainer.BorderSizePixel = 0
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.Parent = surfaceGui

	-- Add padding
	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0, 15)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.PaddingTop = UDim.new(0, 15)
	padding.Parent = mainContainer

	-- ─────────────────────────────────────────────────────────────────────────
	-- TITLE
	-- ─────────────────────────────────────────────────────────────────────────

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Text = "RANK BOARD"
	titleLabel.TextSize = 32
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextStrokeTransparency = 0.7
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = mainContainer

	-- ─────────────────────────────────────────────────────────────────────────
	-- CURRENT RANK SECTION
	-- ─────────────────────────────────────────────────────────────────────────

	local currentRankSection = Instance.new("Frame")
	currentRankSection.Name = "CurrentRankSection"
	currentRankSection.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
	currentRankSection.BackgroundTransparency = 0.3
	currentRankSection.BorderSizePixel = 1
	currentRankSection.BorderColor3 = Color3.fromRGB(100, 150, 200)
	currentRankSection.Size = UDim2.new(1, 0, 0, 70)
	currentRankSection.Position = UDim2.new(0, 0, 0, 60)
	currentRankSection.Parent = mainContainer

	local currentSectionPadding = Instance.new("UIPadding")
	currentSectionPadding.PaddingBottom = UDim.new(0, 8)
	currentSectionPadding.PaddingLeft = UDim.new(0, 10)
	currentSectionPadding.PaddingRight = UDim.new(0, 10)
	currentSectionPadding.PaddingTop = UDim.new(0, 8)
	currentSectionPadding.Parent = currentRankSection

	local currentRankLabel = Instance.new("TextLabel")
	currentRankLabel.Name = "CurrentRankLabel"
	currentRankLabel.Text = "Current Rank: Novice"
	currentRankLabel.TextSize = 20
	currentRankLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
	currentRankLabel.BackgroundTransparency = 1
	currentRankLabel.BorderSizePixel = 0
	currentRankLabel.Size = UDim2.new(1, 0, 0, 28)
	currentRankLabel.Font = Enum.Font.GothamBold
	currentRankLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentRankLabel.Parent = currentRankSection

	local currentMultiplierLabel = Instance.new("TextLabel")
	currentMultiplierLabel.Name = "CurrentMultiplierLabel"
	currentMultiplierLabel.Text = "Multiplier: x1.0"
	currentMultiplierLabel.TextSize = 18
	currentMultiplierLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	currentMultiplierLabel.BackgroundTransparency = 1
	currentMultiplierLabel.BorderSizePixel = 0
	currentMultiplierLabel.Size = UDim2.new(1, 0, 0, 24)
	currentMultiplierLabel.Position = UDim2.new(0, 0, 0, 32)
	currentMultiplierLabel.Font = Enum.Font.Gotham
	currentMultiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentMultiplierLabel.Parent = currentRankSection

	-- ─────────────────────────────────────────────────────────────────────────
	-- COINS SECTION
	-- ─────────────────────────────────────────────────────────────────────────

	local coinsSection = Instance.new("Frame")
	coinsSection.Name = "CoinsSection"
	coinsSection.BackgroundColor3 = Color3.fromRGB(70, 50, 30)
	coinsSection.BackgroundTransparency = 0.3
	coinsSection.BorderSizePixel = 1
	coinsSection.BorderColor3 = Color3.fromRGB(200, 150, 0)
	coinsSection.Size = UDim2.new(1, 0, 0, 45)
	coinsSection.Position = UDim2.new(0, 0, 0, 135)
	coinsSection.Parent = mainContainer

	local coinsSectionPadding = Instance.new("UIPadding")
	coinsSectionPadding.PaddingBottom = UDim.new(0, 8)
	coinsSectionPadding.PaddingLeft = UDim.new(0, 10)
	coinsSectionPadding.PaddingRight = UDim.new(0, 10)
	coinsSectionPadding.PaddingTop = UDim.new(0, 8)
	coinsSectionPadding.Parent = coinsSection

	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Text = "Your Coins: 0"
	coinsLabel.TextSize = 22
	coinsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.BorderSizePixel = 0
	coinsLabel.Size = UDim2.new(1, 0, 1, 0)
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Center
	coinsLabel.Parent = coinsSection

	-- ─────────────────────────────────────────────────────────────────────────
	-- NEXT RANK SECTION
	-- ─────────────────────────────────────────────────────────────────────────

	local nextRankSection = Instance.new("Frame")
	nextRankSection.Name = "NextRankSection"
	nextRankSection.BackgroundColor3 = Color3.fromRGB(50, 30, 50)
	nextRankSection.BackgroundTransparency = 0.3
	nextRankSection.BorderSizePixel = 1
	nextRankSection.BorderColor3 = Color3.fromRGB(180, 100, 200)
	nextRankSection.Size = UDim2.new(1, 0, 0, 80)
	nextRankSection.Position = UDim2.new(0, 0, 0, 185)
	nextRankSection.Parent = mainContainer

	local nextSectionPadding = Instance.new("UIPadding")
	nextSectionPadding.PaddingBottom = UDim.new(0, 8)
	nextSectionPadding.PaddingLeft = UDim.new(0, 10)
	nextSectionPadding.PaddingRight = UDim.new(0, 10)
	nextSectionPadding.PaddingTop = UDim.new(0, 8)
	nextSectionPadding.Parent = nextRankSection

	local nextRankLabel = Instance.new("TextLabel")
	nextRankLabel.Name = "NextRankLabel"
	nextRankLabel.Text = "Next Rank: Adept"
	nextRankLabel.TextSize = 18
	nextRankLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
	nextRankLabel.BackgroundTransparency = 1
	nextRankLabel.BorderSizePixel = 0
	nextRankLabel.Size = UDim2.new(1, 0, 0, 22)
	nextRankLabel.Font = Enum.Font.GothamBold
	nextRankLabel.TextXAlignment = Enum.TextXAlignment.Left
	nextRankLabel.Parent = nextRankSection

	local nextCostLabel = Instance.new("TextLabel")
	nextCostLabel.Name = "NextCostLabel"
	nextCostLabel.Text = "Cost: 100 coins"
	nextCostLabel.TextSize = 16
	nextCostLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	nextCostLabel.BackgroundTransparency = 1
	nextCostLabel.BorderSizePixel = 0
	nextCostLabel.Size = UDim2.new(1, 0, 0, 20)
	nextCostLabel.Position = UDim2.new(0, 0, 0, 26)
	nextCostLabel.Font = Enum.Font.Gotham
	nextCostLabel.TextXAlignment = Enum.TextXAlignment.Left
	nextCostLabel.Parent = nextRankSection

	local nextMultiplierLabel = Instance.new("TextLabel")
	nextMultiplierLabel.Name = "NextMultiplierLabel"
	nextMultiplierLabel.Text = "Next Multiplier: x1.5"
	nextMultiplierLabel.TextSize = 16
	nextMultiplierLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	nextMultiplierLabel.BackgroundTransparency = 1
	nextMultiplierLabel.BorderSizePixel = 0
	nextMultiplierLabel.Size = UDim2.new(1, 0, 0, 20)
	nextMultiplierLabel.Position = UDim2.new(0, 0, 0, 50)
	nextMultiplierLabel.Font = Enum.Font.Gotham
	nextMultiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
	nextMultiplierLabel.Parent = nextRankSection

	-- ─────────────────────────────────────────────────────────────────────────
	-- RANK UP BUTTON (state-based styling)
	-- ─────────────────────────────────────────────────────────────────────────

	local rankUpButton = Instance.new("TextButton")
	rankUpButton.Name = "RankUpButton"
	rankUpButton.Text = "RANK UP"
	rankUpButton.TextSize = 20
	rankUpButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	rankUpButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	rankUpButton.BorderSizePixel = 0
	rankUpButton.Size = UDim2.new(0.8, 0, 0, 50)
	rankUpButton.Position = UDim2.new(0.1, 0, 0, 270)
	rankUpButton.Font = Enum.Font.GothamBold
	rankUpButton.Parent = mainContainer

	-- Corner radius for button
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = rankUpButton

	-- ─────────────────────────────────────────────────────────────────────────
	-- STATUS LABEL (feedback messages)
	-- ─────────────────────────────────────────────────────────────────────────

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Text = ""
	statusLabel.TextSize = 14
	statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	statusLabel.BackgroundTransparency = 1
	statusLabel.BorderSizePixel = 0
	statusLabel.Size = UDim2.new(1, 0, 0, 25)
	statusLabel.Position = UDim2.new(0, 0, 0, 330)
	statusLabel.Font = Enum.Font.GothamItalic
	statusLabel.TextXAlignment = Enum.TextXAlignment.Center
	statusLabel.Parent = mainContainer

	-- Create the client LocalScript for this board
	local clientScript = Instance.new("LocalScript")
	clientScript.Name = "RankBoardController"
	clientScript.Source = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = script.Parent
local mainContainer = gui:WaitForChild("MainContainer")

-- UI Elements
local titleLabel = mainContainer:WaitForChild("TitleLabel")
local currentRankLabel = mainContainer:WaitForChild("CurrentRankSection"):WaitForChild("CurrentRankLabel")
local currentMultiplierLabel = mainContainer:WaitForChild("CurrentRankSection"):WaitForChild("CurrentMultiplierLabel")
local coinsLabel = mainContainer:WaitForChild("CoinsSection"):WaitForChild("CoinsLabel")
local nextRankLabel = mainContainer:WaitForChild("NextRankSection"):WaitForChild("NextRankLabel")
local nextCostLabel = mainContainer:WaitForChild("NextRankSection"):WaitForChild("NextCostLabel")
local nextMultiplierLabel = mainContainer:WaitForChild("NextRankSection"):WaitForChild("NextMultiplierLabel")
local rankUpButton = mainContainer:WaitForChild("RankUpButton")
local statusLabel = mainContainer:WaitForChild("StatusLabel")

local Events = ReplicatedStorage:WaitForChild("Events")
local RankUpRequestEvent = Events:WaitForChild("RankUpRequest")
local RankDataUpdatedEvent = Events:WaitForChild("RankDataUpdated")
local UpdateCurrencyEvent = Events:WaitForChild("UpdateCurrency")

-- State tracking
local currentCoins = 0
local canAffordNextRank = false
local isMaxRank = false

-- ──────────────────────────────────────────────────────────────────────────────
-- Update button appearance based on state
-- ──────────────────────────────────────────────────────────────────────────────

local function updateButtonState()
	if isMaxRank then
		rankUpButton.Text = "MAX RANK"
		rankUpButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		rankUpButton.TextColor3 = Color3.fromRGB(200, 200, 200)
		rankUpButton.Interactable = false
	elseif canAffordNextRank then
		rankUpButton.Text = "RANK UP"
		rankUpButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
		rankUpButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		rankUpButton.Interactable = true
	else
		rankUpButton.Text = "NOT ENOUGH COINS"
		rankUpButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
		rankUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		rankUpButton.Interactable = false
	end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Update all display labels
-- ──────────────────────────────────────────────────────────────────────────────

local function updateRankDisplay(rankIndex, rankName, multiplier, nextRankInfo, statusMsg, coins)
	currentCoins = coins
	
	-- Update current rank info
	currentRankLabel.Text = "Current Rank: " .. rankName
	currentMultiplierLabel.Text = "Multiplier: x" .. tostring(multiplier)
	coinsLabel.Text = "Your Coins: " .. tostring(coins)
	
	-- Update next rank info or max rank state
	if nextRankInfo then
		nextRankLabel.Text = "Next Rank: " .. nextRankInfo.name
		nextCostLabel.Text = "Cost: " .. nextRankInfo.cost .. " coins"
		nextMultiplierLabel.Text = "Next Multiplier: x" .. tostring(nextRankInfo.multiplier or "?")
		isMaxRank = false
		canAffordNextRank = (coins >= nextRankInfo.cost)
	else
		nextRankLabel.Text = "Next Rank: —"
		nextCostLabel.Text = "Cost: —"
		nextMultiplierLabel.Text = "Next Multiplier: —"
		isMaxRank = true
		canAffordNextRank = false
	end
	
	-- Update button appearance
	updateButtonState()
	
	-- Show status message if provided
	if statusMsg and statusMsg ~= "" then
		statusLabel.Text = statusMsg
		if string.find(statusMsg, "Not enough") then
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		elseif string.find(statusMsg, "Rank up") or string.find(statusMsg, "successful") then
			statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		elseif string.find(statusMsg, "Max rank") then
			statusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
		end
		
		-- Clear status after 3 seconds
		task.delay(3, function()
			if statusLabel.Text == statusMsg then
				statusLabel.Text = ""
			end
		end)
	else
		statusLabel.Text = ""
	end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Listen for rank data updates from the server
-- ──────────────────────────────────────────────────────────────────────────────

RankDataUpdatedEvent.OnClientEvent:Connect(function(rankIndex, rankName, multiplier, nextRankInfo, statusMsg, coins)
	updateRankDisplay(rankIndex, rankName, multiplier, nextRankInfo, statusMsg, coins)
end)

-- ──────────────────────────────────────────────────────────────────────────────
-- Listen for currency updates to keep coin display fresh
-- ──────────────────────────────────────────────────────────────────────────────

UpdateCurrencyEvent.OnClientEvent:Connect(function(coins, souls, totalClicks, rollCost, soulsGained, critSouls, soulsCapacity, isFull)
	currentCoins = coins
	coinsLabel.Text = "Your Coins: " .. tostring(coins)
	
	-- Update button state if coins changed
	updateButtonState()
end)

-- ──────────────────────────────────────────────────────────────────────────────
-- Handle rank up button click
-- ──────────────────────────────────────────────────────────────────────────────

rankUpButton.MouseButton1Click:Connect(function()
	if rankUpButton.Interactable then
		RankUpRequestEvent:FireServer()
	end
end)

-- ──────────────────────────────────────────────────────────────────────────────
-- Show loading state on startup
-- ──────────────────────────────────────────────────────────────────────────────

statusLabel.Text = "Loading rank data..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
]]
	clientScript.Parent = surfaceGui
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Listen for "RankBoard" tagged parts and create boards for them
-- ──────────────────────────────────────────────────────────────────────────────

local function setupRankBoard(part: Instance)
	if part:IsA("BasePart") then
		createRankBoardGui(part)
	end
end

-- Setup any existing RankBoard parts
for _, part in ipairs(CollectionService:GetTagged("RankBoard")) do
	setupRankBoard(part)
end

-- Listen for new parts being tagged as RankBoard
CollectionService:Connect("RankBoard", function(part: Instance, added: boolean)
	if added then
		setupRankBoard(part)
	end
end)
