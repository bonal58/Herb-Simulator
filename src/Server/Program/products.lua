local products = {}

local computer = require(script.Parent.computer)

-- keep track of which products are in stock (we always want at least 1 product that is available)
local productsInStock = {}

local function giveProductToPlayer(product, player)
	local playerCarrying = 0
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if game.ServerStorage.Products[product.Name] then
			playerCarrying += 1
		end
	end
	for _, tool in pairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			playerCarrying += 1
		end
	end
	
	if playerCarrying >= 1 then
		return false
	end
	
	local productTool = game.ServerStorage.Products[product.Name]:Clone()
	productTool.Handle.Anchored = false
	handleProductsInStock(false, product)
	productTool.Parent = player.Backpack
	
	-- product touches counterHB
	productTool.Handle.Touched:Connect(function(hit)
		if hit == workspace.CounterHitbox then
			for _, ghost in pairs(workspace.Ghosts:GetChildren()) do
				if ghost.Name == productTool.Name then
					if not ghost.fullfilled.Value then
						ghost.fullfilled.Value = true
						
						for _, v in pairs(ghost:GetChildren()) do
							if v:IsA("BasePart") and v.Name ~= "Handle" then
								v.Transparency = 0
							end
						end
						
						ghost.sold.Value = true
						productTool:Destroy()
						
						return
						
					end
				end
			end
		end
	end)
	
	return true
end

function handleProductsInStock(inStockStatus, product)
	if inStockStatus then
		table.insert(productsInStock, product)
		for _, v in pairs(product:GetDescendants()) do
			if v:IsA("BasePart") then
				local cd = Instance.new("ClickDetector", v)
				cd.MaxActivationDistance = 8
				cd.MouseClick:Connect(function(player)
					local result = giveProductToPlayer(product, player)
					if result then
						print("Picked up " .. product.Name)
					else
						warn("You cannot carry more")
					end
				end)
			end
		end
	else
		product:Destroy()
		table.remove(productsInStock, table.find(productsInStock, product))
	end
end

workspace.ProductPickups.ChildAdded:Connect(function(product) handleProductsInStock(true, product) end)
--workspace.ProductPickups.ChildRemoved:Connect(function(product) handleProductsInStock(false, product) end)

for _, product in pairs(workspace.ProductPickups:GetChildren()) do
	handleProductsInStock(true, product)
end

-- return an array of random wished products
local productsStorage = game.ServerStorage.Products
function products.getProducts(itemCount) -- if the quality of the products is good, increase the itemCount
	local chosenProducts = {}
	
	local randomAvailableProduct = productsInStock[math.random(0, #productsInStock)]
	table.remove(productsInStock, table.find(productsInStock, randomAvailableProduct))
	table.insert(chosenProducts, randomAvailableProduct)
	itemCount -= 1
	
	for i=1, itemCount do 
		local randomProduct = productsStorage:GetChildren()[math.random(0, #productsStorage:GetChildren())]
		table.insert(chosenProducts, randomProduct)
	end
	return chosenProducts
end

function products.getServerStorageProductByName(productName)
	return productsStorage[productName]
end

return products