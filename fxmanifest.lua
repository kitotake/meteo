fx_version 'cerulean'
game 'gta5'

name "meteo"
description "Un système de météo pour serveur FiveM avec affichage externe "
author "kito"
version "1"


-- Dépendance pour la gestion WebSocket (si nécessaire)
-- désactiver ou activer le index.html si tu veut voir la page web cote fivem jeux
files {
    'meteo_web/index.html',  -- Si tu as un fichier HTML pour afficher des infos NUI
    'meteo_web/style.css',    -- Si tu as des styles CSS pour l'interface NUI
    'meteo_web/script.js'     -- Si tu as un fichier JavaScript pour gérer l'interface NUI
}

ui_page 'meteo_web/index.html' -- si tu utilises une page HTML pour afficher des informations NUI


client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}
