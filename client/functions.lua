local Utils = exports.plouffe_lib:Get("Utils")
local Callback = exports.plouffe_lib:Get("Callback")

local Animation = {
    ComputerHack = {dict = "missheist_jewel@hacking"},
    Loot = {dict = "missheist_jewel", ptfxAsset = "scr_jewelheist"},
    Grinder = {dict = "ANIM@SCRIPTED@PLAYER@MISSION@TUNF_TRAIN_IG1_CONTAINER_P1@MALE@", ptfxAsset = "scr_tn_tr"}
}

local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords

local RemoveAnimDict = RemoveAnimDict
local DeleteEntity = DeleteEntity
local FreezeEntityPosition = FreezeEntityPosition

local SetEntityRotation = SetEntityRotation

local NetworkCreateSynchronisedScene = NetworkCreateSynchronisedScene
local NetworkAddPedToSynchronisedScene = NetworkAddPedToSynchronisedScene
local NetworkAddEntityToSynchronisedScene = NetworkAddEntityToSynchronisedScene
local NetworkStartSynchronisedScene = NetworkStartSynchronisedScene

local SetEntityCoords = SetEntityCoords
local SetEntityAsNoLongerNeeded = SetEntityAsNoLongerNeeded

local GetEntityRotation = GetEntityRotation
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords

local DoesEntityExist = DoesEntityExist
local GetClosestObjectOfType = GetClosestObjectOfType
local SetEntityCollision = SetEntityCollision
local GetEntityModel = GetEntityModel

local SetPtfxAssetNextCall = SetPtfxAssetNextCall
local StartNetworkedParticleFxLoopedOnEntity = StartNetworkedParticleFxLoopedOnEntity
local RemovePtfxAsset = RemovePtfxAsset
local RemoveParticleFx = RemoveParticleFx

local GiveWeaponToPed = GiveWeaponToPed
local TaskCombatPed = TaskCombatPed
local SetPedKeepTask = SetPedKeepTask

local GetPedLastWeaponImpactCoord = GetPedLastWeaponImpactCoord
local SetPedDropsWeaponsWhenDead = SetPedDropsWeaponsWhenDead
local SetPedAsNoLongerNeeded = SetPedAsNoLongerNeeded
local IsPedDeadOrDying = IsPedDeadOrDying
local SetPedArmour = SetPedArmour
local SetPedAsCop = SetPedAsCop

local Wait = Wait

local guardsCoords = {
    vector3(-627.58233642578, -226.79837036133, 38.057052612305),
    vector3(-627.60479736328, -225.20967102051, 38.057052612305),
    vector3(-626.54107666016, -224.28570556641, 38.057052612305),
    vector3(-619.7041015625, -237.26081848145, 38.057052612305),
    vector3(-618.49194335938, -237.5994720459, 38.057052612305),
    vector3(-617.41833496094, -237.12036132813, 38.057052612305)
}

local models = setmetatable({
    des_jewel_cab_start = {one = "des_jewel_cab_root2", two = "des_jewel_cab_end", loot = "smash_case_b"},
    des_jewel_cab2_start = {one = "des_jewel_cab2_rootb", two = "des_jewel_cab2_end", loot = "smash_case_b"},
    des_jewel_cab3_start = {one = "des_jewel_cab3_root", two = "des_jewel_cab3_end", loot = "smash_case_b"},
    des_jewel_cab4_start = {one = "des_jewel_cab4_rootb", two = "des_jewel_cab4_end", loot = "smash_case_tray_b"}
}, {
    __call = function(self, model)
        for k,v in pairs(self) do
            if joaat(k) == model then
                return v
            end
        end
    end
})

function Vr:Start()
    self:ExportAllZones()
    self:RegisterEvents()

    if GlobalState.VangelicoRobbery == "Started" then
        Vr:HandleRobberyZones()
    end
end

function Vr:ExportAllZones()
    for k,v in pairs(self.Zones) do
        local registered, reason = exports.plouffe_lib:Register(v)
    end
end

function Vr:RegisterEvents()
    AddEventHandler("plouffe_vangelico:onZone", function(params)
        if self[params.fnc] then
            self[params.fnc](self, params)
        end
    end)

    AddEventHandler("plouffe_vangelico:inside", Vr.Inside)
    AddEventHandler("plouffe_vangelico:exit", Vr.Exit)

    AddStateBagChangeHandler("VangelicoRobbery" ,"global", self.HandleRobberyState)
end

function Vr.EntityDamage(victim, culprit, weapon, baseDamage)
    local valid = models(GetEntityModel(victim))

    if not valid then
        return
    end

    local hasControl = Utils:AssureEntityControl(victim, 1000)
    
    if not hasControl then
        return
    end

    local rotation = GetEntityRotation(victim)
    local coords = GetEntityCoords(victim)

    DeleteEntity(victim)

    local oneEntity =  Utils:CreateProp(valid.one,  {x = coords.x, y = coords.y, z = coords.z}, nil, true, true)
    SetEntityCollision(oneEntity, false, true)
    SetEntityCoords(oneEntity, coords.x, coords.y, coords.z)
    SetEntityRotation(oneEntity, rotation.x, rotation.y, rotation.z)
    FreezeEntityPosition(oneEntity, true)
    
    local twoEntity =  Utils:CreateProp(valid.two,  {x = coords.x, y = coords.y, z = coords.z}, nil, true, true)
    SetEntityCollision(twoEntity, false, true)
    SetEntityCoords(twoEntity, coords.x, coords.y, coords.z)
    SetEntityRotation(twoEntity, rotation.x, rotation.y, rotation.z)
    FreezeEntityPosition(twoEntity, true)
    SetEntityAsNoLongerNeeded(twoEntity)

    Wait(200)
    DeleteEntity(oneEntity)
end

function Vr:HandleRobberyZones(state)
    if not state then
        for k,v in pairs(self.RobberyZones) do
            local registered, reason = exports.plouffe_lib:Register(v)
        end
    else
        for k,v in pairs(self.RobberyZones) do
            exports.plouffe_lib:DestroyZone(k)
        end
    end
end

function Vr.HandleRobberyState(bagName,key,value,reserved,replicated)
    if value == "Started" then
        Vr:HandleRobberyZones()
    elseif value == "Finished" then
        Vr:HandleRobberyZones(true)
    end
end

function Vr.HandleRobberyOfficeState(bagName,key,value,reserved,replicated)
    if value == "Unlocked" then
        Vr:CreateGuard(vector3(-631.25091552734, -229.5778503418, 38.058216094971))
    end
end

function Vr.Inside()
    if Vr.isInside then
        return
    end

    Vr.isInside = true
    Vr.eventCookie = AddEventHandler("entityDamaged", Vr.EntityDamage)
    Vr.officeCookie = AddStateBagChangeHandler("VangelicoRobberyOffice" ,"global", Vr.HandleRobberyOfficeState)

    CreateThread(function(threadId)
        while Vr.isInside do
            local sleepTimer = 0
            local ped = PlayerPedId()

            if GlobalState.VangelicoRobbery == "Started" then
                sleepTimer = 0
                local impact, coords = GetPedLastWeaponImpactCoord(ped)
                
                if impact and GlobalState.VangelicoRobberyOffice == "Locked" then
                    local dstCheck = #(coords - vec3(-628.101379, -229.463852, 38.070023))

                    if dstCheck < 0.1 then
                        TriggerServerEvent("plouffe_vangelico:unlock_office", Vr.Utils.MyAuthKey)
                        Wait(5000)
                    end
                end
            end

            Wait(sleepTimer)
        end
    end)
end

function Vr.Exit()
    RemoveEventHandler(Vr.eventCookie)
    RemoveStateBagChangeHandler(Vr.officeCookie)

    Vr.isInside = nil
    Vr.eventCookie = nil
end

function Vr:GetCloestDoorOfType(doorType)
    for k,v in pairs(self.Doords[doorType]) do
        if exports.plouffe_lib:IsInZone(("%s_1"):format(v)) then
            return v
        end
    end
end

function Vr:GetClosestDisplay(coords)
    for k,v in pairs(models) do
        local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.5, joaat(v.two), false, false, false)
        if entity ~= 0 then
            return entity, v
        end
    end

    return false
end

function Vr:Tryhack()
    if GlobalState.VangelicoRobbery ~= "Started" or GlobalState.VangelicoRobberyOffice == "Locked" then
        return
    end

    local Hack = Animation.ComputerHack:Start()

    if not Hack then
        return
    end

    local succes = exports.hacking:start(10, 3)

    Hack:Exit()

    if not succes then
        return
    end

    TriggerServerEvent("plouffe_vangelico:hack_succes", self.Utils.MyAuthKey)
end

function Vr.GrinderGuards()
    for k,v in pairs(guardsCoords) do
        Vr:CreateGuard(v)
    end
end

function Vr.TryGrinder()
    if not exports.plouffe_lib:IsInZone("vangelico_entry_1") or GlobalState.VangelicoRobbery ~= "Ready" then
        return
    end

    local canRob, reason = Callback:Sync("plouffe_vangelico:canRob", Vr.Utils.MyAuthKey)
    
    if not canRob then
        return
    end
    
    local Grinder = Animation.Grinder:Start()
    local succes = exports.memorygame:start(3,3,3,20)
    
    TriggerServerEvent("plouffe_vangelico:entry_grinder", succes, Vr.Utils.MyAuthKey)

    if not succes then
        return Grinder:Finished()
    end
    
    exports.plouffe_dispatch:SendAlert("10-90 D")

    CreateThread(Vr.GrinderGuards)

    Grinder:Cut()
end
exports("TryGrinder", Vr.TryGrinder)

function Vr:CreateGuard(coords)
    local model = "s_m_m_security_01"
    local weapon = "weapon_pumpshotgun_mk2"

    local ped = Utils:SpawnPed(model, coords, 0.0, true, true)

    GiveWeaponToPed(ped, joaat(weapon), 999, false, true)
    TaskCombatPed(ped, PlayerPedId())
    SetPedKeepTask(ped, true)
    SetPedArmour(ped, 100)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetPedAsCop(ped, true)

    self:HandleGuards(ped)
end

function Vr:HandleGuards(ped)
    
    table.insert(self.Guards, ped)

    if #self.Guards > 1 then
        return
    end

    CreateThread(function()
        while #self.Guards > 0 do
            Wait(5000)

            local remove = {}

            for k,v in pairs(self.Guards) do
                if IsPedDeadOrDying(v) or not DoesEntityExist(v) then
                    SetPedAsNoLongerNeeded(v)
                    remove[#remove + 1] = k
                end 
            end

            if #remove > 0 then
                for k,v in pairs(remove) do
                    self.Guards[v] = nil
                end
            end
        end  
    end)
end

function Vr:Tryloot(params)
    if GlobalState.VangelicoRobbery ~= "Started" or self.looting then
        return
    end

    self.looting = true

    local looted = Animation.Loot:Start()

    self.looting = false

    if not looted then
        return
    end

    TriggerServerEvent("plouffe_vangelico:try_loot", params.index, self.Utils.MyAuthKey)
end

function Animation.Grinder:Prepare()
    self.state = "Prepare"

    Utils:AssureAnim(self.dict, true)
    Utils:AssureFxAsset(self.ptfxAsset, true)

    self.ped = PlayerPedId()
    self.pedCoords = GetEntityCoords(self.ped)
    self.pedRotation = GetEntityRotation(self.ped)

    self.grinderEntity = Utils:CreateProp("tr_prop_tr_grinder_01a", {x = self.pedCoords.x, y = self.pedCoords.y, z = self.pedCoords.z - 5.0}, nil, true, true)
    self.bagEntity =  Utils:CreateProp("hei_p_m_bag_var22_arm_s", {x = self.pedCoords.x, y = self.pedCoords.y, z = self.pedCoords.z - 5.0}, nil, true, true)

    self.offset = GetOffsetFromEntityInWorldCoords(self.ped, -0.1, 2.7, -1.0)

    SetEntityCollision(self.bagEntity, false, true)
    SetEntityCollision(self.grinderEntity, false, true)

    return true
end

function Animation.Grinder:Start()
    if not self:Prepare() then
        return
    end

    self.state = "Start"

    return self
end

function Animation.Grinder:Cut()
    self.state = "Cut"

    local scene = NetworkCreateSynchronisedScene(self.offset.x, self.offset.y, self.offset.z, self.pedRotation.x, self.pedRotation.y, self.pedRotation.z, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(self.ped, scene, self.dict, "action", 1.0, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(self.bagEntity, scene, self.dict, "action_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(self.grinderEntity, scene, self.dict, "action_angle_grinder", 4.0, -8.0, 1)

    NetworkStartSynchronisedScene(scene)
    Wait(3000)

    SetPtfxAssetNextCall(self.ptfxAsset)
    self.ptfx = StartNetworkedParticleFxLoopedOnEntity('scr_tn_tr_angle_grinder_sparks', self.grinderEntity,  0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
    
    Wait(1000)
    RemoveParticleFx(self.ptfx)
    
    Wait(2000)
    self:Finished()
end

function Animation.Grinder:Finished()
    self.state = "Finished"

    DeleteEntity(self.bagEntity)
    DeleteEntity(self.grinderEntity)

    RemoveAnimDict(self.dict)
    RemovePtfxAsset(self.ptfxAsset) 
end

function Animation.Loot:Prepare()
    self.state = "Prepare"

    Utils:AssureAnim(self.dict, true)
    Utils:AssureFxAsset(self.ptfxAsset, true)

    self.ped = PlayerPedId()
    self.pedCoords = GetEntityCoords(self.ped)
    self.pedRotation = GetEntityRotation(self.ped)

    self.displayEntity, self.displayData = Vr:GetClosestDisplay(self.pedCoords)

    if not self.displayEntity then
        return false
    end

    self.anim = self.displayData.loot

    self.offset = GetOffsetFromEntityInWorldCoords(self.ped, 0.0, 0.0, self.anim == "smash_case_b" and 0.0 or - 1.0)

    return true
end

function Animation.Loot:Start()
    if not self:Prepare() then
        return false
    end

    self.state = "Start"

    local scene = NetworkCreateSynchronisedScene(self.offset.x, self.offset.y, self.offset.z, self.pedRotation.x, self.pedRotation.y, self.pedRotation.z, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(self.ped, scene, self.dict, self.anim, 1.0, -4.0, 1, 16, 1148846080, 0)
    NetworkStartSynchronisedScene(scene)

    Wait(1000)

    self:Finished()

    return true
end

function Animation.Loot:Finished()
    self.state = "Finished"

    RemoveAnimDict(self.dict)
    RemovePtfxAsset(self.ptfxAsset)
end

function Animation.ComputerHack:Prepare()
    self.state = "Prepare"

    Utils:AssureAnim(self.dict, true)

    self.ped = PlayerPedId()
    self.pedCoords = GetEntityCoords(self.ped)
    self.pedRotation = GetEntityRotation(self.ped)

    self.offset = GetOffsetFromEntityInWorldCoords(self.ped, 0.0, 0.0, 0.0)

    return true
end

function Animation.ComputerHack:Start()
    if not self:Prepare() then
        return
    end

    self.state = "Start"

    local scene = NetworkCreateSynchronisedScene(self.offset.x, self.offset.y, self.offset.z, self.pedRotation.x, self.pedRotation.y, self.pedRotation.z, 2, true, false, 1.0, 0, 1.0)
    NetworkAddPedToSynchronisedScene(self.ped, scene, self.dict, "hack_intro", 1.5, -2.0, 3341, 16, 1000.0, 0)
    NetworkStartSynchronisedScene(scene)

    Wait(500)
    
    CreateThread(function()
        self:Loop()
    end)

    return self
end

function Animation.ComputerHack:Loop()
    self.state = "Loop"

    local scene = NetworkCreateSynchronisedScene(self.offset.x, self.offset.y, self.offset.z, self.pedRotation.x, self.pedRotation.y, self.pedRotation.z, 2, false, true, 1.0, 0, 1.0)
    NetworkAddPedToSynchronisedScene(self.ped, scene, self.dict, "hack_loop", 1.5, -2.0, 3341, 16, 1000.0, 0)
    NetworkStartSynchronisedScene(scene)

    CreateThread(function()
        local i = 0

        while self.state == "Loop" and i <= 950 do
            Wait(0)
            i = i + 1
        end

        if i >= 950 then
            self:Loop()
        end
    end)
end

function Animation.ComputerHack:Exit()
    self.state = "Exit"

    local scene = NetworkCreateSynchronisedScene(self.offset.x, self.offset.y, self.offset.z, self.pedRotation.x, self.pedRotation.y, self.pedRotation.z, 2, false, false, 1065353216, 0, 1.0)
    NetworkAddPedToSynchronisedScene(self.ped, scene, self.dict, "hack_outro", 1.5, -2.0, 1148846080, 16, 1000.0, 0)
    NetworkStartSynchronisedScene(scene)

    self:Finished()
end

function Animation.ComputerHack:Finished()
    self.state = "Finished"

    RemoveAnimDict(self.dict)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == "plouffe_vangelico" then
        Animation.Grinder:Finished()
        Animation.ComputerHack:Finished()
    end
end)