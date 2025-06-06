fx_version 'cerulean'
game 'gta5'

author 'TinySpriteScripts'
description 'tss-fishing'
version '2.0.0'

shared_scripts {
	'config.lua',
	'@jim_bridge/starter.lua',
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua'
}

lua54 'yes'


dependency 'jim_bridge'