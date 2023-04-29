
fx_version 'cerulean'

game 'gta5'
lua54 'yes'

ui_page 'html/index.html'

files { 
'html/index.html', 
'html/index.css', 
'html/index.js',
'html/img/barcode.png',
}

client_scripts {
	'client/client.lua',
}
shared_scripts {
	'config.lua',
	'@ox_lib/init.lua',
}

server_scripts {
	'server/server.lua',
	'@oxmysql/lib/MySQL.lua',
}
