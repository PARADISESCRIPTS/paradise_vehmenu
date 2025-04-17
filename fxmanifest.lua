fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Paradise'
description 'Vehicle Control Menu'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'scripting/utils.lua',
    'scripting/client.lua'
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*'
}