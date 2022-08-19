Vr = {}
TriggerServerEvent("plouffe_vangelico:sendConfig")
local cookie
cookie = RegisterNetEvent("plouffe_vangelico:getConfig",function(list)
	if not list then
		while true do
			Vr = nil
		end
	else
		for k,v in pairs(list) do
			Vr[k] = v
		end

		Vr:Start()
	end

	RemoveEventHandler(cookie)
end)