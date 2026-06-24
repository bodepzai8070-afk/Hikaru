-- // Yoru Aimbot + ESP Mobile Version
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
local Smoothness = 0.55

local ESPObjects = {}

print("✅ Yoru Mobile Aimbot Loaded!")
print("Nhấn Y hoặc RightShift để Toggle Menu (trong console)")

-- ==================== ESP ====================
local function CreateESP(player)
    if ESPObjects[player] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 0, 0)
    
    local Name = Drawing.new("Text")
    Name.Size = 15
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Outline = true
    Name.Center = true
    
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
                local Top = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 3, 0))
                local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                local Size = Vector2.new((Top.X - Bottom.X) * 1.8, Top.Y - Bottom.Y)
                
                obj.Box.Size = Size
                obj.Box.Position = Vector2.new(Pos.X - Size.X/2, Pos.Y - Size.Y/2 + 10)
                obj.Box.Visible = true
                
                obj.Name.Text = player.Name .. " [" .. math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude) or 999) .. "m]"
                obj.Name.Position = Vector2.new(Pos.X, Pos.Y - Size.Y/2 - 10)
                obj.Name.Visible = true
            else
                obj.Box.Visible = false
                obj.Name.Visible = false
            end
        end
    end
end

-- ==================== AIMBOT ====================
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
        local AimPos = Camera:WorldToViewportPoint(TargetPart.Position)
        
        local MouseLoc = UserInputService:GetMouseLocation()
        mousemoverel((AimPos.X - MouseLoc.X) * Smoothness, (AimPos.Y - MouseLoc.Y) * Smoothness)
    end
end)

-- ==================== TOGGLE BẰNG PHÍM ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Y or input.KeyCode == Enum.KeyCode.RightShift then
        AimbotEnabled = not AimbotEnabled
        print("Aimbot:", AimbotEnabled and "✅ BẬT" or "❌ TẮT")
    elseif input.KeyCode == Enum.KeyCode.H then
        HeadAimOnly = not HeadAimOnly
        print("Nhắm Đầu:", HeadAimOnly and "✅ ON" or "❌ OFF")
    elseif input.KeyCode == Enum.KeyCode.E then
        ESPEnabled = not ESPEnabled
        print("ESP:", ESPEnabled and "✅ BẬT" or "❌ TẮT")
    end
end)

print("=== HƯỚNG DẪN MOBILE ===")
print("Y / RightShift : Bật/Tắt Aimbot")
print("H : Bật/Tắt Nhắm Đầu")
print("E : Bật/Tắt ESP")
print("Giữ Chuột Phải để Auto Aim")
