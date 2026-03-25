local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Item spawner for decorative currency pickups
local ITEM_COLOR = Color3.fromRGB(255, 215, 0) -- Gold
local ITEM_SIZE = Vector3.new(1, 1, 1)

-- Find or create items container
local itemsFolder = workspace:FindFirstChild("Items")
if not itemsFolder then
	itemsFolder = Instance.new("Folder")
	itemsFolder.Name = "Items"
	itemsFolder.Parent = workspace
end

-- Function to create a collectible item
local function createItem(position, value)
	local item = Instance.new("Part")
	item.Name = "CurrencyItem_" .. value
	item.Shape = Enum.PartType.Ball
	item.Material = Enum.Material.Neon
	item.Size = ITEM_SIZE
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.CanCollide = false
	item.CFrame = CFrame.new(position)
	item.Color = ITEM_COLOR
	item.Parent = itemsFolder
	
	-- Store value
	local valueObj = Instance.new("IntValue")
	valueObj.Name = "Value"
	valueObj.Value = value
	valueObj.Parent = item
	
	-- Rotation animation
	local angle = 0
	RunService.RenderStepped:Connect(function()
		angle = angle + 2
		item.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(angle), math.rad(angle), 0)
	end)
	
	return item
end

-- Spawn items in a pattern around the monster area
local itemSpawnPositions = {
	Vector3.new(-50, 5, -15),
	Vector3.new(-50, 5, 0),
	Vector3.new(-50, 5, 15),
	Vector3.new(-30, 5, -25),
	Vector3.new(-30, 5, 25),
	Vector3.new(-20, 5, -10),
	Vector3.new(-20, 5, 10),
}

for i, pos in ipairs(itemSpawnPositions) do
	createItem(pos, 10 * i)
end

print("[ItemSpawner] Currency items spawned!")
