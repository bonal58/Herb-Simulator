local digRemote = game.ReplicatedStorage:WaitForChild("dig")
local field = workspace.Field
local dirt = game.ServerStorage.Dirt

local tweenService = game:GetService("TweenService")

local function isPositionInPart(digPos : Vector3, region : Instance)
	local RelPosition = region.CFrame:PointToObjectSpace(digPos)
	if math.abs(RelPosition.X) <= region.Size.X/2 and math.abs(RelPosition.Y) <= region.Size.Y / 2 and math.abs(RelPosition.Z) <= region.Size.Z / 2 then
		return true
	end
	return false
end

local function increaseDirtSize(dirt : MeshPart)
	local dirtScale = (dirt.Size.X + dirt.Size.Y + dirt.Size.Z) / 3
	if dirtScale > 4 then
		dirt.ready.Value = true
		return
	end
	dirt.ParticleEmitter:Emit(60)
	tweenService:Create(dirt, TweenInfo.new(.5, Enum.EasingStyle.Linear), {
		Size = Vector3.new(
			dirt.Size.X * 1.5,
			dirt.Size.Y * 1.5,
			dirt.Size.Z * 1.5
		),
		Orientation = Vector3.new(
			0,
			dirt.Orientation.Y + math.random(-45, 45),
			0
		)
	}):Play()
end

local function isDirtLocationAvailable(digPos : Vector3)

	-- check if digPos is within field
	if not isPositionInPart(digPos.WorldPosition, workspace.Regions["Harvesters team"].Part) then
		return
	end

	-- check if there is dirt nearby
	for _, dirt in pairs(field:GetChildren()) do
		local shovelDirtDist = (dirt.Position - digPos.WorldPosition).Magnitude
		if shovelDirtDist < 12 then
			if shovelDirtDist < 4 then
				if not dirt.ready.Value then
					increaseDirtSize(dirt)
				end
				return false
			end
			return false
		end
	end
	return true
end

local function handleDigRequest(player : Player, digPos : Attachment)	
	if not isDirtLocationAvailable(digPos) then
		return false
	end

	local newDirt = dirt:Clone()
	newDirt.Position = Vector3.new(
		digPos.WorldPosition.X,
		field.Position.Y + field.Size.Y / 2,
		digPos.WorldPosition.Z
	)
	newDirt.Parent = field

	local dirtOwnerRef = Instance.new("ObjectValue", newDirt)
	dirtOwnerRef.Name = "owner"
	dirtOwnerRef.Value = player

	local dirtReady = Instance.new("BoolValue", newDirt)
	dirtReady.Name = "ready"
	dirtReady.Value = false
	
end

digRemote.OnServerInvoke = handleDigRequest

return nil	