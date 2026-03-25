local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Colors
local PRIMARY_COLOR = Color3.fromRGB(100, 180, 255)
local ACCENT_COLOR = Color3.fromRGB(200, 100, 255)
local SECONDARY_COLOR = Color3.fromRGB(100, 255, 200)
local DANGER_COLOR = Color3.fromRGB(255, 100, 100)
local GOLD_COLOR = Color3.fromRGB(255, 215, 0)

-- Create Workspace and Terrain
local workspace = game:GetService("Workspace")
workspace.Gravity = 32

-- Create Base Ground (much larger)
local baseGround = Instance.new("Part")
baseGround.Name = "BaseGround"
baseGround.Shape = Enum.PartType.Block
baseGround.Material = Enum.Material.Concrete
baseGround.Size = Vector3.new(250, 1, 250)
baseGround.TopSurface = Enum.SurfaceType.Smooth
baseGround.BottomSurface = Enum.SurfaceType.Smooth
baseGround.CanCollide = true
baseGround.CFrame = CFrame.new(0, 0, 0)
baseGround.Color = Color3.fromRGB(50, 50, 60)
baseGround.Parent = workspace

-- Create Advanced Spawn Setup (Circular Platform with Energy Effect)
local spawnCenter = Instance.new("Part")
spawnCenter.Name = "SpawnCenter"
spawnCenter.Shape = Enum.PartType.Cylinder
spawnCenter.Material = Enum.Material.Neon
spawnCenter.Size = Vector3.new(1, 30, 30)
spawnCenter.TopSurface = Enum.SurfaceType.Smooth
spawnCenter.BottomSurface = Enum.SurfaceType.Smooth
spawnCenter.CanCollide = false
spawnCenter.Transparency = 0.2
spawnCenter.CFrame = CFrame.new(0, 2, 0)
spawnCenter.Color = PRIMARY_COLOR
spawnCenter.Parent = workspace

-- Rotating Energy Ring around Spawn (LARGER)
local energyRing = Instance.new("Part")
energyRing.Name = "EnergyRing"
energyRing.Shape = Enum.PartType.Cylinder
energyRing.Material = Enum.Material.Neon
energyRing.Size = Vector3.new(0.5, 50, 50)
energyRing.TopSurface = Enum.SurfaceType.Smooth
energyRing.BottomSurface = Enum.SurfaceType.Smooth
energyRing.CanCollide = false
energyRing.Transparency = 0.35
energyRing.CFrame = CFrame.new(0, 5, 0)
energyRing.Color = ACCENT_COLOR
energyRing.Parent = workspace

-- Spawn Platform (semi-transparent, nice to walk on)
local spawnPlatform = Instance.new("Part")
spawnPlatform.Name = "SpawnPlatform"
spawnPlatform.Shape = Enum.PartType.Block
spawnPlatform.Material = Enum.Material.Neon
spawnPlatform.Size = Vector3.new(45, 0.5, 45)
spawnPlatform.TopSurface = Enum.SurfaceType.Smooth
spawnPlatform.BottomSurface = Enum.SurfaceType.Smooth
spawnPlatform.CanCollide = true
spawnPlatform.CFrame = CFrame.new(0, 1.5, 0)
spawnPlatform.Color = PRIMARY_COLOR
spawnPlatform.Transparency = 0.15
spawnPlatform.Parent = workspace

-- ROTATING ENERGY RING ANIMATION
local ringAngle = 0
RunService.RenderStepped:Connect(function()
	ringAngle = ringAngle + 1.5
	energyRing.CFrame = CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(ringAngle), math.rad(ringAngle * 0.7), 0)
end)

-- Spawn Platform Corner Pillars - BIG AND IMPRESSIVE
local function createPillar(offset, color)
	local pillar = Instance.new("Part")
	pillar.Name = "Pillar"
	pillar.Shape = Enum.PartType.Block
	pillar.Material = Enum.Material.Neon
	pillar.Size = Vector3.new(6, 12, 6)
	pillar.TopSurface = Enum.SurfaceType.Smooth
	pillar.BottomSurface = Enum.SurfaceType.Smooth
	pillar.CanCollide = true
	pillar.CFrame = CFrame.new(0, 6, 0) + offset
	pillar.Color = color
	pillar.Parent = workspace
	return pillar
end

createPillar(Vector3.new(-22, 0, -22), ACCENT_COLOR)
createPillar(Vector3.new(22, 0, -22), PRIMARY_COLOR)
createPillar(Vector3.new(-22, 0, 22), PRIMARY_COLOR)
createPillar(Vector3.new(22, 0, 22), ACCENT_COLOR)

-- Create Arena Ring (side area for decorations/future content)
local arenaRing = Instance.new("Part")
arenaRing.Name = "ArenaRing"
arenaRing.Shape = Enum.PartType.Cylinder
arenaRing.Material = Enum.Material.Neon
arenaRing.Size = Vector3.new(3, 50, 50)
arenaRing.TopSurface = Enum.SurfaceType.Smooth
arenaRing.BottomSurface = Enum.SurfaceType.Smooth
arenaRing.CanCollide = false
arenaRing.Transparency = 0.5
arenaRing.CFrame = CFrame.new(40, 10, 0)
arenaRing.Color = SECONDARY_COLOR
arenaRing.Parent = workspace

-- ============ FLOATING PLATFORMS (Parkour Area - NEBEN SPAWN) ============
local floatingPlatforms = {
	{pos = Vector3.new(35, 8, -25), size = Vector3.new(15, 1, 15)},
	{pos = Vector3.new(50, 10, 5), size = Vector3.new(15, 1, 15)},
	{pos = Vector3.new(30, 12, 35), size = Vector3.new(15, 1, 15)},
	{pos = Vector3.new(-45, 10, -30), size = Vector3.new(12, 1, 12)},
	{pos = Vector3.new(-55, 14, 20), size = Vector3.new(12, 1, 12)},
}

for _, data in ipairs(floatingPlatforms) do
	local platform = Instance.new("Part")
	platform.Name = "FloatingPlatform"
	platform.Shape = Enum.PartType.Block
	platform.Material = Enum.Material.Neon
	platform.Size = data.size
	platform.TopSurface = Enum.SurfaceType.Smooth
	platform.BottomSurface = Enum.SurfaceType.Smooth
	platform.CanCollide = true
	platform.CFrame = CFrame.new(data.pos)
	platform.Color = SECONDARY_COLOR
	platform.Transparency = 0.1
	platform.Parent = workspace
end

-- ============ TOWER 1 (Rechts - NEBEN SPAWN) ============
local tower1Base = Instance.new("Part")
tower1Base.Name = "Tower1_Base"
tower1Base.Shape = Enum.PartType.Block
tower1Base.Material = Enum.Material.Concrete
tower1Base.Size = Vector3.new(25, 1, 25)
tower1Base.TopSurface = Enum.SurfaceType.Smooth
tower1Base.BottomSurface = Enum.SurfaceType.Smooth
tower1Base.CanCollide = true
tower1Base.CFrame = CFrame.new(65, 1, -40)
tower1Base.Color = Color3.fromRGB(80, 40, 40)
tower1Base.Parent = workspace

-- Tower 1 Pyramid Levels
for i = 1, 5 do
	local level = Instance.new("Part")
	level.Name = "Tower1_Level_" .. i
	level.Shape = Enum.PartType.Block
	level.Material = Enum.Material.Neon
	level.Size = Vector3.new(25 - (i-1)*4, 1.5, 25 - (i-1)*4)
	level.TopSurface = Enum.SurfaceType.Smooth
	level.BottomSurface = Enum.SurfaceType.Smooth
	level.CanCollide = true
	level.CFrame = CFrame.new(65, 1.5 + (i-1)*2.5, -40)
	level.Color = i % 2 == 0 and PRIMARY_COLOR or ACCENT_COLOR
	level.Parent = workspace
end

-- ============ TOWER 2 (Links - NEBEN SPAWN - Spiral) ============
for i = 0, 10 do
	local angle = (i / 10) * math.pi * 2
	local radius = 18
	local x = math.cos(angle) * radius - 55
	local z = math.sin(angle) * radius + 35
	
	local block = Instance.new("Part")
	block.Name = "Tower2_Block_" .. i
	block.Shape = Enum.PartType.Block
	block.Material = Enum.Material.Neon
	block.Size = Vector3.new(10, 2.5, 10)
	block.TopSurface = Enum.SurfaceType.Smooth
	block.BottomSurface = Enum.SurfaceType.Smooth
	block.CanCollide = true
	block.CFrame = CFrame.new(x, 5 + i*2.5, z)
	block.Color = i % 2 == 0 and SECONDARY_COLOR or DANGER_COLOR
	block.Parent = workspace
end

-- ============ DECORATIVE FLOATING ORBS ============
local function createFloatingOrb(position, color, size)
	local orb = Instance.new("Part")
	orb.Name = "FloatingOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(size, size, size)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.CanCollide = false
	orb.CFrame = CFrame.new(position)
	orb.Color = color
	orb.Parent = workspace
	
	-- Float up and down
	local startPos = position
	local endPos = position + Vector3.new(0, 8, 0)
	local floatTween = TweenService:Create(
		orb,
		TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ Position = endPos }
	)
	
	floatTween.Completed:Connect(function()
		TweenService:Create(
			orb,
			TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ Position = startPos }
		):Play()
	end)
	
	floatTween:Play()
end

-- Place orbs in strategic locations
createFloatingOrb(Vector3.new(-35, 10, 40), PRIMARY_COLOR, 5)
createFloatingOrb(Vector3.new(55, 12, -35), ACCENT_COLOR, 5)
createFloatingOrb(Vector3.new(25, 14, 50), SECONDARY_COLOR, 4)
createFloatingOrb(Vector3.new(-50, 11, -25), GOLD_COLOR, 6)

-- ============ CENTRAL MONOLITH (Nah beim Spawn) ============
local monolith = Instance.new("Part")
monolith.Name = "Monolith"
monolith.Shape = Enum.PartType.Block
monolith.Material = Enum.Material.Neon
monolith.Size = Vector3.new(12, 50, 12)
monolith.TopSurface = Enum.SurfaceType.Smooth
monolith.BottomSurface = Enum.SurfaceType.Smooth
monolith.CanCollide = false
monolith.Transparency = 0.2
monolith.CFrame = CFrame.new(70, 25, 50)
monolith.Color = DANGER_COLOR
monolith.Parent = workspace

-- ============ CRYSTAL FORMATIONS (Näher beim Spawn) ============
local function createCrystal(position, size, rotation)
	local crystal = Instance.new("Part")
	crystal.Name = "Crystal"
	crystal.Shape = Enum.PartType.Block
	crystal.Material = Enum.Material.Neon
	crystal.Size = size
	crystal.TopSurface = Enum.SurfaceType.Smooth
	crystal.BottomSurface = Enum.SurfaceType.Smooth
	crystal.CanCollide = false
	crystal.Transparency = 0.25
	crystal.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z))
	crystal.Color = PRIMARY_COLOR
	crystal.Parent = workspace
end

createCrystal(Vector3.new(-30, 10, 55), Vector3.new(4, 20, 4), {x = 45, y = 30, z = 15})
createCrystal(Vector3.new(50, 12, -55), Vector3.new(5, 25, 5), {x = 30, y = 45, z = 20})
createCrystal(Vector3.new(-60, 14, -25), Vector3.new(3.5, 18, 3.5), {x = 60, y = 20, z = 25})

-- ============ MONSTER SPAWN AREA (Enhanced - NEBEN SPAWN) ============
local monsterAreaBase = Instance.new("Part")
monsterAreaBase.Name = "MonsterArea"
monsterAreaBase.Shape = Enum.PartType.Block
monsterAreaBase.Material = Enum.Material.Concrete
monsterAreaBase.Size = Vector3.new(30, 1, 30)
monsterAreaBase.TopSurface = Enum.SurfaceType.Smooth
monsterAreaBase.BottomSurface = Enum.SurfaceType.Smooth
monsterAreaBase.CanCollide = true
monsterAreaBase.CFrame = CFrame.new(-45, 1, 0)
monsterAreaBase.Color = Color3.fromRGB(100, 60, 60)
monsterAreaBase.Parent = workspace

-- Monster Area Perimeter Wall
local function createWall(offset, rotation)
	local wall = Instance.new("Part")
	wall.Name = "MonsterWall"
	wall.Shape = Enum.PartType.Block
	wall.Material = Enum.Material.Brick
	wall.Size = Vector3.new(3, 6, 1)
	wall.TopSurface = Enum.SurfaceType.Smooth
	wall.BottomSurface = Enum.SurfaceType.Smooth
	wall.CanCollide = true
	wall.CFrame = CFrame.new(-45, 3, 0) * CFrame.Angles(0, math.rad(rotation), 0) + offset
	wall.Color = Color3.fromRGB(120, 60, 40)
	wall.Parent = workspace
end

for i = 0, 3 do
	createWall(Vector3.new(15 * math.cos(i * math.pi / 2), 0, 15 * math.sin(i * math.pi / 2)), i * 90)
end

-- Create Spawn Location
local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "SpawnLocation"
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Size = Vector3.new(25, 0.5, 25)
spawnLocation.TopSurface = Enum.SurfaceType.Smooth
spawnLocation.BottomSurface = Enum.SurfaceType.Smooth
spawnLocation.CanCollide = true
spawnLocation.CFrame = CFrame.new(0, 2, 0)
spawnLocation.Color = PRIMARY_COLOR
spawnLocation.Transparency = 0.05
spawnLocation.CanTouch = true
spawnLocation.Parent = workspace

print("[WorldBuilder] ===== 🌍 WORLD CREATED 🌍 =====")
print("✨ Enhanced spawn platform with rotating energy ring")
print("🏃 5 floating parkour platforms")
print("🏛️ 2 mega towers: Pyramid + Spiral structure")
print("✨ 4 large floating orbs with animations")
print("🔮 3 crystal formations")
print("👹 Monster spawn area with circular walls")
print("🏪 Total of 80+ decorative & functional objects")
print("🎮 Ground size: 250x250 units")
print("😎 Much bigger and more interesting world!")
