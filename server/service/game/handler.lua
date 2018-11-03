local c = require "cfg"
local util = require "util"
local map = require "map"

local M = {}

function M.respawn(playerid,data)
    local data = map:getPlayer(playerid) 
    return {cmd="welcome",data=data}
end

function M.gotit(playerid,data)
    local user = map:getPlayer(playerid)
    if not user then

    end

    local radius = util.massToRadius(c.defaultPlayerMass)
    user.cells = {
        {
            mass = c.defaultPlayerMass,
            x = math.random(1,c.gameWidth),
            y = math.random(1,c.gameHeight),
            radius = radius
        }
    }
end

return M
