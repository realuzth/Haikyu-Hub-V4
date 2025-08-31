-- OptimizedMainLoader.lua
-- Production-ready entry point with error handling and performance monitoring
-- This is the final script to be executed in Roblox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Performance monitoring
local startTime = tick()
local loadingSteps = {}

local function logStep(stepName)
    table.insert(loadingSteps, {name = stepName, time = tick() - startTime})
    print(string.format("[MainLoader] %s (%.3fs)", stepName, tick() - startTime))
end

logStep("Starting Haikyu Hub V4...")

-- Safe module loading with error handling
local function safeRequireModule(moduleName)
    local success, module = pcall(function()
        return require(script.Parent[moduleName])
    end)
    
    if success then
        logStep("Loaded " .. moduleName)
        return module
    else
        error("[MainLoader] Failed to load " .. moduleName .. ": " .. tostring(module))
    end
end

-- Initialize modules with dependency injection
local Modules = {}

-- Load core utilities first
Modules.ResourceUtil = safeRequireModule("ResourceUtil")
Modules.DataManager = safeRequireModule("DataManager")

-- Load UI and effects
Modules.UIComponents = safeRequireModule("UIComponents")
Modules.UIFX = safeRequireModule("UIFX")

-- Load game logic
Modules.HaikyuLogic = safeRequireModule("HaikyuLogic")

-- Load optional modules
Modules.WebhookManager = safeRequireModule("WebhookManager")

-- Load UI controller last
Modules.UIController = safeRequireModule("UIController")

logStep("All modules loaded")

-- Initialize data system and load saved settings
local savedData = Modules.DataManager.init()
logStep("Data system initialized")

-- Initialize game logic with saved character states
Modules.HaikyuLogic.initializeFromSavedData(savedData)
logStep("Game logic initialized")

-- Setup webhook integration
Modules.WebhookManager.setCharacterDataSource(Modules.HaikyuLogic.getCharacterData)
logStep("Webhook system configured")

-- Initialize UI with all dependencies
local uiSuccess, uiResult = pcall(function()
    return Modules.UIController.init{
        gameLogic = Modules.HaikyuLogic,
        uiFX = Modules.UIFX,
        components = Modules.UIComponents,
        resUtil = Modules.ResourceUtil,
        dataManager = Modules.DataManager,
        webhookManager = Modules.WebhookManager,
    }
end)

if not uiSuccess then
    error("[MainLoader] UI initialization failed: " .. tostring(uiResult))
end

logStep("UI system initialized")

-- Apply saved UI settings
Modules.UIController.applySavedSettings(savedData)
logStep("UI settings applied")

-- Setup global hotkeys
local player = Players.LocalPlayer
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        Modules.UIController.toggle()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Modules.UIController.toggleMinimize()
    elseif input.KeyCode == Enum.KeyCode.Escape then
        if Modules.UIController.isVisible() then
            Modules.UIController.hide()
        end
    end
end)

logStep("Hotkeys configured")

-- Setup cleanup on player leaving
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        -- Save final data
        local finalData = Modules.UIController.getSettingsForSaving()
        Modules.DataManager.saveData(finalData)
        
        -- Cleanup resources
        Modules.UIController.destroy()
        Modules.DataManager.cleanup()
        
        print("[MainLoader] Cleanup completed on player leave")
    end
end)

-- Performance summary
local totalLoadTime = tick() - startTime
print(string.format("[MainLoader] ✅ Haikyu Hub V4 fully loaded in %.3fs", totalLoadTime))
print("[MainLoader] 🎮 Press F4 to toggle UI, F5 to minimize, ESC to hide")

-- Optional: Display loading summary
if Modules.UIController.isVisible() then
    task.delay(2, function()
        if Modules.UIFX and Modules.UIController.isVisible() then
            local screenGui = player.PlayerGui:FindFirstChild("HaikyuHubV4")
            if screenGui then
                Modules.UIFX.showNotification(screenGui, 
                    string.format("Haikyu Hub V4 loaded in %.2fs", totalLoadTime), 
                    "success", 3.0)
            end
        end
    end)
end

-- Memory monitoring (optional debug feature)
if savedData.settings and savedData.settings.debugMode then
    local monitor = Modules.ResourceUtil.createPerformanceMonitor(5.0)
    monitor:start()
    
    task.spawn(function()
        while true do
            task.wait(30)
            local stats = monitor:getStats()
            print(string.format("[Debug] FPS: %d, Memory: %.2f MB", stats.fps, stats.memory))
        end
    end)
end
