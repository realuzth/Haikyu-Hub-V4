-- DataManager.lua
-- Data persistence and settings management for Haikyu Hub
-- Handles saving/loading character states, UI settings, and user preferences

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DataManager = {}

-- Configuration
local CONFIG = {
    SAVE_KEY = "HaikyuHubV4_Data",
    AUTO_SAVE_INTERVAL = 30, -- seconds
    BACKUP_COUNT = 3
}

-- Internal state
local currentData = {}
local lastSaveTime = 0
local autoSaveEnabled = true

-- Default data structure
local function getDefaultData()
    return {
        version = "1.0",
        lastSaved = os.time(),
        characters = {},
        ui = {
            position = {X = 0.5, Y = 0.5},
            size = {X = 600, Y = 400},
            minimized = false,
            visible = true
        },
        settings = {
            soundEnabled = true,
            soundVolume = 0.8,
            updateInterval = 0.15,
            autoSave = true,
            notifications = true
        },
        statistics = {
            totalSpawns = 0,
            sessionTime = 0,
            charactersFound = 0,
            lastSession = os.time()
        }
    }
end

-- Generate unique save key for current player
local function getSaveKey()
    local player = Players.LocalPlayer
    local userId = player.UserId
    return CONFIG.SAVE_KEY .. "_" .. tostring(userId)
end

-- Safe JSON encoding with error handling
local function safeEncode(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success then
        return result
    else
        warn("[DataManager] JSON encode failed:", result)
        return nil
    end
end

-- Safe JSON decoding with error handling
local function safeDecode(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if success then
        return result
    else
        warn("[DataManager] JSON decode failed:", result)
        return nil
    end
end

-- Save data to Roblox DataStore (if available) or local storage
function DataManager.saveData(data)
    if not data then
        data = currentData
    end
    
    data.lastSaved = os.time()
    data.version = "1.0"
    
    local saveKey = getSaveKey()
    local jsonData = safeEncode(data)
    
    if not jsonData then
        warn("[DataManager] Failed to encode save data")
        return false
    end
    
    -- Try to save using writefile (executor function)
    local success = pcall(function()
        if writefile then
            writefile(saveKey .. ".json", jsonData)
            print("[DataManager] Data saved to file:", saveKey .. ".json")
        else
            -- Fallback: store in game attributes (limited size)
            local player = Players.LocalPlayer
            player:SetAttribute(saveKey, jsonData)
            print("[DataManager] Data saved to player attributes")
        end
    end)
    
    if success then
        currentData = data
        lastSaveTime = tick()
        return true
    else
        warn("[DataManager] Save operation failed")
        return false
    end
end

-- Load data from storage
function DataManager.loadData()
    local saveKey = getSaveKey()
    local jsonData = nil
    
    -- Try to load from file first
    if readfile and isfile and isfile(saveKey .. ".json") then
        local success, result = pcall(function()
            return readfile(saveKey .. ".json")
        end)
        
        if success then
            jsonData = result
            print("[DataManager] Data loaded from file")
        end
    end
    
    -- Fallback: load from player attributes
    if not jsonData then
        local player = Players.LocalPlayer
        jsonData = player:GetAttribute(saveKey)
        if jsonData then
            print("[DataManager] Data loaded from player attributes")
        end
    end
    
    -- Parse JSON data
    if jsonData then
        local data = safeDecode(jsonData)
        if data then
            -- Merge with defaults to handle version differences
            local defaultData = getDefaultData()
            currentData = mergeData(defaultData, data)
            print("[DataManager] Save data loaded successfully")
            return currentData
        end
    end
    
    -- No save data found, use defaults
    print("[DataManager] No save data found, using defaults")
    currentData = getDefaultData()
    return currentData
end

-- Merge saved data with defaults (handles missing fields)
function mergeData(defaults, saved)
    local merged = {}
    
    -- Copy all default values first
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            merged[key] = mergeData(value, saved[key] or {})
        else
            merged[key] = value
        end
    end
    
    -- Override with saved values
    for key, value in pairs(saved) do
        if defaults[key] ~= nil then
            if type(value) == "table" and type(defaults[key]) == "table" then
                merged[key] = mergeData(defaults[key], value)
            else
                merged[key] = value
            end
        end
    end
    
    return merged
end

-- Get current data
function DataManager.getData()
    return currentData
end

-- Update specific data section
function DataManager.updateData(section, newData)
    if not currentData[section] then
        currentData[section] = {}
    end
    
    if type(newData) == "table" then
        for key, value in pairs(newData) do
            currentData[section][key] = value
        end
    else
        currentData[section] = newData
    end
    
    -- Auto-save if enabled
    if autoSaveEnabled and tick() - lastSaveTime > CONFIG.AUTO_SAVE_INTERVAL then
        DataManager.saveData()
    end
end

-- Update character data
function DataManager.updateCharacterData(characterName, charData)
    if not currentData.characters then
        currentData.characters = {}
    end
    
    currentData.characters[characterName] = charData
    
    -- Auto-save if enabled
    if autoSaveEnabled and tick() - lastSaveTime > CONFIG.AUTO_SAVE_INTERVAL then
        DataManager.saveData()
    end
end

-- Update UI settings
function DataManager.updateUISettings(uiData)
    DataManager.updateData("ui", uiData)
end

-- Update general settings
function DataManager.updateSettings(settings)
    DataManager.updateData("settings", settings)
end

-- Update statistics
function DataManager.updateStatistics(stats)
    DataManager.updateData("statistics", stats)
end

-- Get specific data section
function DataManager.getCharacterData()
    return currentData.characters or {}
end

function DataManager.getUISettings()
    return currentData.ui or {}
end

function DataManager.getSettings()
    return currentData.settings or {}
end

function DataManager.getStatistics()
    return currentData.statistics or {}
end

-- Auto-save system
function DataManager.startAutoSave(interval)
    interval = interval or CONFIG.AUTO_SAVE_INTERVAL
    
    local function autoSaveLoop()
        while autoSaveEnabled do
            task.wait(interval)
            if tick() - lastSaveTime > interval then
                DataManager.saveData()
            end
        end
    end
    
    task.spawn(autoSaveLoop)
    print("[DataManager] Auto-save started with", interval, "second interval")
end

function DataManager.stopAutoSave()
    autoSaveEnabled = false
    print("[DataManager] Auto-save stopped")
end

-- Create backup of current data
function DataManager.createBackup()
    local backupKey = getSaveKey() .. "_backup_" .. os.time()
    local success = pcall(function()
        if writefile then
            local jsonData = safeEncode(currentData)
            if jsonData then
                writefile(backupKey .. ".json", jsonData)
                print("[DataManager] Backup created:", backupKey)
            end
        end
    end)
    
    return success
end

-- Reset data to defaults
function DataManager.resetToDefaults()
    print("[DataManager] Resetting data to defaults...")
    
    -- Create backup before reset
    DataManager.createBackup()
    
    currentData = getDefaultData()
    DataManager.saveData()
    
    print("[DataManager] Data reset completed")
    return currentData
end

-- Export data for sharing
function DataManager.exportData()
    local exportData = {
        characters = currentData.characters,
        settings = currentData.settings,
        exportTime = os.time(),
        version = currentData.version
    }
    
    return safeEncode(exportData)
end

-- Import data from string
function DataManager.importData(jsonString)
    local importedData = safeDecode(jsonString)
    if not importedData then
        return false, "Invalid JSON data"
    end
    
    -- Validate imported data structure
    if type(importedData.characters) ~= "table" then
        return false, "Invalid character data"
    end
    
    -- Create backup before import
    DataManager.createBackup()
    
    -- Merge imported data
    if importedData.characters then
        currentData.characters = importedData.characters
    end
    if importedData.settings then
        for key, value in pairs(importedData.settings) do
            currentData.settings[key] = value
        end
    end
    
    DataManager.saveData()
    print("[DataManager] Data imported successfully")
    return true, "Import successful"
end

-- Get data size and statistics
function DataManager.getDataStats()
    local jsonSize = 0
    local jsonData = safeEncode(currentData)
    if jsonData then
        jsonSize = #jsonData
    end
    
    local characterCount = 0
    if currentData.characters then
        for _ in pairs(currentData.characters) do
            characterCount = characterCount + 1
        end
    end
    
    return {
        dataSize = jsonSize,
        characterCount = characterCount,
        lastSaved = lastSaveTime,
        version = currentData.version,
        autoSaveEnabled = autoSaveEnabled
    }
end

-- Initialize data system
function DataManager.init()
    print("[DataManager] Initializing data system...")
    
    -- Load existing data or create defaults
    DataManager.loadData()
    
    -- Start auto-save
    if currentData.settings.autoSave then
        DataManager.startAutoSave()
    end
    
    print("[DataManager] Data system initialized")
    return currentData
end

-- Cleanup and final save
function DataManager.cleanup()
    print("[DataManager] Cleaning up data system...")
    
    autoSaveEnabled = false
    DataManager.saveData() -- Final save
    
    print("[DataManager] Data system cleanup completed")
end

return DataManager
