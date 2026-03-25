local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
	warn("[CameraController] LocalPlayer not found")
	return
end

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart", 10)

if not rootPart then
	warn("[CameraController] HumanoidRootPart not found")
	return
end

local camera = workspace.CurrentCamera

-- Set up camera to look at the arena from a good angle
local cameraOffset = Vector3.new(35, 25, 45)
local targetOffset = Vector3.new(5, 0, 0)

local function updateCamera()
	if rootPart and rootPart.Parent then
		local targetPos = rootPart.Position + targetOffset
		local cameraPos = targetPos + cameraOffset
		
		camera.CFrame = CFrame.lookAt(cameraPos, targetPos)
	end
end

-- Update camera every frame
RunService.RenderStepped:Connect(updateCamera)

print("[CameraController] Camera system ready!")
