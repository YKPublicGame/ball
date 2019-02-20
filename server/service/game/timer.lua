local skynet = require "skynet"
local rank = require "rank"
local playermgr = require "playermgr"
local map = require "map"

local M = {}

function M.init()
    skynet.timeout(5*100,M.updateRank)
    skynet.timeout(5*100,M.updateMass)
    skynet.timeout(5*100,M.updateUsers)
end

function M.updateRank()
    skynet.timeout(5*100,M.updateRank)
    rank:update()
    if rank:haveChange() then
        playermgr:broadcast({cmd="leaderboard",data=rank:getRank()})
    end
end

function M.updateMass()
    skynet.timeout(5*100,M.updateMass)
    map:balanceMass()
end

function M.updateUsers()
    skynet.timeout(5*100,M.updateUsers)
    map:updateUsers()
end

return M
