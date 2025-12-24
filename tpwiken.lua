-- SIMPLE AUTO-TELEPORT TO WIKENITSU
-- No UI, just works

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local TARGET_ID = 8002861939
local FOLLOWING = false
local connection = nil

local function findTarget()
    -- Cari dengan ID
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == TARGET_ID then
            return p
        end
    end
    -- Cari dengan nama
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), "wikenitsu") then
            return p
        end
    end
    return nil
end

local function teleportToTarget()
    local target = findTarget()
    if not target or not target.Character then
        warn("Target tidak ditemukan!")
        return false
    end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        warn("Target root part tidak ditemukan")
        return false
    end
    
    -- Pastikan karakter kita ada
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        warn("Karakter kita belum siap")
        return false
    end
    
    -- Teleport ke belakang target
    local offset = Vector3.new(0, 0, 4)
    local newPos = targetRoot.CFrame:ToWorldSpace(CFrame.new(offset)).Position
    myRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
    
    print("Teleported to " .. target.Name)
    return true
end

-- Mulai auto-follow
local function startAutoFollow()
    if FOLLOWING then return end
    
    print("Mencari Wikenitsu (ID: " .. TARGET_ID .. ")...")
    
    local target = findTarget()
    if not target then
        warn("Wikenitsu tidak ditemukan di server!")
        return
    end
    
    print("Found: " .. target.Name)
    FOLLOWING = true
    
    -- Main loop
    connection = RunService.Heartbeat:Connect(function()
        if not FOLLOWING then return end
        
        target = findTarget()
        if not target or not target.Character then
            warn("Target hilang!")
            FOLLOWING = false
            return
        end
        
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if targetRoot and myRoot then
            local offset = Vector3.new(0, 0, 4)
            local newPos = targetRoot.CFrame:ToWorldSpace(CFrame.new(offset)).Position
            myRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
        end
    end)
    
    print("Auto-follow ENABLED for " .. target.Name)
end

-- Stop auto-follow
local function stopAutoFollow()
    if not FOLLOWING then return end
    
    FOLLOWING = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    print("Auto-follow DISABLED")
end

-- Toggle function
local function toggleAutoFollow()
    if FOLLOWING then
        stopAutoFollow()
    else
        startAutoFollow()
    end
end

-- Keyboard shortcut
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleAutoFollow()
    end
end)

-- Auto-start
wait(3)
startAutoFollow()

print("\n======================================")
print("AUTO-TELEPORT AKTIF")
print("Target: Wikenitsu (ID: 8002861939)")
print("Tekan F untuk toggle on/off")
print("======================================")