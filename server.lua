ESX = exports['es_extended']:getSharedObject()

for k, v in pairs(Config.Items) do 
    ESX.RegisterUsableItem(k, function(source)
        TriggerClientEvent('Lux_PlaceableObjects:use', source, v)
    end)
end