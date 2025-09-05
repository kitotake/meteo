local currentWeather = "Clear"

function SendWeatherToWeb(weather)
    PerformHttpRequest("http://localhost:3000/api/meteo", function(err, text, headers)
        if err ~= 200 then
            print("[ERROR] Échec de l'envoi de la météo à l'API : " .. err)
        else
            print("[INFO] Météo envoyée à l'API avec succès")
        end
    end, "POST", json.encode({
        meteo = weather,
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }), {
        ["Content-Type"] = "application/json"
    })
end

function SetWeather(newWeather) 
    if newWeather ~= currentWeather then
        currentWeather = newWeather
        print("[SERVER] Changement de météo :", newWeather)
        TriggerClientEvent("meteo:update", -1, newWeather, os.date("%Y-%m-%d %H:%M:%S"))
        SendWeatherToWeb(newWeather)
    end
end
