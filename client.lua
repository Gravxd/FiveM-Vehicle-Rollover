local isFlipped = false

local function CrashNotification()
    lib.notify(
        {
            id = "car_rollover",
            title = "Vehicle",
            description = "Your vehicle has crashed, the engine is damaged!",
            position = "center-right",
            duration = 6000,
            style = {
                backgroundColor = "#ff963b",
                color = "#000000",
                [".description"] = {
                    color = "#000000"
                }
            },
            icon = "car-burst",
            iconColor = "#C53030"
        }
    )
end

local Running = false
local function RolloverThread()
    CreateThread(
        function()
            while Running do
                Wait(100)

                local vehicle = cache.vehicle
                if cache.vehicle then
                    local vehicleFlipped = IsEntityUpsidedown(vehicle)
                    local vehicleHeight = GetEntityHeightAboveGround(vehicle)

                    if vehicleFlipped and vehicleHeight < 3 and not isFlipped then
                        isFlipped = true
                        SetVehicleEngineHealth(vehicle, 300)
                        SetVehicleUndriveable(vehicle, true)
                        CrashNotification()
                        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)
                    end

                    if not IsEntityUpsidedown(vehicle) and isFlipped then
                        isFlipped = false
                    end
                end
            end
        end
    )
end

local BlockedClasses = {
    [8] = true, -- Motorcycles
    [13] = true, -- Cycles
    [14] = true, -- Boats   
}

lib.onCache(
    "vehicle",
    function(value)
        if not value then
            isFlipped = false
            Running = false
            return
        end

        if BlockedClasses[GetVehicleClass(value)] then
            return
        end

        if not Running then
            Running = true
            RolloverThread()
        end
    end
)
