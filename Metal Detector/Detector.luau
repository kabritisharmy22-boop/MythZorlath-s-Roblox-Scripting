local Part = script.Parent

local SafeBrickColor = BrickColor.new("Bright green")
local UnSafeBrickColor = BrickColor.new("Bright red")

local function ShowIndecator(Part, Indecation)
	if Indecation == "UnSafe" then
		Part.BrickColor = UnSafeBrickColor		
	elseif Indecation == "Safe" then
		Part.BrickColor = SafeBrickColor
	end
	
	print(Indecation)
	
	print("Player has been searched")
end

local Part = script.Parent

local SafeBrickColor = BrickColor.new("Bright green")
local UnSafeBrickColor = BrickColor.new("Bright red")

local function ShowIndicator(part, indication)
	if indication == "Unsafe" then
		part.BrickColor = UnSafeBrickColor		
	elseif indication == "Safe" then
		part.BrickColor = SafeBrickColor
	end

	print(indication)
	print("Player has been searched")
end

Part.Touched:Connect(function(Hit)
	local Char = Hit.Parent
	local player = game.Players:GetPlayerFromCharacter(Char)

	if player then
		print("Searching Player...")

		local hasUnsafeTool = false

		-- 1. Check tools currently equipped in the Character
		for _, item in ipairs(Char:GetChildren()) do
			if item:IsA("Tool") and item:FindFirstChild("Unsafe") then
				hasUnsafeTool = true
				break
			end
		end

		-- 2. Check tools sitting in the Backpack (if not already found)
		if not hasUnsafeTool then
			for _, tool in ipairs(player.Backpack:GetChildren()) do
				if tool:FindFirstChild("Unsafe") then
					hasUnsafeTool = true
					break
				end
			end
		end

		-- 3. Change indicator based on results
		if hasUnsafeTool then
			ShowIndicator(Part, "Unsafe")
			task.wait(1)
			Part.BrickColor = SafeBrickColor
		else
			ShowIndicator(Part, "Safe")
		end
	end
end)
