local c = require "cfg"
local util = require "util"
local map = require "map"

local M = {}

function M.respawn(playerid)
    print(playerid)
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
    
    local ret = {
        cmd = "gameSetup",
        data = {
            gameWidth = c.gameWidth,
            gameHeight = c.gameHeight,
            userList = map:getUserList(),
            foodList = map:getFoodList(),
            virusList = map:getVirusList(), 
            massList = map:getMassList()
        }
    }

    print("=================")
    util.print(ret.data.foodList)

    return ret
end

function M.windowResized(playerid,data)
    local user = map:getPlayer(playerid)
    if not user then
        return
    end

    user.screenWidth = data.screenWidth
    user.screenHeight = data.screenHeight
end

M["0"] = function (playerid,data)
    local user = map:getPlayer(playerid)
    if not user then
        return
    end

    user.target = target
end

return M
