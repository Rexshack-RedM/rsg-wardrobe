fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

description 'rsg-wardrobe'
version '3.1.0'

shared_scripts {
    '@rsg-core/shared/locale.lua',
    'shared/config.lua',
}

client_scripts {
    'client/client.lua',
    'client/menu.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/versionchecker.lua',
}

ui_page 'html/index.html'

files {
    'locales/*.json',
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'rsg-core',
    'rsg-character',
    'oxmysql',
}
