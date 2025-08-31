-- GitHubLoader.lua
-- HTTP-based module loader for GitHub deployment
-- Replace YOUR_USERNAME with your actual GitHub username

local BASE_URL = "https://raw.githubusercontent.com/realuzth/Haikyu-Hub-V4/refs/heads/main/Modules/"

-- HTTP module loader
local function httpRequire(url)
    local success, source = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        error("Failed to fetch module from: " .. url .. " - " .. tostring(source))
    end
    
    local moduleFunc, loadError = loadstring(source)
    if not moduleFunc then
        error("Failed to compile module from: " .. url .. " - " .. tostring(loadError))
    end
    
    return moduleFunc()
end

print("[GitHubLoader] Starting Haikyu Hub V4 from GitHub...")

-- Load modules from GitHub
local Modules = {}
local moduleList = {
    "ResourceUtil",
    "UIComponents", 
    "UIFX",
    "HaikyuLogic",
    "DataManager",
    "WebhookManager",
    "UIController"
}

-- Load each module with error handling
for _, moduleName in ipairs(moduleList) do
    local moduleUrl = BASE_URL .. moduleName .. ".lua"
    print("[GitHubLoader] Loading " .. moduleName .. "...")
    
    local success, module = pcall(function()
        return httpRequire(moduleUrl)
    end)
    
    if success then
        Modules[moduleName] = module
        print("[GitHubLoader] ✅ " .. moduleName .. " loaded successfully")
    else
        error("[GitHubLoader] ❌ Failed to load " .. moduleName .. ": " .. tostring(module))
    end
end

print("[GitHubLoader] All modules loaded from GitHub!")

-- Initialize data system first
local savedData = Modules.DataManager.init()

-- Initialize game logic with saved data
Modules.HaikyuLogic.initializeFromSavedData(savedData)

-- Setup webhook integration
Modules.WebhookManager.setCharacterDataSource(Modules.HaikyuLogic.getCharacterData)

-- Initialize UI with all dependencies
Modules.UIController.init{
    gameLogic = Modules.HaikyuLogic,
    uiFX = Modules.UIFX,
    components = Modules.UIComponents,
    resUtil = Modules.ResourceUtil,
    dataManager = Modules.DataManager,
    webhookManager = Modules.WebhookManager,
}

-- Apply saved UI settings
Modules.UIController.applySavedSettings(savedData)

-- Setup hotkeys
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

print("[GitHubLoader] 🎉 Haikyu Hub V4 loaded successfully from GitHub!")
print("[GitHubLoader] 🎮 Press F4 to toggle UI, F5 to minimize, ESC to hide")

-- Show success notification
task.delay(1, function()
    local player = Players.LocalPlayer
    local screenGui = player.PlayerGui:FindFirstChild("HaikyuHubV4")
    if screenGui and Modules.UIFX then
        Modules.UIFX.showNotification(screenGui, "Loaded from GitHub successfully!", "success", 3.0)
    end
end)
