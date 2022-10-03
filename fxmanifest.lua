fx_version 'cerulean'

games { 'gta5'}
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name         'plouffe_vangelico'
author       'PlouffeLuL'
version      '1.0.0'
repository   'https://github.com/plouffelul/plouffe_vangelico'
description  'Vangelico robbery script'

client_scripts {
	'configs/clientConfig.lua',
    'client/*.lua'
}

server_scripts {
	'configs/serverConfig.lua',
    'server/*.lua'
}

dependencies {
    "plouffe_lib"
}