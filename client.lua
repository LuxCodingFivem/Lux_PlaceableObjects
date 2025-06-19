ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('Lux_PlaceableObjects:use')
AddEventHandler('Lux_PlaceableObjects:use', function(v)
    CreateThread(function()
        local PlayerPed = PlayerPedId()
        local PlayerCoords = GetEntityCoords(PlayerPed)
        local prop = CreateObject(v.prop, PlayerCoords)
        SetEntityCollision(prop, false, false)
        SetEntityAlpha(prop, 200, false)
        SetEntityDrawOutlineColor(10, 170, 210, 200)
        SetEntityDrawOutlineShader(0)
        SetEntityDrawOutline(prop, true)
        
        while true do 
            local coords = CoordsPlayerIsLookingAt()
            if coords ~= nil then
                SetEntityCoords(prop, coords)
                
                if IsControlJustReleased(0, 38) then
                    SetEntityAlpha(prop, 255, false)
                    SetEntityDrawOutline(prop, false)
                    SetEntityCollision(prop, true, true)
                    print(coords.x, coords.y, coords.z)
                    break
                end
            end
        Wait(0)
        end
    end)    
end)

function CoordsPlayerIsLookingAt()
    local playerPed = PlayerPedId() -- Get the player's PED
    local cameraCoord = GetGameplayCamCoord() -- Get camera coordinates
    local cameraRot = GetGameplayCamRot(2) -- Get camera rotation
    local direction = RotationToDirection(cameraRot) -- Convert rotation to direction vector

    local distance = 1000.0 -- Maximum distance of the raycast
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }

    local rayHandle = StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 511, playerPed, 0)
    local _, hit, hitCoord, _, _ = GetShapeTestResult(rayHandle)

    if hit == 1 then
        return hitCoord
    else
        return nil -- No hit detected
    end
end

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }

    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end