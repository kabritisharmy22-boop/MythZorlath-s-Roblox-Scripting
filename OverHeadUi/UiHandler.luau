--// SERVICES
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

--// ASSETS
local Profile = script.Template.ProfileUi

--// GROUPS
local	MainGroup = 398789561

local function UpdateIcons(plr,char, listframe)
	local humanoid = char:WaitForChild("Humanoid")
	if not humanoid then return end

	local VipText = listframe:WaitForChild("VIPtext")
	
	VipText.Visible = plr:GetRankInGroupAsync(MainGroup) >= 19
end

--// HEALTH BAR
local function SetupHealthBar(character, clone)
	local humanoid = character:WaitForChild("Humanoid")
	if not humanoid then return end

	local healthBar = clone.HealthBarFrame:FindFirstChild("HealthBar")
	if not healthBar then return end

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function updateBar()
		local percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		local tween = TweenService:Create(healthBar, tweenInfo, {
			Size = UDim2.new(percent, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(
				math.floor(255 * (1 - percent)),
				math.floor(255 * percent),
				0
			)
		})
		tween:Play()
	end

	updateBar()
	humanoid.HealthChanged:Connect(updateBar)
end

local function UpdateProfile(player, character)
	local head = character:WaitForChild("Head", 5)
	if not head then return end

	local oldUI = head:FindFirstChild("ProfileUi")
	if oldUI then oldUI:Destroy() end

	local clone = Profile:Clone()
	clone.Parent = head

	local nameTag = clone.NameTag
	local rankTag = clone.RankTag
	
	
	nameTag.Text = player.Name
	rankTag.Text = player:GetRoleInGroupAsync(MainGroup)
	
	UpdateIcons(player, character, clone.ListFrame)

	-- Hook up health bar after UI is parented
	SetupHealthBar(character, clone)
end

--// PLAYER CONNECTIONS
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(1)
		UpdateProfile(player, character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			task.wait(3)
		end)
	end)
	
end)
