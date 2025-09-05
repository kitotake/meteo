
local currentWeather = "CLEAR"
local currentTime = { hour = 12, minute = 0 } 
local weatherChangeTimer = 0
local timeSpeed = 1 
local autoWeatherChange = false 
local weatherChangeInterval = 600000 

local availableWeathers = {
    "EXTRASUNNY", "CLEAR", "CLOUDS", "OVERCAST", "SMOG", "FOGGY",
    "RAIN", "THUNDER", "CLEARING", "SNOW", "SNOWLIGHT", "XMAS", "BLIZZARD", "NEUTRAL"
}


local weatherByTime = {
    [6] = {"CLEAR", "EXTRASUNNY", "CLOUDS"},     
    [12] = {"EXTRASUNNY", "CLEAR", "CLOUDS"},    
    [18] = {"OVERCAST", "CLOUDS", "CLEAR"},      
    [0] = {"FOGGY", "CLEAR", "CLOUDS"}        
}

function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function GetRandomWeather()
    return availableWeathers[math.random(1, #availableWeathers)]
end

function GetRealisticWeather()
    local hour = currentTime.hour
    local timeSlot = 12 -- défaut midi
    
    if hour >= 6 and hour < 12 then
        timeSlot = 6 -- matin
    elseif hour >= 12 and hour < 18 then
        timeSlot = 12 -- midi
    elseif hour >= 18 and hour < 24 then
        timeSlot = 18 -- soir
    else
        timeSlot = 0 -- nuit
    end
    
    local weatherOptions = weatherByTime[timeSlot]
    return weatherOptions[math.random(1, #weatherOptions)]
end

function SetWeather(newWeather)
    if newWeather ~= currentWeather then
        currentWeather = newWeather
        print("[SERVER] Changement de météo :", newWeather)

        TriggerClientEvent("meteo:update", -1, newWeather, GetFormattedTime())
        
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 0, 255, 0 },
            multiline = true,
            args = { "Serveur", "🌦️ Météo changée en : ^2" .. newWeather .. " ^7à " .. GetFormattedTime() }
        })
        
        if GetResourceState("meteo") == "started" then
            exports['meteo']:SendWeatherToWeb(newWeather)
        end
    else
        print("[SERVER] La météo est déjà définie sur : " .. currentWeather)
    end
end

function GetFormattedTime()
    return string.format("%02d:%02d", currentTime.hour, currentTime.minute)
end

function UpdateTime()
    currentTime.minute = currentTime.minute + 1
    
    if currentTime.minute >= 60 then
        currentTime.minute = 0
        currentTime.hour = currentTime.hour + 1
        
        if currentTime.hour >= 24 then
            currentTime.hour = 0
        end
    end
    
    TriggerClientEvent("meteo:timeUpdate", -1, currentTime.hour, currentTime.minute)
end

Citizen.CreateThread(function()
    while true do
        UpdateTime()
        
        if autoWeatherChange then
            weatherChangeTimer = weatherChangeTimer + (1000 * timeSpeed)
            
            if weatherChangeTimer >= weatherChangeInterval then
                local newWeather = GetRealisticWeather()
                 SetWeather(newWeather)
                weatherChangeTimer = 0
            end
        end
        Citizen.Wait(1000 / timeSpeed)
    end
end)

RegisterCommand("setmeteo", function(source, args)
    if args[1] then
        local newWeather = string.upper(args[1])
        
        if table.contains(availableWeathers, newWeather) then
            SetWeather(newWeather)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { "Erreur", "❌ Météo invalide : " .. newWeather }
            })
            TriggerClientEvent('chat:addMessage', source, {
                color = { 0, 150, 255 },
                args = { "Info", "🌤️ Météos disponibles : " .. table.concat(availableWeathers, ", ") }
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 0, 150, 255 },
            args = { "Info", "📘 Utilisation : /setmeteo [TYPE]" }
        })
        TriggerClientEvent('chat:addMessage', source, {
            color = { 0, 150, 255 },
            args = { "Info", "🌤️ Météos disponibles : " .. table.concat(availableWeathers, ", ") }
        })
    end
end, true)

RegisterCommand("settime", function(source, args)
    if args[1] and args[2] then
        local hour = tonumber(args[1])
        local minute = tonumber(args[2])
        
        if hour and minute and hour >= 0 and hour <= 23 and minute >= 0 and minute <= 59 then
            currentTime.hour = hour
            currentTime.minute = minute
            
            TriggerClientEvent("meteo:timeUpdate", -1, hour, minute)
            TriggerClientEvent('chat:addMessage', -1, {
                color = { 0, 255, 0 },
                args = { "Serveur", "🕐 Heure changée à : " .. GetFormattedTime() }
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { "Erreur", "❌ Format invalide. Utilisez : /settime [heure] [minute] (ex: /settime 14 30)" }
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 0, 150, 255 },
            args = { "Info", "📘 Utilisation : /settime [heure] [minute]" }
        })
        TriggerClientEvent('chat:addMessage', source, {
            color = { 0, 150, 255 },
            args = { "Info", "🕐 Heure actuelle : " .. GetFormattedTime() }
        })
    end
end, true)

RegisterCommand("settimespeed", function(source, args)
    if args[1] then
        local speed = tonumber(args[1])
        if speed and speed > 0 and speed <= 10 then
            timeSpeed = speed
            TriggerClientEvent('chat:addMessage', -1, {
                color = { 0, 255, 0 },
                args = { "Serveur", "⚡ Vitesse du temps : x" .. timeSpeed }
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { "Erreur", "❌ Vitesse invalide (1-10)" }
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 0, 150, 255 },
            args = { "Info", "📘 Utilisation : /settimespeed [1-10]" } 
        })
    end
end, true)

RegisterCommand("autoweather", function(source, args)
    autoWeatherChange = not autoWeatherChange
    local status = autoWeatherChange and "activé" or "désactivé"
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 0, 255, 0 },
        args = { "Serveur", "🤖 Changement automatique de météo : " .. status }
    })
end, true)

RegisterCommand("meteoinfo", function(source, args)
    TriggerClientEvent('chat:addMessage', source, {
        color = { 0, 150, 255 },
        args = { "Info", "🌤️ Météo actuelle : " .. currentWeather }
    })
    TriggerClientEvent('chat:addMessage', source, {
        color = { 0, 150, 255 },
        args = { "Info", "🕐 Heure actuelle : " .. GetFormattedTime() }
    })
    TriggerClientEvent('chat:addMessage', source, {
        color = { 0, 150, 255 },
        args = { "Info", "⚡ Vitesse du temps : x" .. timeSpeed }
    })
    TriggerClientEvent('chat:addMessage', source, {
        color = { 0, 150, 255 },
        args = { "Info", "🤖 Changement auto : " .. (autoWeatherChange and "ON" or "OFF") }
    })
end, false)

function Log(message)
    print("[METEO LOG] " .. message)
end

Citizen.CreateThread(function()
    Citizen.Wait(1000) 
    print("=== SYSTÈME MÉTÉO ET TEMPS INITIALISÉ ===")
    print("Commandes disponibles :")
    print("- /setmeteo [type] : Changer la météo")
    print("- /settime [heure] [minute] : Définir l'heure")
    print("- /settimespeed [1-10] : Vitesse du temps")
    print("- /autoweather : Activer/désactiver changement auto")
    print("- /meteoinfo : Afficher les informations")
    print("=========================================")
end)