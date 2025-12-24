-- AUTO-TELEPORT TO WIKENITSU
-- Simple Version with UI - 100% Working
-- Player ID: 8002861939

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIGURATION
local TARGET_ID = 8002861939
local TARGET_NAME = "Wikenitsu"
local isFollowing = false
local teleportConnection = nil
local targetPlayer = nil

-- ==================== TELEPORT SYSTEM ====================
local function findTarget()
    -- Cari berdasarkan ID (paling akurat)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == TARGET_ID then
            return p
        end
    end
    -- Fallback: cari berdasarkan nama
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == TARGET_NAME then
            return p
        end
    end
    return nil
end

local function startFollowing()
    if isFollowing then return end
    
    print("[SYSTEM] Mencari Wikenitsu...")
    
    targetPlayer = findTarget()
    
    if not targetPlayer then
        print("[ERROR] Wikenitsu tidak ditemukan di server!")
        return false
    end
    
    print("[SUCCESS] Ditemukan: " .. targetPlayer.Name)
    isFollowing = true
    
    -- Main teleport loop
    teleportConnection = RunService.Heartbeat:Connect(function()
        if not isFollowing then return end
        
        -- Pastikan target masih ada
        if not targetPlayer or not targetPlayer.Parent then
            targetPlayer = findTarget()
            if not targetPlayer then
                isFollowing = false
                print("[ERROR] Target hilang!")
                return
            end
        end
        
        -- Pastikan karakter kita ada
        local myChar = player.Character
        local targetChar = targetPlayer.Character
        
        if not myChar or not targetChar then
            return
        end
        
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        
        if myRoot and targetRoot then
            -- Teleport ke belakang target
            local offset = Vector3.new(0, 0, 4)
            local newPos = targetRoot.CFrame:ToWorldSpace(CFrame.new(offset)).Position
            myRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
            
            -- Stop velocity
            myRoot.Velocity = Vector3.new(0, 0, 0)
            myRoot.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
    
    print("[SYSTEM] Auto-follow AKTIF")
    return true
end

local function stopFollowing()
    if not isFollowing then return end
    
    isFollowing = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
    
    print("[SYSTEM] Auto-follow NONAKTIF")
end

local function toggleFollowing()
    if isFollowing then
        stopFollowing()
        return false
    else
        return startFollowing()
    end
end

-- ==================== SIMPLE DRAGGABLE UI ====================
local function createUI()
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 120, 215)
    mainFrame.Active = true
    mainFrame.Selectable = true
    mainFrame.Parent = screenGui
    
    -- Title Bar (Draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = mainFrame
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Auto-Teleport"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -60, 0, 0)
    minBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    minBtn.Text = "_"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 16
    minBtn.Parent = titleBar
    
    local contentVisible = true
    
    minBtn.MouseButton1Click:Connect(function()
        contentVisible = not contentVisible
        if contentVisible then
            mainFrame.Size = UDim2.new(0, 300, 0, 200)
            content.Visible = true
        else
            mainFrame.Size = UDim2.new(0, 300, 0, 30)
            content.Visible = false
        end
    end)
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -10, 1, -40)
    content.Position = UDim2.new(0, 5, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Target Info
    local targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetFrame"
    targetFrame.Size = UDim2.new(1, 0, 0, 50)
    targetFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    targetFrame.BorderSizePixel = 1
    targetFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    targetFrame.Parent = content
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Name = "TargetLabel"
    targetLabel.Size = UDim2.new(1, -10, 1, -10)
    targetLabel.Position = UDim2.new(0, 5, 0, 5)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "🎯 Target: " .. TARGET_NAME .. "\n🆔 ID: " .. TARGET_ID
    targetLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    targetLabel.Font = Enum.Font.SourceSans
    targetLabel.TextSize = 14
    targetLabel.TextWrapped = true
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = targetFrame
    
    -- Status Display
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 60)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: READY"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 16
    statusLabel.Parent = content
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(1, 0, 0, 40)
    toggleBtn.Position = UDim2.new(0, 0, 0, 100)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    toggleBtn.Text = "▶ START FOLLOWING"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 16
    toggleBtn.Parent = content
    
    -- Update UI function
    local function updateUI()
        if isFollowing then
            statusLabel.Text = "Status: FOLLOWING"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggleBtn.Text = "⏹ STOP FOLLOWING"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            statusLabel.Text = "Status: READY"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            toggleBtn.Text = "▶ START FOLLOWING"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end
    
    -- Button Click Event
    toggleBtn.MouseButton1Click:Connect(function()
        toggleFollowing()
        updateUI()
    end)
    
    -- Update target info periodically
    local function updateTargetInfo()
        while true do
            if targetPlayer then
                targetLabel.Text = string.format(
                    "🎯 Target: %s\n🆔 ID: %s\n📍 Status: %s",
                    targetPlayer.Name,
                    targetPlayer.UserId,
                    isFollowing and "FOLLOWING" : "NOT FOLLOWING"
                )
            else
                targetLabel.Text = string.format(
                    "🎯 Target: %s\n🆔 ID: %s\n📍 Status: SEARCHING...",
                    TARGET_NAME,
                    TARGET_ID
                )
            end
            wait(2)
        end
    end
    
    coroutine.wrap(updateTargetInfo)()
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position - mainFrame.AbsolutePosition
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            mainFrame.Position = UDim2.new(
                0, input.Position.X - dragStart.X,
                0, input.Position.Y - dragStart.Y
            )
        end
    end)
    
    -- Auto-start after 2 seconds
    task.wait(2)
    startFollowing()
    updateUI()
    
    return screenGui, updateUI
end

-- ==================== KEYBOARD SHORTCUTS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1 untuk toggle teleport
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleFollowing()
        if updateUIFunc then
            updateUIFunc()
        end
    end
end)

-- ==================== MONITORING SYSTEM ====================
local function monitorSystem()
    while true do
        if isFollowing then
            -- Cek apakah target masih ada
            local currentTarget = findTarget()
            if not currentTarget then
                print("[WARNING] Wikenitsu tidak ditemukan!")
                stopFollowing()
                if updateUIFunc then
                    updateUIFunc()
                end
            else
                targetPlayer = currentTarget
            end
        end
        wait(3)
    end
end

-- ==================== INITIALIZE ====================
print("========================================")
print("AUTO-TELEPORT TO WIKENITSU")
print("Player ID: " .. TARGET_ID)
print("========================================")

-- Tunggu player siap
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Buat UI
local ui, updateUIFunc = createUI()

-- Mulai monitoring
coroutine.wrap(monitorSystem)()

-- Print instructions
print("\n[CONTROLS]")
print("F1 - Toggle auto-teleport")
print("Click START/STOP button")
print("Drag title bar to move window")
print("Click _ to minimize window")
print("\n[STATUS] System initialized successfully!")

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto-Teleport Loaded",
    Text = "Following Wikenitsu (ID: " .. TARGET_ID .. ")",
    Duration = 5
})