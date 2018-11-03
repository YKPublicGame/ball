local M = {}

function M.massToRadius(mass)
    return 4 + math.sqrt(mass) * 6
end

return M
