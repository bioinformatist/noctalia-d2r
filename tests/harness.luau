local decoded = {}
local state = {}
local watched = {}
local requests = {}
local texts = {}
local tips = {}
local opened = {}
local language = "zh-Hans"
local translations = __TRANSLATIONS__
local acceptRequest = true
noctalia = {
    json = { decode = function(body) return decoded[body] end },
    state = {
        get = function(key) return state[key] end,
        set = function(key, value)
            state[key] = value
            for _, fn in ipairs(watched[key] or {}) do fn(value) end
        end,
        watch = function(key, fn)
            watched[key] = watched[key] or {}
            table.insert(watched[key], fn)
        end,
    },
    http = function(request, callback)
        if not acceptRequest then return false end
        table.insert(requests, { request = request, callback = callback })
        return true
    end,
    setUpdateInterval = function(ms) assert(ms == 120000) end,
    nowMs = function() return 1790950000000 end,
    getConfig = function() return language end,
    -- Host UI is English; the plugin's fallback bundle must still be Chinese.
    tr = function(key) return translations[key] or key end,
    runAsync = function(args) table.insert(opened, args) end,
}
barWidget = {
    setGlyph = function(glyph) assert(glyph == "skull") end,
    setText = function(value) table.insert(texts, value) end,
    setTooltip = function(value) table.insert(tips, value) end,
}

local zones = require("../d2r-tz/lib/zones")
local legacy = require("../d2r-tz/lib/legacy")
local response = require("../d2r-tz/lib/response")
local original = __LEGACY_FIXTURE__
local count = 0
for name, rating in pairs(original) do
    assert(legacy[name] and legacy[name].xp == rating.xp and legacy[name].loot == rating.loot, name)
    count += 1
end
local actualCount = 0
for _ in pairs(legacy) do actualCount += 1 end
assert(count == actualCount)
assert(zones.lookup("Frozen Tundra and Infernal Pit", "en").xp == "B")
local expected = {
    { "Frozen Tundra and Infernal Pit", "B", "B" },
    { "Far Oasis and Maggot Lair", "F", "F" },
    { "Spider Forest, Arachnid Lair, and Spider Cavern", "C", "B" },
    { "Tal Rasha's Tomb, Tal Rasha's Chamber, and Canyon of the Magi", "S", "A" },
    { "Kurast Bazaar, Kurast Causeway, Kurast Sewers, Ruined Temple, Disused Fane, Forgotten Reliquary, Forgotten Temple, Ruined Fane, and Disused Reliquary", "B", "B" },
}
for _, row in ipairs(expected) do
    local rating = zones.lookup(row[1], "en")
    assert(rating.xp == row[2] and rating.loot == row[3])
    assert(rating.provenance == "group" and rating.sourceGroup == row[1])
end
assert(zones.lookup("Spider Forest and Spider Cavern", "en").xp == "C")
assert(zones.lookup("Dark Wood and Underground Passage", "zh-Hans").display == "黑暗森林／地下通道")
local providerNames = {
    { "Jail and Barracks", "B", "B" },
    { "Cathedral and Catacombs", "S", "S" },
    { "Tal Rasha's Tombs and Tal Rasha's Chamber", "S", "S" },
    { "Flayer Jungle and Flayer Dungeon", "S", "A" },
    { "River of Flame and City of the Damned", "B", "B" },
    { "The Chaos Sanctuary", "S", "S" },
    { "Bloody Foothills, Frigid Highlands, and Abaddon", "C", "A" },
    { "Glacial Trail and Drifter Cavern", "A", "B" },
    { "Arreat Plateau and Pit of Acheron", "D", "F" },
    { "Kurast Bazaar, Ruined Temple, and Disused Fane", "A", "C" },
}
for _, row in ipairs(providerNames) do
    local value = zones.lookup(row[1], "zh-Hans")
    assert(value.xp == row[2] and value.loot == row[3], row[1])
    assert(value.display ~= row[1] and value.provenance == "legacy", row[1])
end
for _, name in ipairs({ "The Pit", "The Forgotten Tower", "Stony Field", "Tristram",
    "Far Oasis", "Ancient Tunnels", "Arcane Sanctuary" }) do
    assert(zones.lookup(name, "zh-Hans").display ~= name, name)
end
assert(zones.lookup("Kurast Bazaar, Kurast Causeway and Kurast Sewers", "en").provenance == "group")
assert(zones.lookup("Canyon of the Magi and Tal Rasha's Tombs", "en").loot == "A")
assert(zones.lookup("Tamoe Highland/Outer Cloister/Pit", "en").xp == "S")
assert(zones.lookup("Temple Halls", "en").loot == "A")
assert(zones.lookup("Unknown future zone", "en").display == "Unknown future zone")
assert(zones.lookup("Unknown future zone", "en").xp == "?")
assert(zones.lookup("Far Oasis", "en").xp == legacy["Far Oasis"].xp)
assert(zones.lookup("Far Oasis", "en").loot == legacy["Far Oasis"].loot)
assert(zones.lookup("Frozen Tundra", "en").xp == "?")
assert(zones.lookup("Frozen Tundra", "zh-Hans").display == "冰冻苔原")
assert(zones.lookup("Frozen Tundra and Infernal Pit", "zh-Hans").display == "冰冻苔原与地狱深坑")

-- The native JSON decoder is stubbed; parser branching remains the real code.
decoded.flat = { current = "The Pit", next = "Frozen Tundra and Infernal Pit" }
decoded.nested = { currentTerrorZone = { zone = "Far Oasis" }, nextTerrorZone = { zone = "Spider Forest and Spider Cavern" } }
decoded.missing = { current = "The Pit" }
decoded.invalid = { message = "error" }
assert(response.parse("flat") == "The Pit")
assert(response.parse("nested") == "Far Oasis")
local _, missing = response.parse("missing")
assert(missing == nil)
assert(response.parse("invalid") == nil)
assert(response.parse("malformed") == nil)
decoded.throwing = true
local originalDecode = noctalia.json.decode
noctalia.json.decode = function(body)
    if body == "throwing" then error("invalid JSON") end
    return originalDecode(body)
end
assert(response.parse("throwing") == nil)

require("../d2r-tz/tracker")
assert(#requests == 1 and requests[1].request.headers[3] == "D2R-Contact: ysun@sctmes.com")
assert(state.tracker == nil)
update() -- no overlap
assert(#requests == 1)
requests[1].callback({ ok = false, status = 500, body = "" })
assert(state.tracker.failed and state.tracker.current == nil)
require("../d2r-tz/widget")
assert(texts[#texts] == "恐怖地带 · 暂无数据")
assert(tips[#tips] == "当前：暂无数据（经验 ?／掉落 ?）\n下一轮：尚未公布（经验 ?／掉落 ?）")
local firstCount = #watched.tracker
require("../d2r-tz/widget_copy")
assert(#watched.tracker == firstCount + 1)
update()
assert(#requests == 2)
requests[2].callback({ ok = true, status = 200, body = "missing" })
assert(state.tracker.current == "The Pit" and state.tracker.next == nil and not state.tracker.failed)
assert(tips[#tips] == "当前：地穴（经验 S／掉落 A）\n下一轮：尚未公布（经验 ?／掉落 ?）")
assert(#requests == 2)
language = "zh-Hans"
require("../d2r-tz/widget_copy") -- settings reload rebuilds a widget
local chinese = string.rep("蜘蛛森林", 6)
state.tracker = { current = chinese,
    next = "Frozen Tundra", lastSuccess = 1790950000, failed = false }
for _, fn in ipairs(watched.tracker) do fn(state.tracker) end
local expectedShort = string.sub(chinese, 1, utf8.offset(chinese, 19) - 1)
assert(string.find(texts[#texts], expectedShort, 1, true))
assert(not string.find(texts[#texts], chinese, 1, true))
assert(string.find(tips[#tips], "冰冻苔原", 1, true))
language = "en"
update()
requests[3].callback({ ok = true, status = 200, body = "bad" })
assert(state.tracker.failed and state.tracker.current == "The Pit")
assert(string.find(texts[#texts], "更新失败", 1, true))
update()
requests[4].callback({ ok = true, status = 200, body = "flat" })
assert(not state.tracker.failed and state.tracker.next == "Frozen Tundra and Infernal Pit")
assert(tips[#tips] == "当前：地穴（经验 S／掉落 A）\n下一轮：冰冻苔原与地狱深坑（经验 B／掉落 B）")
assert(texts[#texts] == "恐怖地带 · 地穴 · 经验 S／掉落 A")
onClick()
assert(opened[1][1] == "xdg-open" and opened[1][2] == "https://d2runewizard.com/terror-zone-tracker")
acceptRequest = false
update()
assert(#requests == 4 and state.tracker.failed and state.tracker.current == "The Pit")
print("deterministic Luau behavior: pass")
