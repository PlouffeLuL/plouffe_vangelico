local lastRob = GetResourceKvpInt("lastRob") or 0
local robIntervall = 60 * 60 * 3
local startTime = 0
local timeToRob = 60 * 60 * 1

function Vr.Init()
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
    if os.time() - lastRob > robIntervall and GlobalState.VangelicoRobbery ~= "Ready" then
        self:RefreshRobbery()
    end

    if GlobalState.VangelicoRobbery ~= "Ready" then
        return false
    end

    local cops = exports.plouffe_lib:GetPoliceCount()

    if cops < 4 then
        return false, ("Il n'y a pas asser de policier en service présentement")
    end

    return true
end

function Vr:OpenEntry(playerId, succes)
    if not self:CanRob() then
        return
    end

    if not Inventory.ReduceDurability(playerId, "grinder", 60 * 60 * 12) then
        return
    end

    local count = Inventory.Search(playerId, "count", "grinder_disc")

    if count < 1 then
        return
    end

    if not succes then
        return Inventory.RemoveItem(playerId, "grinder_disc", 1)
    end

    exports.plouffe_doorlock:UpdateDoorState("vangelico_entry", false)

    GlobalState.VangelicoRobbery = "Started"

    local time = os.time()

    lastRob = time

    SetResourceKvpInt("lastRob", time)

    startTime = time

    self:HandleRobbery()
end

function Vr:HackSucces(playerId)
    if GlobalState.VangelicoRobbery ~= "Started" or GlobalState.VangelicoRobberyOffice == "Locked" or self.hackSucces then
        return
    end

    self.hackSucces = true

    Inventory.AddItem(playerId, "card_fleeca", 1)
end

function Vr:OpenOffice(playerId)
    if GlobalState.VangelicoRobbery ~= "Started" or GlobalState.VangelicoRobberyOffice ~= "Locked" then
        return
    end

    GlobalState.VangelicoRobberyOffice = "Unlocked"

    exports.plouffe_doorlock:UpdateDoorState("vangelico_office", false)
end

function Vr:HandleRobbery()
    CreateThread(function()
        while GlobalState.VangelicoRobbery == "Started" and self:IsAnyLootLeft() and os.time() - startTime < timeToRob do
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

function Vr:TryLoot(playerId, index)
    if not self.RobberyZones[index] or (self.RobberyZones[index] and self.RobberyZones[index].looted) or GlobalState.VangelicoRobbery ~= "Started" then
        return
    end

    local ped = GetPlayerPed(playerId)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - self.RobberyZones[index].coords) > 2.0 then
        return
    end

    self.RobberyZones[index].looted = true

    local data = self.Loots[math.random(1,#self.Loots)]

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