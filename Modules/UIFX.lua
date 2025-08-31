-- UIFX.lua
-- Animation and visual effects manager using TweenService
-- Provides smooth transitions, fade effects, pulsing, and loading animations

local TweenService = game:GetService("TweenService")

local UIFX = {}

-- Animation presets
local TWEEN_PRESETS = {
    FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NORMAL = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SLOW = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    BOUNCE = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    ELASTIC = TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    LINEAR = TweenInfo.new(1.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
}

-- Fade in animation
function UIFX.fadeIn(obj, duration, targetTransparency)
    duration = duration or 0.3
    targetTransparency = targetTransparency or 0
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {}
    
    if obj:IsA("GuiObject") then
        properties.BackgroundTransparency = targetTransparency
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            properties.TextTransparency = targetTransparency
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            properties.ImageTransparency = targetTransparency
        end
    end
    
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Fade out animation
function UIFX.fadeOut(obj, duration, targetTransparency)
    duration = duration or 0.3
    targetTransparency = targetTransparency or 1
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {}
    
    if obj:IsA("GuiObject") then
        properties.BackgroundTransparency = targetTransparency
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            properties.TextTransparency = targetTransparency
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            properties.ImageTransparency = targetTransparency
        end
    end
    
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Scale animation (grow/shrink)
function UIFX.scale(obj, targetScale, duration, preset)
    duration = duration or 0.3
    preset = preset or "NORMAL"
    
    local tweenInfo = TWEEN_PRESETS[preset] or TWEEN_PRESETS.NORMAL
    if duration ~= 0.3 then
        tweenInfo = TweenInfo.new(duration, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
    end
    
    local tween = TweenService:Create(obj, tweenInfo, {
        Size = UDim2.new(targetScale, 0, targetScale, 0)
    })
    tween:Play()
    return tween
end

-- Slide animation
function UIFX.slide(obj, targetPosition, duration, preset)
    duration = duration or 0.3
    preset = preset or "NORMAL"
    
    local tweenInfo = TWEEN_PRESETS[preset] or TWEEN_PRESETS.NORMAL
    if duration ~= 0.3 then
        tweenInfo = TweenInfo.new(duration, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
    end
    
    local tween = TweenService:Create(obj, tweenInfo, {
        Position = targetPosition
    })
    tween:Play()
    return tween
end

-- Pulsing glow effect
function UIFX.pulseGlow(obj, intensity, speed)
    intensity = intensity or 0.3
    speed = speed or 1.0
    
    local running = true
    local originalTransparency = obj.BackgroundTransparency
    
    local function pulse()
        while running and obj.Parent do
            -- Fade to glow
            local glowTween = TweenService:Create(obj, 
                TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundTransparency = originalTransparency - intensity}
            )
            glowTween:Play()
            glowTween.Completed:Wait()
            
            if not running or not obj.Parent then break end
            
            -- Fade back
            local fadeTween = TweenService:Create(obj,
                TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundTransparency = originalTransparency + intensity}
            )
            fadeTween:Play()
            fadeTween.Completed:Wait()
        end
    end
    
    task.spawn(pulse)
    
    -- Return stop function
    return function()
        running = false
        obj.BackgroundTransparency = originalTransparency
    end
end

-- Continuous rotation for loading spinners
function UIFX.rotateLoadingRing(ring, speed)
    speed = speed or 2.0
    local running = true
    
    local function rotate()
        while running and ring.Parent do
            local tween = TweenService:Create(ring, 
                TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                {Rotation = ring.Rotation + 360}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end
    
    task.spawn(rotate)
    
    -- Return stop function
    return function()
        running = false
    end
end

-- Color transition effect
function UIFX.colorTransition(obj, targetColor, duration)
    duration = duration or 0.5
    
    local tween = TweenService:Create(obj, 
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = targetColor}
    )
    tween:Play()
    return tween
end

-- Shake animation for alerts
function UIFX.shake(obj, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.5
    
    local originalPosition = obj.Position
    local shakeCount = math.floor(duration * 20) -- 20 shakes per second
    
    for i = 1, shakeCount do
        local offsetX = math.random(-intensity, intensity)
        local offsetY = math.random(-intensity, intensity)
        
        local tween = TweenService:Create(obj,
            TweenInfo.new(0.05, Enum.EasingStyle.Linear),
            {Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + offsetX,
                                  originalPosition.Y.Scale, originalPosition.Y.Offset + offsetY)}
        )
        tween:Play()
        
        if i == shakeCount then
            tween.Completed:Connect(function()
                obj.Position = originalPosition
            end)
        end
        
        task.wait(0.05)
    end
end

-- Typewriter text effect
function UIFX.typewriterText(textLabel, fullText, speed)
    speed = speed or 0.05
    textLabel.Text = ""
    
    for i = 1, #fullText do
        textLabel.Text = string.sub(fullText, 1, i)
        task.wait(speed)
    end
end

-- Smooth size transition
function UIFX.resizeTo(obj, targetSize, duration, preset)
    duration = duration or 0.3
    preset = preset or "NORMAL"
    
    local tweenInfo = TWEEN_PRESETS[preset] or TWEEN_PRESETS.NORMAL
    if duration ~= 0.3 then
        tweenInfo = TweenInfo.new(duration, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
    end
    
    local tween = TweenService:Create(obj, tweenInfo, {Size = targetSize})
    tween:Play()
    return tween
end

-- Button press animation
function UIFX.buttonPress(button, scaleDown, duration)
    scaleDown = scaleDown or 0.95
    duration = duration or 0.1
    
    local originalSize = button.Size
    
    -- Scale down
    local pressDown = TweenService:Create(button,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(originalSize.X.Scale * scaleDown, originalSize.X.Offset * scaleDown,
                          originalSize.Y.Scale * scaleDown, originalSize.Y.Offset * scaleDown)}
    )
    
    pressDown:Play()
    pressDown.Completed:Connect(function()
        -- Scale back up
        local pressUp = TweenService:Create(button,
            TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = originalSize}
        )
        pressUp:Play()
    end)
    
    return pressDown
end

-- Notification popup animation
function UIFX.showNotification(parent, text, notificationType, duration)
    notificationType = notificationType or "info"
    duration = duration or 3.0
    
    local colors = {
        success = Color3.fromRGB(50, 205, 50),
        warning = Color3.fromRGB(255, 165, 0),
        error = Color3.fromRGB(220, 53, 69),
        info = Color3.fromRGB(0, 191, 255)
    }
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, 20, 0, 20) -- Start off-screen
    notification.BackgroundColor3 = colors[notificationType] or colors.info
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = notification
    
    -- Slide in
    local slideIn = TweenService:Create(notification, TWEEN_PRESETS.BOUNCE, {
        Position = UDim2.new(1, -320, 0, 20)
    })
    slideIn:Play()
    
    -- Auto-dismiss after duration
    task.delay(duration, function()
        if notification.Parent then
            local slideOut = TweenService:Create(notification, TWEEN_PRESETS.FAST, {
                Position = UDim2.new(1, 20, 0, 20)
            })
            slideOut:Play()
            slideOut.Completed:Connect(function()
                notification:Destroy()
            end)
        end
    end)
    
    return notification
end

-- Gradient animation
function UIFX.animateGradient(gradientObj, colorSequences, duration)
    duration = duration or 2.0
    
    if #colorSequences < 2 then return end
    
    local currentIndex = 1
    local running = true
    
    local function cycle()
        while running and gradientObj.Parent do
            local nextIndex = (currentIndex % #colorSequences) + 1
            
            local tween = TweenService:Create(gradientObj,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Color = colorSequences[nextIndex]}
            )
            tween:Play()
            tween.Completed:Wait()
            
            currentIndex = nextIndex
        end
    end
    
    task.spawn(cycle)
    
    return function()
        running = false
    end
end

-- Loading dots animation
function UIFX.loadingDots(textLabel, baseText, dotCount, speed)
    dotCount = dotCount or 3
    speed = speed or 0.5
    baseText = baseText or "Loading"
    
    local running = true
    local currentDots = 0
    
    local function animate()
        while running and textLabel.Parent do
            currentDots = (currentDots % dotCount) + 1
            local dots = string.rep(".", currentDots)
            textLabel.Text = baseText .. dots
            task.wait(speed)
        end
    end
    
    task.spawn(animate)
    
    return function()
        running = false
        textLabel.Text = baseText
    end
end

-- Glow pulse effect for UI elements
function UIFX.glowPulse(obj, glowColor, intensity, speed)
    intensity = intensity or 0.4
    speed = speed or 1.0
    glowColor = glowColor or Color3.fromRGB(0, 191, 255)
    
    -- Find or create UIStroke for glow
    local stroke = obj:FindFirstChild("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Parent = obj
    end
    
    stroke.Color = glowColor
    local originalThickness = stroke.Thickness
    local originalTransparency = stroke.Transparency
    
    local running = true
    
    local function pulse()
        while running and obj.Parent do
            -- Glow up
            local glowUp = TweenService:Create(stroke,
                TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    Thickness = originalThickness + intensity * 3,
                    Transparency = originalTransparency - intensity
                }
            )
            glowUp:Play()
            glowUp.Completed:Wait()
            
            if not running or not obj.Parent then break end
            
            -- Glow down
            local glowDown = TweenService:Create(stroke,
                TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    Thickness = originalThickness,
                    Transparency = originalTransparency + intensity
                }
            )
            glowDown:Play()
            glowDown.Completed:Wait()
        end
    end
    
    task.spawn(pulse)
    
    return function()
        running = false
        stroke.Thickness = originalThickness
        stroke.Transparency = originalTransparency
    end
end

-- Smooth show/hide with scale and fade
function UIFX.show(obj, duration)
    duration = duration or 0.3
    
    obj.Size = UDim2.new(0, 0, 0, 0)
    obj.BackgroundTransparency = 1
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.TextTransparency = 1
    end
    
    local targetSize = obj:GetAttribute("OriginalSize") or UDim2.new(1, 0, 1, 0)
    
    -- Scale and fade in simultaneously
    local scaleTween = TweenService:Create(obj, TWEEN_PRESETS.BOUNCE, {Size = targetSize})
    local fadeTween = UIFX.fadeIn(obj, duration, 0)
    
    scaleTween:Play()
    fadeTween:Play()
    
    return {scaleTween, fadeTween}
end

-- Smooth hide with scale and fade
function UIFX.hide(obj, duration)
    duration = duration or 0.3
    
    -- Store original size
    obj:SetAttribute("OriginalSize", obj.Size)
    
    local scaleTween = TweenService:Create(obj, TWEEN_PRESETS.FAST, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    local fadeTween = UIFX.fadeOut(obj, duration, 1)
    
    scaleTween:Play()
    fadeTween:Play()
    
    return {scaleTween, fadeTween}
end

-- Progress bar fill animation
function UIFX.animateProgressBar(progressBar, targetProgress, duration)
    duration = duration or 1.0
    
    local fillBar = progressBar:FindFirstChild("Fill") or progressBar:GetChildren()[1]
    if not fillBar then return end
    
    local tween = TweenService:Create(fillBar,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(targetProgress, 0, 1, 0)}
    )
    tween:Play()
    return tween
end

-- Ripple effect on button click
function UIFX.rippleEffect(button, clickPosition)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X, 0, clickPosition.Y)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = ripple
    
    -- Expand and fade
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    local expandTween = TweenService:Create(ripple,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            Position = UDim2.new(0, clickPosition.X - maxSize/2, 0, clickPosition.Y - maxSize/2),
            BackgroundTransparency = 1
        }
    )
    
    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
    
    return expandTween
end

-- Smooth number counter animation
function UIFX.animateNumber(textLabel, startValue, endValue, duration, formatter)
    duration = duration or 1.0
    formatter = formatter or function(num) return tostring(math.floor(num)) end
    
    local startTime = tick()
    local running = true
    
    local function updateNumber()
        while running and textLabel.Parent do
            local elapsed = tick() - startTime
            local progress = math.min(elapsed / duration, 1)
            
            -- Ease out interpolation
            local easedProgress = 1 - math.pow(1 - progress, 3)
            local currentValue = startValue + (endValue - startValue) * easedProgress
            
            textLabel.Text = formatter(currentValue)
            
            if progress >= 1 then
                break
            end
            
            task.wait()
        end
    end
    
    task.spawn(updateNumber)
    
    return function()
        running = false
        textLabel.Text = formatter(endValue)
    end
end

-- Create a tween group for synchronized animations
function UIFX.createTweenGroup()
    local tweens = {}
    local group = {}
    
    function group:Add(tween)
        table.insert(tweens, tween)
    end
    
    function group:Play()
        for _, tween in ipairs(tweens) do
            tween:Play()
        end
    end
    
    function group:Pause()
        for _, tween in ipairs(tweens) do
            tween:Pause()
        end
    end
    
    function group:Cancel()
        for _, tween in ipairs(tweens) do
            tween:Cancel()
        end
    end
    
    function group:WaitForCompletion()
        for _, tween in ipairs(tweens) do
            tween.Completed:Wait()
        end
    end
    
    return group
end

-- Utility: Apply hover effects to any UI element
function UIFX.addHoverEffect(obj, hoverScale, hoverTransparency)
    hoverScale = hoverScale or 1.05
    hoverTransparency = hoverTransparency or 0.1
    
    local originalSize = obj.Size
    local originalTransparency = obj.BackgroundTransparency
    
    obj.MouseEnter:Connect(function()
        UIFX.scale(obj, hoverScale, 0.15, "FAST")
        TweenService:Create(obj, TWEEN_PRESETS.FAST, {
            BackgroundTransparency = originalTransparency - hoverTransparency
        }):Play()
    end)
    
    obj.MouseLeave:Connect(function()
        TweenService:Create(obj, TWEEN_PRESETS.FAST, {
            Size = originalSize,
            BackgroundTransparency = originalTransparency
        }):Play()
    end)
end

-- Utility: Get tween preset by name
function UIFX.getTweenPreset(presetName)
    return TWEEN_PRESETS[presetName] or TWEEN_PRESETS.NORMAL
end

return UIFX
