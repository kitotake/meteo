-- Côté client : Réception de l'événement "meteo:update" et affichage de la page web
RegisterNetEvent("meteo:update")
AddEventHandler("meteo:update", function(weather, timestamp)
    print("Météo reçue côté client :", weather)  -- Log pour déboguer
   -- SetNuiFocus(true, true)  -- Ouvre la fenêtre NUI
    SendNUIMessage({
        type = "meteo:update",
        meteo = weather,
        timestamp = timestamp
    })

    -- Mettre à jour la météo dans le jeu
    SetWeather(weather)
end)

-- Commande pour fermer l'interface NUI
RegisterCommand("closeMe", function()
    SetNuiFocus(false, false)  -- Ferme la fenêtre NUI
end, false)

-- Gérer la fermeture de l'interface avec une touche (par exemple, 'Esc')
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 177) then  -- Touche 'Esc'
            SetNuiFocus(false, false)  -- Ferme l'interface avec la touche 'Esc'
        end
    end
end)

-- Commande pour ouvrir l'interface NUI (page météo)
RegisterCommand("openmeteo", function()
    SetNuiFocus(true, true)  -- Ouvre la fenêtre NUI
    SendNUIMessage({ show = true })  -- Envoie un message pour afficher l'interface NUI
end)

-- Fonction pour changer la météo dans le jeu
function SetWeather(weather)
    ClearOverrideWeather()  -- Efface les overrides de météo
    SetOverrideWeather(weather)  -- Applique un nouvel override
    SetWeatherTypeNowPersist(weather)  -- Applique la météo de manière persistante
end
