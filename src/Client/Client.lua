local players		= game:GetService("Players")
local player		= players.LocalPlayer

local teams			= require(script.teams)
local ui			= require(script.ui)
local permissions	= require(script.permissions)
local items			= require(script.items)

-- intro
local intro = game.ReplicatedFirst.Intro:Clone()
intro.Main.Visible = true
intro.Parent = player.PlayerGui
ui.prepareForIntro()

-- teams
if ui.loadIntro(intro) then
	local hud = game.ReplicatedFirst.Hud:Clone()
	hud.Parent = player.PlayerGui
	ui.loadHud(hud)
end

-- permissions
local restricted = game.ReplicatedStorage:WaitForChild("restricted")
restricted.OnClientEvent:Connect(permissions.restrict)

-- items
player.CharacterAdded:Connect(function()
	player.Backpack.ChildAdded:Connect(function(child)
		items.prepareItemForGameplay(child, player)
	end)
end)
player.CharacterRemoving:Connect(function()
	items.clearData()
end)