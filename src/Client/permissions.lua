local permissions = {}

local ui = require(script.Parent.ui)

local tweenService = game:GetService("TweenService")
local function animateRegion(regionHitbox)
	regionHitbox.Color = Color3.fromRGB(255, 0, 4)
	tweenService:Create(regionHitbox, TweenInfo.new(.5), {
		Transparency = .8
	}):Play()
	wait(.5)
	tweenService:Create(regionHitbox, TweenInfo.new(.5), {
		Transparency = 1
	}):Play()
end

local hitDebounces = {}
function permissions.restrict(message, regionHitbox, character)
	regionHitbox.CanCollide = true
	if not table.find(hitDebounces, regionHitbox) then
		spawn(function()
			ui.notify(message)
		end)
		table.insert(hitDebounces, regionHitbox)
		character.Humanoid.Jump = true
		character.HumanoidRootPart:ApplyImpulse((
			Vector3.new(
				character.HumanoidRootPart.Position.X,
				character.HumanoidRootPart.Position.Y + 15,
				character.HumanoidRootPart.Position.Z) - regionHitbox.Position).Unit * 1000
			)
		animateRegion(regionHitbox)
		wait(.2)
		regionHitbox.CanCollide = false
		table.remove(hitDebounces, table.find(hitDebounces, regionHitbox))
	end
end

return permissions