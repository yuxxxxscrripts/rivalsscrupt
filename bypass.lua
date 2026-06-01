-- AstrexHook Bypass (Optimized - No Freeze)
-- Removed: getgc loop, setreadonly loop, repeated GetDescendants scans

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

-- Lightweight notification (no extra ScreenGui spam)
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 4
        })
    end)
    print(string.format("[AstrexHook] %s: %s", title, text))
end

-- Block patterns (kept small and specific to Rivals)
local blockPatterns = {
    "byfron", "hyperion", "anticheat", "detection",
    "analytics", "telemetry", "tracker", "pipeline"
}

local function shouldBlock(name)
    name = name:lower()
    for _, p in ipairs(blockPatterns) do
        if name:find(p, 1, true) then return true end
    end
    return false
end

-- ① Disable matching scripts — event-driven only (no GetDescendants loop at startup)
local function startScriptBlocker()
    -- Only hook DescendantAdded going forward; skip the expensive startup scan
    -- If you want an initial scan, do it deferred and chunked:
    task.spawn(function()
        local descendants = game:GetDescendants()
        local CHUNK = 200  -- process 200 objects per frame to avoid freezing
        for i = 1, #descendants, CHUNK do
            for j = i, math.min(i + CHUNK - 1, #descendants) do
                local obj = descendants[j]
                pcall(function()
                    if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and shouldBlock(obj.Name) then
                        obj.Disabled = true
                    end
                end)
            end
            task.wait()  -- yield each chunk — prevents freeze
        end
    end)

    -- Monitor new additions
    game.DescendantAdded:Connect(function(obj)
        pcall(function()
            if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and shouldBlock(obj.Name) then
                obj.Disabled = true
            end
        end)
    end)
end

-- ② Disable anticheat remotes (lightweight, no GC scan)
local function disableRemotes()
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if not remotes then return end
        local analytics = remotes:FindFirstChild("AnalyticsPipeline")
        if not analytics then return end
        for _, remote in ipairs(analytics:GetChildren()) do
            pcall(function() remote:Destroy() end)
        end
    end)
end

-- ③ Block kick — safe, no hookfunction needed
local function blockKick()
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(LocalPlayer)
        if mt and setreadonly then
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__namecall = newcclosure(function(self, ...)
                local method = select(1, ...)
                if method == "Kick" then return end
                return oldIndex(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
end

-- ④ Silence ScriptContext errors
local function silenceErrors()
    pcall(function()
        local sc = game:GetService("ScriptContext")
        if getconnections and sc.Error then
            for _, c in pairs(getconnections(sc.Error)) do
                pcall(function() c:Disable() end)
            end
        end
    end)
end

-- ⑤ Lightweight protection loop — event-driven, no scanning
local function startProtectionLoop()
    -- Only re-block newly added scripts (already covered by DescendantAdded above)
    -- This loop just re-disables remotes in case they're re-created
    task.spawn(function()
        while true do
            task.wait(30)  -- 30s instead of 5s
            pcall(disableRemotes)
        end
    end)
end

-- ================================
-- MAIN ENTRY
-- ================================

local function executeBypass()
    notify("ASTREXHOOK", "Loading bypass...", 3)

    startScriptBlocker()   -- chunked, non-blocking
    disableRemotes()        -- fast
    blockKick()             -- fast
    silenceErrors()         -- fast
    -- hookDangerousFunctions() REMOVED — getgc loop was the freeze culprit
    -- protectMemory()          REMOVED — setreadonly on all GC tables = VM lock

    startProtectionLoop()

    notify("ASTREXHOOK", "✓ Bypass active!", 4)
    print("[AstrexHook] Bypass loaded cleanly (no freeze)")
    return true
end

local ok, err = pcall(executeBypass)
if not ok then
    warn("[AstrexHook] Bypass error: " .. tostring(err))
end

return { success = ok }
