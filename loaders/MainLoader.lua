-- MainLoader.lua
-- Entry point for the modular Haikyu Hub script, executed by LocalPlayer
-- Based on the comprehensive modular architecture guide

local function httpRequire(url)
    -- Secure HTTP loader: fetches module source and executes it
    local source = game:HttpGet(url)
    local moduleFunc = loadstring(source)
    assert(type(moduleFunc) == "function", "Failed to fetch/compile module: " .. url)
    return moduleFunc()
end

-- For development, we'll embed modules directly instead of HTTP loading
-- This can be switched to HTTP loading for production deployment

-- Load modules (embedded for now, can be customized for offline/online)
local Modules = {}

-- We'll require the modules directly since they're in the same project
-- In production, these would be HTTP URLs
local function requireModule(moduleName)
    local success, module = pcall(function()
        return require(script.Parent[moduleName])
    end)
    if success then
        return module
    else
        error("Failed to load module: " .. moduleName)
    end
end

-- Initialize modules
print("[MainLoader] Loading modules...")
Modules.ResourceUtil     = requireModule("ResourceUtil")
Modules.UIComponents     = requireModule("UIComponents") 
Modules.UIFX             = requireModule("UIFX")
Modules.HaikyuLogic      = requireModule("HaikyuLogic")
Modules.DataManager      = requireModule("DataManager")
Modules.WebhookManager   = requireModule("WebhookManager")
Modules.UIController     = requireModule("UIController")

print("[MainLoader] All modules loaded successfully")

-- Initialize data system first
local savedData = Modules.DataManager.init()

-- Initialize game logic with saved data
Modules.HaikyuLogic.initializeFromSavedData(savedData)

-- Setup webhook manager with character data source
Modules.WebhookManager.setCharacterDataSource(Modules.HaikyuLogic.getCharacterData)

-- Init UI and game logic with dependency injection
Modules.UIController.init{
    gameLogic = Modules.HaikyuLogic,
    uiFX      = Modules.UIFX,
    components= Modules.UIComponents,
    resUtil   = Modules.ResourceUtil,
    dataManager = Modules.DataManager,
    webhookManager = Modules.WebhookManager,
}

-- Apply saved UI settings
Modules.UIController.applySavedSettings(savedData)

print("[MainLoader] Haikyu Hub V4 initialized successfully")

-- Optionally add command-line or hotkey for toggling UI visibility
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Toggle UI with F4 key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if Modules.UIController.isVisible() then
            Modules.UIController.hide()
        else
            Modules.UIController.show()
        end
    end
end)
