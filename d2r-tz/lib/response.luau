local M = {}

local function zone(value)
    if type(value) ~= "string" then return nil end
    value = string.gsub(value, "^%s*(.-)%s*$", "%1")
    if value == "" then return nil end
    return value
end

function M.parse(body)
    local ok, data = pcall(noctalia.json.decode, body)
    if not ok then return nil end
    if type(data) ~= "table" then return nil end
    local current = zone(data.current)
    if not current and type(data.currentTerrorZone) == "table" then
        current = zone(data.currentTerrorZone.zone)
    end
    if not current then return nil end
    local nextZone = zone(data.next)
    if not nextZone and type(data.nextTerrorZone) == "table" then
        nextZone = zone(data.nextTerrorZone.zone)
    end
    return current, nextZone
end

return M
