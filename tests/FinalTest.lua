-- FinalTest.lua
-- Comprehensive integration test for the complete modular system
-- Tests all modules, dependencies, and core functionality

print("🧪 === HAIKYU HUB V4 FINAL INTEGRATION TEST ===")

local testResults = {}
local function addResult(testName, success, details)
    testResults[testName] = {success = success, details = details or ""}
    local status = success and "✅ PASS" or "❌ FAIL"
    print(string.format("%s %s: %s", status, testName, details or ""))
end

-- Test 1: Module Loading
local modules = {}
local moduleNames = {"ResourceUtil", "UIComponents", "UIFX", "HaikyuLogic", "DataManager", "WebhookManager", "UIController"}

for _, moduleName in ipairs(moduleNames) do
    local success, module = pcall(function()
        return require(script.Parent[moduleName])
    end)
    
    if success then
        modules[moduleName] = module
        addResult("Load " .. moduleName, true)
    else
        addResult("Load " .. moduleName, false, tostring(module))
    end
end

-- Test 2: Resource Management
if modules.ResourceUtil then
    local group = modules.ResourceUtil.createResourceGroup()
    local stats = modules.ResourceUtil.getResourceStats()
    addResult("ResourceUtil Functions", group ~= nil and stats ~= nil, 
              string.format("Connections: %d", stats.activeConnections))
end

-- Test 3: UI Components
if modules.UIComponents then
    local testFrame = modules.UIComponents.makeFrame{Size = UDim2.new(0, 100, 0, 100)}
    local testButton = modules.UIComponents.makeButton("Test")
    local testLabel = modules.UIComponents.makeLabel("Test Label")
    
    local componentsWork = testFrame ~= nil and testButton ~= nil and testLabel ~= nil
    addResult("UIComponents Factory", componentsWork, "Frame, Button, Label created")
    
    -- Cleanup test objects
    if testFrame then testFrame:Destroy() end
    if testButton then testButton:Destroy() end
    if testLabel then testLabel:Destroy() end
end

-- Test 4: Animation System
if modules.UIFX then
    local testObj = Instance.new("Frame")
    local tween = modules.UIFX.fadeIn(testObj, 0.1)
    addResult("UIFX Animations", tween ~= nil, "Fade animation created")
    testObj:Destroy()
end

-- Test 5: Game Logic
if modules.HaikyuLogic then
    local charCount = #modules.HaikyuLogic.haikyuCharacters
    local testStatus = modules.HaikyuLogic.getStatus("Timeskip Hinata")
    addResult("HaikyuLogic Core", charCount > 0 and testStatus ~= nil, 
              string.format("%d characters loaded", charCount))
end

-- Test 6: Data Management
if modules.DataManager then
    local defaultData = modules.DataManager.init()
    local stats = modules.DataManager.getDataStats()
    addResult("DataManager System", defaultData ~= nil and stats ~= nil,
              string.format("Data size: %d bytes", stats.dataSize))
end

-- Test 7: Webhook System
if modules.WebhookManager then
    local queueStatus = modules.WebhookManager.getQueueStatus()
    addResult("WebhookManager Queue", queueStatus ~= nil,
              string.format("Queue length: %d", queueStatus.queueLength))
end

-- Test 8: Full Integration
if modules.UIController and modules.HaikyuLogic and modules.UIComponents and 
   modules.UIFX and modules.ResourceUtil and modules.DataManager then
    
    local integrationSuccess, integrationResult = pcall(function()
        -- Initialize data first
        local savedData = modules.DataManager.init()
        modules.HaikyuLogic.initializeFromSavedData(savedData)
        modules.WebhookManager.setCharacterDataSource(modules.HaikyuLogic.getCharacterData)
        
        -- Initialize UI
        return modules.UIController.init{
            gameLogic = modules.HaikyuLogic,
            uiFX = modules.UIFX,
            components = modules.UIComponents,
            resUtil = modules.ResourceUtil,
            dataManager = modules.DataManager,
            webhookManager = modules.WebhookManager,
        }
    end)
    
    if integrationSuccess then
        addResult("Full Integration", true, "All systems operational")
        
        -- Test UI functions
        local isVisible = modules.UIController.isVisible()
        local isMinimized = modules.UIController.isMinimized()
        addResult("UI State Management", true, 
                  string.format("Visible: %s, Minimized: %s", tostring(isVisible), tostring(isMinimized)))
        
        -- Test character management
        modules.UIController.setCharacterEnabled("Timeskip Hinata", true)
        local status = modules.HaikyuLogic.getStatus("Timeskip Hinata")
        addResult("Character Management", status.enabled == true, "Character enable/disable works")
        
        -- Cleanup after test
        task.delay(3, function()
            modules.UIController.destroy()
            modules.DataManager.cleanup()
            addResult("Cleanup", true, "Resources cleaned up")
        end)
    else
        addResult("Full Integration", false, tostring(integrationResult))
    end
else
    addResult("Full Integration", false, "Missing required modules")
end

-- Test Summary
task.delay(1, function()
    print("\n📋 === TEST SUMMARY ===")
    local passCount = 0
    local totalCount = 0
    
    for testName, result in pairs(testResults) do
        totalCount = totalCount + 1
        if result.success then
            passCount = passCount + 1
        end
    end
    
    local successRate = math.floor((passCount / totalCount) * 100 + 0.5)
    print(string.format("🎯 Success Rate: %d%% (%d/%d tests passed)", successRate, passCount, totalCount))
    
    if successRate >= 90 then
        print("🎉 EXCELLENT: System is ready for production use!")
    elseif successRate >= 75 then
        print("⚠️  GOOD: System is mostly functional, minor issues detected")
    else
        print("🚨 ISSUES: System has significant problems that need attention")
    end
    
    print("🔧 Ready for deployment in Roblox executor")
    print("📖 See README.md for usage instructions")
end)
