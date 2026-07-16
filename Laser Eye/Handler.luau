local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LazerKeyCode = Enum.KeyCode.C

local RightEyeAttachment = script.RightEyeAttachment
local LeftEyeAttachment = script.LeftEyeAttachment

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")

local TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)

-- Handle character respawning so the script doesn't break after death
local Camera = workspace.CurrentCamera
local FOV= Camera.FieldOfView


Player.CharacterAdded:Connect(function(newChar)
	Char = newChar
end)

local LazerConnection = nil
local Mouse = Player:GetMouse()
local ZoomDistence = 50
local DefaultFOV = FOV
local CurrentFOVTween = nil

local MouseAttachment = Instance.new("Attachment")
MouseAttachment.Name = "MouseLaserTarget"


local function ConnectLazers(Beam, Target)
	Beam.Attachment1 = Target
end

local function SetFOV(target)
	if CurrentFOVTween then
		CurrentFOVTween:Cancel()
	end
	CurrentFOVTween = TweenService:Create(Camera, TweenInfo, {FieldOfView = target})
	CurrentFOVTween:Play()
end

UIS.InputBegan:Connect(function(input, proccessed)
	if proccessed then return end -- Ignore input if typing in chat
	if input.KeyCode == LazerKeyCode then
		local Head = Char:WaitForChild("Head") 
		if not Head then return end
		RightEyeAttachment.Parent = Head
		LeftEyeAttachment.Parent = Head
		
		SetFOV(ZoomDistence)
		-- Parent the attachment to the world so Beams can render to it
		MouseAttachment.Parent = workspace.Terrain
		if LazerConnection then
			LazerConnection:Disconnect()
		end
		LazerConnection = RunService.RenderStepped:Connect(function()
			MouseAttachment.WorldPosition = Mouse.Hit.Position
			local targetPos = Vector3.new(Mouse.Hit.Position.X, HumanoidRootPart.Position.Y, Mouse.Hit.Position.Z)
			if (targetPos - HumanoidRootPart.Position).Magnitude > 1 then	
				HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, targetPos)
			end
			if Mouse.Target then

				local targetModel = Mouse.Target.Parent
				local enemyHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
				-- Verify a Humanoid was found and that it isn't the player's own character
				if enemyHumanoid and Player.Character and targetModel ~= Player.Character then
					enemyHumanoid:TakeDamage(5) 
				end
			end -- FIX 1: Added missing 'end' for the 'if Mouse.Target' statement
			-- Setup the beams (Must be inside the loop to update as you look around)
			ConnectLazers(LeftEyeAttachment.Beam, MouseAttachment)
			ConnectLazers(RightEyeAttachment.Beam, MouseAttachment)
		end) -- FIX 2: Added missing ')' to properly close 'Connect(function()'
	end
end)


UIS.InputEnded:Connect(function(input, proccessed)
	if input.KeyCode == LazerKeyCode then
		if LazerConnection then
			LazerConnection:Disconnect()
			LazerConnection = nil
		end
		-- Disconnect beams
		ConnectLazers(LeftEyeAttachment.Beam, nil)
		ConnectLazers(RightEyeAttachment.Beam, nil)
		
		SetFOV(DefaultFOV)
		-- FIX 2: Remove attachment from world when not in use
		MouseAttachment.Parent = nil
		-- Safety check before moving parents back to script
		local Head = Char:FindFirstChild("Head")
		if Head then
			local findLeftEyeAttachment = Head:FindFirstChild("LeftEyeAttachment")
			local findRightEyeAttachment = Head:FindFirstChild("RightEyeAttachment")
			if findLeftEyeAttachment then findLeftEyeAttachment.Parent = script end
			if findRightEyeAttachment then findRightEyeAttachment.Parent = script end
		end
	end
end)
