local Lighting = game:GetService("Lighting")

-- Set up lighting for the clicker arena
Lighting.Ambient = Color3.fromRGB(100, 120, 140)
Lighting.OutdoorAmbient = Color3.fromRGB(100, 120, 140)
Lighting.Brightness = 2
Lighting.ClockTime = 14 -- Midday

-- Create a sunlight
local sunLight = Instance.new("Part")
sunLight.Name = "Sun"
sunLight.CanCollide = false
sunLight.CanTouch = false
sunLight.Transparency = 1
sunLight.Parent = workspace

local sunlight = Instance.new("SurfaceGui")
local light = Instance.new("Light")
light.Brightness = 2
light.Color = Color3.fromRGB(255, 240, 200)
light.Parent = sunLight

-- Optional: Add fog for atmosphere
Lighting.FogColor = Color3.fromRGB(50, 60, 80)
Lighting.FogEnd = 500
Lighting.FogStart = 100

-- Create atmospheric lighting orbs (glow effect)
local function createLightOrb(position, color, brightness)
	local orb = Instance.new("Part")
	orb.Name = "LightOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(2, 2, 2)
	orb.CanCollide = false
	orb.CFrame = CFrame.new(position)
	orb.Color = color
	orb.Transparency = 0.3
	orb.Parent = workspace
	
	local light = Instance.new("PointLight")
	light.Brightness = brightness
	light.Color = color
	light.Range = 30
	light.Parent = orb
	
	return orb
end

-- Place atmospheric lights around the spawn area
createLightOrb(Vector3.new(20, 15, 20), Color3.fromRGB(100, 200, 255), 1.5)
createLightOrb(Vector3.new(-60, 15, -30), Color3.fromRGB(255, 100, 150), 1.2)
createLightOrb(Vector3.new(-20, 15, 30), Color3.fromRGB(150, 255, 100), 1.3)

print("[Lighting] World ambiance set up!")
