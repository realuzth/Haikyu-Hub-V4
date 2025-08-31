-- HaikyuLogic.lua
-- Tracks game state, individual character presence, statistics, badge counts, alarms, and API for UI
-- Based on 'Steal a Haikyu' tracker functionality

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local HaikyuLogic = {}

-- Character database from original script
local CHARACTER_DATABASE = {
    ["Timeskip Hinata"] = {rarity = "Secret", tier = 1, baseChar = "Hinata", income = 40000},
    ["Awakened Tobio Kageyama"] = {rarity = "Awakened", tier = 2, baseChar = "Kageyama", income = 34200},
    ["Awakened Kiyoomi Sakusa"] = {rarity = "Awakened", tier = 2, baseChar = "Sakusa", income = 25000},
    ["Awakened Korai Hoshiumi"] = {rarity = "Awakened", tier = 2, baseChar = "Hoshiumi", income = 32000},
    ["Awakened Wakatoshi Ushijima"] = {rarity = "Awakened", tier = 2, baseChar = "Ushijima", income = 28000},
    ["Shinsuke Kita"] = {rarity = "Mythic", tier = 3, baseChar = "Kita", income = 17300},
    ["Tobio Kageyama"] = {rarity = "Mythic", tier = 3, baseChar = "Kageyama", income = 10000},
    ["Korai Hoshiumi"] = {rarity = "Mythic", tier = 3, baseChar = "Hoshiumi", income = 5000},
    ["Wakatoshi Ushijima"] = {rarity = "Mythic", tier = 3, baseChar = "Ushijima", income = 4500},
    ["Kiyoomi Sakusa"] = {rarity = "Mythic", tier = 3, baseChar = "Sakusa", income = 2250},
    ["Keiji Akaashi"] = {rarity = "Legendary", tier = 4, baseChar = "Akaashi", income = 1295},
    ["Takanobu Aone"] = {rarity = "Legendary", tier = 4, baseChar = "Aone", income = 1200},
    ["Tetsuro Kuroo"] = {rarity = "Legendary", tier = 4, baseChar = "Kuroo", income = 1100},
    ["Alt Art MSBY Atsumu"] = {rarity = "Legendary", tier = 4, baseChar = "Atsumu", income = 810},
    ["Kotaro Bokuto"] = {rarity = "Legendary", tier = 4, baseChar = "Bokuto", income = 785},
    ["Oikawa"] = {rarity = "Legendary", tier = 4, baseChar = "Oikawa", income = 460},
    ["Koshi Sugawara"] = {rarity = "Rare", tier = 5, baseChar = "Sugawara", income = 210},
    ["Kenma Kozume"] = {rarity = "Rare", tier = 5, baseChar = "Kenma", income = 160},
    ["Yaku Morisuke"] = {rarity = "Rare", tier = 5, baseChar = "Yaku", income = 130},
    ["Yamaguchi"] = {rarity = "Rare", tier = 5, baseChar = "Yamaguchi", income = 90},
    ["Satori Tendo"] = {rarity = "Rare", tier = 5, baseChar = "Tendo", income = 62},
    ["Daichi Sawamura"] = {rarity = "Rare", tier = 5, baseChar = "Daichi", income = 50},
    ["Rintaro Suna"] = {rarity = "Uncommon", tier = 6, baseChar = "Suna", income = 28},
    ["Atsumu Miya"] = {rarity = "Uncommon", tier = 6, baseChar = "Atsumu", income = 25},
    ["Kei Tsukishima"] = {rarity = "Uncommon", tier = 6, baseChar = "Tsukishima", income = 22},
    ["Shoyo Hinata"] = {rarity = "Uncommon", tier = 6, baseChar = "Hinata", income = 15},
    ["Hajime Iwaizumi"] = {rarity = "Uncommon", tier = 6, baseChar = "Iwaizumi", income = 12},
    ["Kentaro Kyotani"] = {rarity = "Uncommon", tier = 6, baseChar = "Kyotani", income = 10},
    ["Yuu Nishinoya"] = {rarity = "Common", tier = 7, baseChar = "Nishinoya", income = 5},
    ["Taketora Yamamoto"] = {rarity = "Common", tier = 7, baseChar = "Yamamoto", income = 3},
    ["Lev Haiba"] = {rarity = "Common", tier = 7, baseChar = "Lev", income = 2},
    ["Komori Motoya"] = {rarity = "Common", tier = 7, baseChar = "Komori", income = 1}
}

-- Generate mutation variants (Golden, Diamond, Emerald)
local function generateMutationVariants()
    local variants = {}
    
    -- Base characters
    for name, data in pairs(CHARACTER_DATABASE) do
        variants[name] = {
            rarity = data.rarity, 
            tier = data.tier, 
            baseChar = data.baseChar, 
            mutation = nil, 
            income = data.income,
            multiplier = 1.0, 
            fullName = name
        }
    end
    
    -- Golden variants (1.25x multiplier)
    for name, data in pairs(CHARACTER_DATABASE) do
        local goldenName = "Golden " .. name
        local goldenIncome = math.floor(data.income * 1.25 + 0.5)
        variants[goldenName] = {
            rarity = data.rarity, 
            tier = data.tier, 
            baseChar = data.baseChar, 
            mutation = "Golden", 
            income = goldenIncome,
            multiplier = 1.25, 
            fullName = goldenName
        }
    end
    
    -- Diamond variants (1.75x multiplier)
    for name, data in pairs(CHARACTER_DATABASE) do
        local diamondName = "Diamond " .. name
        local diamondIncome = math.floor(data.income * 1.75 + 0.5)
        variants[diamondName] = {
            rarity = data.rarity, 
            tier = data.tier, 
            baseChar = data.baseChar, 
            mutation = "Diamond", 
            income = diamondIncome,
            multiplier = 1.75, 
            fullName = diamondName
        }
    end
    
    -- Emerald variants (2.4x multiplier)
    for name, data in pairs(CHARACTER_DATABASE) do
        local emeraldName = "Emerald " .. name
        local emeraldIncome = math.floor(data.income * 2.4 + 0.5)
        variants[emeraldName] = {
            rarity = data.rarity, 
            tier = data.tier, 
            baseChar = data.baseChar, 
            mutation = "Emerald", 
            income = emeraldIncome,
            multiplier = 2.4, 
            fullName = emeraldName
        }
    end
    
    return variants
end

local COMPLETE_DATABASE = generateMutationVariants()

-- Get sorted character list
local function getSortedCharacters()
    local orderedCharacters = {
        "Timeskip Hinata", "Awakened Tobio Kageyama", "Awakened Kiyoomi Sakusa", "Awakened Korai Hoshiumi",
        "Awakened Wakatoshi Ushijima", "Shinsuke Kita", "Tobio Kageyama", "Korai Hoshiumi", "Wakatoshi Ushijima",
        "Kiyoomi Sakusa", "Keiji Akaashi", "Takanobu Aone", "Tetsuro Kuroo", "Alt Art MSBY Atsumu",
        "Kotaro Bokuto", "Oikawa", "Koshi Sugawara", "Kenma Kozume", "Yaku Morisuke", "Yamaguchi",
        "Satori Tendo", "Daichi Sawamura", "Rintaro Suna", "Atsumu Miya", "Kei Tsukishima", "Shoyo Hinata",
        "Hajime Iwaizumi", "Kentaro Kyotani", "Yuu Nishinoya", "Taketora Yamamoto", "Lev Haiba", "Komori Motoya",
        "Golden Timeskip Hinata", "Golden Awakened Tobio Kageyama", "Golden Awakened Kiyoomi Sakusa",
        "Golden Awakened Korai Hoshiumi", "Golden Awakened Wakatoshi Ushijima", "Golden Shinsuke Kita",
        "Golden Tobio Kageyama", "Golden Korai Hoshiumi", "Golden Wakatoshi Ushijima", "Golden Kiyoomi Sakusa",
        "Golden Keiji Akaashi", "Golden Takanobu Aone", "Golden Tetsuro Kuroo", "Golden Alt Art MSBY Atsumu",
        "Golden Kotaro Bokuto", "Golden Oikawa", "Golden Koshi Sugawara", "Golden Kenma Kozume",
        "Golden Yaku Morisuke", "Golden Yamaguchi", "Golden Satori Tendo", "Golden Daichi Sawamura",
        "Golden Rintaro Suna", "Golden Atsumu Miya", "Golden Kei Tsukishima", "Golden Shoyo Hinata",
        "Golden Hajime Iwaizumi", "Golden Kentaro Kyotani", "Golden Yuu Nishinoya", "Golden Taketora Yamamoto",
        "Golden Lev Haiba", "Golden Komori Motoya", "Diamond Timeskip Hinata", "Diamond Awakened Tobio Kageyama",
        "Diamond Awakened Kiyoomi Sakusa", "Diamond Awakened Korai Hoshiumi", "Diamond Awakened Wakatoshi Ushijima",
        "Diamond Shinsuke Kita", "Diamond Tobio Kageyama", "Diamond Korai Hoshiumi", "Diamond Wakatoshi Ushijima",
        "Diamond Kiyoomi Sakusa", "Diamond Keiji Akaashi", "Diamond Takanobu Aone", "Diamond Tetsuro Kuroo",
        "Diamond Alt Art MSBY Atsumu", "Diamond Kotaro Bokuto", "Diamond Oikawa", "Diamond Koshi Sugawara",
        "Diamond Kenma Kozume", "Diamond Yaku Morisuke", "Diamond Yamaguchi", "Diamond Satori Tendo",
        "Diamond Daichi Sawamura", "Diamond Rintaro Suna", "Diamond Atsumu Miya", "Diamond Kei Tsukishima",
        "Diamond Shoyo Hinata", "Diamond Hajime Iwaizumi", "Diamond Kentaro Kyotani", "Diamond Yuu Nishinoya",
        "Diamond Taketora Yamamoto", "Diamond Lev Haiba", "Diamond Komori Motoya", "Emerald Timeskip Hinata", 
        "Emerald Awakened Tobio Kageyama", "Emerald Awakened Kiyoomi Sakusa", "Emerald Awakened Korai Hoshiumi", 
        "Emerald Awakened Wakatoshi Ushijima", "Emerald Shinsuke Kita", "Emerald Tobio Kageyama", 
        "Emerald Korai Hoshiumi", "Emerald Wakatoshi Ushijima", "Emerald Kiyoomi Sakusa", "Emerald Keiji Akaashi", 
        "Emerald Takanobu Aone", "Emerald Tetsuro Kuroo", "Emerald Alt Art MSBY Atsumu", "Emerald Kotaro Bokuto", 
        "Emerald Oikawa", "Emerald Koshi Sugawara", "Emerald Kenma Kozume", "Emerald Yaku Morisuke", 
        "Emerald Yamaguchi", "Emerald Satori Tendo", "Emerald Daichi Sawamura", "Emerald Rintaro Suna", 
        "Emerald Atsumu Miya", "Emerald Kei Tsukishima", "Emerald Shoyo Hinata", "Emerald Hajime Iwaizumi", 
        "Emerald Kentaro Kyotani", "Emerald Yuu Nishinoya", "Emerald Taketora Yamamoto", "Emerald Lev Haiba", 
        "Emerald Komori Motoya"
    }
    
    -- Fill in missing tier data
    for name, data in pairs(COMPLETE_DATABASE) do
        if not data.tier then
            local tierMap = {Secret = 1, Awakened = 2, Mythic = 3, Legendary = 4, Rare = 5, Uncommon = 6, Common = 7}
            data.tier = tierMap[data.rarity] or 8
        end
        if not data.baseChar then
            local cleanName = name:gsub("Golden ", ""):gsub("Diamond ", ""):gsub("Emerald ", "")
            data.baseChar = cleanName
        end
    end
    
    local finalList = {}
    for _, charName in ipairs(orderedCharacters) do
        if COMPLETE_DATABASE[charName] then
            table.insert(finalList, charName)
        end
    end
    
    -- Add any remaining characters not in ordered list
    for name, _ in pairs(COMPLETE_DATABASE) do
        local found = false
        for _, orderedName in ipairs(orderedCharacters) do
            if orderedName == name then
                found = true
                break
            end
        end
        if not found then
            table.insert(finalList, name)
        end
    end
    
    return finalList
end

-- Export character list
HaikyuLogic.haikyuCharacters = getSortedCharacters()

-- Internal state tracking
local characterStatus = {}
for _, name in ipairs(HaikyuLogic.haikyuCharacters) do
    characterStatus[name] = {
        enabled = false, -- Start with false, will be set by saved data
        currentCount = 0,
        totalCount = 0,
        sessionSpawns = 0,
        lastPresentTime = nil,
        status = "never",
        lastSeen = 0,
        totalTime = 0
    }
end

-- Configuration
local CONFIG = {
    UPDATE_INTERVAL = 0.15,
    ALARM_SOUND_ID = "rbxassetid://5476307813",
    SOUND_VOLUME = 0.8
}

-- Utility: Scan workspace for character models
local function getAllPresentCharacters()
    local found = {}
    for _, name in ipairs(HaikyuLogic.haikyuCharacters) do
        found[name] = {}
        for _, child in ipairs(Workspace:GetChildren()) do
            if child.Name == name and child:IsA("Model") then
                table.insert(found[name], child)
            end
        end
    end
    return found
end

-- Alarm: Play sound cue on new appearances
local function playAlarm(rarity, mutation)
    local sound = Instance.new("Sound", SoundService)
    sound.SoundId = CONFIG.ALARM_SOUND_ID
    
    -- Adjust pitch based on rarity
    local basePitch = {
        Secret = 1.4,
        Awakened = 1.3,
        Mythic = 1.2,
        Legendary = 1.1,
        Rare = 1.0,
        Uncommon = 0.9,
        Common = 0.8
    }
    
    local mutationBonus = 0
    if mutation == "Golden" then
        mutationBonus = 0.1
    elseif mutation == "Diamond" then
        mutationBonus = 0.2
    elseif mutation == "Emerald" then
        mutationBonus = 0.3
    end
    
    sound.PlaybackSpeed = (basePitch[rarity] or 1.0) + mutationBonus
    sound.Volume = CONFIG.SOUND_VOLUME * (mutation == "Diamond" and 1.2 or mutation == "Golden" and 1.1 or 1.0)
    sound:Play()
    
    sound.Ended:Connect(function() sound:Destroy() end)
    task.delay(10, function() if sound and sound.Parent then sound:Destroy() end end)
end

-- Public API for polling/updating logic (invoked on Heartbeat or by UI)
function HaikyuLogic.pollCharacters()
    local current = getAllPresentCharacters()
    local now = tick()
    
    -- Compare with last, update states, and trigger alarm if needed
    for _, name in ipairs(HaikyuLogic.haikyuCharacters) do
        local instances = current[name] or {}
        local anyPresent = #instances > 0
        local lastStatus = characterStatus[name]
        
        if anyPresent then
            -- New spawn detected?
            if lastStatus.currentCount < #instances and lastStatus.enabled then
                local charData = COMPLETE_DATABASE[name]
                if charData then
                    playAlarm(charData.rarity, charData.mutation)
                    lastStatus.sessionSpawns = lastStatus.sessionSpawns + 1
                    lastStatus.totalCount = lastStatus.totalCount + 1
                    
                    -- Trigger webhook notification if callback is set
                    if HaikyuLogic.onCharacterSpawn then
                        HaikyuLogic.onCharacterSpawn(name, charData, #instances)
                    end
                end
            end
            lastStatus.status = "present"
            lastStatus.currentCount = #instances
            lastStatus.lastPresentTime = now
            lastStatus.lastSeen = os.time()
        else
            -- Gone/missing
            if lastStatus.lastPresentTime then
                lastStatus.status = "absent"
                lastStatus.currentCount = 0
            else
                lastStatus.status = "never"
            end
        end
    end
end

-- Public API functions
function HaikyuLogic.getStatus(characterName)
    -- Defensive, returns status record for a given character
    return characterStatus[characterName]
end

function HaikyuLogic.setEnabled(characterName, enabled)
    if characterStatus[characterName] then
        characterStatus[characterName].enabled = enabled
    end
end

function HaikyuLogic.getAllStatuses()
    return characterStatus
end

function HaikyuLogic.getCharacterDatabase()
    return COMPLETE_DATABASE
end

function HaikyuLogic.getCharacterData(characterName)
    return COMPLETE_DATABASE[characterName]
end

-- Initialize character states from saved data
function HaikyuLogic.initializeFromSavedData(savedData)
    if not savedData or not savedData.characters then return end
    
    for name, savedCharData in pairs(savedData.characters) do
        if characterStatus[name] then
            characterStatus[name].enabled = savedCharData.enabled or false
            characterStatus[name].totalCount = savedCharData.totalSeen or 0
            characterStatus[name].sessionSpawns = savedCharData.sessionSpawns or 0
            characterStatus[name].lastSeen = savedCharData.lastSeen or 0
            characterStatus[name].totalTime = savedCharData.totalTime or 0
        end
    end
end

-- Get data for saving
function HaikyuLogic.getDataForSaving()
    local saveData = {}
    for name, status in pairs(characterStatus) do
        saveData[name] = {
            enabled = status.enabled,
            totalSeen = status.totalCount,
            sessionSpawns = status.sessionSpawns,
            lastSeen = status.lastSeen,
            totalTime = status.totalTime,
            currentCount = status.currentCount,
            status = status.status
        }
    end
    return saveData
end

-- Update character tracking with delta time
function HaikyuLogic.updateCharacterStates(deltaTime)
    deltaTime = deltaTime or CONFIG.UPDATE_INTERVAL
    
    for _, charName in ipairs(HaikyuLogic.haikyuCharacters) do
        local trackData = characterStatus[charName]
        if not trackData then continue end
        
        if trackData.enabled and trackData.status == "present" then
            trackData.totalTime = trackData.totalTime + deltaTime
        end
    end
end

return HaikyuLogic
