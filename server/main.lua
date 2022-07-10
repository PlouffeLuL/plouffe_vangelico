CreateThread(Vr.Init)

RegisterNetEvent("plouffe_vangelico:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    while not Server.ready do
        Wait(100)
    end

    if registred then
        local cbArray = Vr:GetData()
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_vangelico:getConfig", playerId, cbArray)
    else
        TriggerClientEvent("plouffe_vangelico:getConfig", playerId, nil)
    end
end)

RegisterNetEvent("plouffe_vangelico:entry_grinder", function(succes, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_vangelico:entry_grinder") then
        Vr:OpenEntry(playerId, succes)
    end
end)

RegisterNetEvent("plouffe_vangelico:unlock_office", function(authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_vangelico:unlock_office") then
        Vr:OpenOffice(playerId)
    end
end)

RegisterNetEvent("plouffe_vangelico:hack_succes", function(authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_vangelico:hack_succes") then
        Vr:HackSucces(playerId)
    end
end)

RegisterNetEvent("plouffe_vangelico:try_loot", function(index,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_vangelico:try_loot") then
        Vr:TryLoot(playerId, index)
    end
end)