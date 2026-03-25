--!strict
-- RankManager.server.luau
-- Handles rank progression, validation, and broadcasting rank updates to clients.

local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(
	ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerData")
)
local RankConfig = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RankConfig")
)
local RankUtils = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RankUtils")
)

local Events = ReplicatedStorage:WaitForChild("Events")
local RankUpRequestEvent = Events:WaitForChild("RankUpRequest")
local RankDataUpdatedEvent = Events:WaitForChild("RankDataUpdated")

-- ──────────────────────────────────────────────────────────────────────────────
-- Send initial rank data to player on join.
-- ──────────────────────────────────────────────────────────────────────────────

local function sendInitialRankData(player: Player)
	task.wait(0.5) -- Give GameInit time to load rank data
	local pdata = PlayerData.get(player)
	if not pdata then
		PlayerData.init(player)
		pdata = PlayerData.get(player)
	end
	if not pdata then return end

	local currentRankInfo = RankUtils.getRankInfo(pdata.rankIndex)
	local nextRankInfo = RankUtils.getNextRankInfo(pdata.rankIndex)

	RankDataUpdatedEvent:FireClient(
		player,
		pdata.rankIndex,
		currentRankInfo.name,
		currentRankInfo.multiplier,
		nextRankInfo,
		"",
		pdata.coins
	)
end

Players.PlayerAdded:Connect(sendInitialRankData)

-- ──────────────────────────────────────────────────────────────────────────────
-- Handler for rank up requests from the client.
-- ──────────────────────────────────────────────────────────────────────────────

local function handleRankUpRequest(player: Player)
	local pdata = PlayerData.get(player)
	if not pdata then
		PlayerData.init(player)
		pdata = PlayerData.get(player)
	end
	if not pdata then return end

	-- Check if already at max rank
	if RankConfig.isMaxRank(pdata.rankIndex) then
		-- Broadcast current rank info (max rank, no upgrade available)
		local currentRankInfo = RankUtils.getRankInfo(pdata.rankIndex)
		RankDataUpdatedEvent:FireClient(
			player,
			pdata.rankIndex,
			currentRankInfo.name,
			currentRankInfo.multiplier,
			nil, -- nextRankInfo
			"Max rank reached",
			pdata.coins
		)
		return
	end

	-- Get next rank cost
	local nextRankInfo = RankUtils.getNextRankInfo(pdata.rankIndex)
	if not nextRankInfo then
		-- Should not happen, but guard against it
		local currentRankInfo = RankUtils.getRankInfo(pdata.rankIndex)
		RankDataUpdatedEvent:FireClient(
			player,
			pdata.rankIndex,
			currentRankInfo.name,
			currentRankInfo.multiplier,
			nil,
			"Error: next rank unavailable",
			pdata.coins
		)
		return
	end

	-- Check if player has enough coins
	if pdata.coins < nextRankInfo.cost then
		local currentRankInfo = RankUtils.getRankInfo(pdata.rankIndex)
		RankDataUpdatedEvent:FireClient(
			player,
			pdata.rankIndex,
			currentRankInfo.name,
			currentRankInfo.multiplier,
			nextRankInfo,
			"Not enough coins",
			pdata.coins
		)
		return
	end

	-- Deduct coins and upgrade rank
	pdata.coins -= nextRankInfo.cost
	pdata.rankIndex += 1

	-- Broadcast updated rank info
	local updatedRankInfo = RankUtils.getRankInfo(pdata.rankIndex)
	local futureNextRankInfo = RankUtils.getNextRankInfo(pdata.rankIndex)

	RankDataUpdatedEvent:FireClient(
		player,
		pdata.rankIndex,
		updatedRankInfo.name,
		updatedRankInfo.multiplier,
		futureNextRankInfo,
		"Rank up!",
		pdata.coins
	)
end

RankUpRequestEvent.OnServerEvent:Connect(handleRankUpRequest)
