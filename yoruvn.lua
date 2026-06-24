-- ============================================================
-- ROBLOX SCRIPT - FULL AIMBOT + ESP + MENU (Yoru VN 🇻🇳) - FIXED
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== CHỐNG EXECUTOR ==========================
local function CheckExecutor()
    local blocked = {"CodeX", "Arsus", "Krnl"}
    local exec = syn and "Synapse" or krnl and "Krnl" or fluxus and "Fluxus" or "Unknown"
    for _, name in ipairs(blocked) do
        if exec:find(name) then
            game:Shutdown()
        end
    end
    local s, e = pcall(function() loadstring("print('test')") end)
    if not s then game:Shutdown() end
end
CheckExecutor()

-- ==================== CẤU HÌNH ==========================
local Settings = {
    AimbotEnabled = true,
    ESPEnabled = true,
    AimPart = "Head",
    FOVRadius = 200,
    Smoothness = 0.3,
    TeamCheck = false,
    VisibleCheck = false,
    ShowMenu = true
}

-- ==================== TẠO MENU ==========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YoruVN_Menu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 420)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Glow
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 10, 1, 10)
Glow.Position = UDim2.new(0, -5, 0, -5)
Glow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Glow.BackgroundTransparency = 0.8
Glow.BorderSizePixel = 0
Glow.Parent = MainFrame

-- Title
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

-- Toggle
local function CreateToggle(text, initialValue, yPos, callback)
    local state = initialValue
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Position = UDim2.new(0.5, -100, 0, yPos)
    btn.Text = text .. ": " .. tostring(state)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.BorderColor3 = Color3.fromRGB(0, 200, 255)
    btn.BorderSizePixel = 1
    btn.Parent = MainFrame
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. tostring(state)
        callback(state)
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 90)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 50)}):Play()
    end)
    return btn
end

-- Slider
local function CreateSlider(text, minVal, maxVal, initialValue, yPos, callback)
    local currentValue = initialValue
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 20)
    label.Position = UDim2.new(0.5, -100, 0, yPos - 5)
    label.Text = text .. ": " .. tostring(math.floor(currentValue))
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Parent = MainFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0, 200, 0, 10)
    sliderBg.Position = UDim2.new(0.5, -100, 0, yPos + 20)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = MainFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local dragging = false
    
    local function updateSlider(x)
        local relativeX = math.clamp((x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        currentValue = minVal + (maxVal - minVal) * relativeX
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = text .. ": " .. tostring(math.floor(currentValue))
        callback(currentValue)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    return sliderBg
end

-- Tạo UI
CreateToggle("Aimbot", Settings.AimbotEnabled, 70, function(v) Settings.AimbotEnabled = v end)
CreateToggle("ESP", Settings.ESPEnabled, 115, function(v) Settings.ESPEnabled = v end)
CreateToggle("Team Check", Settings.TeamCheck, 160, function(v) Settings.TeamCheck = v end)
CreateToggle("Visible Check", Settings.VisibleCheck, 205, function(v) Settings.VisibleCheck = v end)
CreateSlider("FOV", 50, 500, Settings.FOVRadius, 260, function(v) Settings.FOVRadius = v end)
CreateSlider("Smooth", 1, 100, Settings.Smoothness * 100, 310, function(v) Settings.Smoothness = v / 100 end)

-- Exit
local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 100, 0, 35)
ExitBtn.Position = UDim2.new(0.5, -50, 0, 370)
ExitBtn.Text = "EXIT"
ExitBtn.TextColor3 = Color3.fromRGB(255,255,255)
ExitBtn.TextSize = 18
ExitBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ExitBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
ExitBtn.BorderSizePixel = 1
ExitBtn.Parent = MainFrame
ExitBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==================== LOADING ==========================
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

local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 300, 0, 20)
ProgressBg.Position = UDim2.new(0.5, -150, 0.5, 0)
ProgressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressBg.BorderSizePixel = 1
ProgressBg.BorderColor3 = Color3.fromRGB(0, 200, 255)
ProgressBg.Parent = LoadingFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBg

local startTime = tick()
local duration = 5
local loadConnection = RunService.RenderStepped:Connect(function()
    local elapsed = tick() - startTime
    local progress = math.min(elapsed / duration, 1)
    ProgressBar.Size = UDim2.new(progress, 0, 1, 0)
    LoadText.Text = string.format("LOADING %.0f%%", progress * 100)
    
    if progress >= 1 then
        loadConnection:Disconnect()
        LoadingGui:Destroy()
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 420)}):Play()
        TweenService:Create(Glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {BackgroundTransparency = 0.2}):Play()
    end
end)

-- ==================== AIMBOT CORE ==========================
local function GetClosestPlayer()
    local closestDist = math.huge
    local closestTarget = nil
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local char = player.Character
        if not char or not char:FindFirstChild("Humanoid") then continue end
        local targetPart = char:FindFirstChild(Settings.AimPart)
        if not targetPart then continue end
        
        if Settings.VisibleCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
            if result and not result.Instance:IsDescendantOf(char) then continue end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < Settings.FOVRadius and dist < closestDist then
            closestDist = dist
            closestTarget = targetPart
        end
    end
    return closestTarget
end

local function mousemoverel(dx, dy)
    if syn and syn.mouse then
        syn.mouse.move(dx, dy)
    elseif Mouse and Mouse.Move then
        Mouse.Move(dx, dy)
    end
end

-- ==================== ESP ==========================
local espCache = {}

local function UpdateESP()
    if not Settings.ESPEnabled then
        for _, data in pairs(espCache) do
            for _, obj in pairs(data) do pcall(function() obj.Visible = false end) end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then
            if espCache[player] then
                for _, obj in pairs(espCache[player]) do pcall(obj.Remove) end
                espCache[player] = nil
            end
            continue
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            if espCache[player] then
                for _, obj in pairs(espCache[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end

        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                         (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 999

        if not espCache[player] then
            local box = Drawing.new("Box")
            local line = Drawing.new("Line")
            local txt = Drawing.new("Text")
            
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Thickness = 2
            box.Filled = false
            
            line.Color = Color3.fromRGB(0, 255, 0)
            line.Thickness = 1.5
            
            txt.Color = Color3.fromRGB(255,255,255)
            txt.Size = 14
            txt.Center = true
            txt.Outline = true

            espCache[player] = {box = box, line = line, txt = txt}
        end

        local data = espCache[player]
        local size = math.clamp(2500 / distance, 25, 350)

        data.box.Size = Vector2.new(size, size * 1.8)
        data.box.Position = Vector2.new(pos.X - size/2, pos.Y - size * 1.1)
        data.box.Visible = true

        data.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        data.line.To = Vector2.new(pos.X, pos.Y)
        data.line.Visible = true

        data.txt.Text = player.Name .. " | " .. math.floor(distance) .. "m"
        data.txt.Position = Vector2.new(pos.X, pos.Y - size * 1.1 - 20)
        data.txt.Visible = true
    end
end

-- ==================== MAIN LOOP ==========================
RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    if Settings.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local center = Camera.ViewportSize / 2
            local dx = targetPos.X - center.X
            local dy = targetPos.Y - center.Y
            mousemoverel(dx * Settings.Smoothness, dy * Settings.Smoothness)
        end
    end
end)

-- ==================== KEYBIND ==========================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Settings.ShowMenu = not Settings.ShowMenu
        MainFrame.Visible = Settings.ShowMenu
    end
end)

print([[
   ╔══════════════════════════════════════════╗
   ║   YORU VN 🇻🇳  -  SCRIPT ĐÃ FIX XONG     ║
   ║   Nhấn RightShift để mở menu             ║
   ╚══════════════════════════════════════════╝
]])
