local join = game.ReplicatedStorage:WaitForChild("join")

-- put UI in replicatedfirst
game.StarterGui.Intro.Parent = game.ReplicatedFirst
game.StarterGui.Hud.Parent = game.ReplicatedFirst

join.OnServerInvoke = function(player, team)
	if game.Teams[team] == game.Teams.Neutral then
		player.Team = game.Teams[team]
		player.Character = nil
		
		for _, item in pairs(player.Backpack:GetChildren()) do
			item:Destroy()
		end
		return true
	end
	if #game.Teams[team]:GetPlayers() < game.Teams[team].max.Value then
		player.Team = game.Teams[team]
		player:LoadCharacter()
		
		local humanoidDescription = player.Character.Humanoid:GetAppliedDescription()
		humanoidDescription.Shirt = game.Teams[team]:FindFirstChild("shirt") and game.Teams[team].shirt.Value or 1307761638
		humanoidDescription.Pants = game.Teams[team]:FindFirstChild("pants") and game.Teams[team].pants.Value or 5666581419
		humanoidDescription.HeadColor = Color3.fromRGB(127, 127, 127)
		humanoidDescription.WaistAccessory = "15255144817"
		player.Character.Humanoid:ApplyDescription(humanoidDescription)
		
		if player.Team:FindFirstChild("Items") then
			for _, item in pairs(player.Team.Items:GetChildren()) do
				local itemClone = item.Value:Clone()
				itemClone.Parent = player.Backpack
			end
		end
		
		return true
	end
	return false
end

return {}