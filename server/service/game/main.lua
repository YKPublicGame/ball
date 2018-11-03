local skynet = require "skynet"
local map = require "map"
local handler = require "handler"

local CMD = {}

-- 玩家进入
function CMD.enter()
    print("enter")
    return map:addPlayer()
end

function CMD.msg(playerid,cmd,data)
    local f = handler[cmd]
    if not f then
        return
    end

    return f(playerid,data)
end

skynet.start(function ()
    map:init()

    skynet.dispatch("lua",function(session,source,cmd,...)
        local c = CMD[cmd]
        assert(c)
        if session > 0 then
            skynet.ret(skynet.pack(c(...)))
        else
            c(...)
        end
    end)
end)
