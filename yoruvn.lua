-- // Yoru Aimbot + ESP Menu by Grok
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = true
local HeadAimOnly = true
local ESPEnabled = true
local AimKey = Enum.UserInputType.MouseButton2
local FOV = 180
local Smoothness = 0.5

local Targets = {}
local ESPObjects = {}

-- ==================== MENU YORU ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YoruMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Title.Text = "YORU MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Toggle Aimbot
local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(0.9, 0, 0, 40)
AimToggle.Position = UDim2.new(0.05, 0, 0, 60)
AimToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
AimToggle.Text = "Aimbot: ON"
AimToggle.TextColor3 = Color3.new(0,1,0)
AimToggle.TextScaled = true
AimToggle.Parent = Frame

-- Head Only
local HeadToggle = Instance.new("TextButton")
HeadToggle.Size = UDim2.new(0.9, 0, 0, 40)
HeadToggle.Position = UDim2.new(0.05, 0, 0, 110)
HeadToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
HeadToggle.Text = "Nhắm Đầu: ON"
HeadToggle.TextColor3 = Color3.new(0,1,0)
HeadToggle.TextScaled = true
HeadToggle.Parent = Frame

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.9, 0, 0, 40)
ESPToggle.Position = UDim2.new(0.05, 0, 0, 160)
ESPToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
ESPToggle.Text = "ESP Địch: ON"
ESPToggle.TextColor3 = Color3.new(0,1,0)
ESPToggle.TextScaled = true
ESPToggle.Parent = Frame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 40)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 220)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "Đóng Menu"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Parent = Frame

-- ==================== FUNCTIONS ====================
local function CreateESP(player)
    if ESPObjects[player] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 0, 0)
    
    local Name = Drawing.new("Text")
    Name.Size = 16
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Outline = true
    
    ESPObjects[player] = {Box = Box, Name = Name}
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player \~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPObjects[player] then CreateESP(player) end
            local obj = ESPObjects[player]
            local Root = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen and ESPEnabled then
                local Size = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 3, 0)).Y) / 2
                obj.Box.Size = Vector2.new(Size*1.5, Size*3)
                obj.Box.Position = Vector2.new(Pos.X - obj.Box.Size.X/2, Pos.Y - obj.Box.Size.Y/2)
                obj.Box.Visible = true
                
                obj.Name.Text = player.Name .. " [" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude) .. "m]"
                obj.Name.Position = Vector2.new(Pos.X, Pos.Y - obj.Box.Size.Y/2 - 20)
                obj.Name.Visible = true
            else
                obj.Box.Visible = false
                obj.Name.Visible = false
            end
        end
    end
end

-- ==================== AIMBOT LOGIC ====================
RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    if not AimbotEnabled then return end
    
    local Closest = nil
    local Shortest = FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player \~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
            local Head = player.Character.Head
            local Pos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Dist < Shortest then
                    Shortest = Dist
                    Closest = player
                end
            end
        end
    end
    
    if Closest and UserInputService:IsMouseButtonPressed(AimKey) then
        local TargetPart = HeadAimOnly and Closest.Character.Head or Closest.Character.HumanoidRootPart
        local AimPos = Camera:WorldToViewportPoint(TargetPart.Position + Vector3.new(0, 0.1, 0))
        
        local Mouse = UserInputService:GetMouseLocation()
        local TargetVec = Vector2.new(AimPos.X, AimPos.Y)
        
        mousemoverel((TargetVec.X - Mouse.X) * Smoothness, (TargetVec.Y - Mouse.Y) * Smoothness)
    end
end)

-- ==================== MENU CONTROLS ====================
AimToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    AimToggle.TextColor3 = AimbotEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
end)

HeadToggle.MouseButton1Click:Connect(function()
    HeadAimOnly = not HeadAimOnly
    HeadToggle.Text = "Nhắm Đầu: " .. (HeadAimOnly and "ON" or "OFF")
    HeadToggle.TextColor3 = HeadAimOnly and Color3.new(0,1,0) or Color3.new(1,0,0)
end)

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = "ESP Địch: " .. (ESPEnabled and "ON" or "OFF")
    ESPToggle.TextColor3 = ESPEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

-- Mở menu bằng phím RightShift hoặc Y
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Y then
        Frame.Visible = not Frame.Visible
    end
end)

print("✅ Yoru Aimbot + ESP Loaded!")
print("Nhấn RightShift hoặc Y để mở Menu")
