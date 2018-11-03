local skynet = require "skynet"

skynet.start(function ()
    skynet.error("ball server start...")

    skynet.newservice("ws_gate",skynet.getenv("ws_port"))
end)
