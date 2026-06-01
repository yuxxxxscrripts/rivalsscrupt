-- ================================
-- OPTIMIZED BYPASS - NO FREEZES
-- ================================

local originalError = error
local originalWarn = warn

-- Suppress annoying warnings (runs instantly, no freeze)
warn = function(...)
    local args = {...}
    local msg = tostring(args[1] or "")
    if msg:find("Locale") or msg:find("Visible") or msg:find("CoreGui") then 
        return 
    end
    return originalWarn(...)
end

-- Suppress errors (runs instantly, no freeze)
error = function(msg, level)
    if type(msg) == "string" and (msg:find("Locale") or msg:find("Visible")) then 
        return 
    end
    return originalError(msg, level)
end

-- Simple one-time script blocker (NO LOOP, NO FREEZE)
local function blockAnticheatScripts()
    local keywords = {"byfron", "hyperion", "anticheat", "detection", "monitor", "integrity", "analytics", "telemetry"}
    
    -- Single pass through existing scripts (fast, doesn't freeze)
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    pcall(function() obj.Disabled = true end)
                    break
                end
            end
        end
    end
    
    -- Watch for new scripts (lightweight, no freeze)
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    pcall(function() obj.Disabled = true end)
                    break
                end
            end
        end
    end)
end

-- Kill remote events (one-time, no loop)
local function killAnticheatRemotes()
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local analytics = remotes:FindFirstChild("AnalyticsPipeline")
            if analytics then
                for _, remote in ipairs(analytics:GetChildren()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        remote:Destroy()
                    end
                end
            end
        end
    end)
end

-- Block kicks (simple hook)
local function blockKicks()
    local lp = game:GetService("Players").LocalPlayer
    pcall(function()
        hookfunction(lp.Kick, function() return nil end)
    end)
end

-- Disable script errors from being sent
local function disableErrorReporting()
    pcall(function()
        local scriptContext = game:GetService("ScriptContext")
        if getconnections then
            for _, conn in pairs(getconnections(scriptContext.Error)) do
                pcall(function() conn:Disable() end)
            end
        end
    end)
end

-- ================================
-- RUN BYPASS (ONCE, NO FREEZE)
-- ================================

print("[AstrexHook] Running optimized bypass...")

-- Execute all bypass methods (each runs once, no loops)
blockAnticheatScripts()
killAnticheatRemotes()
blockKicks()
disableErrorReporting()

print("[AstrexHook] Bypass complete! No loops running.")

-- Show notification (optional, won't freeze)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ASTREXHOOK",
        Text = "Bypass Active - No Freezes!",
        Duration = 3
    })
end)

return true
