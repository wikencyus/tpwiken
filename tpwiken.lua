-- Script Penurun Grafik Roblox - Delta Executor
-- Dibuat untuk menurunkan semua pengaturan grafik ke minimum

local Players = game:GetService("Players")
local UserSettings = UserSettings()
local Settings = UserSettings:GetService("UserGameSettings")

if not Settings then
    warn("UserGameSettings tidak ditemukan!")
    return
end

-- Fungsi untuk mengatur semua pengaturan grafik ke minimum
local function setLowestGraphics()
    -- Pengaturan kualitas grafik
    Settings.SavedQualityLevel = 1
    Settings.MasterVolume = 0.1  -- Volume rendah
    
    -- Pengaturan grafis utama
    pcall(function()
        Settings.GraphicsQualityLevel = 1
    end)
    
    -- Pengaturan tampilan
    pcall(function()
        Settings.OverallGraphicsQuality = 1
    end)
    
    -- Nonaktifkan efek-efek visual
    pcall(function()
        Settings.Shadows = false
        Settings.AdvancedGraphics = false
        Settings.AdvancedGraphicsApi = false
    end)
    
    -- Pengaturan performa
    pcall(function()
        Settings.Fullscreen = false  -- Windowed mode lebih ringan
        Settings.VSync = false
        Settings.MSAA = 0
        Settings.MSAAQuality = 0
        Settings.TextureQuality = 1
        Settings.RenderThrottlingMode = Enum.RenderThrottlingMode.AlwaysOn
    end)
    
    -- Kurangi detail lingkungan
    pcall(function()
        settings().Rendering.EnableFRM = false
        settings().Rendering.QualityLevel = "Level01"
        settings().Rendering.MeshCacheSize = 1
        settings().Rendering.TextureCacheSize = 1
    end)
    
    -- Pengaturan tambahan untuk Delta Executor
    pcall(function()
        -- Coba akses pengaturan internal Roblox
        local success, result = pcall(function()
            settings().Rendering.GlobalShadows = false
            settings().Rendering.FullFramebufferArray = false
            settings().Rendering.EagerBulkExecution = false
        end)
    end)
    
    print("Pengaturan grafik telah diturunkan ke minimum!")
end

-- Coba jalankan segera
setLowestGraphics()

-- Buat loop untuk memastikan pengaturan tetap rendah
spawn(function()
    while wait(5) do
        pcall(function()
            if Settings.GraphicsQualityLevel > 1 then
                Settings.GraphicsQualityLevel = 1
            end
            
            if Settings.SavedQualityLevel > 1 then
                Settings.SavedQualityLevel = 1
            end
            
            -- Pastikan efek visual tetap dimatikan
            Settings.Shadows = false
        end)
    end
end)

-- Fungsi untuk mengatur pengaturan rendering engine
local function optimizeRendering()
    pcall(function()
        settings().Rendering.EnableFRM = false
        settings().Rendering.QualityLevel = "Level01"
        settings().Physics.PhysicsEnvironmentalThrottle = 2
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsSenderRate = 30
        settings().Physics.PhysicsReceiverRate = 30
    end)
end

-- Coba optimasi rendering
optimizeRendering()

print("==========================================")
print("Script Penurun Grafik Roblox di Delta Executor")
print("Semua pengaturan grafik telah diatur ke minimum")
print("Game sekarang berjalan dengan grafik terendah")
print("==========================================")

-- Notifikasi ke pengguna
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Grafik Diturunkan",
    Text = "Semua pengaturan grafik telah diatur ke minimum",
    Duration = 5,
})