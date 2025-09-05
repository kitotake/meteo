window.addEventListener("message", function (event) {
    if (event.data.type === "meteo:update") {
        const weather = event.data.meteo;
        const timestamp = event.data.timestamp;

       
        document.getElementById("currentWeather").textContent = weather;
        document.getElementById("timestamp").textContent = `Dernière mise à jour : ${timestamp}`;
    }

    

    
});
