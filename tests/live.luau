local fixture = require("./fixture")
noctalia = { json = { decode = function() return fixture end } }
local response = require("../d2r-tz/lib/response")
local current, nextZone = response.parse("live")
assert(type(current) == "string" and current ~= "")
assert(nextZone == nil or type(nextZone) == "string")
print("live provider parser: pass; current=" .. current .. "; next=" .. tostring(nextZone))
