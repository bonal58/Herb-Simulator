local items = {

}

--[[{
    ["Shovel"] =  ▼  {
       ["anims"] =  ▶ {...},
       ["digPos"] = digPos,
       ["hud"] = Shovel
    },
    ["clearData"] = "function",
    ["prepareItemForGameplay"] = "function"
}]]

local itemModules = {
	shovel = require(script.shovel)
}

local function activateItem(item)
	itemModules.shovel.dig(items, item)
end

local function equipItem(item)
	items[item].anims.idle:Play()
	items[item].hud.Visible = true
end

local function unequipItem(item)
	for _, anim in pairs(items[item].anims) do anim:Stop() end
	items[item].hud.Visible = false
end

function items.prepareItemForGameplay(item : Tool, player : Player)
	
	if items[item.Name] then
		return
	end

	-- Handle animations
	local character = player.Character

	local anims = {}
	for _, anim in pairs(item.anims:GetChildren()) do anims[anim.Name] = character.Humanoid:LoadAnimation(anim) end

	items[item.Name] = {anims = anims}

	item.Activated:Connect(function() activateItem(item.Name) end)
	item.Equipped:Connect(function() equipItem(item.Name) end)
	item.Unequipped:Connect(function() unequipItem(item.Name) end)
	
	-- Handle hud
	local itemHuds = player.PlayerGui.Hud.itemHuds
	if itemHuds:FindFirstChild(item.Name) then
		items[item.Name]["hud"] = itemHuds[item.Name]
	end
	
	-- Handle custom prepareItemForGameplay (prepareForGameplay) methods
	for _, itemModule in pairs(itemModules) do
		local hasCustomPrepareMethod = (type(itemModule) == "table") and (type(itemModule["prepareForGameplay"]) == "function")
		itemModule.prepareForGameplay(items, item, player)
	end
	
end

function items.clearData()
	for key, item in pairs(items) do
		if type(item) == "table" then
			items[key] = nil
		end
	end
end

return items