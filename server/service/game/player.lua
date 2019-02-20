local skynet = require "skynet"
local map = require "map"

local M = {}

M.__index = M

function M.new(...)
    local o = {}
    setmetatable(o,M)
    o:init(...)
    return o
end

function M:init(id,name,gate,fd)
    self.id = id
    self.name = name
    self.gate = gate
    self.fd = fd
end

function M:send(msg)
    skynet.send(self.gate,"lua","send",self.fd,msg)
end

function M:getID()
    return self.id
end

return M
