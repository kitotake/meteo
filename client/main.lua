local currentTime = { hour = 12, minute = 0 }
local weatherDisplayTime = 0
local showWeatherNotification = true

RegisterNetEvent("meteo:update")
AddEventHandler("meteo:update", function(weather, timestamp)
    print("Météo reçue côté client :", weather)
    
    SetWeather(weather)
    
    SendNUIMessage({
        type = "meteo:update",
        meteo = weather,
        timestamp = timestamp or GetFormattedTime()
    })
    
    if showWeatherNotification then
        SetNotificationTextEntry("STRING")
        AddTextComponentString("🌦️ Météo changée : " .. weather)
        DrawNotification(false, false)
        
        showWeatherNotification = false
        Citizen.SetTimeout(5000, function()
            showWeatherNotification = true
        end)
    end
end)

RegisterNetEvent("meteo:timeUpdate")
AddEventHandler("meteo:timeUpdate", function(hour, minute)
    currentTime.hour = hour
    currentTime.minute = minute
    
    NetworkOverrideClockTime(hour, minute, 0)
end)

Citizen.CreateThread(function()
    while true do
        NetworkOverrideClockTime(currentTime.hour, currentTime.minute, 0)
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if IsControlJustPressed(0, 167) then 
            weatherDisplayTime = GetGameTimer() + 3000 
        end
        
        if GetGameTimer() < weatherDisplayTime then
            local timeString = GetFormattedTime()
            local weatherString = GetCurrentWeatherType()
            
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("🕐 " .. timeString .. "\n🌤️ " .. weatherString)
            DrawText(0.85, 0.05)
        end
    end
end)


RegisterCommand("closeMe", function()
    SetNuiFocus(false, false)
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 177) then 
            SetNuiFocus(false, false)
        end
    end
end)

RegisterCommand("openmeteo", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ 
        show = true,
        type = "meteo:update",
        meteo = GetCurrentWeatherType(),
        timestamp = GetFormattedTime()
    })
end)

RegisterCommand("time", function()
    TriggerEvent('chat:addMessage', {
        color = { 0, 150, 255 },
        args = { "Info", "🕐 Heure : " .. GetFormattedTime() .. " | 🌤️ Météo : " .. GetCurrentWeatherType() }
    })
end, false)


function SetWeather(weather)
    ClearOverrideWeather()
    SetOverrideWeather(weather)
    SetWeatherTypeNowPersist(weather)
end

function GetCurrentWeatherType()
   
    local weathers = {
        "EXTRASUNNY", "CLEAR", "CLOUDS", "OVERCAST", "SMOG", "FOGGY",
        "RAIN", "THUNDER", "CLEARING", "SNOW", "SNOWLIGHT", "XMAS", "BLIZZARD", "NEUTRAL"
    }
 
    for _, weather in ipairs(weathers) do
        if GetWeatherTypeTransition() then
            return weather
        end
    end
    return "UNKNOWN"
end

function GetFormattedTime()
    return string.format("%02d:%02d", currentTime.hour, currentTime.minute)
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    print("=== CLIENT MÉTÉO INITIALISÉ ===")
    print("Commandes disponibles :")
    print("- /openmeteo : Ouvrir l'interface météo")
    print("- /time : Afficher l'heure et météo")
    print("- F6 : Afficher temporairement les infos")
    print("===============================")
end)