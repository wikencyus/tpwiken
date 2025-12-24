-- Delta Executor UI Panel dengan fitur drag & minimize
-- Hanya untuk lingkungan testing yang sah

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Configuration
local DELTA_API_URL = "https://delta-executor.com/api" -- Contoh API endpoint
local PANEL_SETTINGS = {
    DefaultSize = UDim2.new(0, 400, 0, 500),
    MinimizedSize = UDim2.new(0, 400, 0, 40),
    DefaultPosition = UDim2.new(0.5, -200, 0.5, -250)
}

-- Delta Executor Core Functions
local DeltaExecutor = {
    _executionQueue = {},
    _isConnected = false,
    _lastExecutionTime = 0
}

function DeltaExecutor:Connect()
    -- Simulate connection to Delta API
    self._isConnected = true
    print("[Delta] Connected to execution service")
    return true
end

function DeltaExecutor:ExecuteScript(scriptCode)
    if not self._isConnected then
        self:Connect()
    end
    
    -- Rate limiting check
    local currentTime = tick()
    if currentTime - self._lastExecutionTime < 0.5 then
        table.insert(self._executionQueue, scriptCode)
        return false, "Rate limited - Added to queue"
    end
    
    self._lastExecutionTime = currentTime
    
    -- Simulate script execution
    local success, result = pcall(function()
        -- In a real executor, this would be the actual execution
        local loadFunction = loadstring or load
        if loadFunction then
            local compiled = loadFunction(scriptCode)
            if compiled then
                return compiled()
            end
        end
        return nil
    end)
    
    return success, result
end

function DeltaExecutor:ExecuteQueue()
    while #self._executionQueue > 0 do
        local scriptCode = table.remove(self._executionQueue, 1)
        local success, result = self:ExecuteScript(scriptCode)
        
        if not success then
            warn("[Delta] Queue execution failed:", result)
        end
        
        wait(0.5) -- Rate limit
    end
end

-- Draggable UI Panel
local DraggablePanel = {}
DraggablePanel.__index = DraggablePanel

function DraggablePanel.new(name)
    local self = setmetatable({}, DraggablePanel)
    
    self.Name = name or "DeltaPanel"
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
    self.ScreenGui.Name = "DeltaExecutorUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    self.Panel = Instance.new("Frame")
    self.Panel.Name = "MainPanel"
    self.Panel.Size = PANEL_SETTINGS.DefaultSize
    self.Panel.Position = PANEL_SETTINGS.DefaultPosition
    self.Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
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
    self.TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.Panel
    
    -- Title
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(0.6, 0, 1, 0)
    self.Title.Position = UDim2.new(0, 10, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = "Delta Executor v1.0"
    self.Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Font = Enum.Font.Code
    self.Title.TextSize = 14
    self.Title.Parent = self.TopBar
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    self.MinimizeButton.Text = "_"
    self.MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MinimizeButton.Font = Enum.Font.Code
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
    self.CloseButton.Font = Enum.Font.Code
    self.CloseButton.TextSize = 14
    self.CloseButton.Parent = self.TopBar
    
    -- Content Area
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -10, 1, -40)
    self.Content.Position = UDim2.new(0, 5, 0, 35)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Panel
    
    -- Script Input Area
    self.ScriptBox = Instance.new("ScrollingFrame")
    self.ScriptBox.Name = "ScriptBox"
    self.ScriptBox.Size = UDim2.new(1, 0, 0.7, 0)
    self.ScriptBox.Position = UDim2.new(0, 0, 0, 0)
    self.ScriptBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.ScriptBox.BorderSizePixel = 1
    self.ScriptBox.BorderColor3 = Color3.fromRGB(50, 50, 60)
    self.ScriptBox.ScrollBarThickness = 8
    self.ScriptBox.Parent = self.Content
    
    local scriptInput = Instance.new("TextBox")
    scriptInput.Name = "ScriptInput"
    scriptInput.Size = UDim2.new(1, -10, 1, -10)
    scriptInput.Position = UDim2.new(0, 5, 0, 5)
    scriptInput.BackgroundTransparency = 1
    scriptInput.TextColor3 = Color3.fromRGB(200, 200, 255)
    scriptInput.Text = "-- Paste your script here\nprint('Delta Executor Ready')"
    scriptInput.Font = Enum.Font.Code
    scriptInput.TextSize = 12
    scriptInput.TextXAlignment = Enum.TextXAlignment.Left
    scriptInput.TextYAlignment = Enum.TextYAlignment.Top
    scriptInput.TextWrapped = true
    scriptInput.ClearTextOnFocus = false
    scriptInput.MultiLine = true
    scriptInput.Parent = self.ScriptBox
    
    -- Buttons Container
    self.ButtonContainer = Instance.new("Frame")
    self.ButtonContainer.Name = "ButtonContainer"
    self.ButtonContainer.Size = UDim2.new(1, 0, 0.25, 0)
    self.ButtonContainer.Position = UDim2.new(0, 0, 0.75, 0)
    self.ButtonContainer.BackgroundTransparency = 1
    self.ButtonContainer.Parent = self.Content
    
    -- Execute Button
    self.ExecuteButton = Instance.new("TextButton")
    self.ExecuteButton.Name = "ExecuteButton"
    self.ExecuteButton.Size = UDim2.new(0.48, 0, 0, 40)
    self.ExecuteButton.Position = UDim2.new(0, 0, 0, 5)
    self.ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    self.ExecuteButton.Text = "EXECUTE"
    self.ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ExecuteButton.Font = Enum.Font.Code
    self.ExecuteButton.TextSize = 14
    self.ExecuteButton.Parent = self.ButtonContainer
    
    -- Clear Button
    self.ClearButton = Instance.new("TextButton")
    self.ClearButton.Name = "ClearButton"
    self.ClearButton.Size = UDim2.new(0.48, 0, 0, 40)
    self.ClearButton.Position = UDim2.new(0.52, 0, 0, 5)
    self.ClearButton.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    self.ClearButton.Text = "CLEAR"
    self.ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ClearButton.Font = Enum.Font.Code
    self.ClearButton.TextSize = 14
    self.ClearButton.Parent = self.ButtonContainer
    
    -- Status Label
    self.StatusLabel = Instance.new("TextLabel")
    self.StatusLabel.Name = "StatusLabel"
    self.StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    self.StatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
    self.StatusLabel.BackgroundTransparency = 1
    self.StatusLabel.Text = "Status: Ready"
    self.StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    self.StatusLabel.Font = Enum.Font.Code
    self.StatusLabel.TextSize = 12
    self.StatusLabel.Parent = self.Content
    
    -- Notification System
    self.Notification = Instance.new("TextLabel")
    self.Notification.Name = "Notification"
    self.Notification.Size = UDim2.new(1, -20, 0, 0)
    self.Notification.Position = UDim2.new(0, 10, 1, 10)
    self.Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    self.Notification.BorderSizePixel = 1
    self.Notification.BorderColor3 = Color3.fromRGB(0, 150, 255)
    self.Notification.Text = ""
    self.Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Notification.Font = Enum.Font.Code
    self.Notification.TextSize = 12
    self.Notification.Visible = false
    self.Notification.Parent = self.Panel
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
        self:Destroy()
    end)
    
    -- Execute button
    self.ExecuteButton.MouseButton1Click:Connect(function()
        self:ExecuteCurrentScript()
    end)
    
    -- Clear button
    self.ClearButton.MouseButton1Click:Connect(function()
        self.ScriptBox.ScriptInput.Text = ""
        self:ShowNotification("Script cleared", Color3.fromRGB(0, 200, 255))
    end)
    
    -- Keybinds for quick access
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightControl then
            self:ToggleVisibility()
        elseif input.KeyCode == Enum.KeyCode.F9 then
            self:ExecuteCurrentScript()
        elseif input.KeyCode == Enum.KeyCode.F10 then
            self:ToggleMinimize()
        end
    end)
end

function DraggablePanel:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if self.IsMinimized then
        local tween = TweenService:Create(self.Panel, tweenInfo, {
            Size = PANEL_SETTINGS.MinimizedSize
        })
        tween:Play()
        self.Content.Visible = false
        self.Title.Text = "Delta [Minimized] - RightCtrl to open"
    else
        local tween = TweenService:Create(self.Panel, tweenInfo, {
            Size = PANEL_SETTINGS.DefaultSize
        })
        tween:Play()
        self.Content.Visible = true
        self.Title.Text = "Delta Executor v1.0"
    end
end

function DraggablePanel:ToggleVisibility()
    self.Panel.Visible = not self.Panel.Visible
end

function DraggablePanel:ExecuteCurrentScript()
    local scriptCode = self.ScriptBox.ScriptInput.Text
    
    if scriptCode == "" or scriptCode == nil then
        self:ShowNotification("No script to execute", Color3.fromRGB(255, 100, 100))
        return
    end
    
    self.StatusLabel.Text = "Status: Executing..."
    self.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    -- Use Delta Executor to run the script
    local success, result = DeltaExecutor:ExecuteScript(scriptCode)
    
    if success then
        self.StatusLabel.Text = "Status: Execution successful"
        self.StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
        self:ShowNotification("Script executed successfully", Color3.fromRGB(0, 200, 100))
    else
        self.StatusLabel.Text = "Status: Execution failed"
        self.StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        self:ShowNotification("Execution error: " .. tostring(result), Color3.fromRGB(255, 100, 100))
    end
end

function DraggablePanel:ShowNotification(message, color)
    self.Notification.Text = message
    self.Notification.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    self.Notification.Visible = true
    self.Notification.Size = UDim2.new(1, -20, 0, 30)
    
    wait(3)
    
    self.Notification.Size = UDim2.new(1, -20, 0, 0)
    wait(0.3)
    self.Notification.Visible = false
end

function DraggablePanel:Destroy()
    self.ScreenGui:Destroy()
    DeltaExecutor._isConnected = false
end

-- Initialize the system
local function InitializeDeltaExecutor()
    print("Initializing Delta Executor UI...")
    
    -- Initialize Delta Executor
    DeltaExecutor:Connect()
    
    -- Create UI Panel
    local panel = DraggablePanel.new("DeltaExecutorPanel")
    
    -- Add sample scripts to quick load
    local sampleScripts = {
        ["Teleport to Player"] = [[
            local targetName = "Wikenitsu"
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local target = Players:FindFirstChild(targetName)
            
            if target and target.Character then
                player.Character:MoveTo(target.Character.HumanoidRootPart.Position)
                print("Teleported to", targetName)
            else
                warn("Target not found:", targetName)
            end
        ]],
        
        ["Speed Hack"] = [[
            local player = game:GetService("Players").LocalPlayer
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            
            if humanoid then
                humanoid.WalkSpeed = 100
                print("Speed set to 100")
            end
        ]],
        
        ["Fly Script"] = [[
            -- Simple fly script
            local player = game:GetService("Players").LocalPlayer
            local mouse = player:GetMouse()
            
            local flying = true
            local speed = 50
            
            local function fly()
                local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                if not humanoid then return end
                
                local root = player.Character.HumanoidRootPart
                if not root then return end
                
                humanoid.PlatformStand = true
                
                while flying and wait() do
                    local direction = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + root.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - root.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - root.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + root.CFrame.RightVector
                    end
                    
                    if direction.Magnitude > 0 then
                        direction = direction.Unit * speed
                    end
                    
                    root.Velocity = direction
                    root.RotVelocity = Vector3.new()
                end
                
                humanoid.PlatformStand = false
            end
            
            fly()
        ]]
    }
    
    -- Create quick script buttons
    local yOffset = 50
    for scriptName, scriptCode in pairs(sampleScripts) do
        local button = Instance.new("TextButton")
        button.Name = scriptName
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = UDim2.new(0, 0, 0, yOffset)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.Text = scriptName
        button.TextColor3 = Color3.fromRGB(200, 200, 255)
        button.Font = Enum.Font.Code
        button.TextSize = 12
        button.Parent = panel.ButtonContainer
        
        button.MouseButton1Click:Connect(function()
            panel.ScriptBox.ScriptInput.Text = scriptCode
            panel:ShowNotification("Loaded: " .. scriptName, Color3.fromRGB(0, 150, 255))
        end)
        
        yOffset = yOffset + 35
    end
    
    -- Auto-resize script box
    panel.ScriptBox.ScriptInput:GetPropertyChangedSignal("Text"):Connect(function()
        local textHeight = panel.ScriptBox.ScriptInput.TextBounds.Y + 20
        panel.ScriptBox.CanvasSize = UDim2.new(0, 0, 0, textHeight)
    end)
    
    -- Welcome notification
    panel:ShowNotification("Delta Executor loaded! Press RightCtrl to hide/show", Color3.fromRGB(0, 150, 255))
    
    return panel
end

-- Start the executor
local success, err = pcall(InitializeDeltaExecutor)
if not success then
    warn("Failed to initialize Delta Executor:", err)
end

print("Delta Executor Script Loaded Successfully!")
print("Controls:")
print("- RightCtrl: Toggle UI visibility")
print("- F9: Execute current script")
print("- F10: Minimize/Restore panel")
print("- Drag top bar to move panel")
