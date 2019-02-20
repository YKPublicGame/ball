local skynet = require "skynet"
local map = require "map"
local handler = require "handler"
local playermgr = require "playermgr"
local rank = require "rank"
local timer = require "timer"


local CMD = {}

function CMD.msg(fd,cmd,data)
    local f = handler[cmd]
    if not f then
        return
    end

    local player = map:getPlayerByFd(fd)
    if not player then
        if cmd == "enter" then
            player = map:addPlayer(fd,data.name)
        else
            return
        end
    end

    return f(player,data)
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
    rank:init()
    playermgr:init()
    timer.init()
end)
