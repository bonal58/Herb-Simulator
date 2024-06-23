local regions = workspace.Regions
local players = game:GetService("Players")

local restricted = game.ReplicatedStorage:WaitForChild("restricted")

for _, region in pairs(regions:GetChildren()) do
	for _, regionHitbox in pairs(region:GetChildren()) do
		if regionHitbox:IsA("BasePart") then
			regionHitbox.Transparency = 1
			regionHitbox.Touched:Connect(function(hit)
				if hit.Parent:IsA("Model") then
					if hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Parent ~= workspace.Customers then
						local player = players:GetPlayerFromCharacter(hit.Parent)
						local illegal = true
						for _, allowed in pairs(regionHitbox.Parent.Allowed:GetChildren()) do
							if player.Team == allowed.Value then
								illegal = false
							end
						end
						if illegal then
							restricted:FireClient(player, player.Team.Name .. " shouldn't go there", regionHitbox, player.Character)
						end
					end
				end
			end)
		end
	end
end

return {}