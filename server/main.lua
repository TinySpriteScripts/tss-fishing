
createCallback('sayer-fishing:GetItemData', function(source, cb, itemName)
	local retval = false
	local Player = getPlayer(source)
	if Player ~= nil then 
		if hasItem(itemName,1,source) then
			retval = true
		end
	end
	
	cb(retval)
end)

CreateThread(function()
	for k,v in pairs(Config.FishingItems) do
		createUseableItem(k, function(source, item)
			local src = source
	    	local Player = getPlayer(src)
			if v.Type == 'rod' then
				if Config.JobRequired.Enable then
					if Player.job == Config.JobRequired.JobCode then
	    				TriggerClientEvent('sayer-fishing:tryToFish', source, k)
					else
						triggerNotify("Fishing", "You Need To Be A ..."..Config.JobRequired.Label.." to use this equipment", source)
					end
				else
					TriggerClientEvent('sayer-fishing:tryToFish', source, k)
				end
			elseif v.Type == 'bait' then
				if Config.JobRequired.Enable then
					if Player.job == Config.JobRequired.JobCode then
	    				TriggerClientEvent('sayer-fishing:BaitRod', source, k)
					else
						triggerNotify("Fishing", "You Need To Be A ..."..Config.JobRequired.Label.." to use this equipment", source)
					end
				else
					TriggerClientEvent('sayer-fishing:BaitRod', source, k)
				end
			end
		end)
	end
end)

RegisterNetEvent('sayer-fishing:receiveFish', function(rodItem, baitItem)
    local src = source
    local Player = getPlayer(src)

    local luck = math.random(0,100)
	if Config.FishingItems[rodItem] ~= nil then
		if Config.FishingItems[rodItem].Type == 'rod' then
			if Config.FishingItems[rodItem].CatchMultiplier ~= nil then
				luck = luck - Config.FishingItems[rodItem].CatchMultiplier
			end
		end
	end

	local randomItem = Config.FishingItems[baitItem].CatchList[math.random(1,#Config.FishingItems[baitItem].CatchList)]
	if not Config.FishingRewards[randomItem] then print("ERROR Item "..randomItem.." does not exist in Config.FishingRewards") return end
	if luck <= Config.FishingRewards[randomItem].Chance then
		addItem(randomItem,1, src)
		debugPrint("Item = "..randomItem.." / XP = "..Config.FishingRewards[randomItem].XPGive.." !")
		triggerNotify("Fishing", "You Caught a "..Items[randomItem].label.."!", 'success', src)

		if Config.UseLevelSystem then
			AddSkillXP(src, Config.SkillCode, Config.FishingRewards[randomItem].XPGive)
		end

		if Config.FishingRelievesStress then
			local stress = GetMetadata(Player, "stress")
			local new_stress = stress - Config.StressReliefAmount
			SetMetadata(Player, "stress", new_stress)
		end

	else
		triggerNotify("Fishing", "Bait returned empty", 'error', src)
	end
end)

RegisterNetEvent('sayer-fishing:RemoveItem', function(item,amount)
	if not source then return end
	removeItem(item, amount, source)
end)

function AddSkillXP(src, skill, amount)
	if not src then return end
	if Config.DoubleXP then
		amount = amount * 2
	end
	exports['tss-skills']:AddXP(skill, amount, src)
end