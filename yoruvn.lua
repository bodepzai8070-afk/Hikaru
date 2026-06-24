-- ============================================================
-- ROBLOX SCRIPT - MENU LOADING + ANIMATION (Yoru VN 🇻🇳)
-- Chống Executor: CodeX, Arsus (tự động thoát nếu phát hiện)
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ==================== CHỐNG EXECUTOR ==========================
local function CheckExecutor()
    local blocked = {"CodeX", "Arsus", "Krnl"} -- thêm tên executor cần chặn
    local exec = syn and "Synapse" or krnl and "Krnl" or fluxus and "Fluxus" or "Unknown"
    for _, name in ipairs(blocked) do
        if exec:find(name) then
            game:Shutdown() -- thoát game ngay lập tức
        end
    end
    -- Kiểm tra thêm bằng file/loadstring
    local s, e = pcall(function() loadstring("print('test')") end)
    if not s then game:Shutdown() end
end
CheckExecutor()

-- ==================== TẠO MENU CHÍNH (Yoru VN) ===============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YoruVN_Menu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Frame chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Hiệu ứng viền sáng (animation)
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 10, 1, 10)
Glow.Position = UDim2.new(0, -5, 0, -5)
Glow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Glow.BackgroundTransparency = 0.8
Glow.BorderSizePixel = 0
Glow.Parent = MainFrame

-- Tiêu đề Yoru VN 🇻🇳
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Text = "YORU VN 🇻🇳"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 36
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Nút chức năng mẫu
local function CreateButton(text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 45)
    btn.Position = UDim2.new(0.5, -100, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 18
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.BorderColor3 = Color3.fromRGB(0, 200, 255)
    btn.BorderSizePixel = 1
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    -- Hover animation
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 90)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)}):Play()
    end)
    return btn
end

CreateButton("AIMBOT HEAD", 100, Color3.fromRGB(200, 50, 50), function()
    print("Aimbot Head toggled")
end)

CreateButton("ESP BOX", 160, Color3.fromRGB(50, 200, 50), function()
    print("ESP toggled")
end)

CreateButton("TELEPORT", 220, Color3.fromRGB(50, 100, 200), function()
    print("Teleport executed")
end)

CreateButton("EXIT", 280, Color3.fromRGB(100, 0, 0), function()
    MainFrame.Visible = false
    ScreenGui:Destroy()
end)

-- ==================== LOADING 5s + ANIMATION =================
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "LoadingScreen"
LoadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.5
LoadingFrame.Parent = LoadingGui

local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(0, 300, 0, 60)
LoadText.Position = UDim2.new(0.5, -150, 0.5, -80)
LoadText.Text = "YORU VN LOADING..."
LoadText.TextColor3 = Color3.fromRGB(0, 200, 255)
LoadText.TextSize = 32
LoadText.TextScaled = true
LoadText.BackgroundTransparency = 1
LoadText.Font = Enum.Font.GothamBold
LoadText.Parent = LoadingFrame

-- Thanh tiến trình
local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 0, 20)
ProgressBar.Position = UDim2.new(0.5, -150, 0.5, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = LoadingFrame

local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 300, 0, 20)
ProgressBg.Position = UDim2.new(0.5, -150, 0.5, 0)
ProgressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressBg.BorderSizePixel = 1
ProgressBg.BorderColor3 = Color3.fromRGB(0, 200, 255)
ProgressBg.Parent = LoadingFrame

-- Animation loading
local startTime = tick()
local duration = 5 -- 5 giây

RunService.RenderStepped:Connect(function()
    local elapsed = tick() - startTime
    local progress = math.min(elapsed / duration, 1)
    ProgressBar.Size = UDim2.new(progress, 0, 0, 20)
    LoadText.Text = string.format("LOADING %.0f%%", progress * 100)
    
    if progress >= 1 then
        LoadingGui:Destroy()
        MainFrame.Visible = true
        -- Animation xuất hiện menu (pop-up)
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
            {Size = UDim2.new(0, 450, 0, 350)}):Play()
        TweenService:Create(Glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), 
            {BackgroundTransparency = 0.2}):Play() -- viền sáng nhấp nháy
        -- Hủy loop
        RunService.RenderStepped:Disconnect()
    end
end)

-- ==================== PHÍM TẮT MỞ MENU ======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==================== LOGO YORU VN (CONSOLE) =================
print([[
   ╔══════════════════════════════════════╗
   ║   YORU VN 🇻🇳  -  MENU LOADED        ║
   ║   Nhấn RightShift để ẩn/hiện menu   ║
   ╚══════════════════════════════════════╝
]])
