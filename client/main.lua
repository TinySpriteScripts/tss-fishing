local SelectedBait = nil
local isFishing = false
local CancelNextCast = false
cachedData = {}

onPlayerLoaded(function()
    debugPrint("player has loaded")
end, true)

local function CancelFishing()
    CancelNextCast = true
    triggerNotify("Fishing", "Stopping Cast", 'success')
end

RegisterNetEvent("sayer-fishing:tryToFish", function(rod)
    if isFishing then CancelFishing() return end
	TryToFish(rod) 
end)

CreateThread(function()
	while true do
		Wait(1500)

		local ped = PlayerPedId()

		if cachedData["ped"] ~= ped then
			cachedData["ped"] = ped
		end
	end
end)

local function TryToCatchFish()
    if not Config.MiniGame then return true end
    if skillCheck() then
        return true
    end
    return false
end


local function IsInZone(tempCoords)
    local retval = false
    if Config.FishAnywhere then
        retval = true
    else
        for k,v in pairs(Config.FishingZones) do
            if #(tempCoords - vec3(v.Coords.x,v.Coords.y,v.Coords.z)) < v.Radius then
                retval = true
                break
            end
        end
    end
    return retval
end

local function HasFishingBait(bait)
    local retval = false
    for k,v in pairs(Config.FishingItems) do
        if v.Type == 'bait' then
            if k == bait then
                if hasItem(k, 1) then
                    retval = true
                    break
                end
            end
        end
    end
    Wait(1000)
    return retval
end

local function WaitForModel(model)
    if not IsModelValid(model) then
        return
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

local function GenerateFishingRod(ped)
    local pedPos = GetEntityCoords(ped)
    local fishingRodHash = `prop_fishing_rod_01`
    WaitForModel(fishingRodHash)
    local rodHandle = CreateObject(fishingRodHash, pedPos, true)
    AttachEntityToEntity(rodHandle, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.05, 0, 80.0, 120.0, 160.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(fishingRodHash)
    return rodHandle
end

function IsInWater()
    local startedCheck = GetGameTimer()
    local ped = cachedData["ped"]
    local pedPos = GetEntityCoords(ped)
    local forwardVector = GetEntityForwardVector(ped)
    local forwardPos = vector3(pedPos["x"] + forwardVector["x"] * 10, pedPos["y"] + forwardVector["y"] * 10, pedPos["z"])
    local fishHash = `a_c_fish`

    WaitForModel(fishHash)

    local waterHeight = GetWaterHeight(forwardPos["x"], forwardPos["y"], forwardPos["z"])
    local fishHandle = CreatePed(1, fishHash, forwardPos, 0.0, false)
    
    SetEntityAlpha(fishHandle, 0, true) -- makes the fish invisible.

    triggerNotify("Fishing", "Checking location...", "success")
    while GetGameTimer() - startedCheck < 3000 do
        Wait(0)
    end
    RemoveLoadingPrompt()
    local fishInWater = IsEntityInWater(fishHandle)
    DeleteEntity(fishHandle)
    SetModelAsNoLongerNeeded(fishHash)
    return fishInWater, fishInWater and vector3(forwardPos["x"], forwardPos["y"], waterHeight) or false
end

local function PlayAnimation(ped, dict, anim, settings)
	if dict then
        CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

function TryToFish(rod)
    if IsPedSwimming(cachedData["ped"]) then return triggerNotify("Fishing","You can't be swimming and fishing at the same time.", "error") end 
    if IsPedInAnyVehicle(cachedData["ped"]) then return triggerNotify("Fishing","You need to exit your vehicle to start fishing.", "error") end 
    local tempCoords = GetEntityCoords(cachedData["ped"])
    local waterValidated, castLocation = IsInWater()

    if waterValidated then
        local fishingRod = GenerateFishingRod(cachedData["ped"])

        if IsInZone(tempCoords) then
            CastBait(fishingRod, castLocation, false, rod)
        else
            triggerNotify("Fishing","You need to be in a fishing zone", "primary")
            DeleteEntity(fishingRod)
        end
    else
        triggerNotify("Fishing","You need to aim towards the water to fish", "primary")
    end
end

RegisterNetEvent('sayer-fishing:BaitRod',function(bait)
    if not isFishing then return end
    if not Config.FishingItems[bait] then print("Incorrect Item") return end
    if Config.FishingItems[bait].Type ~= 'bait' then print("Incorrect Item") return end
    SelectedBait = bait
end)

function CastBait(rodHandle, castLocation, notFirst, rod)
    if isFishing then return end
    if not hasItem(rod, 1) then triggerNotify("Fishing", "Rod isnt in your inventory", 'error') return end
    isFishing = true

    local startedCasting = GetGameTimer()

    if not notFirst then
        triggerNotify("Fishing",'Please select your bait in inventory', 'success')
    end

    repeat
        Wait(10)
    until SelectedBait ~= nil

    if not HasFishingBait(SelectedBait) then
        if not notFirst then
            triggerNotify("Fishing",'You don\'t have any bait!', 'error')
        else
            triggerNotify("Fishing",'Ran out of bait', 'error')
        end
        SelectedBait = nil
        CancelNextCast = false
        isFishing = false
        return DeleteEntity(rodHandle)
    end

    PlayAnimation(cachedData["ped"], "mini@tennis", "forehand_ts_md_far", {
        ["flag"] = 48
    })

    while IsEntityPlayingAnim(cachedData["ped"], "mini@tennis", "forehand_ts_md_far", 3) do
        Wait(0)
    end

    PlayAnimation(cachedData["ped"], "amb@world_human_stand_fishing@idle_a", "idle_c", {
        ["flag"] = 11
    })

    local startedBaiting = GetGameTimer()
    local randomBait = math.random(Config.CatchTime.Min, Config.CatchTime.Max)
    local realBaitTime = randomBait * 1000

    triggerNotify("Fishing","Waiting for a fish to bite...", "success")
    TriggerServerEvent('sayer-fishing:RemoveItem',SelectedBait,1)

    local interupted = false

    Wait(1000)

    while GetGameTimer() - startedBaiting < realBaitTime do
        Wait(5)

        if not IsEntityPlayingAnim(cachedData["ped"], "amb@world_human_stand_fishing@idle_a", "idle_c", 3) then
            interupted = true

            break
        end
    end

    RemoveLoadingPrompt()

    if interupted or CancelNextCast then
        ClearPedTasks(cachedData["ped"])

        isFishing = false
        CancelNextCast = false
        SelectedBait = nil
        -- CastBait(rodHandle, castLocation, true, rod)
        return DeleteEntity(rodHandle)
    end

    if TryToCatchFish() then
        TriggerServerEvent("sayer-fishing:receiveFish", rod, SelectedBait)
    else
        triggerNotify("Fishing","The fish got loose.", "error")
    end

    ClearPedTasks(cachedData["ped"])
    isFishing = false
    CastBait(rodHandle, castLocation, true, rod)
    return DeleteEntity(rodHandle)
end