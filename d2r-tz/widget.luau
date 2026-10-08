local zones = require("./lib/zones.luau")
local TRACKER = "https://d2runewizard.com/terror-zone-tracker"
local language = noctalia.getConfig("zone_language")
local latest = noctalia.state.get("tracker")

local function short(name)
    local ok, byte = pcall(utf8.offset, name, 19)
    if not ok then return string.sub(name, 1, 18) end
    return byte and string.sub(name, 1, byte - 1) or name
end

local function zoneLine(label, zone, fallback)
    local name = zone and zone.display or noctalia.tr(fallback)
    local xp = zone and zone.xp or "?"
    local loot = zone and zone.loot or "?"
    return noctalia.tr(label) .. "：" .. name .. "（" .. noctalia.tr("xp") .. " " .. xp
        .. "／" .. noctalia.tr("loot") .. " " .. loot .. "）"
end

local function render(value)
    barWidget.setGlyph("skull")
    if type(value) ~= "table" or type(value.current) ~= "string" then
        barWidget.setText(noctalia.tr("title") .. " · " .. noctalia.tr("unavailable"))
        barWidget.setTooltip(zoneLine("current", nil, "unavailable") .. "\n"
            .. zoneLine("next", nil, "not_announced"))
        return
    end
    local current = zones.lookup(value.current, language)
    local nextZone = zones.lookup(value.next, language)
    local status = value.failed and (" · " .. noctalia.tr("cached_failed")) or ""
    barWidget.setText(noctalia.tr("title") .. " · " .. short(current.display) .. " · "
        .. noctalia.tr("xp") .. " " .. current.xp .. "／" .. noctalia.tr("loot") .. " " .. current.loot .. status)
    barWidget.setTooltip(zoneLine("current", current, "unavailable") .. "\n"
        .. zoneLine("next", nextZone, "not_announced"))
end

noctalia.state.watch("tracker", function(value)
    latest = value
    render(value)
end)
render(latest)

function onClick()
    noctalia.runAsync({ "xdg-open", TRACKER })
end
