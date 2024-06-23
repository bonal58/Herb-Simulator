local ui = {}

local teams = require(script.Parent.teams)
local join = game.ReplicatedStorage:WaitForChild("join")
local tweenService = game:GetService("TweenService")

local function prepareForGameplay(intro)
	intro:WaitForChild("Main").Visible = false
	
	workspace.Camera.CameraType = Enum.CameraType.Custom
	workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
end
function ui.prepareForIntro()
	local intro = game.Players.LocalPlayer.PlayerGui.Intro
	intro.Main.Visible = true
	
	workspace.Camera.CameraType = Enum.CameraType.Scriptable
	workspace.Camera.CFrame = CFrame.new(workspace:WaitForChild("IntroCamFrom").Position, workspace:WaitForChild("IntroCamTo").Position)
end

function ui.loadIntro(intro)
	for _, button in pairs(intro.Main.Teams:GetChildren()) do
		if button:IsA("ImageButton") and button.Name ~= "default" then
			button:Destroy()
		end
	end
	for _, team in pairs(teams.getTeams()) do
		local teamButton = intro.Main.Teams.default:Clone()
		teamButton.Parent = intro.Main.Teams
		teamButton.title.Text = team.team.Name
		teamButton.plrs.Text = team.players .. "/" .. team.max
		teamButton.Visible = true
		teamButton.Name = "team"
		teamButton.BackgroundColor = team.color
		if team.players >= team.max then
			teamButton.join.Visible = false
		end
		teamButton.MouseButton1Click:Connect(function()
			if join:InvokeServer(tostring(team.team)) then
				prepareForGameplay(intro)
			else
				warn("You cannot join this team")
			end
		end)
	end
	return true
end

local extended = false
function ui.loadHud(hud)
	hud.notification.Visible = false
	hud.menu.extend.Size = UDim2.fromScale(0, 1)
	hud.menu.MouseButton1Click:Connect(function()
		tweenService:Create(hud.menu.extend, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(extended and 0 or 2, 1),
			Rotation = extended and 0 or 360
		}):Play()
		extended = not extended
	end)
	hud.menu.extend.teams.MouseButton1Click:Connect(function()
		if join:InvokeServer("Neutral") then
			hud.menu.extend.Size = UDim2.fromScale(0, 1)
			hud.menu.extend.Rotation = 0
			extended = false
			ui.prepareForIntro()
		end
	end)
end

local player = game.Players.LocalPlayer
function ui.notify(message)
	local newNotification = player.PlayerGui.Hud.notification:Clone()
	newNotification.Name = "newNotification"
	newNotification.Parent = player.PlayerGui.Hud
	newNotification.Text = message
	newNotification.Visible = true
	
	local randomOffset = Random.new():NextNumber(-.12, .12)

	tweenService:Create(newNotification, TweenInfo.new(.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(.5 + randomOffset, .9 - Random.new():NextNumber(0, .03)),
		Rotation = randomOffset * 100
	}):Play()
	wait(2)
	tweenService:Create(newNotification, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(.5, 1),
		TextTransparency = 1,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 0),
		Rotation = 0
	}):Play()
	wait(4)
	newNotification:Destroy()
end

return ui