local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = true
local HeadAimOnly = true
local ESPEnabled = true
local AimKey = Enum.UserInputType.MouseButton2
local FOV = 200
local Smoothness = 0.55

local ESPObjects = {}

print("🔥 YORU VN MENU ĐÃ HIỆN - Mobile Optimized")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YoruVN_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 420)
MainFrame.Position = UDim2.new(0.5, -145, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 55)
TopBar.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "YORU VN 🇻🇳"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 35)
Status.Position = UDim2.new(0, 0, 0, 55)
Status.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
Status.Text = "UNIVERSAL AIMBOT + ESP"
Status.TextColor3 = Color3.fromRGB(255, 220, 0)
Status.TextScaled = true
Status.Parent = MainFrame

local function CreateBtn(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local AimBtn = CreateBtn("Aimbot: ✅ ON", 100, function()
    AimbotEnabled = not AimbotEnabled
    AimBtn.Text = "Aimbot: " .. (AimbotEnabled and "✅ ON" or "❌ OFF")
end)

local HeadBtn = CreateBtn("Nhắm Đầu: ✅ ON", 160, function()
    HeadAimOnly = not HeadAimOnly
    HeadBtn.Text = "Nhắm Đầu: " .. (HeadAimOnly and "✅ ON" or "❌ BODY")
end)

local ESPBtn = CreateBtn("ESP Địch: ✅ ON", 220, function()
    ESPEnabled = not ESPEnabled
    ESPBtn.Text = "ESP Địch: " .. (ESPEnabled and "✅ ON" or "❌ OFF")
end)

local CloseBtn = CreateBtn("ĐÓNG MENU", 290, function()
    MainFrame.Visible = false
end)

local function CreateESP(plr)
    if ESPObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2.5
    box.Filled = false
    box.Color = Color3.fromRGB(255, 40, 40)
    
    local name = Drawing.new("Text")
    name.Size = 16
    name.Color = Color3.fromRGB(255, 255, 80)
    name.Outline = true
    name.Center = true
    
    ESPObjects[plr] = {Box = box, Name = name}
end

local function UpdateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPObjects[plr] then CreateESP(plr) end
            local data = ESPObjects[plr]
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen and ESPEnabled then
                local height = (Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y) * 1.7
                data.Box.Size = Vector2.new(height * 1.5, height * 3.2)
                data.Box.Position = Vector2.new(pos.X - data.Box.Size.X/2, pos.Y - data.Box.Size.Y/2)
                data.Box.Visible = true
                
                local dist = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                            math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                
                data.Name.Text = plr.Name .. " ["..dist.."m]"
                data.Name.Position = Vector2.new(pos.X, pos.Y - data.Box.Size.Y/2 - 20)
                data.Name.Visible = true
            else
                data.Box.Visible = false
                data.Name.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    if not AimbotEnabled then return end
    
    local closest = nil
    local shortest = FOV
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local hpos, vis = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                if vis then
                    local d = (Vector2.new(hpos.X, hpos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if d < shortest then
                        shortest = d
                        closest = plr
                    end
                end
            end
        end
    end
    
    if closest and UserInputService:IsMouseButtonPressed(AimKey) then
        local target = HeadAimOnly and closest.Character.Head or closest.Character.HumanoidRootPart
        local aimpos = Camera:WorldToViewportPoint(target.Position + Vector3.new(0,0.1,0))
        local mouse = UserInputService:GetMouseLocation()
        mousemoverel((aimpos.X - mouse.X) * Smoothness, (aimpos.Y - mouse.Y) * Smoothness)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Y then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ Menu đã hiện ngay! Nhấn Y để mở/đóng lại.")
