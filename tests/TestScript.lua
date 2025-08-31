-- TestScript.lua
-- Simple test to verify all modules load correctly and basic functionality works

print("=== Haikyu Hub V4 Module Test ===")

-- Test individual module loading
local function testModuleLoad(moduleName)
    local success, module = pcall(function()
        return require(script.Parent[moduleName])
    end)
    
    if success then
        print("✓ " .. moduleName .. " loaded successfully")
        return module
    else
        print("✗ " .. moduleName .. " failed to load: " .. tostring(module))
        return nil
    end
end

-- Load all modules
local ResourceUtil = testModuleLoad("ResourceUtil")
local UIComponents = testModuleLoad("UIComponents")
local UIFX = testModuleLoad("UIFX")
local HaikyuLogic = testModuleLoad("HaikyuLogic")
local UIController = testModuleLoad("UIController")

-- Test basic functionality
if ResourceUtil then
    print("Testing ResourceUtil...")
    local group = ResourceUtil.createResourceGroup()
    print("✓ Resource group created")
    
    local stats = ResourceUtil.getResourceStats()
    print("✓ Resource stats:", stats.activeConnections, "connections")
end

if UIComponents then
    print("Testing UIComponents...")
    local testFrame = UIComponents.makeFrame{Size = UDim2.new(0, 100, 0, 100)}
    print("✓ Frame created")
    
    local testButton = UIComponents.makeButton("Test")
    print("✓ Button created")
    
    testFrame:Destroy()
    testButton:Destroy()
end

if HaikyuLogic then
    print("Testing HaikyuLogic...")
    print("✓ Character count:", #HaikyuLogic.haikyuCharacters)
    
    local testStatus = HaikyuLogic.getStatus("Timeskip Hinata")
    if testStatus then
        print("✓ Character status retrieved")
    end
end

if UIController and HaikyuLogic and UIComponents and UIFX and ResourceUtil then
    print("Testing full integration...")
    
    -- Test initialization
    local success, result = pcall(function()
        return UIController.init{
            gameLogic = HaikyuLogic,
            uiFX = UIFX,
            components = UIComponents,
            resUtil = ResourceUtil,
        }
    end)
    
    if success then
        print("✓ Full integration test passed")
        
        -- Test UI functions
        print("✓ UI visibility:", UIController.isVisible())
        print("✓ UI minimized:", UIController.isMinimized())
        
        -- Cleanup after test
        task.wait(2)
        UIController.destroy()
        print("✓ Cleanup completed")
    else
        print("✗ Integration test failed:", result)
    end
else
    print("✗ Cannot run integration test - missing modules")
end

print("=== Test Complete ===")
