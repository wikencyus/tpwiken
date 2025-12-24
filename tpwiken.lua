-- Auto-Teleport to Wikenitsu with Draggable Panel
-- Delta Executor Version

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Configuration
local TARGET_PLAYER_NAME = "Wikenitsu" -- Ganti dengan nama player target
local TELEPORT_SETTINGS = {
    Enabled = false,
    UpdateInterval = 0.1, -- Detik antara update teleport
    FollowDistance = 3, -- Jarak dari target
    AutoStart = false -- Mulai otomatis?
}

-- Teleport System
local TeleportSystem = {
    _connection = nil,
    _lastPosition = nil,
    _isFollowing = false
}

function TeleportSystem:StartFollowing()
    if self._isFollowing then
        return false, "Already following"
    end
    
    self._isFollowing = true
    
    -- Cari target player
    local function findTarget()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == TARGET_PLAYER_NAME then
                return p
            end
        end
        return nil
    end
    
    -- Dapatkan karakter pemain
    local function getCharacter(player)
        if player and player.Character then
            return player.Character
        end
        return nil
    end
    
    -- Dapatkan HumanoidRootPart
    local function getRootPart(character)
        if character then
            return character:FindFirstChild("HumanoidRootPart") or 
                   character:FindFirstChild("Torso") or
                   character.PrimaryPart
        end
        return nil
    end
    
    -- Loop teleport utama
    self._connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self._isFollowing then
            return
        end
        
        -- Pastikan karakter sendiri ada
        local myCharacter = getCharacter(player)
        local myRoot = getRootPart(myCharacter)
        
        if not myCharacter or not myRoot then
            warn("Your character not found!")
            return
        end
        
        -- Cari target
        local targetPlayer = findTarget()
        if not targetPlayer then
            warn("Target player '" .. TARGET_PLAYER_NAME .. "' not found!")
            return
        end
        
        local targetCharacter = getCharacter(targetPlayer)
        local targetRoot = getRootPart(targetCharacter)
        
        if not targetCharacter or not targetRoot then
            warn("Target character not found!")
            return
        end
        
        -- Cek jika target bergerak
        local currentPos = targetRoot.Position
        if self._lastPosition and (currentPos - self._lastPosition).Magnitude < 0.1 then
            return -- Target tidak bergerak
        end
        
        self._lastPosition = currentPos
        
        -- Hitung posisi baru (di belakang target)
        local offset = Vector3.new(0, 0, TELEPORT_SETTINGS.FollowDistance)
        local targetCFrame = targetRoot.CFrame
        local newPosition = targetCFrame:ToWorldSpace(CFrame.new(offset)).Position
        
        -- Teleport ke posisi baru
        myRoot.CFrame = CFrame.new(newPosition, targetRoot.Position)
        
        -- Optional: Set velocity ke 0 untuk mencegah sliding
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.RotVelocity = Vector3.new(0, 0, 0)
    end)
    
    return true, "Started following " .. TARGET_PLAYER_NAME
end

function TeleportSystem:StopFollowing()
    if not self._isFollowing then
        return false, "Not following"
    end
    
    self._isFollowing = false
    
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    
    self._lastPosition = nil
    
    return true, "Stopped following"
end

function TeleportSystem:ToggleFollowing()
    if self._isFollowing then
        return self:StopFollowing()
    else
        return self:StartFollowing()
    end
end

-- Draggable UI Panel
local DraggablePanel = {}
DraggablePanel.__index = DraggablePanel

function DraggablePanel.new()
    local self = setmetatable({}, DraggablePanel)
    
    self.IsMinimized = false
    self.IsDragging = false
    self.DragStart = nil
    self.Panel = nil
    
    self:CreateUI()
    self:BindEvents()
    
    return self
end

function DraggablePanel:CreateUI()
    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AutoTeleportUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    self.Panel = Instance.new("Frame")
    self.Panel.Name = "MainPanel"
    self.Panel.Size = UDim2.new(0, 350, 0, 250)
    self.Panel.Position = UDim2.new(0, 20, 0, 20)
    self.Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.Panel.BorderSizePixel = 2
    self.Panel.BorderColor3 = Color3.fromRGB(0, 150, 255)
    self.Panel.Active = true
    self.Panel.Selectable = true
    self.Panel.ClipsDescendants = true
    self.Panel.Parent = self.ScreenGui
    
    -- Top Bar (Draggable Area)
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 30)
    self.TopBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.Panel
    
    -- Title
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(0.7, 0, 1, 0)
    self.Title.Position = UDim2.new(0, 10, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = "Auto-Teleport to " .. TARGET_PLAYER_NAME
    self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Font = Enum.Font.SourceSansBold
    self.Title.TextSize = 14
    self.Title.Parent = self.TopBar
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    self.MinimizeButton.Text = "_"
    self.MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MinimizeButton.Font = Enum.Font.SourceSansBold
    self.MinimizeButton.TextSize = 18
    self.MinimizeButton.Parent = self.TopBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 0)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    self.CloseButton.Text = "X"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.TextSize = 14
    self.CloseButton.Parent = self.TopBar
    
    -- Content Area
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -10, 1, -40)
    self.Content.Position = UDim2.new(0, 5, 0, 35)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Panel
    
    -- Status Display
    self.StatusBox = Instance.new("Frame")
    self.StatusBox.Name = "StatusBox"
    self.StatusBox.Size = UDim2.new(1, 0, 0, 60)
    self.StatusBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    self.StatusBox.BorderSizePixel = 1
    self.StatusBox.BorderColor3 = Color3.fromRGB(50, 50, 60)
    self.StatusBox.Parent = self.Content
    
    self.StatusLabel = Instance.new("TextLabel")
    self.StatusLabel.Name = "StatusLabel"
    self.StatusLabel.Size = UDim2.new(1, -10, 0.6, 0)
    self.StatusLabel.Position = UDim2.new(0, 5, 0, 5)
    self.StatusLabel.BackgroundTransparency = 1
    self.StatusLabel.Text = "Status: Ready"
    self.StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    self.StatusLabel.Font = Enum.Font.SourceSans
    self.StatusLabel.TextSize = 16
    self.StatusLabel.Parent = self.StatusBox
    
    self.TargetLabel = Instance.new("TextLabel")
    self.TargetLabel.Name = "TargetLabel"
    self.TargetLabel.Size = UDim2.new(1, -10, 0.4, 0)
    self.TargetLabel.Position = UDim2.new(0, 5, 0.6, 0)
    self.TargetLabel.BackgroundTransparency = 1
    self.TargetLabel.Text = "Target: " .. TARGET_PLAYER_NAME
    self.TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    self.TargetLabel.Font = Enum.Font.SourceSans
    self.TargetLabel.TextSize = 14
    self.TargetLabel.Parent = self.StatusBox
    
    -- Controls
    self.Controls = Instance.new("Frame")
    self.Controls.Name = "Controls"
    self.Controls.Size = UDim2.new(1, 0, 0, 120)
    self.Controls.Position = UDim2.new(0, 0, 0, 70)
    self.Controls.BackgroundTransparency = 1
    self.Controls.Parent = self.Content
    
    -- Toggle Button
    self.ToggleButton = Instance.new("TextButton")
    self.ToggleButton.Name = "ToggleButton"
    self.ToggleButton.Size = UDim2.new(1, 0, 0, 40)
    self.ToggleButton.Position = UDim2.new(0, 0, 0, 5)
    self.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    self.ToggleButton.Text = "START FOLLOWING"
    self.ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ToggleButton.Font = Enum.Font.SourceSansBold
    self.ToggleButton.TextSize = 16
    self.ToggleButton.Parent = self.Controls
    
    -- Settings
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "Settings"
    settingsFrame.Size = UDim2.new(1, 0, 0, 40)
    settingsFrame.Position = UDim2.new(0, 0, 0, 50)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.Parent = self.Controls
    
    local intervalLabel = Instance.new("TextLabel")
    intervalLabel.Name = "IntervalLabel"
    intervalLabel.Size = UDim2.new(0.6, 0, 1, 0)
    intervalLabel.Position = UDim2.new(0, 0, 0, 0)
    intervalLabel.BackgroundTransparency = 1
    intervalLabel.Text = "Update Interval: " .. TELEPORT_SETTINGS.UpdateInterval .. "s"
    intervalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    intervalLabel.Font = Enum.Font.SourceSans
    intervalLabel.TextSize = 12
    intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
    intervalLabel.Parent = settingsFrame
    
    -- Notification
    self.Notification = Instance.new("TextLabel")
    self.Notification.Name = "Notification"
    self.Notification.Size = UDim2.new(1, -10, 0, 0)
    self.Notification.Position = UDim2.new(0, 5, 1, 5)
    self.Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    self.Notification.BorderSizePixel = 1
    self.Notification.BorderColor3 = Color3.fromRGB(0, 150, 255)
    self.Notification.Text = ""
    self.Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Notification.Font = Enum.Font.SourceSans
    self.Notification.TextSize = 12
    self.Notification.Visible = false
    self.Notification.Parent = self.Content
end

function DraggablePanel:BindEvents()
    -- Drag functionality
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            self.DragStart = input.Position
            self.Panel.ZIndex = 100
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not self.IsDragging then
                    connection:Disconnect()
                    return
                end
                
                local delta = UserInputService:GetMouseLocation() - self.DragStart
                self.Panel.Position = UDim2.new(
                    0, self.Panel.Position.X.Offset + delta.X,
                    0, self.Panel.Position.Y.Offset + delta.Y
                )
                self.DragStart = UserInputService:GetMouseLocation()
            end)
        end
    end)
    
    self.TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
            self.Panel.ZIndex = 1
        end
    end)
    
    -- Minimize functionality
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        TeleportSystem:StopFollowing()
        self.ScreenGui:Destroy()
    end)
    
    -- Toggle teleport button
    self.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleTeleport()
    end)
    
    -- Keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- F1 untuk toggle teleport
        if input.KeyCode == Enum.KeyCode.F1 then
            self:ToggleTeleport()
        -- F2 untuk toggle UI
        elseif input.KeyCode == Enum.KeyCode.F2 then
            self.Panel.Visible = not self.Panel.Visible
        end
    end)
end

function DraggablePanel:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if self.IsMinimized then
        local tween = TweenService:Create(self.Panel, tweenInfo, {
            Size = UDim2.new(0, 350, 0, 30)
        })
        tween:Play()
        self.Content.Visible = false
        self.Title.Text = "Teleport [" .. (TeleportSystem._isFollowing and "ON" or "OFF") .. "]"
    else
        local tween = TweenService:Create(self.Panel, tweenInfo, {
            Size = UDim2.new(0, 350, 0, 250)
        })
        tween:Play()
        self.Content.Visible = true
        self.Title.Text = "Auto-Teleport to " .. TARGET_PLAYER_NAME
    end
end

function DraggablePanel:ToggleTeleport()
    local success, message = TeleportSystem:ToggleFollowing()
    
    if success then
        if TeleportSystem._isFollowing then
            self.ToggleButton.Text = "STOP FOLLOWING"
            self.ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            self.StatusLabel.Text = "Status: FOLLOWING " .. TARGET_PLAYER_NAME
            self.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            self:ShowNotification("Now following " .. TARGET_PLAYER_NAME, Color3.fromRGB(0, 200, 100))
        else
            self.ToggleButton.Text = "START FOLLOWING"
            self.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            self.StatusLabel.Text = "Status: Stopped"
            self.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:ShowNotification("Stopped following " .. TARGET_PLAYER_NAME, Color3.fromRGB(255, 100, 100))
        end
    else
        self:ShowNotification("Error: " .. message, Color3.fromRGB(255, 50, 50))
    end
end

function DraggablePanel:ShowNotification(message, color)
    self.Notification.Text = message
    self.Notification.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    self.Notification.Visible = true
    self.Notification.Size = UDim2.new(1, -10, 0, 30)
    
    wait(3)
    
    self.Notification.Size = UDim2.new(1, -10, 0, 0)
    wait(0.3)
    self.Notification.Visible = false
end

-- Update status secara real-time
local function updateStatusLoop(panel)
    while panel and panel.Panel and panel.Panel.Parent do
        if TeleportSystem._isFollowing then
            -- Cari target untuk menampilkan status real-time
            local targetFound = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == TARGET_PLAYER_NAME then
                    targetFound = true
                    
                    -- Update target position info
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = p.Character.HumanoidRootPart.Position
                        panel.TargetLabel.Text = string.format(
                            "Target: %s (%.1f, %.1f, %.1f)", 
                            TARGET_PLAYER_NAME, 
                            pos.X, pos.Y, pos.Z
                        )
                    end
                    break
                end
            end
            
            if not targetFound then
                panel.TargetLabel.Text = "Target: " .. TARGET_PLAYER_NAME .. " (NOT FOUND)"
                panel.TargetLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            else
                panel.TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
            end
        end
        
        wait(1)
    end
end

-- Initialize the system
local function InitializeAutoTeleport()
    print("Initializing Auto-Teleport System...")
    print("Target Player: " .. TARGET_PLAYER_NAME)
    
    -- Create UI Panel
    local panel = DraggablePanel.new()
    
    -- Start status update loop
    coroutine.wrap(updateStatusLoop)(panel)
    
    -- Auto-start jika diatur
    if TELEPORT_SETTINGS.AutoStart then
        wait(1)
        panel:ToggleTeleport()
    end
    
    -- Print instructions
    print("\n=== Auto-Teleport System Loaded ===")
    print("Target: " .. TARGET_PLAYER_NAME)
    print("Controls:")
    print("- Click START FOLLOWING button")
    print("- Or press F1 to toggle")
    print("- Press F2 to hide/show panel")
    print("- Drag top bar to move panel")
    print("- Click _ to minimize")
    print("===================================")
    
    return panel
end

-- Start the system
local success, err = pcall(InitializeAutoTeleport)
if not success then
    warn("Failed to initialize Auto-Teleport:", err)
    -- Fallback simple version
    local function simpleFollow()
        TeleportSystem:StartFollowing()
        print("Simple auto-teleport started for " .. TARGET_PLAYER_NAME)
    end
    simpleFollow()
end