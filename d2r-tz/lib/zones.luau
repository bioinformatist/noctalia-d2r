local legacy = require("./legacy.luau")

local M = {}
M.legacySource = "https://github.com/bioinformatist/dotfiles/blob/efe768bc00aef31dc44f013bc97726b6bc453c82/home/desktop/eww-features/d2r/terror-zones.json"
M.groupSource = "https://www.d2tz.info/online"
M.groupRetrieved = "2026-10-02"

-- Exact rotations from Blizzard's RotW list. The five D2TZ rows below grade
-- whole groups, not their individual areas. Provider variants are explicit.
local groups = {
    { "Blood Moor", "鲜血荒地", { "Blood Moor" } },
    { "Cold Plains and The Cave", "冰冷之原与洞窟", { "Cold Plains", "The Cave" } },
    { "Burial Grounds, The Crypt, and the Mausoleum", "埋骨之地、墓穴与大陵寝", { "Burial Grounds", "The Crypt", "Mausoleum" }, { "Burial Grounds, Crypt, and Mausoleum" } },
    { "Stony Field / Tristram", "石块旷野／崔斯特瑞姆", { "Stony Field", "Tristram" }, { "Stony Field and Tristram" } },
    { "Dark Wood / Underground Passage", "黑暗森林／地下通道", { "Dark Wood", "Underground Passage" }, { "Dark Wood and Underground Passage" } },
    { "Black Marsh / The Hole / The Forgotten Tower", "黑色荒地／地洞／遗忘之塔", { "Black Marsh", "The Hole", "Forgotten Tower" } },
    { "Jail / Barracks", "监牢／军营", { "Jail", "Barracks" }, { "Jail and Barracks" } },
    { "The Pit / Tamoe Highland / Outer Cloister", "地穴／泰摩高地／外侧回廊", { "The Pit", "Tamoe Highland", "Outer Cloister" }, { "Tamoe Highland/Outer Cloister/Pit" } },
    { "Inner Cloister / Cathedral and Catacombs", "内侧回廊／大教堂与地下墓穴", { "Inner Cloister", "Cathedral", "Catacombs" } },
    { "Cathedral and Catacombs", "大教堂与地下墓穴", { "Cathedral", "Catacombs" } },
    { "Moo Moo Farm", "哞哞农场", { "Moo Moo Farm" }, { "Secret Cow Level" } },
    { "Sewers", "下水道", { "Lut Gholein Sewers" }, { "Lut Gholein Sewers", "Act 2 Sewers" } },
    { "Rocky Waste and Stony Tomb", "碎石荒地与石制古墓", { "Rocky Waste", "Stony Tomb" } },
    { "Dry Hills and Halls of the Dead", "干燥高地与死亡之殿", { "Dry Hills", "Halls of the Dead" } },
    { "Far Oasis and Maggot Lair", "遥远绿洲与蛆虫巢穴", { "Far Oasis", "Maggot Lair" }, { "Far Oasis and The Maggot Lair" }, { xp = "F", loot = "F", sourceGroup = "Far Oasis and Maggot Lair" } },
    { "Lost City, Valley of Snakes, Claw Viper Temple, and Ancient Tunnels", "失落之城、群蛇峡谷、利爪蝮蛇神殿与古代通道", { "Lost City", "Valley of Snakes", "Claw Viper Temple", "Ancient Tunnels" }, { "Lost City, Valley of Snakes, and Claw Viper Temple, Ancient Tunnels" } },
    { "Harem, Palace Cellar, and Arcane Sanctuary", "后宫、皇宫地窖与神秘庇护所", { "Harem", "Palace Cellar", "Arcane Sanctuary" }, { "Harem, Palace and Arcane Sanctuary" } },
    { "Tal Rasha's Tomb, Tal Rasha's Chamber, and Canyon of the Magi", "塔拉夏古墓、塔拉夏密室与术士峡谷", { "Tal Rasha's Tombs", "Tal Rasha's Chamber", "Canyon of the Magi" }, { "Canyon of the Magi and Tal Rasha's Tombs", "Canyon of the Magi / Tal Rasha's Tombs" }, { xp = "S", loot = "A", sourceGroup = "Tal Rasha's Tomb, Tal Rasha's Chamber, and Canyon of the Magi" } },
    { "Tal Rasha's Tombs and Tal Rasha's Chamber", "塔拉夏古墓与塔拉夏密室", { "Tal Rasha's Tombs", "Tal Rasha's Chamber" } },
    { "Spider Forest, Arachnid Lair, and Spider Cavern", "蜘蛛森林、蜘蛛巢穴与蜘蛛洞窟", { "Spider Forest", "Arachnid Lair", "Spider Cavern" }, { "Spider Forest and Spider Cavern", "Spider Forest and Spider Cavern / Arachnid Lair" }, { xp = "C", loot = "B", sourceGroup = "Spider Forest, Arachnid Lair, and Spider Cavern" } },
    { "Great Marsh", "庞大湿地", { "Great Marsh" } },
    { "Flayer Jungle and Flayer Dungeon / Swampy Pit", "剥皮丛林、剥皮地牢与沼泽地洞", { "Flayer Jungle", "Flayer Dungeon", "Swampy Pit" } },
    { "Flayer Jungle and Flayer Dungeon", "剥皮丛林与剥皮地牢", { "Flayer Jungle", "Flayer Dungeon" } },
    { "Kurast Bazaar, Kurast Causeway, Kurast Sewers, Ruined Temple, Disused Fane, Forgotten Reliquary, Forgotten Temple, Ruined Fane, and Disused Reliquary", "库拉斯特商场、堤道、下水道与诸神殿", { "Kurast Bazaar", "Kurast Causeway", "Kurast Sewers", "Ruined Temple", "Disused Fane", "Forgotten Reliquary", "Forgotten Temple", "Ruined Fane", "Disused Reliquary" }, { "Kurast Bazaar, Kurast Causeway and Kurast Sewers", "Kurast Bazaar / Kurast Causeway / Kurast Sewers / Temples" }, { xp = "B", loot = "B", sourceGroup = "Kurast Bazaar, Kurast Causeway, Kurast Sewers, Ruined Temple, Disused Fane, Forgotten Reliquary, Forgotten Temple, Ruined Fane, and Disused Reliquary" } },
    { "Kurast Bazaar, Ruined Temple, Disused Fane, Lower Kurast, Upper Kurast, Forgotten Temple, Forgotten Reliquary, Disused Reliquary, Ruined Fane", "库拉斯特商场、上下库拉斯特与诸神殿", { "Kurast Bazaar", "Ruined Temple", "Disused Fane", "Lower Kurast", "Upper Kurast", "Forgotten Temple", "Forgotten Reliquary", "Disused Reliquary", "Ruined Fane" } },
    { "Kurast Bazaar, Ruined Temple, and Disused Fane", "库拉斯特商场、残破神殿与废弃圣坛", { "Kurast Bazaar", "Ruined Temple", "Disused Fane" } },
    { "Travincal", "崔凡克", { "Travincal" } },
    { "Durance of Hate", "憎恨囚牢", { "Durance of Hate" } },
    { "Outer Steppes and Plains of Despair", "外围荒原与绝望平原", { "Outer Steppes", "Plains of Despair" } },
    { "River of Flame / City of the Damned", "火焰之河／神罚之城", { "River of Flame", "City of the Damned" }, { "River of Flame and City of the Damned" } },
    { "Chaos Sanctuary", "混沌庇护所", { "Chaos Sanctuary" }, { "The Chaos Sanctuary" } },
    { "Bloody Foothills / Frigid Highlands / Abaddon", "血腥丘陵／冰冻高地／亚巴顿", { "Bloody Foothills", "Frigid Highlands", "Abaddon" }, { "Bloody Foothills / Frigid Highlands / Abbadon", "Bloody Foothills, Frigid Highlands, and Abaddon" } },
    { "Glacial Trail / Drifter Cavern", "冰河路径／漂泊者洞穴", { "Glacial Trail", "Drifter Cavern" }, { "Glacial Trail and Drifter Cavern" } },
    { "Crystalline Passage and Frozen River", "水晶通道与冰河", { "Crystalline Passage", "Frozen River" } },
    { "Frozen Tundra and Infernal Pit", "冰冻苔原与地狱深坑", { "Frozen Tundra", "Infernal Pit" }, { "Frozen Tundra + Infernal Pit" }, { xp = "B", loot = "B", sourceGroup = "Frozen Tundra and Infernal Pit" } },
    { "Arreat Plateau / Pit of Acheron", "亚瑞特高原／冥河之洞", { "Arreat Plateau", "Pit of Acheron" }, { "Arreat Plateau and Pit of Acheron" } },
    { "Nihlathak's Temple, Halls of Anguish, Halls of Pain, and Halls of Vaught", "尼拉塞克神殿、痛苦之厅、悲惨之厅与沃特之厅", { "Nihlathak's Temple", "Halls of Anguish", "Halls of Pain", "Halls of Vaught" }, { "Temple Halls", "Nihlathak's Temple / Temple Halls" } },
    { "Ancient's Way and Icy Cellar", "先祖之路与冰窖", { "Ancient's Way", "Icy Cellar" } },
    { "Worldstone Keep, Throne of Destruction, and Worldstone Chamber", "世界之石要塞、毁灭王座与世界之石大殿", { "Worldstone Keep", "Throne of Destruction", "Worldstone Chamber" } },
}

local zhAreas = {
    ["Blood Moor"] = "鲜血荒地",
    ["Den of Evil"] = "邪恶洞窟",
    ["Cold Plains"] = "冰冷之原",
    ["The Cave"] = "洞窟",
    ["Stony Field"] = "石块旷野",
    ["Tristram"] = "崔斯特瑞姆",
    ["Dark Wood"] = "黑暗森林",
    ["Underground Passage"] = "地下通道",
    ["Black Marsh"] = "黑色荒地",
    ["The Hole"] = "地洞",
    ["Tamoe Highland"] = "泰摩高地",
    ["Outer Cloister"] = "外侧回廊",
    ["Inner Cloister"] = "内侧回廊",
    ["Monastery Gate"] = "修道院大门",
    ["Barracks"] = "军营",
    ["Jail"] = "监牢",
    ["Cathedral"] = "大教堂",
    ["Catacombs"] = "地下墓穴",
    ["The Pit"] = "地穴",
    ["Forgotten Tower"] = "遗忘之塔",
    ["Tower Cellar"] = "高塔地窖",
    ["Burial Grounds"] = "埋骨之地",
    ["The Crypt"] = "墓穴",
    ["Mausoleum"] = "大陵寝",
    ["Moo Moo Farm"] = "哞哞农场",
    ["Secret Cow Level"] = "哞哞农场",
    ["Lut Gholein Sewers"] = "鲁高因下水道",
    ["Act 2 Sewers"] = "鲁高因下水道",
    ["Rocky Waste"] = "碎石荒地",
    ["Stony Tomb"] = "石制古墓",
    ["Dry Hills"] = "干燥高地",
    ["Halls of the Dead"] = "死亡之殿",
    ["Far Oasis"] = "遥远绿洲",
    ["Lost City"] = "失落之城",
    ["Valley of Snakes"] = "群蛇峡谷",
    ["Claw Viper Temple"] = "利爪蝮蛇神殿",
    ["Ancient Tunnels"] = "古代通道",
    ["Harem"] = "后宫",
    ["Palace Cellar"] = "皇宫地窖",
    ["Arcane Sanctuary"] = "神秘庇护所",
    ["Canyon of the Magi"] = "术士峡谷",
    ["Tal Rasha's Tombs"] = "塔拉夏古墓",
    ["Tal Rasha's Chamber"] = "塔拉夏密室",
    ["Spider Forest"] = "蜘蛛森林",
    ["Spider Cavern"] = "蜘蛛洞窟",
    ["Arachnid Lair"] = "蜘蛛巢穴",
    ["Maggot Lair"] = "蛆虫巢穴",
    ["Great Marsh"] = "庞大湿地",
    ["Flayer Jungle"] = "剥皮丛林",
    ["Swampy Pit"] = "沼泽地洞",
    ["Flayer Dungeon"] = "剥皮地牢",
    ["Kurast Bazaar"] = "库拉斯特商场",
    ["Ruined Temple"] = "残破神殿",
    ["Disused Fane"] = "废弃圣坛",
    ["Upper Kurast"] = "上层库拉斯特",
    ["Kurast Causeway"] = "库拉斯特堤道",
    ["Lower Kurast"] = "下层库拉斯特",
    ["Travincal"] = "崔凡克",
    ["Durance of Hate"] = "憎恨囚牢",
    ["Kurast Sewers"] = "库拉斯特下水道",
    ["Forgotten Reliquary"] = "遗忘圣物室",
    ["Forgotten Temple"] = "遗忘神殿",
    ["Ruined Fane"] = "残破圣坛",
    ["Disused Reliquary"] = "废弃圣物室",
    ["Outer Steppes"] = "外围荒原",
    ["Plains of Despair"] = "绝望平原",
    ["City of the Damned"] = "神罚之城",
    ["River of Flame"] = "火焰之河",
    ["Chaos Sanctuary"] = "混沌庇护所",
    ["Bloody Foothills"] = "血腥丘陵",
    ["Frigid Highlands"] = "冰冻高地",
    ["Abaddon"] = "亚巴顿",
    ["Arreat Plateau"] = "亚瑞特高原",
    ["Pit of Acheron"] = "冥河之洞",
    ["Crystalline Passage"] = "水晶通道",
    ["Frozen River"] = "冰河",
    ["Glacial Trail"] = "冰河路径",
    ["Drifter Cavern"] = "漂泊者洞穴",
    ["Frozen Tundra"] = "冰冻苔原",
    ["Infernal Pit"] = "地狱深坑",
    ["Ancient's Way"] = "先祖之路",
    ["Icy Cellar"] = "冰窖",
    ["Halls of Anguish"] = "痛苦之厅",
    ["Halls of Pain"] = "悲惨之厅",
    ["Halls of Vaught"] = "沃特之厅",
    ["Nihlathak's Temple"] = "尼拉塞克神殿",
    ["Temple Halls"] = "神殿诸厅",
    ["Worldstone Keep"] = "世界之石要塞",
    ["Throne of Destruction"] = "毁灭王座",
    ["Worldstone Chamber"] = "世界之石大殿",
}

local function norm(s)
    s = string.gsub(s, " ", " ")
    s = string.gsub(s, " ", " ")
    s = string.gsub(s, "’", "'")
    s = string.gsub(s, "%s+", " ")
    s = string.lower((string.gsub(s, "^%s*(.-)%s*$", "%1")))
    return (string.gsub(s, "^the%s+", ""))
end
local areaByName = {}
for name in pairs(zhAreas) do areaByName[norm(name)] = name end
local areaAliases = {
    ["act 2 sewers"] = "Lut Gholein Sewers",
    ["secret cow level"] = "Moo Moo Farm",
    ["tal rasha's tomb"] = "Tal Rasha's Tombs",
    ["abbadon"] = "Abaddon",
    ["palace"] = "Palace Cellar",
    ["ancients' way"] = "Ancient's Way",
    ["ancients way"] = "Ancient's Way",
    ["halls of vaught (temple halls)"] = "Halls of Vaught",
}
local function area(name)
    return areaAliases[norm(name)] or areaByName[norm(name)]
end
local function parts(name)
    name = string.lower(name)
    name = string.gsub(name, " ", " ")
    name = string.gsub(name, " ", " ")
    name = string.gsub(name, ",%s*and%s+", "/")
    name = string.gsub(name, "%s+and%s+", "/")
    name = string.gsub(name, "[,+&]", "/")
    return string.split(name, "/")
end
-- Normalize every area before matching a whole group. Retain explicit group
-- aliases and their ratings; other complete known combinations use area data.
local function groupKey(name)
    local names = parts(name)
    for i, part in ipairs(names) do names[i] = area(part) or norm(part) end
    table.sort(names)
    return table.concat(names, "/")
end
local groupByName = {}
for _, group in ipairs(groups) do
    groupByName[groupKey(group[1])] = group
    for _, alias in ipairs(group[4] or {}) do
        groupByName[groupKey(alias)] = group
    end
end

local rank = { F = 0, D = 1, C = 2, B = 3, A = 4, S = 5 }
local function best(old, incoming)
    if incoming and (old == "?" or rank[incoming] > rank[old]) then return incoming end
    return old
end
local function grade(parts)
    local xp, loot, found = "?", "?", 0
    for _, part in ipairs(parts) do
        local name = area(part)
        local rating = name and legacy[name]
        if rating then
            xp, loot = best(xp, rating.xp), best(loot, rating.loot)
            found += 1
        end
    end
    return xp, loot, found
end

function M.lookup(raw, language)
    if type(raw) ~= "string" or raw == "" then return nil end
    local group = groupByName[groupKey(raw)]
    if group then
        local override = group[5]
        local xp, loot = "?", "?"
        if override then xp, loot = override.xp, override.loot
        else xp, loot = grade(group[3]) end
        return {
            en = raw, display = language == "zh-Hans" and group[2] or raw,
            xp = xp, loot = loot,
            provenance = override and "group" or "legacy",
            sourceGroup = override and override.sourceGroup or nil,
        }
    end
    local names, translated = parts(raw), {}
    for i, part in ipairs(names) do
        names[i] = area(part)
        if not names[i] then
            -- Do not present a partial grade as a rating for an unknown group.
            return { en = raw, display = raw, xp = "?", loot = "?", provenance = "unknown" }
        end
        translated[i] = zhAreas[names[i]]
    end
    local xp, loot, found = grade(names)
    return { en = raw, display = language == "zh-Hans" and table.concat(translated, "／") or raw,
        xp = xp, loot = loot, provenance = found > 0 and "legacy" or "unknown" }
end

return M
