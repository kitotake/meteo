# 🌤️ meteo | FiveM Weather Dashboard

Un système de météo pour serveur FiveM avec affichage externe sur navigateur via WebSocket.

## 🧩 Composants

- `meteo/` : Code Lua pour le serveur FiveM.
- `metep_web/` : Serveur Node.js pour la communication WebSocket/HTTP
- `metep_web/` : Page HTML/CSS/JS affichant la météo en direct.

## 🔧 Lancer en local

```bash
cd meteo_web
npm install express ws cors body-parser
node server.js
