-- ============================================================================
-- PHẦN 1: GLOBAL CHECK & KHỞI TẠO DỊCH VỤ / CẤU HÌNH
-- ============================================================================
if _G.AxiomMenuExecuted then return end
_G.AxiomMenuExecuted = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    STUDS_TO_METERS = 0.28,
    THROTTLE_INTERVAL = 0.03, -- Tăng nhẹ interval để giảm tải CPU
    ACCENT_COLOR = Color3.fromRGB(0, 255, 204),
    WARNING_COLOR = Color3.fromRGB(255, 50, 50),
    SAFE_COLOR = Color3.fromRGB(0, 255, 100),
    FONT = Enum.Font.Code,
    CULL_DISTANCE = 250
}

local State = {
    EspEnabled = true,
    MenuOpen = true,
    NoclipActive = false,
    LowGraphicsActive = false,
    InfinityJumpActive = false,
    TeleportUiVisible = true,
    ActivePool = {},
    NoclipConnection = nil,
    JumpConnection = nil,
    CachedCharacterParts = {},
    OriginalCollisionStates = {}
}

-- ============================================================================
-- PHẦN 2: XÂY DỰNG GIAO DIỆN (UI) & TÍNH NĂNG KÉO THẢ (DRAG)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Axiom_Delta_Suite"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if ScreenGui.Parent ~= CoreGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local LogoButton = Instance.new("TextButton")
LogoButton.Name = "LogoButton"
LogoButton.Size = UDim2.new(0, 48, 0, 48)
LogoButton.Position = UDim2.new(0.04, 0, 0.08, 0)
LogoButton.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
LogoButton.Text = "K"
LogoButton.TextColor3 = CONFIG.ACCENT_COLOR
LogoButton.TextSize = 20
LogoButton.Font = CONFIG.FONT
LogoButton.AutoButtonColor = false
LogoButton.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = LogoButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = CONFIG.ACCENT_COLOR
LogoStroke.Transparency = 0.3
LogoStroke.Thickness = 1.5
LogoStroke.Parent = LogoButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 480)
MainFrame.Position = UDim2.new(0.04, 60, 0.08, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.ACCENT_COLOR
MainStroke.Transparency = 0.5
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 26, 34)
TitleBar.BackgroundTransparency = 0.5
TitleBar.Text = "   AXIOM // DELTA_ENGINE"
TitleBar.TextColor3 = Color3.fromRGB(240, 244, 248)
TitleBar.TextSize = 13
TitleBar.Font = CONFIG.FONT
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(LogoButton)
makeDraggable(MainFrame)

LogoButton.MouseButton1Click:Connect(function()
    State.MenuOpen = not State.MenuOpen
    local targetSize = State.MenuOpen and UDim2.new(0, 310, 0, 480) or UDim2.new(0, 0, 0, 0)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {Size = targetSize}):Play()
end)

-- ============================================================================
-- PHẦN 3: TÍNH NĂNG ESP (HIỂN THỊ TÊN & KHOẢNG CÁCH) - SỬA LỖI RECYCLE & RESPAWN
-- ============================================================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 36)
ToggleButton.Position = UDim2.new(0.05, 0, 0.09, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
ToggleButton.Text = "ESP (TÊN & KHOẢNG CÁCH): BẬT"
ToggleButton.TextColor3 = CONFIG.SAFE_COLOR
ToggleButton.TextSize = 11
ToggleButton.Font = CONFIG.FONT
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = CONFIG.SAFE_COLOR
ToggleStroke.Transparency = 0.4
ToggleStroke.Thickness = 1
ToggleStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    State.EspEnabled = not State.EspEnabled
    if State.EspEnabled then
        ToggleButton.Text = "ESP (TÊN & KHOẢNG CÁCH): BẬT"
        ToggleButton.TextColor3 = CONFIG.SAFE_COLOR
        ToggleStroke.Color = CONFIG.SAFE_COLOR
    else
        ToggleButton.Text = "ESP (TÊN & KHOẢNG CÁCH): TẮT"
        ToggleButton.TextColor3 = CONFIG.WARNING_COLOR
        ToggleStroke.Color = CONFIG.WARNING_COLOR
        for _, data in pairs(State.ActivePool) do
            if data.Billboard then data.Billboard.Enabled = false end
        end
    end
end)

local function acquireESPNode(player)
    if State.ActivePool[player] then return State.ActivePool[player] end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AxiomNode"
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0.1
    textLabel.TextStrokeColor3 = Color3.fromRGB(5, 7, 10)
    textLabel.TextSize = 11
    textLabel.Font = CONFIG.FONT
    textLabel.TextColor3 = CONFIG.ACCENT_COLOR
    textLabel.Text = ""
    textLabel.Parent = billboard

    local nodeData = { Billboard = billboard, Label = textLabel }
    State.ActivePool[player] = nodeData
    return nodeData
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        acquireESPNode(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if State.ActivePool[player] then
        if State.ActivePool[player].Billboard then
            State.ActivePool[player].Billboard:Destroy()
        end
        State.ActivePool[player] = nil
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        acquireESPNode(player)
    end
end

task.spawn(function()
    while true do
        task.wait(CONFIG.THROTTLE_INTERVAL)
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        for player, data in pairs(State.ActivePool) do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if localRoot and root and head and humanoid and humanoid.Health > 0 then
                local distanceStuds = (localRoot.Position - root.Position).Magnitude
                
                if distanceStuds > CONFIG.CULL_DISTANCE then
                    data.Billboard.Enabled = false
                else
                    if State.EspEnabled then
                        if data.Billboard.Parent ~= head then
                            data.Billboard.Parent = head
                        end
                        data.Billboard.Enabled = true
                        local distanceMeters = distanceStuds * CONFIG.STUDS_TO_METERS
                        data.Label.Text = string.format("%s\nCÁCH: %.1fm", player.Name, distanceMeters)
                    else
                        data.Billboard.Enabled = false
                    end
                end
            else
                data.Billboard.Enabled = false
            end
        end
    end
end)

-- ============================================================================
-- PHẦN 4: TÍNH NĂNG NOCLIP (ĐI XUYÊN TƯỜNG)
-- ============================================================================
local function cacheCharacterParts(char)
    table.clear(State.CachedCharacterParts)
    table.clear(State.OriginalCollisionStates)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(State.CachedCharacterParts, part)
            State.OriginalCollisionStates[part] = part.CanCollide
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.defer(function()
        cacheCharacterParts(char)
        if State.NoclipActive then
            State.NoclipActive = false
            -- Reset toggle ui state logic if needed
        end
    end)
end)

if LocalPlayer.Character then
    cacheCharacterParts(LocalPlayer.Character)
end

local NoclipButton = Instance.new("TextButton")
NoclipButton.Size = UDim2.new(0.9, 0, 0, 36)
NoclipButton.Position = UDim2.new(0.05, 0, 0.18, 0)
NoclipButton.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
NoclipButton.Text = "NOCLIP (ĐI XUYÊN TƯỜNG): TẮT"
NoclipButton.TextColor3 = CONFIG.WARNING_COLOR
NoclipButton.TextSize = 11
NoclipButton.Font = CONFIG.FONT
NoclipButton.AutoButtonColor = false
NoclipButton.Parent = MainFrame

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 6)
NoclipCorner.Parent = NoclipButton

local NoclipStroke = Instance.new("UIStroke")
NoclipStroke.Color = CONFIG.WARNING_COLOR
NoclipStroke.Transparency = 0.4
NoclipStroke.Thickness = 1
NoclipStroke.Parent = NoclipButton

NoclipButton.MouseButton1Click:Connect(function()
    State.NoclipActive = not State.NoclipActive
    if State.NoclipActive then
        NoclipButton.Text = "NOCLIP (ĐI XUYÊN TƯỜNG): BẬT"
        NoclipButton.TextColor3 = CONFIG.SAFE_COLOR
        NoclipStroke.Color = CONFIG.SAFE_COLOR
        if LocalPlayer.Character then
            cacheCharacterParts(LocalPlayer.Character)
        end
        State.NoclipConnection = RunService.Stepped:Connect(function()
            if not State.NoclipActive then return end
            for i = 1, #State.CachedCharacterParts do
                local part = State.CachedCharacterParts[i]
                if part and part.Parent and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        NoclipButton.Text = "NOCLIP (ĐI XUYÊN TƯỜNG): TẮT"
        NoclipButton.TextColor3 = CONFIG.WARNING_COLOR
        NoclipStroke.Color = CONFIG.WARNING_COLOR
        if State.NoclipConnection then
            State.NoclipConnection:Disconnect()
            State.NoclipConnection = nil
        end
        for i = 1, #State.CachedCharacterParts do
            local part = State.CachedCharacterParts[i]
            if part and part.Parent then
                local originalState = State.OriginalCollisionStates[part]
                part.CanCollide = originalState ~= nil and originalState or true
            end
        end
    end
end)

-- ============================================================================
-- PHẦN 5: TÍNH NĂNG NHẢY VÔ CỰC (INFINITY JUMP)
-- ============================================================================
local JumpButton = Instance.new("TextButton")
JumpButton.Size = UDim2.new(0.9, 0, 0, 36)
JumpButton.Position = UDim2.new(0.05, 0, 0.27, 0)
JumpButton.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
JumpButton.Text = "NHẢY VÔ CỰC (INFINITY JUMP): TẮT"
JumpButton.TextColor3 = CONFIG.WARNING_COLOR
JumpButton.TextSize = 11
JumpButton.Font = CONFIG.FONT
JumpButton.AutoButtonColor = false
JumpButton.Parent = MainFrame

local JumpCorner = Instance.new("UICorner")
JumpCorner.CornerRadius = UDim.new(0, 6)
JumpCorner.Parent = JumpButton

local JumpStroke = Instance.new("UIStroke")
JumpStroke.Color = CONFIG.WARNING_COLOR
JumpStroke.Transparency = 0.4
JumpStroke.Thickness = 1
JumpStroke.Parent = JumpButton

JumpButton.MouseButton1Click:Connect(function()
    State.InfinityJumpActive = not State.InfinityJumpActive
    if State.InfinityJumpActive then
        JumpButton.Text = "NHẢY VÔ CỰC (INFINITY JUMP): BẬT"
        JumpButton.TextColor3 = CONFIG.SAFE_COLOR
        JumpStroke.Color = CONFIG.SAFE_COLOR
        State.JumpConnection = UserInputService.JumpRequest:Connect(function()
            if not State.InfinityJumpActive then return end
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        JumpButton.Text = "NHẢY VÔ CỰC (INFINITY JUMP): TẮT"
        JumpButton.TextColor3 = CONFIG.WARNING_COLOR
        JumpStroke.Color = CONFIG.WARNING_COLOR
        if State.JumpConnection then
            State.JumpConnection:Disconnect()
            State.JumpConnection = nil
        end
    end
end)

-- ============================================================================
-- PHẦN 6: TÍNH NĂNG TỐI ƯU FPS & GIẢM LAG (CÓ DANH SÁCH WHITELIST AN TOÀN)
-- ============================================================================
local function isWhitelisted(objName)
    local lower = objName:lower()
    return lower:find("baseplate") or lower:find("spawnlocation") or lower:find("floor") or lower:find("ground") or lower:find("sàn") or lower:find("checkpoint") or lower:find("teleport")
end

local LagButton = Instance.new("TextButton")
LagButton.Size = UDim2.new(0.9, 0, 0, 36)
LagButton.Position = UDim2.new(0.05, 0, 0.36, 0)
LagButton.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
LagButton.Text = "TỐI ƯU FPS & GIẢM LAG: TẮT"
LagButton.TextColor3 = CONFIG.WARNING_COLOR
LagButton.TextSize = 11
LagButton.Font = CONFIG.FONT
LagButton.AutoButtonColor = false
LagButton.Parent = MainFrame

local LagCorner = Instance.new("UICorner")
LagCorner.CornerRadius = UDim.new(0, 6)
LagCorner.Parent = LagButton

local LagStroke = Instance.new("UIStroke")
LagStroke.Color = CONFIG.WARNING_COLOR
LagStroke.Transparency = 0.4
LagStroke.Thickness = 1
LagStroke.Parent = LagButton

LagButton.MouseButton1Click:Connect(function()
    State.LowGraphicsActive = not State.LowGraphicsActive
    if State.LowGraphicsActive then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
                child.Enabled = false
            end
        end
        
        -- Dùng task.defer hoặc chạy ngầm để không bị khựng UI khi xử lý nhiều phần tử
        task.spawn(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if not isWhitelisted(obj.Name) then
                        obj.CastShadow = false
                        if obj.Material ~= Enum.Material.SmoothPlastic then
                            obj.Material = Enum.Material.SmoothPlastic
                        end
                    end
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                end
            end
            pcall(function() collectgarbage("collect") end)
        end)

        LagButton.Text = "TỐI ƯU FPS & GIẢM LAG: BẬT"
        LagButton.TextColor3 = CONFIG.SAFE_COLOR
        LagStroke.Color = CONFIG.SAFE_COLOR
    else
        Lighting.GlobalShadows = true
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
                child.Enabled = true
            end
        end
        LagButton.Text = "TỐI ƯU FPS & GIẢM LAG: TẮT"
        LagButton.TextColor3 = CONFIG.WARNING_COLOR
        LagStroke.Color = CONFIG.WARNING_COLOR
    end
end)

-- ============================================================================
-- PHẦN 7: TÍNH NĂNG TỐC ĐỘ (WALKSPEED)
-- ============================================================================
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.9, 0, 0, 36)
SpeedBox.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
SpeedBox.PlaceholderText = "Nhập tốc độ chạy (WalkSpeed)..."
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.fromRGB(240, 244, 248)
SpeedBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 125)
SpeedBox.TextSize = 11
SpeedBox.Font = CONFIG.FONT
SpeedBox.Parent = MainFrame

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 6)
SpeedBoxCorner.Parent = SpeedBox

SpeedBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local val = tonumber(SpeedBox.Text)
    if val and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = val
        end
    end
end)

-- ============================================================================
-- PHẦN 8: TÍNH NĂNG DỊCH CHUYỂN THÔNG MINH (SMART TELEPORT)
-- ============================================================================
local TeleportContainer = Instance.new("Frame")
TeleportContainer.Size = UDim2.new(0.9, 0, 0, 36)
TeleportContainer.Position = UDim2.new(0.05, 0, 0.54, 0)
TeleportContainer.BackgroundTransparency = 1
TeleportContainer.Parent = MainFrame

local TeleportBox = Instance.new("TextBox")
TeleportBox.Size = UDim2.new(0.68, 0, 1, 0)
TeleportBox.Position = UDim2.new(0, 0, 0, 0)
TeleportBox.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
TeleportBox.PlaceholderText = "Nhập Tên hoặc ID..."
TeleportBox.Text = ""
TeleportBox.TextColor3 = Color3.fromRGB(240, 244, 248)
TeleportBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 125)
TeleportBox.TextSize = 11
TeleportBox.Font = CONFIG.FONT
TeleportBox.Parent = TeleportContainer

local TeleportBoxCorner = Instance.new("UICorner")
TeleportBoxCorner.CornerRadius = UDim.new(0, 6)
TeleportBoxCorner.Parent = TeleportBox

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0.28, 0, 1, 0)
TeleportButton.Position = UDim2.new(0.72, 0, 0, 0)
TeleportButton.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
TeleportButton.Text = "TP"
TeleportButton.TextColor3 = CONFIG.ACCENT_COLOR
TeleportButton.TextSize = 11
TeleportButton.Font = CONFIG.FONT
TeleportButton.AutoButtonColor = false
TeleportButton.Parent = TeleportContainer

local TeleportBtnCorner = Instance.new("UICorner")
TeleportBtnCorner.CornerRadius = UDim.new(0, 6)
TeleportBtnCorner.Parent = TeleportButton

local ToggleTpButton = Instance.new("TextButton")
ToggleTpButton.Size = UDim2.new(0.9, 0, 0, 36)
ToggleTpButton.Position = UDim2.new(0.05, 0, 0.54, 0)
ToggleTpButton.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
ToggleTpButton.Text = "HIỆN LẠI KHUNG DỊCH CHUYỂN"
ToggleTpButton.TextColor3 = CONFIG.ACCENT_COLOR
ToggleTpButton.TextSize = 11
ToggleTpButton.Font = CONFIG.FONT
ToggleTpButton.AutoButtonColor = false
ToggleTpButton.Visible = false
ToggleTpButton.Parent = MainFrame

local ToggleTpCorner = Instance.new("UICorner")
ToggleTpCorner.CornerRadius = UDim.new(0, 6)
ToggleTpCorner.Parent = ToggleTpButton

TeleportButton.MouseButton1Click:Connect(function()
    local query = TeleportBox.Text:lower()
    if query == "" then return end
    local targetPlayer = nil
    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player ~= LocalPlayer then
            if tostring(player.UserId) == query or player.Name:lower():sub(1, #query) == query then
                targetPlayer = player
                break
            end
        end
    end
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and localRoot then
            localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            TeleportContainer.Visible = false
            State.TeleportUiVisible = false
            ToggleTpButton.Visible = true
        end
    end
end)

ToggleTpButton.MouseButton1Click:Connect(function()
    TeleportContainer.Visible = true
    State.TeleportUiVisible = true
    ToggleTpButton.Visible = false
    TeleportBox.Text = ""
end)
