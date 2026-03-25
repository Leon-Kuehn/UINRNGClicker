local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

print("================================")
print("Roblox Clicker - House Hub Loading")
print("================================")

local worldModel = Workspace:FindFirstChild("ClickerHouseWorld")
if worldModel then
	worldModel:Destroy()
end

worldModel = Instance.new("Model")
worldModel.Name = "ClickerHouseWorld"
worldModel.Parent = Workspace

local function createPart(name, size, cframe, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or worldModel
	return part
end

local function styleBoardSurface(board, title, subtitle)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "BoardSurface"
	surface.Face = Enum.NormalId.Front
	surface.AlwaysOnTop = false
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 36
	surface.Parent = board

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(17, 29, 43)
	frame.BorderSizePixel = 0
	frame.Parent = surface

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(85, 164, 230)
	stroke.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(1, 0.45)
	titleLabel.Position = UDim2.fromScale(0, 0.08)
	titleLabel.Text = title
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.fromRGB(225, 238, 255)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Parent = frame

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Size = UDim2.fromScale(0.88, 0.25)
	subtitleLabel.Position = UDim2.fromScale(0.06, 0.55)
	subtitleLabel.TextWrapped = true
	subtitleLabel.Text = subtitle
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = Color3.fromRGB(165, 194, 224)
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.Parent = frame

	local hintLabel = Instance.new("TextLabel")
	hintLabel.BackgroundTransparency = 1
	hintLabel.Size = UDim2.fromScale(0.88, 0.2)
	hintLabel.Position = UDim2.fromScale(0.06, 0.8)
	hintLabel.Text = "E druecken zum Kaufen"
	hintLabel.TextScaled = true
	hintLabel.TextColor3 = Color3.fromRGB(121, 223, 161)
	hintLabel.Font = Enum.Font.GothamBold
	hintLabel.Parent = frame
end

local function createUpgradeBoard(parent, cfg, buyRequest)
	local board = createPart(
		cfg.id .. "Board",
		Vector3.new(6.4, 3.4, 0.5),
		cfg.cframe,
		cfg.color,
		Enum.Material.WoodPlanks,
		parent
	)

	styleBoardSurface(board, cfg.title, cfg.subtitle)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "BuyPrompt"
	prompt.ActionText = "Kaufen"
	prompt.ObjectText = cfg.title
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = board

	prompt.Triggered:Connect(function(player)
		if buyRequest then
			buyRequest:Fire(player, cfg.id)
		end
	end)
end

Lighting.Ambient = Color3.fromRGB(118, 126, 137)
Lighting.OutdoorAmbient = Color3.fromRGB(118, 126, 137)
Lighting.Brightness = 2.2
Lighting.ClockTime = 14
Lighting.FogStart = 300
Lighting.FogEnd = 1200
Lighting.FogColor = Color3.fromRGB(162, 180, 196)

Workspace.Gravity = 32

local ground = createPart(
	"Ground",
	Vector3.new(220, 1, 220),
	CFrame.new(0, 0, 0),
	Color3.fromRGB(71, 89, 63),
	Enum.Material.Grass,
	worldModel
)
ground.Anchored = true

local house = Instance.new("Model")
house.Name = "House"
house.Parent = worldModel

createPart("HouseFloor", Vector3.new(54, 1, 44), CFrame.new(0, 0.5, 0), Color3.fromRGB(163, 142, 116), Enum.Material.WoodPlanks, house)
createPart("HouseRoof", Vector3.new(54, 1, 44), CFrame.new(0, 15.5, 0), Color3.fromRGB(62, 72, 90), Enum.Material.Slate, house)

createPart("BackWall", Vector3.new(54, 14, 1), CFrame.new(0, 7.5, -21.5), Color3.fromRGB(222, 224, 228), Enum.Material.SmoothPlastic, house)
createPart("LeftWall", Vector3.new(1, 14, 44), CFrame.new(-26.5, 7.5, 0), Color3.fromRGB(222, 224, 228), Enum.Material.SmoothPlastic, house)
createPart("RightWall", Vector3.new(1, 14, 44), CFrame.new(26.5, 7.5, 0), Color3.fromRGB(222, 224, 228), Enum.Material.SmoothPlastic, house)

createPart("FrontWallLeft", Vector3.new(20, 14, 1), CFrame.new(-17, 7.5, 21.5), Color3.fromRGB(222, 224, 228), Enum.Material.SmoothPlastic, house)
createPart("FrontWallRight", Vector3.new(20, 14, 1), CFrame.new(17, 7.5, 21.5), Color3.fromRGB(222, 224, 228), Enum.Material.SmoothPlastic, house)
createPart("DoorTop", Vector3.new(14, 4, 1), CFrame.new(0, 13.5, 21.5), Color3.fromRGB(222, 224, 228), Enum.Material.SmoothPlastic, house)

local trimColor = Color3.fromRGB(97, 119, 143)
createPart("TrimBack", Vector3.new(54.2, 0.5, 0.8), CFrame.new(0, 14.8, -21.5), trimColor, Enum.Material.Metal, house)
createPart("TrimLeft", Vector3.new(0.8, 0.5, 44.2), CFrame.new(-26.5, 14.8, 0), trimColor, Enum.Material.Metal, house)
createPart("TrimRight", Vector3.new(0.8, 0.5, 44.2), CFrame.new(26.5, 14.8, 0), trimColor, Enum.Material.Metal, house)

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "SpawnLocation"
spawnLocation.Size = Vector3.new(10, 0.5, 10)
spawnLocation.CFrame = CFrame.new(0, 1.5, 8)
spawnLocation.Anchored = true
spawnLocation.Neutral = true
spawnLocation.Duration = 0
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Color = Color3.fromRGB(101, 184, 255)
spawnLocation.Transparency = 0.2
spawnLocation.Parent = house

local chandelierBase = createPart("Chandelier", Vector3.new(1, 1, 1), CFrame.new(0, 13.8, 0), Color3.fromRGB(255, 229, 182), Enum.Material.Neon, house)
local roomLight = Instance.new("PointLight")
roomLight.Brightness = 3
roomLight.Range = 45
roomLight.Color = Color3.fromRGB(255, 238, 212)
roomLight.Parent = chandelierBase

local boardWall = Instance.new("Model")
boardWall.Name = "UpgradeBoards"
boardWall.Parent = house

local buyUpgradeRequest = ReplicatedStorage:WaitForChild("BuyUpgradeRequest", 10)

local boards = {
	{
		id = "double_tap",
		title = "Double Tap",
		subtitle = "Basis-Schaden x2",
		color = Color3.fromRGB(69, 112, 196),
		cframe = CFrame.new(-18, 5.2, -21.2),
	},
	{
		id = "crit_chance",
		title = "Crit Chance",
		subtitle = "+10% Krit Chance",
		color = Color3.fromRGB(89, 136, 221),
		cframe = CFrame.new(-6, 5.2, -21.2),
	},
	{
		id = "crit_mult",
		title = "Crit Mult",
		subtitle = "Krit Multiplikator x2",
		color = Color3.fromRGB(102, 98, 214),
		cframe = CFrame.new(6, 5.2, -21.2),
	},
	{
		id = "auto_click",
		title = "Auto Clicker",
		subtitle = "+1 Klick pro Sekunde",
		color = Color3.fromRGB(78, 163, 199),
		cframe = CFrame.new(18, 5.2, -21.2),
	},
	{
		id = "passive_income",
		title = "Passive Income",
		subtitle = "+1 Currency pro Sekunde",
		color = Color3.fromRGB(82, 178, 134),
		cframe = CFrame.new(0, 5.2, 21.2) * CFrame.Angles(0, math.rad(180), 0),
	},
}

for _, cfg in ipairs(boards) do
	createUpgradeBoard(boardWall, cfg, buyUpgradeRequest)
end

local infoBoard = createPart(
	"InfoBoard",
	Vector3.new(10, 4.2, 0.5),
	CFrame.new(0, 5.5, 16),
	Color3.fromRGB(49, 68, 95),
	Enum.Material.WoodPlanks,
	house
)

styleBoardSurface(infoBoard, "Clicker Haus", "Klicke frei auf den Screen und kaufe Upgrades an den Tafeln.")

print("House Hub erstellt: einfach, aufgeraeumt, mit Wandtafeln fuer Upgrades/Perks.")
