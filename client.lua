ESX = exports['es_extended']:getSharedObject()

local PropsById = {}

local function RotationToDirection(rot)
    local radX = math.rad(rot.x)
    local radZ = math.rad(rot.z)
    return vector3(
        -math.sin(radZ) * math.abs(math.cos(radX)),
         math.cos(radZ) * math.abs(math.cos(radX)),
         math.sin(radX)
    )
end

local function CoordsPlayerIsLookingAt()
    local camPos  = GetGameplayCamCoord()
    local camRot  = GetGameplayCamRot(2)
    local dir     = RotationToDirection(camRot)
    local maxDist = 1000.0
    local dest    = camPos + dir * maxDist

    local ray     = StartShapeTestRay(camPos, dest, 511, PlayerPedId(), 0)
    local _, hit, hitPos = GetShapeTestResult(ray)
    return (hit == 1) and hitPos or nil
end

RegisterNetEvent('Lux_PlaceableObjects:use')
AddEventHandler('Lux_PlaceableObjects:use', function(itemName, data)
    CreateThread(function()
        local ped   = PlayerPedId()
        local start = GetEntityCoords(ped)
        local ghost = CreateObject(data.prop, start, false, false, false)
        local heading = 0.0

        SetEntityCollision(ghost, false, false)
        SetEntityAlpha(ghost, 200,  false)
        SetEntityDrawOutlineColor(10, 170, 210, 200)
        SetEntityDrawOutlineShader(0)
        SetEntityDrawOutline(ghost, true)

        while true do
            ESX.ShowHelpNotification(string.format(Translation[Config.Locale]['place_onject']))
            local tgt = CoordsPlayerIsLookingAt()
            if tgt then
                SetEntityCoords(ghost, tgt.x, tgt.y, tgt.z)
                SetEntityHeading(ghost, heading)
            end

            if IsControlPressed(0, 174) then -- LEFT
                heading = heading + 1.0
                if heading < 0 then heading = heading + 360.0 end
            end

            if IsControlPressed(0, 175) then -- RIGHT
                heading = heading - 1.0
                if heading > 360 then heading = heading - 360.0 end
            end

            if IsControlJustReleased(0, 38) then -- E
                SetEntityAlpha(ghost, 255, false)
                SetEntityDrawOutline(ghost, false)
                SetEntityCollision(ghost, true, true)
                DeleteEntity(ghost)

                -- Rotation mit an Server senden
                TriggerServerEvent('Lux_PlaceableObjects:Palce', itemName, data.prop, tgt, data.name, heading)
                getProps()
                break
            end

            Wait(0)
        end
    end)
end)



function getProps()
    ESX.TriggerServerCallback('Lux_PlaceableObjects:getProps', function(list)
        local seen = {}

        for _, p in ipairs(list) do
            seen[p.id] = true

            if not PropsById[p.id] then
                PropsById[p.id] = {
                    id      = p.id,
                    item    = p.item,
                    model   = p.prop,
                    coords  = vector3(p.coords.x, p.coords.y, p.coords.z),
                    heading = p.heading or 0.0,
                    name    = p.name,
                    placed  = false,
                    entity  = nil
                }
            else
                PropsById[p.id].coords = vector3(p.coords.x, p.coords.y, p.coords.z)
                PropsById[p.id].heading = p.heading or 0.0
            end
        end

        for id, v in pairs(PropsById) do
            if not seen[id] then
                if v.entity then DeleteEntity(v.entity) end
                PropsById[id] = nil
            end
        end
    end)
end

CreateThread(function()
    while true do
        getProps()
        Wait(5000)
    end
end)

CreateThread(function()
    while true do
        local ped    = PlayerPedId()
        local pCoord = GetEntityCoords(ped)

        for _, v in pairs(PropsById) do
            if not v.placed then
                v.entity = CreateObject(v.model, v.coords, false, false, false)
                SetEntityHeading(v.entity, v.heading or 0.0)
                SetEntityCollision(v.entity, true, true)
                v.placed = true
            end

            if v.entity and #(pCoord - v.coords) < 2.0 then
                ESX.ShowHelpNotification(
                    string.format(Translation[Config.Locale]['collect_object'], v.name)
                )
                if IsControlJustReleased(0, 38) then
                    DeleteEntity(v.entity)
                    TriggerServerEvent('Lux_PlaceableObjects:Remove', v.id)
                end
            end
        end

        Wait(0) 
    end
end)
