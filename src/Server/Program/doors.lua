local doors = {}

local tweenservice = game:GetService("TweenService")

function doors.openGate(gate)
	local restHeight = gate.PrimaryPart.Position.Y
	if gate.PrimaryPart.Position.Y ~= restHeight then
		return
	end
	
	if gate.isOpen.Value then
		warn("Door is alreayd open")
		return
	end

	gate.isOpen.Value = true
	
	local gateOpen = tweenservice:Create(gate.PrimaryPart, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0), {
		CFrame = CFrame.new(
			gate.PrimaryPart.Position.X,
			gate.PrimaryPart.Position.Y + 12.5,
			gate.PrimaryPart.Position.Z
		)
	})
	gateOpen.Completed:Connect(function()
		wait(5)
		local gateClose = tweenservice:Create(gate.PrimaryPart, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0), {
			CFrame = CFrame.new(
				gate.PrimaryPart.Position.X,
				restHeight,
				gate.PrimaryPart.Position.Z
			)
		})
		gateClose:Play()
		gateClose.Completed:Connect(function()
			gate.isOpen.Value = false
			gate.PrimaryPart.ParticleAttachment.ParticleEmitter:Emit(300)
		end)
	end)
	gateOpen:Play()
end

return doors