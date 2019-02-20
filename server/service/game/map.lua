local util = require "util"
local c = require "cfg"

-- 根据质量计算半径
local function massToRadius(mass)
    return 4 + math.sqrt(mass) * 6
end

local M = {}

function M:init()
    self.id = 0
    self.food = {}
    self.massFood = {}
    self.virus = {}
    self.users ={}
end

function M:getUserList()
    return self.users
end

function M:getFoodList()
    return self.food
end

function M:getVirusList()
    return self.virus
end

function M:getMassList()
    return self.massFood
end

function M:getID()
    self.id = self.id + 1
    return self.id
end

function M:addPlayer()
    local radius = util.massToRadius(c.defaultPlayerMass)

    local p = {
        id = self:getID(),
        x = math.random(1,c.gameWidth),
        y = math.random(1,c.gameHeight),
        w = c.defaultPlayerMass,
        h = c.defaultPlayerMass,
        cells = {
            {
                mass = c.defaultPlayerMass,
                x = math.random(1,c.gameWidth),
                y = math.random(1,c.gameHeight),
                radius = radius
            }
        },
        massTotal = c.defaultPlayerMass,
        hue = math.random(1,360),
        type = 0,
        lastHeartbeat = os.time(),
        target = {
            x = 0,
            y = 0
        }
    }
    table.insert(self.users,p)
    return p
end

function M:getPlayer(id)
    for _,user in ipairs(self.users) do
        if user.id == id then
            return user
        end
    end
end

-- 加食物
function M:addFood(toAdd)
    local radius = massToRadius(c.foodMass)
    for i=1,toAdd do
        local o = {
            id = self:getID(),
            x = math.random(1,c.gameWidth),
            y = math.random(1,c.gameHeight),
            radius = radius,
            mass = c.foodMass,
            hue = math.random(1,360)
        }
        table.insert(self.food,o)
    end
end

-- 加毒刺
function M:addVirus(toAdd)
    local radius = massToRadius(math.random(c.virus.defaultMass.from,c.virus.defaultMass.to))
    for i=1,toAdd do
        local o = {
            id = self:getID(),
            x = math.random(1,c.gameWidth),
            y = math.random(1,c.gameHeight),
            radius = radius,
            mass = 3,
            fill = c.virus.fill,
            stroke = c.virus.stroke,
            strokeWidth = c.virus.strokeWidth
        }
        table.insert(self.virus,o)
    end
end

function M:removeFood(toRem)
    for i=1,toRem do
        table.remove(self.food)
    end
end

function M:movePlayer(player)
    local x =0
    local y =0
    for i=1,player.cells.length do
        local target = {
            x = player.x - player.cells[i].x + player.target.x,
            y = player.y - player.cells[i].y + player.target.y
        }
        local dist = math.sqrt(math.pow(target.y, 2) + math.pow(target.x, 2))
        local deg = math.atan2(target.y, target.x)
        local slowDown = 1
        if player.cells[i].speed <= 6.25 then
            slowDown = util.log(player.cells[i].mass, c.slowBase) - initMassLog + 1
        end
        local deltaY = player.cells[i].speed * Math.sin(deg)/ slowDown
        local deltaX = player.cells[i].speed * Math.cos(deg)/ slowDown
        if player.cells[i].speed > 6.25 then
            player.cells[i].speed = player.cells[i].speed - 0.5
        end
        if dist < (50 + player.cells[i].radius) then
            deltaY = deltaY*( dist / (50 + player.cells[i].radius))
            deltaX = deltaX*(dist / (50 + player.cells[i].radius))
        end
        if not isNaN(deltaY) then
            player.cells[i].y = player.cells[i].y + deltaY
        end
        if not isNaN(deltaX) then
            player.cells[i].x = player.cells[i].x + deltaX
        end
        -- Find best solution.
        for j=1,player.cells.length do
            if j ~= i and player.cells[i] then
                local distance = math.sqrt(math.pow(player.cells[j].y-player.cells[i].y,2) + math.pow(player.cells[j].x-player.cells[i].x,2))
                local radiusTotal = (player.cells[i].radius + player.cells[j].radius)
                if distance < radiusTotal then
                    if player.lastSplit > os.time() - 1000 * c.mergeTimer then
                        if player.cells[i].x < player.cells[j].x then
                            player.cells[i].x = player.cells[i].x - 1
                        elseif player.cells[i].x > player.cells[j].x then
                            player.cells[i].x = player.cells[i].x + 1
                        end
                        if player.cells[i].y < player.cells[j].y then
                            player.cells[i].y = player.cells[i].y - 1
                        elseif player.cells[i].y > player.cells[j].y then
                            player.cells[i].y = player.cells[i].y + 1
                        end
                    end
                elseif distance < radiusTotal / 1.75 then
                    player.cells[i].mass = player.cells[i].mass + player.cells[j].mass
                    player.cells[i].radius = massToRadius(player.cells[i].mass)
                    player.cells.splice(j, 1)
                end
            end
        end
        if player.cells.length > i then
            local borderCalc = player.cells[i].radius / 3
            if player.cells[i].x > c.gameWidth - borderCalc then
                player.cells[i].x = c.gameWidth - borderCalc
            end
            if player.cells[i].y > c.gameHeight - borderCalc then
                player.cells[i].y = c.gameHeight - borderCalc
            end
            if player.cells[i].x < borderCalc then
                player.cells[i].x = borderCalc
            end
            if player.cells[i].y < borderCalc then
                player.cells[i].y = borderCalc
            end
            x = x + player.cells[i].x
            y = y + player.cells[i].y
        end
    end
    player.x = x/player.cells.length
    player.y = y/player.cells.length
end

function M:moveMass(mass)
    local deg = Math.atan2(mass.target.y, mass.target.x)
    local deltaY = mass.speed * Math.sin(deg)
    local deltaX = mass.speed * Math.cos(deg)

    mass.speed = mass.speed - 0.5
    if (mass.speed < 0) then
        mass.speed = 0
    end
    if not isNaN(deltaY) then
        mass.y = mass.y + deltaY
    end
    if not isNaN(deltaX) then
        mass.x = mass.x + deltaX
    end

    local borderCalc = mass.radius + 5

    if (mass.x > c.gameWidth - borderCalc) then
        mass.x = c.gameWidth - borderCalc
    end
    if (mass.y > c.gameHeight - borderCalc) then
        mass.y = c.gameHeight - borderCalc
    end
    if (mass.x < borderCalc) then
        mass.x = borderCalc
    end
    if (mass.y < borderCalc) then
        mass.y = borderCalc
    end
end

function M:balanceMass()
    local totalMass = #self.food * c.foodMass
    --+ users.map(function(u) {
--        return u.massTotal
--    }).reduce(function(pu, cu) {
--        return pu + cu
--    },
--    0)

    local massDiff = c.gameMass - totalMass
    local maxFoodDiff = c.maxFood - #self.food
    local foodDiff = math.floor(massDiff / c.foodMass - maxFoodDiff)
    local foodToAdd = math.min(foodDiff, maxFoodDiff)
    local foodToRemove = -math.max(foodDiff, maxFoodDiff)

    -- 食物太少，增加食物
    if foodToAdd > 0 then
        self:addFood(foodToAdd)
    -- 食物太多，减少食物
    elseif (foodToRemove > 0) then
        self:removeFood(foodToRemove)
    end

    -- 保持毒刺数量不变
    local virusToAdd = c.maxVirus - #self.virus
    if virusToAdd > 0 then
        self:addVirus(virusToAdd)
    end
end

function M:updateUsers()
    for _,v in ipairs(self.users) do
        self:tickPlayer(p)
    end

    for _,v in ipairs(self.massFood) do
        if v.speed > 0 then
           self:moveMass(v)
        end
    end
end

return M
