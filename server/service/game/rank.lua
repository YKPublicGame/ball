local M = {}

function M:init()
    self.change = true
    self.rank = {
        {id=1,name="yunge"},
        {id=2,name="xili"}
    }
    self.tbl = {}
end

function M:addPlayer(id,name)
    table.insert(self.tbl,{
        id = id,
        name = name,
        score = score
    })
end

function M:deletePlayer(id)
    for i,v in ipairs(self.tbl) do
        if v.id == id then
            table.remove(self.tbl,i)
            break
        end
    end
end

local function cmd(a,b)
    return a.score < b.score
end

function M:update()
    table.sort(self.tbl,cmp)
end

function M:haveChange()
    return self.change
end

function M:getRank()
    return self.rank
end

return M

