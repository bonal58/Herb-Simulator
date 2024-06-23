local computer = {}

local displayGui = workspace.Computer.display.SurfaceGui
local progress = displayGui.progress
local progressText = displayGui.progressText
local order = displayGui.order

local tweenService = game:GetService("TweenService")

local function createProgressTween(t)
	return tweenService:Create(progress, TweenInfo.new(t, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(0, .15)
	})
end

local progressTween

local function startProgress(t)
	progress.Size = UDim2.fromScale(1, .15)
	progressText.Text = t .. " sec"
	progressTween = createProgressTween(t)
	progressTween:Play()
	for i = 1, t, 1 do
		wait(1)
		progressText.Text = t - i .. " sec"
	end
end

function computer.updateProgress(purchases, desiredProducts)
	order.Text = purchases .. "/" .. desiredProducts
end

function computer.takeOrder(customer)
	startProgress(math.random(10, 14))
end

return computer