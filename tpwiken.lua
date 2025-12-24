-- Auto-Teleport to Wikenitsu (ID: 8002861939)
-- Script yang pasti bekerja

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIGURATION
local TARGET_PLAYER_ID = 8002861939 -- ID Wikenitsu
local TARGET_PLAYER_NAME = "Wikenitsu"
local UPDATE_INTERVAL = 0.1 -- Update setiap 0.1 detik
local FOLLOW_DISTANCE = 4 -- Jarak dari target
local AUTO_START = true -- Mulai otomatis

-- State variables
local isFollowing = false
local connection = nil
local targetPlayer = nil
local uiEnabled = true

-- ==================== TELEPORT SYSTEM ====================
local function findPlayerById(playerId)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == playerId then
            return p
        end
    end
    return nil
end

local function findPlayerByName(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name) == string.lower(playerName) then
            return p
        end
    end
    return nil
end

local function getCharacterRoot(character)
    if not character then return nil end
    
    -- Cari HumanoidRootPart
    local root = character:FindFirstChild("HumanoidRootPart") or
                 character:FindFirstChild("Torso") or
                 character:FindFirstChild("UpperTorso") or
                 character.PrimaryPart
                 
    return root
end

local function startFollowing()
    if isFollowing then return end
    
    print("[TELEPORT] Mencari player dengan ID:", TARGET_PLAYER_ID)
    
    -- Cari target menggunakan ID terlebih dahulu
    targetPlayer = findPlayerById(TARGET_PLAYER_ID)
    
    -- Jika tidak ditemukan dengan ID, coba dengan nama
    if not targetPlayer then
        print("[TELEPORT] Player dengan ID tidak ditemukan, mencoba dengan nama...")
        targetPlayer = findPlayerByName(TARGET_PLAYER_NAME)
    end
    
    if not targetPlayer then
        print("[ERROR] Player tidak ditemukan di server!")
        if uiEnabled then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto-Teleport Error",
                Text = TARGET_PLAYER_NAME .. " tidak ditemukan!",
                Duration = 5,
                Icon = "rbxassetid://0"
            })
        end
        return false
    end
    
    print("[SUCCESS] Target ditemukan: " .. targetPlayer.Name)
    
    isFollowing = true
    
    -- Main teleport loop
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isFollowing then return end
        
        -- Pastikan target masih ada
        if not targetPlayer or not targetPlayer.Parent then
            targetPlayer = findPlayerById(TARGET_PLAYER_ID) or findPlayerByName(TARGET_PLAYER_NAME)
            if not targetPlayer then
                print("[ERROR] Target hilang!")
                isFollowing = false
                if connection then connection:Disconnect() end
                return
            end
        end
        
        -- Cek karakter sendiri
        local myCharacter = player.Character
        if not myCharacter then
            player.CharacterAdded:Wait()
            myCharacter = player.Character
        end
        
        local myHumanoid = myCharacter:FindFirstChild("Humanoid")
        local myRoot = getCharacterRoot(myCharacter)
        
        if not myHumanoid or not myRoot then
            print("[WARNING] Karakter sendiri belum siap")
            return
        end
        
        -- Cek karakter target
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then
            print("[WARNING] Karakter target belum siap")
            return
        end
        
        local targetRoot = getCharacterRoot(targetCharacter)
        if not targetRoot then
            print("[WARNING] Target root part tidak ditemukan")
            return
        end
        
        -- Hitung posisi baru (di belakang target)
        local targetCFrame = targetRoot.CFrame
        local offset = Vector3.new(0, 0, FOLLOW_DISTANCE)
        local newPosition = targetCFrame:ToWorldSpace(CFrame.new(offset)).Position
        
        -- Tambahkan sedikit ketinggian agar tidak terjebak di tanah
        newPosition = newPosition + Vector3.new(0, 3, 0)
        
        -- Teleport ke posisi baru
        myRoot.CFrame = CFrame.new(newPosition, targetRoot.Position)
        
        -- Stop velocity untuk mencegah sliding
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.RotVelocity = Vector3.new(0, 0, 0)
        
        -- Stop humanoid movement
        myHumanoid:MoveTo(targetRoot.Position)
    end)
    
    print("[TELEPORT] Mulai mengikuti " .. targetPlayer.Name)
    return true
end

local function stopFollowing()
    if not isFollowing then return end
    
    isFollowing = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    print("[TELEPORT] Berhenti mengikuti")
end

local function toggleFollowing()
    if isFollowing then
        stopFollowing()
        return false
    else
        return startFollowing()
    end
end

-- ==================== SIMPLE UI ====================
local function createSimpleUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoTeleportUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -150, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.Active = true
    mainFrame.Selectable = true
    mainFrame.Parent = screenGui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Auto-Teleport to Wikenitsu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        uiEnabled = false
    end)
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -10, 1, -40)
    content.Position = UDim2.new(0, 5, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Status Display
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: READY"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 16
    statusLabel.Parent = content
    
    -- Target Info
    local targetInfo = Instance.new("TextLabel")
    targetInfo.Name = "TargetInfo"
    targetInfo.Size = UDim2.new(1, 0, 0, 40)
    targetInfo.Position = UDim2.new(0, 0, 0, 35)
    targetInfo.BackgroundTransparency = 1
    targetInfo.Text = "Target: Wikenitsu\nID: 8002861939"
    targetInfo.TextColor3 = Color3.fromRGB(200, 200, 255)
    targetInfo.Font = Enum.Font.SourceSans
    targetInfo.TextSize = 14
    targetInfo.TextWrapped = true
    targetInfo.Parent = content
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, 0, 0, 40)
    toggleButton.Position = UDim2.new(0, 0, 0, 90)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    toggleButton.Text = "START FOLLOWING"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 16
    toggleButton.Parent = content
    
    -- Instructions
    local instructions = Instance.new("TextLabel")
    instructions.Name = "Instructions"
    instructions.Size = UDim2.new(1, 0, 0, 30)
    instructions.Position = UDim2.new(0, 0, 0, 135)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Press F3 to toggle teleport"
    instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
    instructions.Font = Enum.Font.SourceSans
    instructions.TextSize = 12
    instructions.Parent = content
    
    -- Update button function
    local function updateButton()
        if isFollowing then
            toggleButton.Text = "STOP FOLLOWING"
            toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            statusLabel.Text = "Status: FOLLOWING"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            toggleButton.Text = "START FOLLOWING"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            statusLabel.Text = "Status: READY"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        toggleFollowing()
        updateButton()
    end)
    
    -- Make frame draggable
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
    
    updateButton()
    return screenGui, updateButton
end

-- ==================== KEYBOARD SHORTCUTS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F3 untuk toggle teleport
    if input.KeyCode == Enum.KeyCode.F3 then
        toggleFollowing()
        if ui then
            updateButtonFunc()
        end
    -- F4 untuk hide/show UI
    elseif input.KeyCode == Enum.KeyCode.F4 and ui then
        ui.Enabled = not ui.Enabled
    end
end)

-- ==================== MONITOR TARGET ====================
local function monitorTarget()
    while true do
        if isFollowing and targetPlayer then
            -- Update target info
            local found = findPlayerById(TARGET_PLAYER_ID) or findPlayerByName(TARGET_PLAYER_NAME)
            if not found then
                print("[WARNING] Target hilang dari server!")
                stopFollowing()
                if uiEnabled then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Target Lost",
                        Text = TARGET_PLAYER_NAME .. " left the game",
                        Duration = 5
                    })
                end
            end
        end
        wait(5)
    end
end

-- ==================== INITIALIZE ====================
print("==========================================")
print("AUTO-TELEPORT TO WIKENITSU")
print("Player ID: 8002861939")
print("==========================================")

-- Tunggu hingga player siap
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Buat UI
local ui, updateButtonFunc = createSimpleUI()

-- Mulai monitoring
coroutine.wrap(monitorTarget)()

-- Auto-start jika diatur
if AUTO_START then
    wait(2) -- Tunggu sebentar
    startFollowing()
    updateButtonFunc()
end

-- Print instructions
print("\n[CONTROLS]")
print("F3 - Toggle auto-teleport")
print("F4 - Hide/show UI")
print("Click START/STOP button")
print("Drag title bar to move UI")
print("\n[STATUS] System ready!")

-- Debug info setiap 30 detik
while true do
    if isFollowing then
        print("[DEBUG] Still following " .. (targetPlayer and targetPlayer.Name or "unknown"))
    end
    wait(30)
end