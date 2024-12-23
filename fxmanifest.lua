
fx_version 'cerulean'

author 'Envi-Scripts'
description 'Receipt system created by Envi-Scripts, redesigned and updated by Sr. Asorey'
version '1.1.3'
game 'gta5'
lua54 'yes'

ui_page 'html/index.html'

files { 
	'html/index.html',
	'html/index.css',
	'html/index.js',
	'html/img/barcode.png',
	'html/img/paperbg.jpg',
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
}

data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_prop_payment_terminal.ytyp'