ESX = exports['es_extended']:getSharedObject()

local Props = {}

for k, v in pairs(Config.Items) do 
    ESX.RegisterUsableItem(k, function(source)
        TriggerClientEvent('Lux_PlaceableObjects:use', source, k, v)
    end)
end

RegisterServerEvent('Lux_PlaceableObjects:Palce')
AddEventHandler('Lux_PlaceableObjects:Palce', function(item, prop, coords, name, heading)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, 1)
    table.insert(Props, {id = #Props + 1, item = item, prop = prop, coords = coords, name = name, heading = heading})
end)

ESX.RegisterServerCallback('Lux_PlaceableObjects:getProps', function(source, cb)
    cb(Props)
end)

RegisterServerEvent('Lux_PlaceableObjects:Remove')
AddEventHandler('Lux_PlaceableObjects:Remove', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    for i, v in ipairs(Props) do
        if v.id == id then
            xPlayer.addInventoryItem(v.item, 1)
            table.remove(Props, i)
            break
        end
    end
end)
