require(script.shovel)

local module = {}

local function determinePickupBehaviour(pickup : Model)
	if pickup:FindFirstChild("respawn") then
		spawn(function()
			pickup.Parent = game.ServerStorage
			wait(pickup.respawn.Value)
			pickup.Parent = workspace.ItemPickups
		end)
	end
end

function module.requestItemPickup(player : Player, pickup : Model)
	local allowedTeams = pickup.allowedTeams:GetChildren()
	local canPickup = false
	for _, allowedTeam in pairs(allowedTeams) do
		if player.Team == allowedTeam.Value then
			canPickup = true
			break
		end
	end
	
	if canPickup then
		local newItem = game.ServerStorage.Items[pickup.Name]:Clone()
		newItem.Parent = player.Backpack
		determinePickupBehaviour(pickup)
	end
end

return module