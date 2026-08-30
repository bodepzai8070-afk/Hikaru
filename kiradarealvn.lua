-- [[ K Exploit Menu - Client-Side Script ]]
-- Đặt trong StarterPlayerScripts hoặc LocalScript trong StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Biến toàn cục
local MenuVisible = false
local EspEnabled = false
local NoclipEnabled = false
local TeleportBoxVisible = false
local EspConnections = {}
local NoclipConnections = {}
local TeleportTarget = nil

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Tạo nút K nổi
local KButton = Instance.new("TextButton")
KButton.Name = "KButton"
KButton.Size = UDim2.new(0, 60, 0, 60)
KButton.Position = UDim2.new(0, 20, 0, 100)
KButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KButton.BackgroundTransparency = 0.2
KButton.BorderSizePixel = 0
KButton.Text = "K"
KButton.TextColor3 = Color3.fromRGB(0, 255, 170)
KButton.TextScaled = true
KButton.Font = Enum.Font.GothamBlack
KButton.ZIndex = 10
KButton.Parent = ScreenGui

-- Stroke cho nút K
local KStroke = Instance.new("UIStroke")
KStroke.Color = Color3.fromRGB(0, 255, 170)
KStroke.Thickness = 2
KStroke.Transparency = 0.3
KStroke.Parent = KButton

-- Corner cho nút K
local KCorner = Instance.new("UICorner")
KCorner.CornerRadius = UDim.new(0, 15)
KCorner.Parent = KButton

-- Animation logo K
local KGlow = Instance.new("Frame")
KGlow.Size = UDim2.new(1, 0, 1, 0)
KGlow.Position = UDim2.new(0, 0, 0, 0)
KGlow.BackgroundTransparency = 1
KGlow.ZIndex = 9
KGlow.Parent = KButton

local KGlowStroke = Instance.new("UIStroke")
KGlowStroke.Color = Color3.fromRGB(0, 255, 170)
KGlowStroke.Thickness = 3
KGlowStroke.Transparency = 0.7
KGlowStroke.Parent = KGlow

local KGlowCorner = Instance.new("UICorner")
KGlowCorner.CornerRadius = UDim.new(0, 15)
KGlowCorner.Parent = KGlow

-- Animation pulse
coroutine.wrap(function()
    while true do
        TweenService:Create(KGlowStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.3}):Play()
        wait(0.8)
        TweenService:Create(KGlowStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.7}):Play()
        wait(0.8)
    end
end)()

-- Tạo Main Panel
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 300, 0, 450)
MainPanel.Position = UDim2.new(0.5, -150, 0.5, -225)
MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainPanel.BackgroundTransparency = 0.1
MainPanel.BorderSizePixel = 0
MainPanel.Visible = false
MainPanel.ZIndex = 8
MainPanel.Parent = ScreenGui

-- Stroke cho Main Panel
local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(0, 255, 170)
PanelStroke.Thickness = 1.5
PanelStroke.Transparency = 0.5
PanelStroke.Parent = MainPanel

-- Corner cho Main Panel
local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = MainPanel

-- Tiêu đề Panel
local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1, 0, 0, 40)
PanelTitle.Position = UDim2.new(0, 0, 0, 0)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "K MENU"
PanelTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
PanelTitle.Font = Enum.Font.GothamBlack
PanelTitle.TextSize = 20
PanelTitle.ZIndex = 9
PanelTitle.Parent = MainPanel

-- ScrollFrame cho các nút
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
ScrollFrame.ZIndex = 9
ScrollFrame.Parent = MainPanel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame

-- Hàm tạo nút chức năng
local function CreateToggleButton(name, default, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.BorderSizePixel = 0
    Button.Text = name .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.ZIndex = 9
    Button.Parent = ScrollFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 255, 170)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local state = default
    local function UpdateVisual()
        Button.Text = name .. ": " .. (state and "ON" or "OFF")
        Button.BackgroundColor3 = state and Color3.fromRGB(0, 80, 60) or Color3.fromRGB(40, 40, 40)
    end

    Button.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisual()
        callback(state)
    end)

    UpdateVisual()
    return Button
end

-- Hàm tạo input box
local function CreateInputBox(placeholder, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Container.BorderSizePixel = 0
    Container.ZIndex = 9
    Container.Parent = ScrollFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 255, 170)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -10, 1, 0)
    TextBox.Position = UDim2.new(0, 5, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.PlaceholderText = placeholder
    TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.ZIndex = 10
    TextBox.Parent = Container

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(TextBox.Text)
        end
    end)

    return Container, TextBox
end

-- Hàm tạo label thông tin
local function CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(0, 255, 170)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.ZIndex = 9
    Label.Parent = ScrollFrame
    return Label
end

-- === 1. ESP SYSTEM ===
local EspToggle = CreateToggleButton("ESP", false, function(enabled)
    EspEnabled = enabled
    if enabled then
        -- Kết nối theo dõi players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESPBillboard"
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = char:WaitForChild("Head")

                    local infoLabel = Instance.new("TextLabel")
                    infoLabel.Size = UDim2.new(1, 0, 1, 0)
                    infoLabel.BackgroundTransparency = 1
                    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
                    infoLabel.Font = Enum.Font.GothamBold
                    infoLabel.TextSize = 12
                    infoLabel.Parent = billboard

                    local connection = RunService.RenderStepped:Connect(function()
                        if char and char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            infoLabel.Text = "ID: " .. player.UserId .. "\n" .. string.format("%.1f", distance) .. "m"
                        end
                    end)
                    table.insert(EspConnections, connection)
                    table.insert(EspConnections, billboard)
                end
            end
        end

        -- Kết nối player added
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(function(char)
                    if EspEnabled then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ESPBillboard"
                        billboard.Size = UDim2.new(0, 150, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = char:WaitForChild("Head")

                        local infoLabel = Instance.new("TextLabel")
                        infoLabel.Size = UDim2.new(1, 0, 1, 0)
                        infoLabel.BackgroundTransparency = 1
                        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
                        infoLabel.Font = Enum.Font.GothamBold
                        infoLabel.TextSize = 12
                        infoLabel.Parent = billboard

                        local connection = RunService.RenderStepped:Connect(function()
                            if char and char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                infoLabel.Text = "ID: " .. player.UserId .. "\n" .. string.format("%.1f", distance) .. "m"
                            end
                        end)
                        table.insert(EspConnections, connection)
                        table.insert(EspConnections, billboard)
                    end
                end)
            end
        end)
        table.insert(EspConnections, playerAddedConn)
    else
        -- Cleanup ESP
        for _, item in ipairs(EspConnections) do
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif typeof(item) == "Instance" then
                item:Destroy()
            end
        end
        EspConnections = {}
    end
end)

-- === 2. PERFORMANCE OPTIMIZATION ===
local function OptimizePerformance()
    -- Tắt reflections
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Reflectance = 0
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    -- Giảm chất lượng rendering
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100
    Lighting.Brightness = 2
end

local OptimizeButton = Instance.new("TextButton")
OptimizeButton.Name = "OptimizeButton"
OptimizeButton.Size = UDim2.new(1, 0, 0, 40)
OptimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OptimizeButton.BorderSizePixel = 0
OptimizeButton.Text = "TỐI ƯU HIỆU SUẤT"
OptimizeButton.TextColor3 = Color3.fromRGB(0, 255, 170)
OptimizeButton.Font = Enum.Font.GothamBold
OptimizeButton.TextSize = 14
OptimizeButton.ZIndex = 9
OptimizeButton.Parent = ScrollFrame

local OptimizeStroke = Instance.new("UIStroke")
OptimizeStroke.Color = Color3.fromRGB(0, 255, 170)
OptimizeStroke.Thickness = 1
OptimizeStroke.Transparency = 0.7
OptimizeStroke.Parent = OptimizeButton

local OptimizeCorner = Instance.new("UICorner")
OptimizeCorner.CornerRadius = UDim.new(0, 8)
OptimizeCorner.Parent = OptimizeButton

OptimizeButton.MouseButton1Click:Connect(OptimizePerformance)

-- === 3. SMART TELEPORT SYSTEM ===
CreateLabel("TELEPORT:")
local TeleportInputContainer, TeleportInput = CreateInputBox("Nhập tên hoặc ID người chơi...", function(text)
    if text and text ~= "" then
        TeleportTarget = text
        TeleportBoxVisible = false
        TeleportInputContainer.Visible = false
        TeleportButton.Visible = false
        TeleportShowButton.Visible = true
    end
end)

local TeleportButton = Instance.new("TextButton")
TeleportButton.Name = "TeleportButton"
TeleportButton.Size = UDim2.new(1, 0, 0, 40)
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 80, 60)
TeleportButton.BorderSizePixel = 0
TeleportButton.Text
