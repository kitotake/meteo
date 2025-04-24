local currentWeather = "CLEAR"

local availableWeathers = {
    "EXTRASUNNY", "CLEAR", "CLOUDS", "OVERCAST", "SMOG", "FOGGY",
    "RAIN", "THUNDER", "CLEARING", "SNOW", "SNOWLIGHT", "XMAS", "BLIZZARD", "NEUTRAL"
}

-- Fonction pour vérifier si un élément existe dans la table
function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Fonction pour envoyer la météo aux clients
function SetWeather(newWeather)
    if newWeather ~= currentWeather then
        currentWeather = newWeather
        print("[SERVER] Changement de météo :", newWeather)

        -- Envoie l'événement aux clients pour mettre à jour la météo
        TriggerClientEvent("meteo:update", -1, newWeather)
        
        -- Envoi d'un message dans le chat pour annoncer le changement de météo
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 0, 255, 0 },
            multiline = true,
            args = { "Serveur", "🌦️ Météo changée en : ^2" .. newWeather }
        })
    else
        print("[SERVER] La météo est déjà définie sur : " .. currentWeather)
    end
end


-- Commande pour changer la météo
RegisterCommand("setmeteo", function(source, args)
    if args[1] then
        local newWeather = string.upper(args[1])
        
        -- Vérifier si la météo est valide
        if table.contains(availableWeathers, newWeather) then
            SetWeather(newWeather)
        else
            -- Météo inconnue
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
        -- Si aucun paramètre n'est passé
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

-- Exemple de fonction partagée
function Log(message)
    print("[METEO LOG] " .. message)
end


RegisterNetEvent("meteo:update")
AddEventHandler("meteo:update", function(weather)
    print("Météo reçue côté client :", weather)  -- Cela va afficher la météo reçue dans la console du client
    SetWeatherTypeNowPersist(weather)  -- Applique la météo dans le jeu
end)