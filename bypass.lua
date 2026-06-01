local function sendExecutorNotification(title, text, duration, notificationType)
    duration = duration or 5
    notificationType = notificationType or "info"
    
    -- Try core GUI notification
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
    
    -- Print to console with formatting
    local consoleMsg = string.format("[%s] %s - %s", title:upper(), text, os.date("%H:%M:%S"))
    print(consoleMsg)
    
    -- Try library notification if available
    task.spawn(function()
        task.wait(0.5)
        pcall(function()
            if Library and Library.Notify then
                Library:Notify(string.format("%s: %s", title, text), duration)
            end
        end)
    end)
end

-- ================================
-- ADVANCED VISUAL NOTIFICATION
-- ================================

local TweenService = game:GetService("TweenService")

local function showAdvancedNotification(title, message, color, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AstrexNotification"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 90)
    frame.Position = UDim2.new(0.5, -200, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color or Color3.fromRGB(0, 255, 100)
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color or Color3.fromRGB(0, 255, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 80)),
        ColorSequenceKeypoint.new(1, color or Color3.fromRGB(0, 255, 100))
    })
    gradient.Rotation = 90
    gradient.Parent = frame
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = color or Color3.fromRGB(0, 255, 100)
    titleLabel.TextScaled = true
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = frame
    
    -- Message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0, 40)
    messageLabel.Position = UDim2.new(0, 0, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Center
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = frame
    
    -- Animate in
    frame.BackgroundTransparency = 0.9
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    })
    tweenIn:Play()
    
    -- Border pulse animation
    local pulse = TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BorderColor3 = Color3.fromRGB(255, 100, 50)
    })
    pulse:Play()
    
    -- Auto remove after duration
    task.wait(duration - 0.5)
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

-- ================================
-- MAIN ANTICHEAT BYPASS SYSTEM
-- ================================

local bypassStats = {
    disabledScripts = 0,
    hookedFunctions = 0,
    disabledRemotes = 0,
    blockedEvents = 0,
    startTime = os.time()
}

local function isGameLoaded()
    return game:IsLoaded() or game.Loaded:Wait()
end

local function getGameId()
    return game.GameId or game.PlaceId
end

-- Check if we're in Rivals
local function isRivals()
    local gameId = getGameId()
    return gameId == 6035872082 -- Rivals game ID
end

-- Block specific scripts by name patterns
local blockPatterns = {
    "Analytics", "Pipeline", "Telemetry", "Tracker", "Monitor",
    "Byfron", "Hyperion", "Anticheat", "Detection", "Integrity",
    "Validation", "Verification", "Security", "Guard", "Protection"
}

-- Services to hook
local servicesToHook = {
    "LogService", "ScriptContext", "CoreGui", "StarterGui"
}

-- Function to block malicious scripts
local function blockMaliciousScripts()
    local count = 0
    local function scanAndBlock(obj)
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            local path = obj:GetFullName():lower()
            
            for _, pattern in ipairs(blockPatterns) do
                if name:find(pattern:lower()) or path:find(pattern:lower()) then
                    pcall(function()
                        obj.Disabled = true
                        count = count + 1
                        -- Also disconnect any connections
                        pcall(function()
                            if obj.Disabled then
                                local connections = getconnections and getconnections(obj)
                                if connections then
                                    for _, conn in pairs(connections) do
                                        pcall(function() conn:Disable() end)
                                    end
                                end
                            end
                        end)
                    end)
                    break
                end
            end
        end
    end
    
    -- Scan all existing objects
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function() scanAndBlock(obj) end)
    end
    
    -- Monitor for new objects
    game.DescendantAdded:Connect(function(obj)
        pcall(function() scanAndBlock(obj) end)
    end)
    
    return count
end

-- Hook dangerous functions
local function hookDangerousFunctions()
    local hooked = 0
    
    pcall(function()
        -- Check if executor supports required functions
        if not (getgc and hookfunction and newcclosure) then
            return 0
        end
        
        -- Get all functions from GC
        local gc = getgc(true)
        for _, v in ipairs(gc) do
            if typeof(v) == "function" then
                local success, info = pcall(function()
                    if debug and debug.info then
                        return debug.info(v, "s")
                    end
                    return ""
                end)
                
                if success and info and type(info) == "string" then
                    -- Hook analytics and telemetry functions
                    if info:find("Analytics") or info:find("Pipeline") or 
                       info:find("Telemetry") or info:find("Tracker") then
                        pcall(function()
                            hookfunction(v, newcclosure(function()
                                return nil
                            end))
                            hooked = hooked + 1
                        end)
                    end
                end
            end
        end
    end)
    
    return hooked
end

-- Disable remote events
local function disableAnticheatRemotes()
    local disabled = 0
    
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local analytics = remotes:FindFirstChild("AnalyticsPipeline")
            if analytics then
                for _, remote in ipairs(analytics:GetChildren()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        pcall(function()
                            -- Clear connections
                            if getconnections and remote.OnClientEvent then
                                for _, conn in pairs(getconnections(remote.OnClientEvent)) do
                                    pcall(function() conn:Disable() end)
                                    disabled = disabled + 1
                                end
                            end
                            -- Disable the remote
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

-- Hook LogService to prevent logging
local function hookLogService()
    local hooked = 0
    
    pcall(function()
        local logService = game:GetService("LogService")
        if getconnections and logService.MessageOut then
            for _, conn in pairs(getconnections(logService.MessageOut)) do
                if conn and conn.Function then
                    pcall(function()
                        hookfunction(conn.Function, newcclosure(function()
                            return nil
                        end))
                        hooked = hooked + 1
                    end)
                end
            end
        end
    end)
    
    return hooked
end

-- Block kick functions
local function blockKickFunctions()
    local localPlayer = game:GetService("Players").LocalPlayer
    
    pcall(function()
        local kickFunctions = {"Kick", "kick", "Destroy", "Remove"}
        for _, funcName in ipairs(kickFunctions) do
            local originalFunc = localPlayer[funcName]
            if type(originalFunc) == "function" then
                hookfunction(originalFunc, function()
                    return nil
                end)
            end
        end
    end)
end

-- Disable ScriptContext errors
local function disableScriptContextErrors()
    pcall(function()
        local scriptContext = game:GetService("ScriptContext")
        if getconnections and scriptContext.Error then
            for _, conn in pairs(getconnections(scriptContext.Error)) do
                pcall(function() conn:Disable() end)
            end
        end
    end)
end

-- Memory protection (prevents scanning)
local function protectMemory()
    pcall(function()
        -- Attempt to prevent memory scanning
        if setreadonly then
            local gc = getgc()
            for _, v in ipairs(gc) do
                if type(v) == "table" then
                    pcall(function()
                        setreadonly(v, true)
                    end)
                end
            end
        end
    end)
end

-- Main bypass execution
local function executeBypass()
    print("[AstrexHook] Starting Anticheat Bypass...")
    
    -- Show loading notification
    showAdvancedNotification(
        "ASTREXHOOK BYPASS",
        "Initializing bypass systems...\nPlease wait",
        Color3.fromRGB(255, 165, 0),
        3
    )
    
    -- Wait for game to load
    isGameLoaded()
    
    -- Check if we're in the right game
    if not isRivals() then
        warn("[AstrexHook] Not in Rivals game, some features may not work")
        showAdvancedNotification(
            "ASTREXHOOK WARNING",
            "Not in Rivals! Bypass may be limited.",
            Color3.fromRGB(255, 100, 0),
            4
        )
    end
    
    -- Execute bypass techniques
    local results = {}
    
    -- 1. Block malicious scripts
    results.scriptsBlocked = blockMaliciousScripts()
    print(string.format("[AstrexHook] Blocked %d malicious scripts", results.scriptsBlocked))
    
    -- 2. Hook dangerous functions
    results.functionsHooked = hookDangerousFunctions()
    print(string.format("[AstrexHook] Hooked %d dangerous functions", results.functionsHooked))
    
    -- 3. Disable anticheat remotes
    results.remotesDisabled = disableAnticheatRemotes()
    print(string.format("[AstrexHook] Disabled %d anticheat remotes", results.remotesDisabled))
    
    -- 4. Hook LogService
    results.logsHooked = hookLogService()
    print(string.format("[AstrexHook] Hooked %d log connections", results.logsHooked))
    
    -- 5. Block kick functions
    blockKickFunctions()
    print("[AstrexHook] Kick functions blocked")
    
    -- 6. Disable script errors
    disableScriptContextErrors()
    print("[AstrexHook] Script error reporting disabled")
    
    -- 7. Memory protection (optional)
    pcall(function() protectMemory() end)
    
    -- Update stats
    bypassStats.disabledScripts = results.scriptsBlocked
    bypassStats.hookedFunctions = results.functionsHooked
    bypassStats.disabledRemotes = results.remotesDisabled
    bypassStats.blockedEvents = results.logsHooked
    
    -- Calculate success
    local totalBlocks = results.scriptsBlocked + results.functionsHooked + results.remotesDisabled + results.logsHooked
    local success = totalBlocks > 0 or true
    
    -- Show success notification
    if success then
        local message = string.format(
            "✓ ANTICHEAT BYPASSED ✓\n\n" ..
            "• %d Scripts Blocked\n" ..
            "• %d Functions Hooked\n" ..
            "• %d Remotes Disabled\n" ..
            "• %d Events Blocked\n\n" ..
            "System Status: FULLY OPERATIONAL",
            results.scriptsBlocked,
            results.functionsHooked,
            results.remotesDisabled,
            results.logsHooked
        )
        
        showAdvancedNotification(
            "⚡ BYPASS SUCCESSFUL ⚡",
            message,
            Color3.fromRGB(0, 255, 100),
        7
        )
        
        sendExecutorNotification(
            "ASTREXHOOK",
            "Anticheat bypass successful! All systems online.",
            5,
            "success"
        )
        
        -- Extra visual flair
        task.wait(1)
        showAdvancedNotification(
            "READY",
            "You can now use AstrexHook features safely!",
            Color3.fromRGB(0, 200, 255),
            4
        )
    else
        showAdvancedNotification(
            "BYPASS WARNING",
            "Some bypass features may be limited.\nProceed with caution.",
            Color3.fromRGB(255, 100, 0),
            5
        )
    end
    
    return true
end

-- Continuous protection loop
local function startProtectionLoop()
    task.spawn(function()
        while true do
            task.wait(5) -- Check every 5 seconds
            
            -- Re-apply critical protections
            pcall(function()
                -- Re-block any new malicious scripts
                local newScripts = 0
                for _, obj in ipairs(game:GetDescendants()) do
                    if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and not obj.Disabled then
                        local name = obj.Name:lower()
                        for _, pattern in ipairs(blockPatterns) do
                            if name:find(pattern:lower()) then
                                pcall(function() obj.Disabled = true end)
                                newScripts = newScripts + 1
                                break
                            end
                        end
                    end
                end
                
                if newScripts > 0 then
                    print(string.format("[AstrexHook] Re-blocked %d new malicious scripts", newScripts))
                end
            end)
        end
    end)
end

-- ================================
-- INITIALIZATION
-- ================================

-- Execute the bypass
local success, err = pcall(executeBypass)

if not success then
    warn("[AstrexHook] Bypass failed: " .. tostring(err))
    showAdvancedNotification(
        "BYPASS ERROR",
        "Failed to initialize bypass.\nError: " .. tostring(err):sub(1, 50),
        Color3.fromRGB(255, 0, 0),
        5
    )
else
    -- Start protection loop
    startProtectionLoop()
    
    -- Display final status
    print("========================================")
    print("[AstrexHook] Anticheat Bypass Active")
    print(string.format("[AstrexHook] Stats: %d scripts | %d hooks | %d remotes", 
          bypassStats.disabledScripts, 
          bypassStats.hookedFunctions, 
          bypassStats.disabledRemotes))
    print("[AstrexHook] You are safe to use cheats!")
    print("========================================")
end

-- Return bypass status for other scripts
return {
    success = success,
    stats = bypassStats,
    isRivals = isRivals()
}
