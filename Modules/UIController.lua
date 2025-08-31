-- UIController.lua
-- Main UI orchestrator that builds the interface, handles events, and manages state
-- Connects game logic with visual components and manages the complete user experience

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local UIController = {}

-- Dependencies (injected during init)
local gameLogic, uiFX, components, resUtil, dataManager, webhookManager
local resourceGroup

-- UI state
local screenGui
local mainFrame
local sidebar
local contentPanel
local infoLabel
local characterToggles = {}
local isVisible = true
local isMinimized = false
local isDragging = false
local dragStart, startPos

-- Configuration
local CONFIG = {
    REFRESH_INTERVAL = 0.15,
    UI_SIZE = UDim2.new(0, 600, 0, 400),
    MIN_SIZE = UDim2.new(0, 300, 0, 200),
    ANIMATION_SPEED = 0.3
}

-- Initialize the UI system
function UIController.init(deps)
    -- Store dependencies
    gameLogic = deps.gameLogic
    uiFX = deps.uiFX
    components = deps.components
    resUtil = deps.resUtil
    dataManager = deps.dataManager
    webhookManager = deps.webhookManager
    
    -- Create resource group for cleanup
    resourceGroup = resUtil.createResourceGroup()
    
    print("[UIController] Initializing UI system...")
    
    -- Create main UI structure
    createMainUI()
    setupEventHandlers()
    startUpdateLoop()
    
    print("[UIController] UI system initialized successfully")
    return UIController
end

-- Create the main UI structure
function createMainUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HaikyuHubV4"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    resourceGroup:trackObject(screenGui)
    screenGui.Parent = playerGui
    
    -- Main frame with futuristic styling
    mainFrame = components.makeFrame{
        Size = CONFIG.UI_SIZE,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BGColor = Color3.fromRGB(20, 30, 55),
        CornerRadius = UDim.new(0, 14),
        Transparency = 0.1,
        Gradient = {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 55)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 65))
            },
            Rotation = 135
        },
        Stroke = {
            Color = Color3.fromRGB(0, 191, 255),
            Thickness = 2,
            Transparency = 0.6
        }
    }
    mainFrame.Parent = screenGui
    
    -- Header with drag support
    local header = components.makeHeader("Haikyu Hub V4", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0)
    })
    header.Parent = mainFrame
    
    -- Setup header button events
    resourceGroup:trackConnection(header.CloseButton.MouseButton1Click:Connect(function()
        uiFX.buttonPress(header.CloseButton)
        UIController.destroy()
    end))
    
    resourceGroup:trackConnection(header.MinimizeButton.MouseButton1Click:Connect(function()
        uiFX.buttonPress(header.MinimizeButton)
        UIController.toggleMinimize()
    end))
    
    -- Drag functionality
    setupDragSupport(header)
    
    -- Sidebar for character toggles
    sidebar = components.makeSidebar{
        Size = UDim2.new(0, 180, 1, -60),
        Position = UDim2.new(0, 10, 0, 50)
    }
    sidebar.Parent = mainFrame
    
    -- Content panel for status display
    contentPanel = components.makeContentPanel{
        Size = UDim2.new(1, -200, 1, -60),
        Position = UDim2.new(0, 190, 0, 50)
    }
    contentPanel.Parent = mainFrame
    
    -- Info label at bottom
    infoLabel = components.makeInfoLabel("Initializing...", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 1, -25)
    })
    infoLabel.Parent = mainFrame
    
    -- Populate character toggles
    populateCharacterToggles()
    
    -- Initial UI animations
    uiFX.fadeIn(mainFrame, 0.5, 0.1)
    uiFX.glowPulse(mainFrame, Color3.fromRGB(0, 191, 255), 0.2, 2.0)
end

-- Setup drag support for the header
function setupDragSupport(header)
    resourceGroup:trackConnection(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end))
    
    resourceGroup:trackConnection(header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end))
    
    resourceGroup:trackConnection(UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            mainFrame.Position = newPosition
        end
    end))
end

-- Populate the sidebar with character toggles
function populateCharacterToggles()
    local characterList = sidebar.CharacterList
    
    for i, characterName in ipairs(gameLogic.haikyuCharacters) do
        local toggle = components.makeCharacterToggle(characterName, {
            LayoutOrder = i,
            Checked = false -- Will be updated from saved data
        })
        toggle.Parent = characterList
        
        -- Store reference
        characterToggles[characterName] = toggle
        
        -- Connect toggle event
        resourceGroup:trackConnection(toggle.Checkbox.MouseButton1Click:Connect(function()
            local isChecked = toggle.Checkbox:Toggle()
            gameLogic.setEnabled(characterName, isChecked)
            
            -- Visual feedback
            uiFX.buttonPress(toggle.Checkbox)
            if isChecked then
                uiFX.glowPulse(toggle, Color3.fromRGB(50, 205, 50), 0.3, 0.5)
            end
            
            updateCharacterToggleDisplay(characterName)
        end))
        
        -- Add hover effects
        uiFX.addHoverEffect(toggle, 1.02, 0.1)
    end
    
    -- Initialize toggle states from game logic
    for characterName, toggle in pairs(characterToggles) do
        local status = gameLogic.getStatus(characterName)
        if status then
            toggle.Checkbox:SetAttribute("Checked", status.enabled)
            updateCharacterToggleDisplay(characterName)
        end
    end
end

-- Update character toggle display based on current status
function updateCharacterToggleDisplay(characterName)
    local toggle = characterToggles[characterName]
    local status = gameLogic.getStatus(characterName)
    
    if not toggle or not status then return end
    
    -- Update status indicator
    toggle.StatusDot:SetStatus(status.status)
    
    -- Update checkbox appearance
    local isEnabled = status.enabled
    toggle.Checkbox.BackgroundColor3 = isEnabled and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(140, 140, 140)
    
    local stroke = toggle.Checkbox:FindFirstChild("UIStroke")
    if stroke then
        stroke.Color = isEnabled and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(0, 191, 255)
        stroke.Transparency = isEnabled and 0.3 or 0.8
    end
    
    local checkIcon = toggle.Checkbox:FindFirstChild("TextLabel")
    if checkIcon then
        checkIcon.Text = isEnabled and "✓" or ""
    end
end

-- Refresh the content panel with current character statuses
function refreshContentPanel()
    local contentArea = contentPanel.ContentArea
    
    -- Clear existing content
    for _, child in ipairs(contentArea:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Add status entries for enabled characters
    local enabledCount = 0
    local presentCount = 0
    
    for _, characterName in ipairs(gameLogic.haikyuCharacters) do
        local status = gameLogic.getStatus(characterName)
        if not status or not status.enabled then continue end
        
        enabledCount = enabledCount + 1
        if status.status == "present" then
            presentCount = presentCount + 1
        end
        
        -- Create status row
        local statusRow = components.makeFrame{
            Size = UDim2.new(1, -8, 0, 24),
            BGColor = Color3.fromRGB(0, 0, 0),
            Transparency = 0.7,
            CornerRadius = UDim.new(0, 4)
        }
        statusRow.Parent = contentArea
        
        -- Character name
        local nameLabel = components.makeLabel(characterName, {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor = Color3.fromRGB(255, 255, 255)
        })
        nameLabel.Parent = statusRow
        
        -- Status indicator
        local statusIndicator = components.makeStatusIndicator{
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0.6, 4, 0.5, -4)
        }
        statusIndicator:SetStatus(status.status)
        statusIndicator.Parent = statusRow
        
        -- Count display
        local countLabel = components.makeLabel(
            string.format("×%d", status.currentCount),
            {
                Size = UDim2.new(0.25, 0, 1, 0),
                Position = UDim2.new(0.65, 0, 0, 0),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor = status.status == "present" and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(200, 200, 200),
                TextXAlignment = Enum.TextXAlignment.Center
            }
        )
        countLabel.Parent = statusRow
        
        -- Session spawns
        local sessionLabel = components.makeLabel(
            string.format("S:%d", status.sessionSpawns),
            {
                Size = UDim2.new(0.15, 0, 1, 0),
                Position = UDim2.new(0.85, 0, 0, 0),
                TextSize = 9,
                Font = Enum.Font.Gotham,
                TextColor = Color3.fromRGB(0, 191, 255),
                TextXAlignment = Enum.TextXAlignment.Center
            }
        )
        sessionLabel.Parent = statusRow
        
        -- Add subtle animation on creation
        statusRow.BackgroundTransparency = 1
        uiFX.fadeIn(statusRow, 0.2, 0.7)
    end
    
    -- Update info label
    local timestamp = os.date("%H:%M:%S")
    infoLabel.Text = string.format("Last updated: %s | Tracking: %d | Present: %d", 
                                   timestamp, enabledCount, presentCount)
end

-- Setup main event handlers
function setupEventHandlers()
    -- Setup character spawn callback for webhooks
    if gameLogic and webhookManager then
        gameLogic.onCharacterSpawn = function(characterName, characterData, spawnCount)
            -- Auto-save data on spawn
            if dataManager then
                dataManager.updateCharacterData(characterName, gameLogic.getStatus(characterName))
            end
            
            -- Send webhook notification if enabled
            local settings = dataManager and dataManager.getSettings() or {}
            if settings.webhookUrl and settings.webhookUrl ~= "" and settings.notifications then
                webhookManager.notifyCharacterSpawn(characterName, settings.webhookUrl)
            end
        end
    end
    
    -- Main update loop
    local lastRefresh = 0
    resourceGroup:trackConnection(RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastRefresh >= CONFIG.REFRESH_INTERVAL then
            gameLogic.pollCharacters()
            gameLogic.updateCharacterStates(now - lastRefresh)
            
            -- Update UI displays
            for characterName, _ in pairs(characterToggles) do
                updateCharacterToggleDisplay(characterName)
            end
            
            refreshContentPanel()
            lastRefresh = now
        end
    end))
    
    -- Keyboard shortcuts
    resourceGroup:trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F4 then
            UIController.toggle()
        elseif input.KeyCode == Enum.KeyCode.F5 then
            UIController.toggleMinimize()
        elseif input.KeyCode == Enum.KeyCode.Escape then
            if isVisible then
                UIController.hide()
            end
        end
    end))
end

-- Start the main update loop
function startUpdateLoop()
    local lastUpdate = tick()
    
    local function updateLoop()
        while screenGui and screenGui.Parent do
            local now = tick()
            local deltaTime = now - lastUpdate
            
            -- Update game logic
            gameLogic.updateCharacterStates(deltaTime)
            
            lastUpdate = now
            task.wait(CONFIG.REFRESH_INTERVAL)
        end
    end
    
    resourceGroup:trackTimer(task.spawn(updateLoop))
end

-- Public API functions
function UIController.show()
    if not screenGui then return end
    
    screenGui.Enabled = true
    isVisible = true
    
    if not isMinimized then
        uiFX.fadeIn(mainFrame, CONFIG.ANIMATION_SPEED, 0.1)
        uiFX.slide(mainFrame, UDim2.new(0.5, -300, 0.5, -200), CONFIG.ANIMATION_SPEED, "BOUNCE")
    end
end

function UIController.hide()
    if not screenGui then return end
    
    local hideTween = uiFX.fadeOut(mainFrame, CONFIG.ANIMATION_SPEED, 1)
    hideTween.Completed:Connect(function()
        screenGui.Enabled = false
        isVisible = false
    end)
end

function UIController.toggle()
    if isVisible then
        UIController.hide()
    else
        UIController.show()
    end
end

function UIController.toggleMinimize()
    if not mainFrame then return end
    
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Minimize: hide sidebar and content, shrink frame
        uiFX.fadeOut(sidebar, 0.2, 1)
        uiFX.fadeOut(contentPanel, 0.2, 1)
        uiFX.resizeTo(mainFrame, UDim2.new(0, 200, 0, 40), 0.3, "BOUNCE")
    else
        -- Restore: show sidebar and content, restore size
        uiFX.resizeTo(mainFrame, CONFIG.UI_SIZE, 0.3, "BOUNCE")
        task.delay(0.15, function()
            uiFX.fadeIn(sidebar, 0.2, 0.15)
            uiFX.fadeIn(contentPanel, 0.2, 0.2)
        end)
    end
end

function UIController.isVisible()
    return isVisible and screenGui and screenGui.Enabled
end

function UIController.isMinimized()
    return isMinimized
end

-- Update UI with new data
function UIController.updateDisplay()
    if not isVisible or isMinimized then return end
    
    -- Refresh all character toggle displays
    for characterName, _ in pairs(characterToggles) do
        updateCharacterToggleDisplay(characterName)
    end
    
    -- Refresh content panel
    refreshContentPanel()
end

-- Set character enabled state from external source
function UIController.setCharacterEnabled(characterName, enabled)
    gameLogic.setEnabled(characterName, enabled)
    
    local toggle = characterToggles[characterName]
    if toggle then
        toggle.Checkbox:SetAttribute("Checked", enabled)
        updateCharacterToggleDisplay(characterName)
        
        -- Visual feedback
        if enabled then
            uiFX.glowPulse(toggle, Color3.fromRGB(50, 205, 50), 0.3, 0.5)
        end
    end
end

-- Enable all characters
function UIController.enableAll()
    for _, characterName in ipairs(gameLogic.haikyuCharacters) do
        UIController.setCharacterEnabled(characterName, true)
    end
    
    uiFX.showNotification(screenGui, "All characters enabled!", "success", 2.0)
end

-- Disable all characters
function UIController.disableAll()
    for _, characterName in ipairs(gameLogic.haikyuCharacters) do
        UIController.setCharacterEnabled(characterName, false)
    end
    
    uiFX.showNotification(screenGui, "All characters disabled!", "warning", 2.0)
end

-- Get UI statistics
function UIController.getStats()
    if not screenGui then return nil end
    
    return {
        isVisible = isVisible,
        isMinimized = isMinimized,
        characterCount = #gameLogic.haikyuCharacters,
        enabledCount = 0, -- Will be calculated
        presentCount = 0, -- Will be calculated
        resourceStats = resUtil.getResourceStats()
    }
end

-- Apply saved UI settings
function UIController.applySavedSettings(savedSettings)
    if not savedSettings then return end
    
    -- Apply character enabled states
    if savedSettings.characters then
        for characterName, charData in pairs(savedSettings.characters) do
            UIController.setCharacterEnabled(characterName, charData.enabled or false)
        end
    end
    
    -- Apply UI position and size
    if savedSettings.ui then
        if savedSettings.ui.position and mainFrame then
            mainFrame.Position = UDim2.fromScale(savedSettings.ui.position.X, savedSettings.ui.position.Y)
        end
        if savedSettings.ui.size and mainFrame then
            mainFrame.Size = UDim2.fromOffset(savedSettings.ui.size.X, savedSettings.ui.size.Y)
        end
        if savedSettings.ui.minimized ~= nil then
            if savedSettings.ui.minimized ~= isMinimized then
                UIController.toggleMinimize()
            end
        end
    end
end

-- Get current UI settings for saving
function UIController.getSettingsForSaving()
    if not mainFrame then return {} end
    
    return {
        ui = {
            position = {
                X = mainFrame.Position.X.Scale,
                Y = mainFrame.Position.Y.Scale
            },
            size = {
                X = mainFrame.AbsoluteSize.X,
                Y = mainFrame.AbsoluteSize.Y
            },
            minimized = isMinimized,
            visible = isVisible
        },
        characters = gameLogic.getDataForSaving()
    }
end

-- Add control buttons to header
function addControlButtons()
    if not mainFrame then return end
    
    -- Enable All button
    local enableAllBtn = components.makeButton("Enable All", {
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(0, 10, 1, -30),
        BGColor = Color3.fromRGB(50, 205, 50),
        TextSize = 10
    })
    enableAllBtn.Parent = mainFrame
    
    resourceGroup:trackConnection(enableAllBtn.MouseButton1Click:Connect(function()
        uiFX.buttonPress(enableAllBtn)
        UIController.enableAll()
    end))
    
    -- Disable All button
    local disableAllBtn = components.makeButton("Disable All", {
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(0, 100, 1, -30),
        BGColor = Color3.fromRGB(220, 53, 69),
        TextSize = 10
    })
    disableAllBtn.Parent = mainFrame
    
    resourceGroup:trackConnection(disableAllBtn.MouseButton1Click:Connect(function()
        uiFX.buttonPress(disableAllBtn)
        UIController.disableAll()
    end))
end

-- Cleanup and destroy UI
function UIController.destroy()
    print("[UIController] Cleaning up UI system...")
    
    -- Fade out animation before destroying
    if mainFrame then
        local fadeOut = uiFX.fadeOut(mainFrame, 0.3, 1)
        fadeOut.Completed:Connect(function()
            -- Clean up all resources
            if resourceGroup then
                resourceGroup:cleanup()
            end
            
            -- Destroy main UI
            if screenGui then
                screenGui:Destroy()
                screenGui = nil
            end
            
            -- Reset state
            mainFrame = nil
            sidebar = nil
            contentPanel = nil
            infoLabel = nil
            characterToggles = {}
            isVisible = false
            isMinimized = false
            
            print("[UIController] UI system destroyed")
        end)
    else
        -- Direct cleanup if no animation needed
        if resourceGroup then
            resourceGroup:cleanup()
        end
        if screenGui then
            screenGui:Destroy()
        end
    end
end

-- Error handling wrapper
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[UIController] Error:", result)
        if screenGui then
            uiFX.showNotification(screenGui, "UI Error: " .. tostring(result), "error", 5.0)
        end
    end
    return success, result
end

-- Initialize with error handling
local originalInit = UIController.init
function UIController.init(deps)
    return safeCall(originalInit, deps)
end

return UIController
