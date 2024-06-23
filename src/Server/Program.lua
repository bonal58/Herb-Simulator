local customer = require(script.customer)
local doors = require(script.doors)
local products = require(script.products)
local items = require(script.items)
require(script.joining)
require(script.permissions)

spawn(function()
	while wait(.5) do
		customer.create()
	end
end)

-- doors
local openTriggers = {}

for _, door in pairs(workspace.Doors:GetChildren()) do
	if door.Name ~= "Gate" then
		continue
	end
	
	local isOpen = Instance.new("BoolValue", door)
	isOpen.Name = "isOpen"
	
	for _, prox in pairs(door.PrimaryPart:GetDescendants()) do
		if prox:IsA("ProximityPrompt") then
			table.insert(openTriggers, prox)
		end
	end
end

for _, openTrigger in pairs(openTriggers) do
	openTrigger.Triggered:Connect(function()
		doors.openGate(openTrigger.Parent.Parent.Parent)
	end)
end

-- handle item pickups
for _, pickup in pairs(workspace.ItemPickups:GetChildren()) do
	local pickupCD = Instance.new("ClickDetector", pickup.Handle)
	pickupCD.MouseClick:Connect(function(player)
		items.requestItemPickup(player, pickup)
	end)
end