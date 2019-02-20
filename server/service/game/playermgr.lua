local Player = require "player"

local M = {}

function M:init()
    self.id = 0
    self.players = {}
end

function M:addPlayer(name, gate,fd)
    local id = self.id + 1
    self.id = id
    local p = Player.new(id,name,gate,fd)
    self.players[id] = p
    return p
end

function M:deletePlayer(id)

end

function M:getPlayer(id)
    return self.players[id]
end

function M:send(id,msg)
    local p = self:getPlayer(id)
    if p then
        p:send(msg)
    end
end

function M:broadcast(msg)
    for _,p in pairs(self.players) do
        p:send(msg)
    end
end

return M
