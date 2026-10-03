local zones = require("./lib/zones.luau")
local TRACKER = "https://d2runewizard.com/terror-zone-tracker"
local language = noctalia.getConfig("zone_language")
local latest = noctalia.state.get("tracker")

local function short(name)
    local ok, byte = pcall(utf8.offset, name, 19)
    if not ok then return string.sub(name, 1, 18) end
    return byte and string.sub(name, 1, byte - 1) or name
end

local function provenance(zone)
    if zone.provenance == "group" then
        return noctalia.tr("ratings.group", { group = zone.sourceGroup,
            date = zones.groupRetrieved, url = zones.groupSource })
    elseif zone.provenance == "legacy" then
        return noctalia.tr("ratings.legacy", { url = zones.legacySource })
    end
    return noctalia.tr("ratings.unknown")
end

local function render(value)
    barWidget.setGlyph("skull")
    if type(value) ~= "table" or type(value.current) ~= "string" then
        barWidget.setText("D2RW · " .. noctalia.tr("unavailable"))
        barWidget.setTooltip(noctalia.tr("refresh_failed") .. "\n" .. TRACKER)
        return
    end
    local current = zones.lookup(value.current, language)
    local nextZone = zones.lookup(value.next, language)
    local status = value.failed and (" · " .. noctalia.tr("cached_failed")) or ""
    barWidget.setText("D2RW · " .. short(current.display) .. " · XP " .. current.xp .. " / " .. noctalia.tr("loot") .. " " .. current.loot .. status)
    local nextName = nextZone and nextZone.display or noctalia.tr("not_announced")
    local nextXp = nextZone and nextZone.xp or "?"
    local nextLoot = nextZone and nextZone.loot or "?"
    local nextSource = nextZone and provenance(nextZone) or noctalia.tr("ratings.unknown")
    local acquired = type(value.lastSuccess) == "number"
        and noctalia.formatTime("%Y-%m-%d %H:%M:%S %Z", value.lastSuccess)
        or noctalia.tr("unknown_time")
    barWidget.setTooltip(table.concat({
        "D2RW — D2Runewizard",
        (value.failed and noctalia.tr("cached_failed") or noctalia.tr("online")),
        noctalia.tr("current") .. ": " .. current.display .. " — XP " .. current.xp .. " / " .. noctalia.tr("loot") .. " " .. current.loot,
        provenance(current),
        noctalia.tr("next") .. ": " .. nextName .. " — XP " .. nextXp .. " / " .. noctalia.tr("loot") .. " " .. nextLoot,
        nextSource,
        noctalia.tr("last_success") .. ": " .. acquired .. " (" .. noctalia.tr("acquired_local") .. ")",
        TRACKER,
    }, "\n"))
end

noctalia.state.watch("tracker", function(value)
    latest = value
    render(value)
end)
render(latest)

function onClick()
    noctalia.runAsync({ "xdg-open", TRACKER })
end
