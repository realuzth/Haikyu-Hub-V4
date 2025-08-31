-- ResourceUtil.lua
-- Resource and memory management utilities
-- Tracks event connections, timers, and other resources to prevent memory leaks

local ResourceUtil = {}

-- Connection tracking for safe cleanup
local activeConnections = {}
local activeTweens = {}
local activeTimers = {}

-- Track a connection for later cleanup
function ResourceUtil.trackConnection(connectionTable, connection)
    if not connectionTable then
        error("Connection table is required")
    end
    if not connection or type(connection.Disconnect) ~= "function" then
        error("Invalid connection object")
    end
    
    table.insert(connectionTable, connection)
    table.insert(activeConnections, connection)
    return connection
end

-- Disconnect all connections in a table
function ResourceUtil.disconnectAll(connectionTable)
    if not connectionTable then return end
    
    for i = #connectionTable, 1, -1 do
        local conn = connectionTable[i]
        if conn and type(conn.Disconnect) == "function" then
            pcall(function() conn:Disconnect() end)
        end
        connectionTable[i] = nil
    end
    
    -- Clear the table
    for i = #connectionTable, 1, -1 do
        connectionTable[i] = nil
    end
end

-- Track a tween for cleanup
function ResourceUtil.trackTween(tweenTable, tween)
    if not tweenTable then
        error("Tween table is required")
    end
    if not tween or type(tween.Cancel) ~= "function" then
        error("Invalid tween object")
    end
    
    table.insert(tweenTable, tween)
    table.insert(activeTweens, tween)
    return tween
end

-- Cancel all tweens in a table
function ResourceUtil.cancelAllTweens(tweenTable)
    if not tweenTable then return end
    
    for i = #tweenTable, 1, -1 do
        local tween = tweenTable[i]
        if tween and type(tween.Cancel) == "function" then
            pcall(function() tween:Cancel() end)
        end
        tweenTable[i] = nil
    end
end

-- Track a timer/task for cleanup
function ResourceUtil.trackTimer(timerTable, timerThread)
    if not timerTable then
        error("Timer table is required")
    end
    if not timerThread then
        error("Invalid timer thread")
    end
    
    table.insert(timerTable, timerThread)
    table.insert(activeTimers, timerThread)
    return timerThread
end

-- Cancel all timers in a table
function ResourceUtil.cancelAllTimers(timerTable)
    if not timerTable then return end
    
    for i = #timerTable, 1, -1 do
        local timer = timerTable[i]
        if timer then
            pcall(function() task.cancel(timer) end)
        end
        timerTable[i] = nil
    end
end

-- Create a new resource group for organized cleanup
function ResourceUtil.createResourceGroup()
    local group = {
        connections = {},
        tweens = {},
        timers = {},
        objects = {}
    }
    
    function group:trackConnection(connection)
        return ResourceUtil.trackConnection(self.connections, connection)
    end
    
    function group:trackTween(tween)
        return ResourceUtil.trackTween(self.tweens, tween)
    end
    
    function group:trackTimer(timer)
        return ResourceUtil.trackTimer(self.timers, timer)
    end
    
    function group:trackObject(object)
        table.insert(self.objects, object)
        return object
    end
    
    function group:cleanup()
        ResourceUtil.disconnectAll(self.connections)
        ResourceUtil.cancelAllTweens(self.tweens)
        ResourceUtil.cancelAllTimers(self.timers)
        
        -- Destroy tracked objects
        for _, obj in ipairs(self.objects) do
            if obj and obj.Destroy then
                pcall(function() obj:Destroy() end)
            end
        end
        
        -- Clear all tables
        self.connections = {}
        self.tweens = {}
        self.timers = {}
        self.objects = {}
    end
    
    return group
end

-- Safe event connection with automatic tracking
function ResourceUtil.safeConnect(signal, callback, connectionTable)
    if not signal or type(signal.Connect) ~= "function" then
        error("Invalid signal object")
    end
    if type(callback) ~= "function" then
        error("Callback must be a function")
    end
    
    local connection = signal:Connect(callback)
    
    if connectionTable then
        ResourceUtil.trackConnection(connectionTable, connection)
    else
        table.insert(activeConnections, connection)
    end
    
    return connection
end

-- Safe task spawning with tracking
function ResourceUtil.safeSpawn(func, timerTable)
    if type(func) ~= "function" then
        error("Function is required for spawning")
    end
    
    local thread = task.spawn(func)
    
    if timerTable then
        ResourceUtil.trackTimer(timerTable, thread)
    else
        table.insert(activeTimers, thread)
    end
    
    return thread
end

-- Safe task delay with tracking
function ResourceUtil.safeDelay(duration, func, timerTable)
    if type(func) ~= "function" then
        error("Function is required for delay")
    end
    
    local thread = task.delay(duration, func)
    
    if timerTable then
        ResourceUtil.trackTimer(timerTable, thread)
    else
        table.insert(activeTimers, thread)
    end
    
    return thread
end

-- Memory usage monitoring
function ResourceUtil.getMemoryUsage()
    local stats = game:GetService("Stats")
    local memory = {}
    
    -- Get Lua memory usage
    memory.luaMemory = stats:GetTotalMemoryUsageMb()
    memory.renderMemory = stats.RenderMemory:GetValue()
    memory.physicsMemory = stats.PhysicsMemory:GetValue()
    
    return memory
end

-- Performance monitoring
function ResourceUtil.createPerformanceMonitor(updateInterval)
    updateInterval = updateInterval or 1.0
    
    local monitor = {
        fps = 0,
        memory = 0,
        lastUpdate = tick(),
        frameCount = 0,
        running = false
    }
    
    function monitor:start()
        if self.running then return end
        self.running = true
        
        local RunService = game:GetService("RunService")
        
        -- FPS tracking
        local fpsConnection = RunService.Heartbeat:Connect(function()
            self.frameCount = self.frameCount + 1
            local now = tick()
            
            if now - self.lastUpdate >= updateInterval then
                self.fps = self.frameCount / (now - self.lastUpdate)
                self.memory = ResourceUtil.getMemoryUsage().luaMemory
                self.frameCount = 0
                self.lastUpdate = now
            end
        end)
        
        self.connection = fpsConnection
    end
    
    function monitor:stop()
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
        self.running = false
    end
    
    function monitor:getStats()
        return {
            fps = math.floor(self.fps + 0.5),
            memory = math.floor(self.memory * 100 + 0.5) / 100
        }
    end
    
    return monitor
end

-- Global cleanup function for emergency use
function ResourceUtil.emergencyCleanup()
    print("[ResourceUtil] Emergency cleanup initiated...")
    
    -- Disconnect all tracked connections
    for _, conn in ipairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    activeConnections = {}
    
    -- Cancel all tracked tweens
    for _, tween in ipairs(activeTweens) do
        pcall(function() tween:Cancel() end)
    end
    activeTweens = {}
    
    -- Cancel all tracked timers
    for _, timer in ipairs(activeTimers) do
        pcall(function() task.cancel(timer) end)
    end
    activeTimers = {}
    
    print("[ResourceUtil] Emergency cleanup completed")
end

-- Utility: Create a debounced function to prevent spam
function ResourceUtil.debounce(func, delay)
    delay = delay or 0.5
    local lastCall = 0
    
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            return func(...)
        end
    end
end

-- Utility: Create a throttled function to limit call frequency
function ResourceUtil.throttle(func, interval)
    interval = interval or 0.1
    local lastCall = 0
    local pending = false
    
    return function(...)
        local now = tick()
        if now - lastCall >= interval then
            lastCall = now
            return func(...)
        elseif not pending then
            pending = true
            task.delay(interval - (now - lastCall), function()
                pending = false
                lastCall = tick()
                func(...)
            end)
        end
    end
end

-- Get resource statistics
function ResourceUtil.getResourceStats()
    return {
        activeConnections = #activeConnections,
        activeTweens = #activeTweens,
        activeTimers = #activeTimers,
        memoryUsage = ResourceUtil.getMemoryUsage()
    }
end

return ResourceUtil
