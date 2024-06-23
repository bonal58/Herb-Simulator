local signs = {}

local sold = workspace.Signs.gramsSold
local satisfaction = workspace.Signs.satistfiedCustomers

function signs.soldIncrease(g)
	sold.ParticleEmitter:Emit(g * 10)
	sold.SurfaceGui.sold.Text += g
end

function signs.satisfactionUpdate(newSatisfaction)
	local oldSatisfaction = satisfaction.SurfaceGui.satisfaction.Text
	local result = (oldSatisfaction + newSatisfaction) / 2
	result *= 100
	result = math.floor(result)
	result = result / 100
	satisfaction.SurfaceGui.satisfaction.Text = result
	if newSatisfaction >= tonumber(oldSatisfaction) then
		satisfaction.greenParticle:Emit(10)
	else
		satisfaction.redParticle:Emit(10)
	end
end

function signs.getSatisfaction()
	return satisfaction.SurfaceGui.satisfaction.Text
end

return signs