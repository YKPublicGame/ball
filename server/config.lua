-- preload = "./examples/preload.lua"	-- run preload.lua before every lua service run
thread = 8
--logger = "skynet.log"
logpath = "."
harbor = 0
start = "main"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap

root = "./skynet/"
luaservice = root.."service/?.lua;"..root.."test/?.lua;"..root.."examples/?.lua;"..root.."test/?/init.lua"
lualoader = root .. "lualib/loader.lua"
lua_path = root.."lualib/?.lua;"..root.."lualib/?/init.lua"
lua_cpath = root .. "luaclib/?.so"
snax = root.."examples/?.lua;"..root.."test/?.lua"


-- snax_interface_g = "snax_g"
luaservice = "./service/?.lua;./service/?/main.lua;"..luaservice
lua_path = "./lualib/?.lua;./skynet_websocket/?.lua;"..lua_path
lua_cpath = "./luaclib/?.so;"..lua_cpath
cpath = root.."cservice/?.so"
--daemon = "./skynet.pid"


ws_port = 8002
