local shovel = {}

local digDebounce = false
local digKeyframe = 0
local doneMarker = nil

local digRemote = game.ReplicatedStorage:WaitForChild("dig")

local function increaseDirt(items: {}, item: Tool)
	local shovelHP = string.match(items[item].hud.health.Text, "(.-)%%")
	local digRequest = digRemote:InvokeServer(items[item].digPos)
	print(digRequest)
	items[item].hud.health.Text = shovelHP - 5 .. "%"
end

function shovel.dig(items, item)
	if not digDebounce then
		digDebounce = true
		
		items[item].anims.use.TimePosition = digKeyframe
		items[item].anims.use:Play(0)
		
		if not doneMarker then
			doneMarker = items[item].anims.use:GetMarkerReachedSignal("done"):Connect(function(keyframeName)
				digDebounce = false
				digKeyframe = items[item].anims.use.TimePosition
				increaseDirt(items, item)
			end)
		end
		
		items[item].anims.use.Stopped:Connect(function()
			digKeyframe = 0
			digDebounce = false
		end)

	else
		warn("wait")
	end
end

function shovel.prepareForGameplay(items, item, player)
	items[item.Name]["digPos"] = item.Handle.digPos
end

return shovel