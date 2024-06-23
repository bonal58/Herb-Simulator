local customer = {}

local chatService = game:GetService("Chat")
local customers = workspace.Customers
local customerWalkPath = workspace.CustomerWalkPath
local computer = require(script.Parent.computer)
local signs = require(script.Parent.signs)
local products = require(script.Parent.products)

local tweenService = game:GetService("TweenService")

local ghostProducts = {}
local counterHB = workspace.CounterHitbox
function ghostProducts.create(desiredProducts)
	local offsetFromCenter = 0
	local offsetLeft = true
	for _, desiredProduct in pairs(desiredProducts:GetChildren()) do
		local ghost = game.ServerStorage.Products[desiredProduct.Name]:Clone()
		ghost.Handle.Anchored = true
		ghost.Handle.CanTouch = false
		local soldValue = Instance.new("BoolValue", ghost)
		soldValue.Name = "sold"
		ghost.Parent = workspace.Ghosts
		local fullfilled = Instance.new("BoolValue", ghost)
		fullfilled.Name = "fullfilled"
		for _, v in pairs(ghost:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "Handle" then
				v.Transparency = .9
			end
		end
		ghost.Handle.CFrame = CFrame.new(
			Vector3.new(
				counterHB.Position.X + Random.new():NextNumber(-1.5, 1.5),
				counterHB.Position.Y,
				counterHB.Position.Z + (offsetLeft and offsetFromCenter or -offsetFromCenter)
			)
		) * CFrame.Angles(0, math.rad(-90), math.rad(-90))
		tweenService:Create(ghost.Handle, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			CFrame = CFrame.new(
				Vector3.new(
					ghost.Handle.Position.X,
					ghost.Handle.Position.Y + 1.2,
					ghost.Handle.Position.Z
				)
			) * CFrame.Angles(0, math.rad(-90), math.rad(-90))
		}):Play()
		offsetFromCenter += 1
		offsetLeft = not offsetLeft
		wait(.1)
	end
end
function ghostProducts.destroy(customer)
	for _, ghostProduct in pairs(workspace.Ghosts:GetChildren()) do
		if ghostProduct.sold.Value then
			ghostProduct.Parent = customer.purchases
		end
	end
	
	local purchases = customer.purchases:GetChildren()
	local desiredProducts = customer.desiredProducts:GetChildren()
	local satisfaction = #purchases / #desiredProducts * 100
	
	signs.satisfactionUpdate(satisfaction)
	
	for _, ghostProduct in pairs(workspace.Ghosts:GetChildren()) do
		spawn(function()
			for _, v in pairs(ghostProduct:GetDescendants()) do
				if v:IsA("BasePart") then
					tweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, 0),
						Transparency = 1
					}):Play()
				elseif v:IsA("TextLabel") then
					tweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						TextTransparency = 1,
						TextSize = 0
					}):Play()
				end
			end
			wait(1)
			ghostProduct:Destroy()
		end)
	end
	
	wait(.5)
	
	for _, purchase in pairs(purchases) do
		spawn(function()
			while customer do
				if not purchase:FindFirstChild("Handle") then
					return
				end
				tweenService:Create(purchase.Handle, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = customer.HumanoidRootPart.CFrame
				}):Play()
				wait()
			end
		end)
	end
end

local function readyForOrder(customer)
	local customerProximity = customer.HumanoidRootPart.OfferAttachment.ProximityPrompt
	customerProximity.Enabled = true
	customerProximity.Triggered:Wait()
	customerProximity.Enabled = false
	ghostProducts.create(customer.desiredProducts)
	computer.takeOrder(customer)
	ghostProducts.destroy(customer)
end

local function startWalkPath(customer)
	spawn(function()
		local humanoid = customer.Humanoid
		local currentNode = -1
		local done = false
		repeat
			local walkToNode = customerWalkPath:FindFirstChild(currentNode + 1)
			if walkToNode then
				if not walkToNode:FindFirstChildWhichIsA("BoolValue") then

					-- remove occupied bool when moving to the next one
					if customerWalkPath:FindFirstChild(currentNode) then
						if customerWalkPath:FindFirstChild(currentNode):FindFirstChildWhichIsA("BoolValue") then
							customerWalkPath:FindFirstChild(currentNode):FindFirstChildWhichIsA("BoolValue"):Destroy()
						end
					end

					-- insert occupation in the node we walking to
					local occupied = Instance.new("BoolValue", walkToNode)
					humanoid.WalkToPoint = walkToNode.Position

					-- checkout code
					if walkToNode:FindFirstChild("0") then
						humanoid.WalkToPoint = walkToNode.Position
						wait((customer.HumanoidRootPart.Position - walkToNode.Position).Magnitude / 16)
						humanoid.WalkToPoint = walkToNode:FindFirstChild("0").Position
						chatService:Chat(customer.Head, "Hi")
						readyForOrder(customer)
						currentNode += 1
					else
						currentNode += 1
					end

				end
			else
				-- final node code
				print("a customer left the store")
				local customerPurchases = 0
				for _, purchase in pairs(customer.purchases:GetChildren()) do
					customerPurchases += purchase.grams.Value
				end
				signs.soldIncrease(customerPurchases)
				customerWalkPath:FindFirstChild(currentNode):FindFirstChildWhichIsA("BoolValue"):Destroy()
				customer:Destroy()
				done = true
			end
			if customer:FindFirstChild("HumanoidRootPart") then
				wait((customer.HumanoidRootPart.Position - walkToNode.Position).Magnitude / 16 - .2)
			end
		until done
	end)
end

customer.create = function()
	if #customers:GetChildren() - 1 > #customerWalkPath:GetChildren() - 5 then
		return "queue full"
	end
	
	local newCustomer		= customers.default:Clone()
	--print(math.random(signs.getSatisfaction() * .05, signs.getSatisfaction() * .1))
	for _, desiredProduct in pairs(products.getProducts(math.random(signs.getSatisfaction() * .05, signs.getSatisfaction() * .1))) do
		local productFolder = Instance.new("Folder", newCustomer.desiredProducts)
		productFolder.Name	= products.getServerStorageProductByName(desiredProduct.Name).Name
		local priceValue	= Instance.new("NumberValue", productFolder)
		priceValue.Name		= "price"
		priceValue.Value	= products.getServerStorageProductByName(desiredProduct.Name).price.Value
		local gramsValue	= Instance.new("IntValue", productFolder)
		gramsValue.Name		= "grams"
		gramsValue.Value	= products.getServerStorageProductByName(desiredProduct.Name).grams.Value
	end
	newCustomer.HumanoidRootPart.CFrame = workspace.CustomerSpawn.CFrame
	newCustomer.Name = " "
	newCustomer.Parent = customers
	newCustomer.HumanoidRootPart:SetNetworkOwner(nil)
	startWalkPath(newCustomer)
end

return customer