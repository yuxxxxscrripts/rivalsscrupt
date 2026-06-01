-- ================================
-- RIVALS ANTICHEAT BYPASS v3 - OPTIMIZED
-- Fast Loading Edition
-- ================================

-- ================================
-- FAST EXECUTOR NOTIFICATION SYSTEM
-- ================================

local function sendExecutorNotification(title, text, duration)
    duration = duration or 5
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
    
    print(string.format("[%s] %s", title:upper(), text))
end

-- ================================
-- OPTIMIZED VISUAL NOTIFICATION (No TweenService delay)
-- ================================

local function showFastNotification(title, message, color, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AstrexNotify"
    screenGui.ResetOnSpawn = false
    
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        pcall(function()
            screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 0.5)
        end)
    end
    if not screenGui.Parent then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 70)
    frame.Position = UDim2.new(0.5, -175, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color or Color3.fromRGB(0, 255, 100)
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = color or Color3.fromRGB(0, 255, 100)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = frame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0, 35)
    messageLabel.Position = UDim2.new(0, 0, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 11
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Center
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = frame
    
    task.delay(duration or 3, function()
        pcall(function() screenGui:Destroy() end)
    end)
end

-- ================================
-- FAST BYPASS VARIABLES
-- ================================

local bypassStats = {
    disabledScripts = 0,
    startTime = os.time()
}

-- Block patterns (reduced for speed)
local blockPatterns = {
    "Analytics", "Pipeline", "Telemetry", "Tracker", "Monitor",
    "Byfron", "Hyperion", "Anticheat", "Detection", "Integrity",
    "Validation", "Security", "Guard"
}

-- ================================
-- FAST SCRIPT BLOCKING (Optimized)
-- ================================

local function blockScriptsFast()
    local count = 0
    
    -- Fast scan using ipairs with pcall batch
    local descendants = game:GetDescendants()
    local total = #descendants
    
    for i = 1, total do
        local obj = descendants[i]
        if obj and (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) then
            local name = obj.Name
            local nameLower = name:lower()
            
            for _, pattern in ipairs(blockPatterns) do
                if name:find(pattern) or nameLower:find(pattern:lower()) then
                    pcall(function() 
                        obj.Disabled = true 
                        count = count + 1 
                    end)
                    break
                end
            end
        end
    end
    
    -- Simple descendant monitor (lightweight)
    game.DescendantAdded:Connect(function(obj)
        if obj and (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) then
            local name = obj.Name
            for _, pattern in ipairs(blockPatterns) do
                if name:find(pattern) then
                    pcall(function() obj.Disabled = true end)
                    break
                end
            end
        end
    end)
    
    return count
end

-- ================================
-- FAST REMOTE DISABLE
-- ================================

local function disableRemotesFast()
    local disabled = 0
    
    pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remotes = replicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local analytics = remotes:FindFirstChild("AnalyticsPipeline")
            if analytics then
                for _, remote in ipairs(analytics:GetChildren()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        pcall(function() 
                            remote:Destroy() 
                            disabled = disabled + 1 
                        end)
                    end
                end
            end
        end
    end)
    
    return disabled
end

-- ================================
-- FAST KICK BLOCK
-- ================================

local function blockKickFast()
    pcall(function()
        local localPlayer = game:GetService("Players").LocalPlayer
        local kickFuncs = {"Kick", "kick"}
        for _, funcName in ipairs(kickFuncs) do
            local original = localPlayer[funcName]
            if type(original) == "function" then
                hookfunction(original, function() return nil end)
            end
        end
    end)
end

-- ================================
-- DISABLE SCRIPT ERRORS (Fast)
-- ================================

local function disableErrorsFast()
    pcall(function()
        local scriptContext = game:GetService("ScriptContext")
        if getconnections and scriptContext.Error then
            local conns = getconnections(scriptContext.Error)
            for i = 1, #conns do
                pcall(function() conns[i]:Disable() end)
            end
        end
    end)
end

-- ================================
-- FALLBACK BYPASS (Lightweight)
-- ================================

local function fallbackBypass()
    -- Simple error/warn suppression
    local oldError = error
    local oldWarn = warn
    
    warn = function(...)
        local args = {...}
        local msg = tostring(args[1] or "")
        if msg:find("Locale") or msg:find("Visible") or msg:find("CoreGui") or msg:find("Analytics") then 
            return 
        end
        return oldWarn(...)
    end
    
    error = function(msg, level)
        if type(msg) == "string" and (msg:find("Locale") or msg:find("Visible") or msg:find("Analytics")) then 
            return 
        end
        return oldError(msg, level)
    end
    
    -- Disable common anticheat scripts
    task.spawn(function()
        local checkList = {"Analytics", "Pipeline", "Telemetry", "Tracker"}
        for i = 1, 10 do
            task.wait(0.5)
            for _, obj in ipairs(game:GetDescendants()) do
                if obj and (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) then
                    local name = obj.Name
                    for _, pattern in ipairs(checkList) do
                        if name:find(pattern) then
                            pcall(function() obj.Disabled = true end)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ================================
-- OPTIMIZED MAIN BYPASS
-- ================================

local bypassActive = false

local function executeFastBypass()
    print("[AstrexHook] Fast bypass initializing...")
    
    -- Show loading (very quick)
    showFastNotification("ASTREXHOOK", "Initializing bypass...", Color3.fromRGB(255, 165, 0), 2)
    
    -- Run all bypass methods in parallel for speed
    local results = {}
    
    -- Use spawn for parallel execution
    local scriptsBlocked = 0
    local remotesDisabled = 0
    
    local threads = {
        task.spawn(function() scriptsBlocked = blockScriptsFast() end),
        task.spawn(function() remotesDisabled = disableRemotesFast() end),
        task.spawn(function() blockKickFast() end),
        task.spawn(function() disableErrorsFast() end),
    }
    
    -- Wait for all threads to complete (max 0.5 seconds)
    for i = 1, 4 do
        task.wait(0.05)
    end
    
    results.scriptsBlocked = scriptsBlocked
    results.remotesDisabled = remotesDisabled
    
    bypassActive = true
    
    -- Update stats
    bypassStats.disabledScripts = results.scriptsBlocked
    bypassStats.disabledRemotes = results.remotesDisabled
    
    -- Show success notification quickly
    if results.scriptsBlocked > 0 or results.remotesDisabled > 0 then
        local msg = string.format("✓ Bypass Active!\nBlocked: %d scripts | %d remotes",
            results.scriptsBlocked,
            results.remotesDisabled
        )
        showFastNotification("⚡ BYPASS SUCCESSFUL", msg, Color3.fromRGB(0, 255, 100), 4)
        sendExecutorNotification("ASTREXHOOK", "Anticheat bypassed successfully!", 3)
    else
        -- Fallback if main bypass didn't catch anything
        fallbackBypass()
        showFastNotification("BYPASS ACTIVE", "Using fallback protection mode", Color3.fromRGB(0, 200, 255), 3)
    end
    
    print(string.format("[AstrexHook] Bypass complete! Blocked: %d scripts", results.scriptsBlocked))
    
    return true
end

-- ================================
-- LIGHTWEIGHT PROTECTION LOOP
-- ================================

local function startLightProtection()
    task.spawn(function()
        local lastCheck = tick()
        while bypassActive do
            task.wait(10) -- Check every 10 seconds (less frequent = better performance)
            
            if tick() - lastCheck > 8 then
                lastCheck = tick()
                pcall(function()
                    -- Quick check for new scripts
                    local newCount = 0
                    local descendants = game:GetDescendants()
                    local total = math.min(#descendants, 2000) -- Limit scan for performance
                    
                    for i = 1, total do
                        local obj = descendants[i]
                        if obj and (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and not obj.Disabled then
                            local name = obj.Name
                            for _, pattern in ipairs(blockPatterns) do
                                if name:find(pattern) then
                                    pcall(function() obj.Disabled = true end)
                                    newCount = newCount + 1
                                    break
                                end
                            end
                        end
                    end
                    
                    if newCount > 0 then
                        print(string.format("[AstrexHook] Blocked %d new scripts", newCount))
                    end
                end)
            end
        end
    end)
end

-- ================================
-- FAST INITIALIZATION
-- ================================

-- Execute bypass immediately (don't wait for game load)
local success, err = pcall(executeFastBypass)

if not success then
    warn("[AstrexHook] Fast bypass error: " .. tostring(err))
    -- Attempt fallback immediately
    pcall(function() fallbackBypass() end)
    showFastNotification("BYPASS ACTIVE", "Fallback protection engaged", Color3.fromRGB(255, 200, 0), 3)
else
    -- Start lightweight protection loop
    startLightProtection()
    
    -- Final status
    print("========================================")
    print("[AstrexHook] Bypass Active - Fast Mode")
    print(string.format("[AstrexHook] Blocked: %d scripts", bypassStats.disabledScripts))
    print("[AstrexHook] You are safe to use cheats!")
    print("========================================")
end

-- ================================
-- EXPORTS
-- ================================

return {
    success = success,
    active = bypassActive,
    stats = bypassStats
}
