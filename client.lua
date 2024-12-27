local holdingNPC = false
local npc
local pickupKey = 38 -- E key
local throwKey = 47 -- G key
local throwForce = 50.0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)

        if not holdingNPC then
            if IsControlJustPressed(1, pickupKey) then
                local nearbyPeds = GetNearbyPeds(playerPed, 3.0)
                for _, ped in ipairs(nearbyPeds) do
                    if not IsPedAPlayer(ped) then
                        holdingNPC = true
                        npc = ped
                        
                        -- Load the animation dictionary
                        RequestAnimDict("anim@heists@box_carry@")
                        while (not HasAnimDictLoaded("anim@heists@box_carry@")) do 
                            Citizen.Wait(100)
                        end

                        AttachEntityToEntity(npc, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                        TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8, -1, 49, 0, false, false, false)
                        break
                    end
                end
            end
        else
            if IsControlJustPressed(1, throwKey) then
                holdingNPC = false
                DetachEntity(npc, true, true)
                
                local forwardVector = GetEntityForwardVector(playerPed)
                local throwVelocity = vector3(forwardVector.x * throwForce, forwardVector.y * throwForce, throwForce / 2)
                ApplyForceToEntity(npc, 1, throwVelocity.x, throwVelocity.y, throwVelocity.z, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                
                ClearPedTasksImmediately(playerPed)
                npc = nil
            end
        end
    end
end)

function GetNearbyPeds(playerPed, radius)
    local peds = {}
    local handle, ped = FindFirstPed()
    local success
    repeat
        local pos = GetEntityCoords(ped)
        local distance = Vdist(pos.x, pos.y, pos.z, GetEntityCoords(playerPed))
        if not IsPedAPlayer(ped) and distance <= radius then
            table.insert(peds, ped)
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    return peds
end
