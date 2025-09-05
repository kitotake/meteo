// server.js (exécuté avec Node.js) // node server.js
const express = require("express");
const http = require("http");
const WebSocket = require("ws"); 

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

app.use(express.json());

app.post("/api/meteo", (req, res) => {
    const meteo = req.body.meteo;
    const timestamp = req.body.timestamp;

    console.log("Nouvelle météo :", meteo, timestamp);
    wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({ meteo, timestamp }));
        }
    });

    res.sendStatus(200);
});

server.listen(3000, () => {
    console.log("Serveur WebSocket + API sur http://localhost:3000");
});