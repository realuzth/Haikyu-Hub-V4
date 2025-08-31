-- WebhookManager.lua
-- Discord webhook notification system for character spawn alerts
-- Sends formatted messages with character information and statistics

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WebhookManager = {}

-- Configuration
local CONFIG = {
    DEFAULT_WEBHOOK_URL = "", -- User must provide their own webhook URL
    RATE_LIMIT_DELAY = 2.0, -- seconds between webhook calls
    MAX_RETRIES = 3,
    TIMEOUT = 10
}

-- Internal state
local lastWebhookTime = 0
local webhookQueue = {}
local isProcessingQueue = false

-- Create Discord embed for character spawn
local function createCharacterEmbed(characterName, characterData, spawnCount)
    local player = Players.LocalPlayer
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    
    -- Color based on rarity
    local rarityColors = {
        Secret = 16711935,    -- Purple
        Awakened = 16776960,  -- Gold
        Mythic = 16711680,    -- Red
        Legendary = 16753920, -- Orange
        Rare = 65535,         -- Cyan
        Uncommon = 65280,     -- Green
        Common = 8421504      -- Gray
    }
    
    local embedColor = rarityColors[characterData.rarity] or 8421504
    
    -- Mutation prefix for title
    local mutationPrefix = ""
    if characterData.mutation then
        mutationPrefix = characterData.mutation .. " "
    end
    
    local embed = {
        title = "🎯 Character Spawned!",
        description = string.format("**%s%s** has appeared!", mutationPrefix, characterData.baseChar),
        color = embedColor,
        fields = {
            {
                name = "📊 Character Info",
                value = string.format("**Rarity:** %s\n**Income:** %s\n**Count:** %d", 
                    characterData.rarity,
                    formatNumber(characterData.income),
                    spawnCount
                ),
                inline = true
            },
            {
                name = "👤 Player Info", 
                value = string.format("**Player:** %s\n**User ID:** %d\n**Server:** %s",
                    player.Name,
                    player.UserId,
                    game.JobId:sub(1, 8) .. "..."
                ),
                inline = true
            }
        },
        footer = {
            text = "Haikyu Hub V4 • " .. timestamp,
            icon_url = "https://cdn.discordapp.com/emojis/1234567890123456789.png" -- Optional
        },
        timestamp = timestamp
    }
    
    return embed
end

-- Format numbers with commas
local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- Send webhook with rate limiting
local function sendWebhookRequest(webhookUrl, payload)
    local now = tick()
    
    -- Rate limiting
    if now - lastWebhookTime < CONFIG.RATE_LIMIT_DELAY then
        return false, "Rate limited"
    end
    
    local jsonPayload = HttpService:JSONEncode(payload)
    
    for attempt = 1, CONFIG.MAX_RETRIES do
        local success, response = pcall(function()
            return HttpService:PostAsync(webhookUrl, jsonPayload, Enum.HttpContentType.ApplicationJson)
        end)
        
        if success then
            lastWebhookTime = now
            return true, response
        else
            warn("[WebhookManager] Attempt", attempt, "failed:", response)
            if attempt < CONFIG.MAX_RETRIES then
                task.wait(1) -- Wait before retry
            end
        end
    end
    
    return false, "Max retries exceeded"
end

-- Queue webhook for processing
local function queueWebhook(webhookUrl, payload)
    table.insert(webhookQueue, {url = webhookUrl, payload = payload, timestamp = tick()})
    
    if not isProcessingQueue then
        processWebhookQueue()
    end
end

-- Process webhook queue with rate limiting
function processWebhookQueue()
    if isProcessingQueue then return end
    isProcessingQueue = true
    
    task.spawn(function()
        while #webhookQueue > 0 do
            local webhook = table.remove(webhookQueue, 1)
            
            local success, result = sendWebhookRequest(webhook.url, webhook.payload)
            if success then
                print("[WebhookManager] Webhook sent successfully")
            else
                warn("[WebhookManager] Webhook failed:", result)
            end
            
            task.wait(CONFIG.RATE_LIMIT_DELAY)
        end
        
        isProcessingQueue = false
    end)
end

-- Public API: Send character spawn notification
function WebhookManager.notifyCharacterSpawn(characterName, webhookUrl)
    if not webhookUrl or webhookUrl == "" then
        return false, "No webhook URL provided"
    end
    
    -- Get character data from database
    local characterData = nil
    -- This would be injected from HaikyuLogic
    if WebhookManager.getCharacterData then
        characterData = WebhookManager.getCharacterData(characterName)
    end
    
    if not characterData then
        return false, "Character data not found"
    end
    
    local embed = createCharacterEmbed(characterName, characterData, 1)
    local payload = {
        username = "Haikyu Hub V4",
        avatar_url = "https://cdn.discordapp.com/emojis/1234567890123456789.png", -- Optional
        embeds = {embed}
    }
    
    queueWebhook(webhookUrl, payload)
    return true, "Notification queued"
end

-- Send summary statistics
function WebhookManager.sendSummary(webhookUrl, stats)
    if not webhookUrl or webhookUrl == "" then
        return false, "No webhook URL provided"
    end
    
    local player = Players.LocalPlayer
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    
    local embed = {
        title = "📈 Session Summary",
        description = "Haikyu Hub tracking session completed",
        color = 3447003, -- Blue
        fields = {
            {
                name = "📊 Session Stats",
                value = string.format("**Total Spawns:** %d\n**Characters Found:** %d\n**Session Time:** %s",
                    stats.totalSpawns or 0,
                    stats.charactersFound or 0,
                    formatTime(stats.sessionTime or 0)
                ),
                inline = true
            },
            {
                name = "🎯 Top Characters",
                value = stats.topCharacters or "None tracked",
                inline = true
            }
        },
        footer = {
            text = "Haikyu Hub V4 • " .. player.Name,
        },
        timestamp = timestamp
    }
    
    local payload = {
        username = "Haikyu Hub V4",
        embeds = {embed}
    }
    
    queueWebhook(webhookUrl, payload)
    return true, "Summary queued"
end

-- Format time duration
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

-- Test webhook connection
function WebhookManager.testWebhook(webhookUrl)
    if not webhookUrl or webhookUrl == "" then
        return false, "No webhook URL provided"
    end
    
    local testPayload = {
        username = "Haikyu Hub V4",
        content = "🧪 **Test Message**\nWebhook connection successful! Haikyu Hub V4 is ready to send notifications."
    }
    
    local success, result = sendWebhookRequest(webhookUrl, testPayload)
    return success, result
end

-- Set character data source (dependency injection)
function WebhookManager.setCharacterDataSource(getCharacterDataFunc)
    WebhookManager.getCharacterData = getCharacterDataFunc
end

-- Get webhook queue status
function WebhookManager.getQueueStatus()
    return {
        queueLength = #webhookQueue,
        isProcessing = isProcessingQueue,
        lastSent = lastWebhookTime,
        rateLimitDelay = CONFIG.RATE_LIMIT_DELAY
    }
end

-- Clear webhook queue
function WebhookManager.clearQueue()
    webhookQueue = {}
    print("[WebhookManager] Webhook queue cleared")
end

-- Update configuration
function WebhookManager.updateConfig(newConfig)
    for key, value in pairs(newConfig) do
        if CONFIG[key] ~= nil then
            CONFIG[key] = value
        end
    end
end

return WebhookManager
