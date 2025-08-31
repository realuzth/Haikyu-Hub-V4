-- UIComponents.lua
-- Factory functions for creating styled UI elements with futuristic HoHo Hub V4 aesthetic
-- Provides consistent styling, gradients, rounded corners, and modern design patterns

local UIComponents = {}

-- Color palette for futuristic theme
local COLORS = {
    PRIMARY_BG = Color3.fromRGB(20, 30, 55),
    SECONDARY_BG = Color3.fromRGB(25, 35, 65),
    HEADER_BG = Color3.fromRGB(25, 85, 110),
    SIDEBAR_BG = Color3.fromRGB(28, 52, 100),
    BUTTON_ACTIVE = Color3.fromRGB(31, 95, 172),
    BUTTON_INACTIVE = Color3.fromRGB(140, 140, 140),
    BUTTON_HOVER = Color3.fromRGB(45, 115, 200),
    SUCCESS_GREEN = Color3.fromRGB(50, 205, 50),
    WARNING_ORANGE = Color3.fromRGB(255, 165, 0),
    ERROR_RED = Color3.fromRGB(220, 53, 69),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    ACCENT_BLUE = Color3.fromRGB(0, 191, 255),
    ACCENT_TEAL = Color3.fromRGB(0, 255, 255)
}

-- Create a frame with futuristic styling
function UIComponents.makeFrame(props)
    props = props or {}
    
    local frame = Instance.new("Frame")
    frame.Size = props.Size or UDim2.new(1, 0, 1, 0)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = props.BGColor or COLORS.PRIMARY_BG
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = props.Transparency or 0.1
    
    -- Add rounded corners
    if props.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = props.CornerRadius
        corner.Parent = frame
    end
    
    -- Add gradient if specified
    if props.Gradient then
        local gradient = Instance.new("UIGradient")
        gradient.Color = props.Gradient.Color or ColorSequence.new{
            ColorSequenceKeypoint.new(0, COLORS.PRIMARY_BG),
            ColorSequenceKeypoint.new(1, COLORS.SECONDARY_BG)
        }
        gradient.Rotation = props.Gradient.Rotation or 90
        gradient.Parent = frame
    end
    
    -- Add stroke/outline if specified
    if props.Stroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = props.Stroke.Color or COLORS.ACCENT_BLUE
        stroke.Thickness = props.Stroke.Thickness or 1
        stroke.Transparency = props.Stroke.Transparency or 0.5
        stroke.Parent = frame
    end
    
    return frame
end

-- Create a styled button with hover effects
function UIComponents.makeButton(text, props)
    props = props or {}
    
    local button = Instance.new("TextButton")
    button.Size = props.Size or UDim2.new(0, 100, 0, 32)
    button.Position = props.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = props.BGColor or COLORS.BUTTON_ACTIVE
    button.BorderSizePixel = 0
    button.Text = text or "Button"
    button.TextColor3 = props.TextColor or COLORS.TEXT_PRIMARY
    button.TextSize = props.TextSize or 14
    button.Font = props.Font or Enum.Font.GothamBold
    button.BackgroundTransparency = props.Transparency or 0.2
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = props.CornerRadius or UDim.new(0, 8)
    corner.Parent = button
    
    -- Gradient effect
    if props.UseGradient ~= false then
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, button.BackgroundColor3),
            ColorSequenceKeypoint.new(1, Color3.new(
                math.min(1, button.BackgroundColor3.R * 1.3),
                math.min(1, button.BackgroundColor3.G * 1.3),
                math.min(1, button.BackgroundColor3.B * 1.3)
            ))
        }
        gradient.Rotation = 45
        gradient.Parent = button
    end
    
    -- Glow stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = props.StrokeColor or COLORS.ACCENT_BLUE
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = props.HoverColor or COLORS.BUTTON_HOVER
        stroke.Transparency = 0.3
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = props.BGColor or COLORS.BUTTON_ACTIVE
        stroke.Transparency = 0.7
    end)
    
    return button
end

-- Create a styled text label
function UIComponents.makeLabel(text, props)
    props = props or {}
    
    local label = Instance.new("TextLabel")
    label.Size = props.Size or UDim2.new(1, 0, 0, 24)
    label.Position = props.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = props.BGTransparency or 1
    label.Text = text or "Label"
    label.TextColor3 = props.TextColor or COLORS.TEXT_PRIMARY
    label.TextSize = props.TextSize or 14
    label.Font = props.Font or Enum.Font.Gotham
    label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    label.TextWrapped = props.TextWrapped or false
    
    -- Optional background
    if props.BGColor then
        label.BackgroundTransparency = props.BGTransparency or 0.3
        label.BackgroundColor3 = props.BGColor
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = props.CornerRadius or UDim.new(0, 6)
        corner.Parent = label
    end
    
    return label
end

-- Create a checkbox/toggle with glow effect
function UIComponents.makeCheckbox(props)
    props = props or {}
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = props.Size or UDim2.new(0, 20, 0, 20)
    checkbox.Position = props.Position or UDim2.new(0, 0, 0, 0)
    checkbox.Text = ""
    checkbox.BackgroundColor3 = props.Checked and COLORS.SUCCESS_GREEN or COLORS.BUTTON_INACTIVE
    checkbox.BorderSizePixel = 0
    checkbox.BackgroundTransparency = 0.2
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = checkbox
    
    -- Glow stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = props.Checked and COLORS.SUCCESS_GREEN or COLORS.ACCENT_BLUE
    stroke.Thickness = 1
    stroke.Transparency = props.Checked and 0.3 or 0.8
    stroke.Parent = checkbox
    
    -- Check mark icon
    local checkIcon = Instance.new("TextLabel")
    checkIcon.Size = UDim2.new(1, 0, 1, 0)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Text = props.Checked and "✓" or ""
    checkIcon.TextColor3 = COLORS.TEXT_PRIMARY
    checkIcon.TextSize = 14
    checkIcon.Font = Enum.Font.GothamBold
    checkIcon.TextXAlignment = Enum.TextXAlignment.Center
    checkIcon.TextYAlignment = Enum.TextYAlignment.Center
    checkIcon.Parent = checkbox
    
    -- Store state
    checkbox:SetAttribute("Checked", props.Checked or false)
    
    -- Toggle function
    function checkbox:Toggle()
        local isChecked = not checkbox:GetAttribute("Checked")
        checkbox:SetAttribute("Checked", isChecked)
        
        checkbox.BackgroundColor3 = isChecked and COLORS.SUCCESS_GREEN or COLORS.BUTTON_INACTIVE
        stroke.Color = isChecked and COLORS.SUCCESS_GREEN or COLORS.ACCENT_BLUE
        stroke.Transparency = isChecked and 0.3 or 0.8
        checkIcon.Text = isChecked and "✓" or ""
        
        return isChecked
    end
    
    return checkbox
end

-- Create a scrolling frame with custom scrollbar
function UIComponents.makeScrollingFrame(props)
    props = props or {}
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = props.Size or UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundColor3 = props.BGColor or COLORS.SECONDARY_BG
    scrollFrame.BackgroundTransparency = props.Transparency or 0.3
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = COLORS.ACCENT_BLUE
    scrollFrame.ScrollBarImageTransparency = 0.3
    scrollFrame.CanvasSize = props.CanvasSize or UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollingDirection = props.ScrollingDirection or Enum.ScrollingDirection.Y
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = props.CornerRadius or UDim.new(0, 8)
    corner.Parent = scrollFrame
    
    -- Auto-layout if specified
    if props.UseListLayout then
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = props.Padding or UDim.new(0, 4)
        listLayout.Parent = scrollFrame
        
        -- Auto-resize canvas
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end)
    end
    
    return scrollFrame
end

-- Create an image label with loading state
function UIComponents.makeImageLabel(props)
    props = props or {}
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = props.Size or UDim2.new(0, 32, 0, 32)
    imageLabel.Position = props.Position or UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = props.BGTransparency or 1
    imageLabel.Image = props.Image or ""
    imageLabel.ImageTransparency = props.ImageTransparency or 0
    imageLabel.ScaleType = props.ScaleType or Enum.ScaleType.Fit
    
    -- Rounded corners
    if props.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = props.CornerRadius
        corner.Parent = imageLabel
    end
    
    return imageLabel
end

-- Create a progress bar
function UIComponents.makeProgressBar(props)
    props = props or {}
    
    local container = Instance.new("Frame")
    container.Size = props.Size or UDim2.new(1, 0, 0, 8)
    container.Position = props.Position or UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = props.BGColor or COLORS.BUTTON_INACTIVE
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(props.Progress or 0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = props.FillColor or COLORS.ACCENT_BLUE
    fill.BorderSizePixel = 0
    fill.Parent = container
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    -- Gradient on fill
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, fill.BackgroundColor3),
        ColorSequenceKeypoint.new(1, Color3.new(
            math.min(1, fill.BackgroundColor3.R * 1.4),
            math.min(1, fill.BackgroundColor3.G * 1.4),
            math.min(1, fill.BackgroundColor3.B * 1.4)
        ))
    }
    gradient.Parent = fill
    
    -- Update progress function
    function container:SetProgress(progress)
        fill.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
    end
    
    return container
end

-- Create a status indicator (dot with color)
function UIComponents.makeStatusIndicator(props)
    props = props or {}
    
    local indicator = Instance.new("Frame")
    indicator.Size = props.Size or UDim2.new(0, 12, 0, 12)
    indicator.Position = props.Position or UDim2.new(0, 0, 0, 0)
    indicator.BackgroundColor3 = props.Color or COLORS.BUTTON_INACTIVE
    indicator.BorderSizePixel = 0
    
    -- Make it circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = indicator
    
    -- Glow effect
    local stroke = Instance.new("UIStroke")
    stroke.Color = indicator.BackgroundColor3
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = indicator
    
    -- Update status function
    function indicator:SetStatus(status)
        local statusColors = {
            present = COLORS.SUCCESS_GREEN,
            absent = COLORS.WARNING_ORANGE,
            never = COLORS.BUTTON_INACTIVE,
            error = COLORS.ERROR_RED
        }
        
        local color = statusColors[status] or COLORS.BUTTON_INACTIVE
        indicator.BackgroundColor3 = color
        stroke.Color = color
    end
    
    return indicator
end

-- Create a character toggle row (checkbox + label + status)
function UIComponents.makeCharacterToggle(characterName, props)
    props = props or {}
    
    local container = Instance.new("Frame")
    container.Size = props.Size or UDim2.new(1, -8, 0, 28)
    container.BackgroundTransparency = 1
    container.LayoutOrder = props.LayoutOrder or 0
    
    -- Checkbox
    local checkbox = UIComponents.makeCheckbox{
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 4, 0.5, -9),
        Checked = props.Checked or false
    }
    checkbox.Parent = container
    
    -- Character name label
    local nameLabel = UIComponents.makeLabel(characterName, {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor = COLORS.TEXT_PRIMARY
    })
    nameLabel.Parent = container
    
    -- Status indicator
    local statusDot = UIComponents.makeStatusIndicator{
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -16, 0.5, -5)
    }
    statusDot.Parent = container
    
    -- Hover effect on container
    local hoverFrame = Instance.new("Frame")
    hoverFrame.Size = UDim2.new(1, 0, 1, 0)
    hoverFrame.BackgroundColor3 = COLORS.ACCENT_BLUE
    hoverFrame.BackgroundTransparency = 1
    hoverFrame.BorderSizePixel = 0
    hoverFrame.Parent = container
    
    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 6)
    hoverCorner.Parent = hoverFrame
    
    container.MouseEnter:Connect(function()
        hoverFrame.BackgroundTransparency = 0.9
    end)
    
    container.MouseLeave:Connect(function()
        hoverFrame.BackgroundTransparency = 1
    end)
    
    -- Expose components
    container.Checkbox = checkbox
    container.NameLabel = nameLabel
    container.StatusDot = statusDot
    
    return container
end

-- Create a header with title and controls
function UIComponents.makeHeader(title, props)
    props = props or {}
    
    local header = UIComponents.makeFrame{
        Size = props.Size or UDim2.new(1, 0, 0, 40),
        Position = props.Position or UDim2.new(0, 0, 0, 0),
        BGColor = COLORS.HEADER_BG,
        CornerRadius = UDim.new(0, 12),
        Gradient = {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, COLORS.HEADER_BG),
                ColorSequenceKeypoint.new(1, Color3.new(
                    math.min(1, COLORS.HEADER_BG.R * 1.2),
                    math.min(1, COLORS.HEADER_BG.G * 1.2),
                    math.min(1, COLORS.HEADER_BG.B * 1.2)
                ))
            },
            Rotation = 45
        }
    }
    
    -- Title label
    local titleLabel = UIComponents.makeLabel(title, {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor = COLORS.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    titleLabel.Parent = header
    
    -- Close button
    local closeButton = UIComponents.makeButton("×", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BGColor = COLORS.ERROR_RED,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        CornerRadius = UDim.new(0, 6)
    })
    closeButton.Parent = header
    
    -- Minimize button
    local minimizeButton = UIComponents.makeButton("−", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BGColor = COLORS.WARNING_ORANGE,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        CornerRadius = UDim.new(0, 6)
    })
    minimizeButton.Parent = header
    
    -- Expose components
    header.TitleLabel = titleLabel
    header.CloseButton = closeButton
    header.MinimizeButton = minimizeButton
    
    return header
end

-- Create a content panel for displaying information
function UIComponents.makeContentPanel(props)
    props = props or {}
    
    local panel = UIComponents.makeFrame{
        Size = props.Size or UDim2.new(1, -200, 1, -60),
        Position = props.Position or UDim2.new(0, 190, 0, 50),
        BGColor = COLORS.SECONDARY_BG,
        CornerRadius = UDim.new(0, 8),
        Transparency = 0.2,
        Stroke = {
            Color = COLORS.ACCENT_BLUE,
            Thickness = 1,
            Transparency = 0.6
        }
    }
    
    -- Content area with padding
    local contentArea = UIComponents.makeScrollingFrame{
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BGColor = Color3.fromRGB(0, 0, 0),
        Transparency = 0.8,
        CornerRadius = UDim.new(0, 6),
        UseListLayout = true,
        Padding = UDim.new(0, 6)
    }
    contentArea.Parent = panel
    
    panel.ContentArea = contentArea
    return panel
end

-- Create an info label for status display
function UIComponents.makeInfoLabel(text, props)
    props = props or {}
    
    local infoLabel = UIComponents.makeLabel(text, {
        Size = props.Size or UDim2.new(1, -20, 0, 20),
        Position = props.Position or UDim2.new(0, 10, 1, -25),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor = COLORS.TEXT_SECONDARY,
        TextXAlignment = Enum.TextXAlignment.Left,
        BGColor = Color3.fromRGB(0, 0, 0),
        BGTransparency = 0.7,
        CornerRadius = UDim.new(0, 4)
    })
    
    return infoLabel
end

-- Create a loading spinner
function UIComponents.makeLoadingSpinner(props)
    props = props or {}
    
    local spinner = Instance.new("ImageLabel")
    spinner.Size = props.Size or UDim2.new(0, 24, 0, 24)
    spinner.Position = props.Position or UDim2.new(0.5, -12, 0.5, -12)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxasset://textures/loading/robloxTilt.png"
    spinner.ImageColor3 = props.Color or COLORS.ACCENT_BLUE
    spinner.ImageTransparency = props.Transparency or 0.2
    
    return spinner
end

-- Create a sidebar with character list
function UIComponents.makeSidebar(props)
    props = props or {}
    
    local sidebar = UIComponents.makeFrame{
        Size = props.Size or UDim2.new(0, 180, 1, -60),
        Position = props.Position or UDim2.new(0, 10, 0, 50),
        BGColor = COLORS.SIDEBAR_BG,
        CornerRadius = UDim.new(0, 8),
        Transparency = 0.15,
        Stroke = {
            Color = COLORS.ACCENT_TEAL,
            Thickness = 1,
            Transparency = 0.7
        }
    }
    
    -- Header for sidebar
    local sidebarHeader = UIComponents.makeLabel("Characters", {
        Size = UDim2.new(1, -12, 0, 30),
        Position = UDim2.new(0, 6, 0, 6),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor = COLORS.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Center,
        BGColor = Color3.fromRGB(0, 0, 0),
        BGTransparency = 0.6,
        CornerRadius = UDim.new(0, 6)
    })
    sidebarHeader.Parent = sidebar
    
    -- Character list container
    local characterList = UIComponents.makeScrollingFrame{
        Size = UDim2.new(1, -12, 1, -42),
        Position = UDim2.new(0, 6, 0, 36),
        BGColor = Color3.fromRGB(0, 0, 0),
        Transparency = 0.8,
        CornerRadius = UDim.new(0, 6),
        UseListLayout = true,
        Padding = UDim.new(0, 2)
    }
    characterList.Parent = sidebar
    
    sidebar.CharacterList = characterList
    sidebar.Header = sidebarHeader
    
    return sidebar
end

return UIComponents
