local c = require "cfg"
local util = require "util"
local map = require "map"

local M = {}

function M.enter(player,data)
    local ret = {
        cmd = "welcome",
        data = {
            id = player.id,
            gameWidth = c.gameWidth,
            gameHeight = c.gameHeight,
            userList = map:getUserList(),
            foodList = map:getFoodList(),
            virusList = map:getVirusList(), 
            massList = map:getMassList()
        }
    }

    return ret
end

function M.windowResized(player,data)
    player.screenWidth = data.screenWidth
    player.screenHeight = data.screenHeight
end

function M.target(player,data)
    player.target = data.target
end

function M.split(player,data)
end

function M.feed(player,data)
end

return M
