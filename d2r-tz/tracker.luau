local response = require("./lib/response.luau")
local URL = "https://d2runewizard.com/api/trackers/terror-zone"
local inFlight = false
local last = noctalia.state.get("tracker")

local function failed()
    if type(last) ~= "table" or type(last.current) ~= "string" then
        last = { failed = true }
    else
        last.failed = true
    end
    noctalia.state.set("tracker", last)
end

local function refresh()
    if inFlight then return end
    inFlight = true
    local started = noctalia.http({
        url = URL,
        method = "GET",
        headers = {
            "Accept: application/json",
            "User-Agent: Noctalia-D2R-TZ/0.1.0",
            "D2R-Contact: ysun@sctmes.com",
            "D2R-Platform: Noctalia",
            "D2R-Repo: https://github.com/bioinformatist/noctalia-d2r",
        },
    }, function(reply)
        inFlight = false
        if type(reply) ~= "table" or not reply.ok or reply.status ~= 200 or type(reply.body) ~= "string" then
            failed()
            return
        end
        local current, nextZone = response.parse(reply.body)
        if not current then
            failed()
            return
        end
        last = {
            current = current,
            next = nextZone,
            lastSuccess = math.floor(noctalia.nowMs() / 1000),
            failed = false,
        }
        noctalia.state.set("tracker", last)
    end)
    if not started then
        inFlight = false
        failed()
    end
end

noctalia.setUpdateInterval(120000)
refresh()
function update()
    refresh()
end

-- Language changes only affect widgets; preserve the shared cache and request.
function onConfigChanged()
end
