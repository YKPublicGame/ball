local cjson = require "cjson"

local f = io.open("./config.json")
local data = f:read("*all")
f:close()
print("data",data)
local cfg = cjson.decode(data)

return cfg

