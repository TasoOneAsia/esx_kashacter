fx_version 'cerulean'
game 'gta5'
description 'esx_kashacters is a multicharacter system build for the ESX Framework'

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server/main.lua",
}

client_scripts {
    "client/main.lua",
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/css/main.css',
    'html/js/app.js',
    'html/locales/fr.js',
    'html/locales/en.js',
    'html/locales/pl.js',
}

dependency 'es_extended'
