local Auth = exports.plouffe_lib:Get("Auth")
local Callback = exports.plouffe_lib:Get("Callback")
local Inventory = exports.plouffe_lib:Get("Inventory")
local Groups = exports.plouffe_lib:Get("Groups")
local Lang = exports.plouffe_lib:Get("Lang")

local lastRob = GetResourceKvpInt("lastRob") or 0
local startTime = 0

local doors = {
    vangelico_entry = {
        register = true,
        lock = true,
        lockOnly = true,
        interactCoords = {
            {coords = vector3(-631.19000244141, -237.43562316895, 38.076957702637), maxDst = 1.0}
        },
        doors = {
            {model = 9467943, coords = vec3(-630.426514, -238.437546, 38.206532)},
            {model = 1425919976, coords = vec3(-631.955383, -236.333267, 38.206532)}
        },
        access = {
            groups = {
                police = {rankSpecific = 7}
            }
        }
    },

    vangelico_office = {
        register = true,
        lock = true,
        lockOnly = true,
        interactCoords = {
            {coords = vector3(-628.44219970703, -229.66502380371, 38.057033538818), maxDst = 1.0}
        },
        doors = {
            {model = 1335309163, coords = vec3(-629.133850, -230.151703, 38.206585)}
        },
        access = {
            groups = {
                police = {rankSpecific = 7}
            }
        }
    }
}

function Vr.Init()
    Vr.ValidateConfig()
    Utils:CreateDepencie("plouffe_doorlock", Vr.ExportsAllDoors)
    GlobalState.VangelicoRobbery = "Ready"
    GlobalState.VangelicoRobberyOffice = "Locked"
    Server.ready = true
end

function Vr:GetData()
    local retval = {}

    for k,v in pairs(self) do
        if type(v) ~= "function" then
            retval[k] = v
        end
    end

    return retval
end

function Vr.ExportsAllDoors()
    for k,v in pairs(doors) do
        exports.plouffe_doorlock:RegisterDoor(k,v, false)
    end
end

function Vr.LoadPlayer()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    while not Server.ready do
        Wait(100)
    end

    if registred then
        local data = Vr:GetData()
        data.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_vangelico:getConfig", playerId, data)
    else
        TriggerClientEvent("plouffe_vangelico:getConfig", playerId, nil)
    end
end

function Vr.ValidateConfig()
    local minLoots = tonumber(GetConvar("plouffe_vangelico:min_loots", ""))
    local maxLoots = tonumber(GetConvar("plouffe_vangelico:max_loots", ""))

    if not minLoots then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'min_loots' convar. Refer to documentation")
        end
    elseif not maxLoots then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'max_loots' convar. Refer to documentation")
        end
    end

    local data = json.decode(GetConvar("plouffe_vangelico:loots", ""))
    if data and type(data) == "table" then
        Vr.Loots = {}

        for k,v in pairs(data) do
            table.insert(Vr.Loots, {
                name = v, min = minLoots, max = maxLoots
            })
        end
        data = nil
    end

    Vr.HackLoot = GetConvar("plouffe_vangelico:hack_loot", "")
    Vr.HackLootAmount = tonumber(GetConvar("plouffe_vangelico:hack_loot_amount", ""))
    Vr.GrinderItem = GetConvar("plouffe_vangelico:grinder_item_name", "")
    Vr.GrinderDiscItem = GetConvar("plouffe_vangelico:grinder_disc_name", "")
    Vr.minCops = tonumber(GetConvar("plouffe_vangelico:min_cops", ""))
    Vr.PoliceGroups = json.decode(GetConvar("plouffe_vangelico:police_groups", ""))
    Vr.robIntervall = tonumber(GetConvar("plouffe_vangelico:rob_interval", ""))
    Vr.timeToRob = tonumber(GetConvar("plouffe_vangelico:allowed_time_to_rob", ""))
    Vr.UseGuards = GetConvar("plouffe_vangelico:use_guards", "false") == "true"

    if not Vr.minCops then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'min_cops' convar. Refer to documentation")
        end
    elseif not Vr.HackLootAmount then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'hack_loot_amount' convar. Refer to documentation")
        end
    elseif not Vr.GrinderItem then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'grinder_item_name' convar. Refer to documentation")
        end
    elseif not Vr.GrinderDiscItem then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'grinder_disc_name' convar. Refer to documentation")
        end
    elseif not Vr.PoliceGroups then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'police_groups' convar. Refer to documentation")
        end
    elseif not Vr.robIntervall then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'rob_interval' convar. Refer to documentation")
        end
    elseif not Vr.timeToRob then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'allowed_time_to_rob' convar. Refer to documentation")
        end
    end

    Vr.timeToRob *= (60 * 60)
    Vr.robIntervall *= (60 * 60)
end

function Vr:RefreshRobbery()
    GlobalState.VangelicoRobbery = "Ready"
    GlobalState.VangelicoRobberyOffice = "Locked"

    for k,v in pairs(self.RobberyZones) do
        v.looted = nil
    end

    exports.plouffe_doorlock:UpdateDoorStateTable({
        "vangelico_entry",
        "vangelico_office"
    }, true)
end

function Vr:CanRob()
    if os.time() - lastRob > Vr.robIntervall and GlobalState.VangelicoRobbery ~= "Ready" then
        self:RefreshRobbery()
    end

    if GlobalState.VangelicoRobbery ~= "Ready" then
        return false
    end

    local count = Inventory.Search(playerId, "count", Vr.GrinderItem)
    if count < 1 then
        return false, Lang.missing_something
    end

    local count = Inventory.Search(playerId, "count", Vr.GrinderDiscItem)
    if count < 1 then
        return false, Lang.missing_something
    end

    for k,v in pairs(self.PoliceGroups) do
        local cops = Groups:GetGroupPlayers(v)

        if cops.len < self.MinCops then
            return false, Lang.bank_notEnoughCop
        end
    end

    return true
end

function Vr.OpenEntry(succes, authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_vangelico:entry_grinder") then
        return
    end

    if not Vr:CanRob() then
        return
    end

    if not Inventory.ReduceDurability(playerId, Vr.GrinderItem, 60 * 60 * 12) then
        return
    end

    local count = Inventory.Search(playerId, "count", Vr.GrinderDiscItem)

    if count < 1 then
        return
    end

    if not succes then
        return Inventory.RemoveItem(playerId, Vr.GrinderDiscItem, 1)
    end

    exports.plouffe_doorlock:UpdateDoorState("vangelico_entry", false)

    GlobalState.VangelicoRobbery = "Started"

    local time = os.time()

    lastRob = time

    SetResourceKvpInt("lastRob", time)

    startTime = time

    Vr:HandleRobbery()
end

function Vr.HackSucces(authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_vangelico:hack_succes") then
        return
    end

    if GlobalState.VangelicoRobbery ~= "Started" or GlobalState.VangelicoRobberyOffice == "Locked" or Vr.hackSucces then
        return
    end

    Vr.hackSucces = true

    if Vr.HackLootAmount > 0 then
        Inventory.AddItem(playerId, Vr.HackLoot, Vr.HackLootAmount)
    end
end

function Vr.OpenOffice(authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_vangelico:unlock_office") then
        return
    end

    if GlobalState.VangelicoRobbery ~= "Started" or GlobalState.VangelicoRobberyOffice ~= "Locked" then
        return
    end

    GlobalState.VangelicoRobberyOffice = "Unlocked"

    exports.plouffe_doorlock:UpdateDoorState("vangelico_office", false)
end

function Vr:HandleRobbery()
    CreateThread(function()
        while GlobalState.VangelicoRobbery == "Started" and self:IsAnyLootLeft() and os.time() - startTime < Vr.timeToRob do
            Wait(1000 * 10)
        end

        if GlobalState.VangelicoRobbery ~= "Finished" then
            GlobalState.VangelicoRobbery = "Finished"
        end
    end)
end

function Vr:IsAnyLootLeft()
    for k,v in pairs(self.RobberyZones) do
        if not v.looted then
            return true
        end
    end

    return false
end

function Vr.TryLoot(index,authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_vangelico:try_loot") then
        return
    end

    if not Vr.RobberyZones[index] or (Vr.RobberyZones[index] and Vr.RobberyZones[index].looted) or GlobalState.VangelicoRobbery ~= "Started" then
        return
    end

    local ped = GetPlayerPed(playerId)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - Vr.RobberyZones[index].coords) > 2.0 then
        return
    end

    Vr.RobberyZones[index].looted = true

    local data = Vr.Loots[math.random(1,#Vr.Loots)]

    Inventory.AddItem(playerId, data.name, math.random(data.min, data.max))
end

Callback:RegisterServerCallback("plouffe_vangelico:canRob", function(source, cb, authkey)
    local _source = source
    if Auth:Validate(_source,authkey) and Auth:Events(_source,"plouffe_vangelico:canRob") then
        cb(Vr:CanRob())
    else
        cb(false)
    end
end)

CreateThread(Vr.Init)