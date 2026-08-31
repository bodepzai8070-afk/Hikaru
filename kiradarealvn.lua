-- ============================================================================
-- KIRADAVN PRIME CYBERNETIC MASTER SUITE (DELTA EXECUTOR)
-- ============================================================================
if _G.KiradavnPrimeSuiteExecuted then return end
_G.KiradavnPrimeSuiteExecuted = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local CONFIG = {
    STUDS_TO_METERS = 0.28,
    THROTTLE_INTERVAL = 0.03,
    THEME = {
        BG = Color3.fromRGB(8, 9, 13),
        CONTAINER = Color3.fromRGB(13, 15, 22),
        ACCENT = Color3.fromRGB(0, 255, 170),
        WARNING = Color3.fromRGB(255, 75, 100),
        SUCCESS = Color3.fromRGB(0, 240, 120),
        TEXT_MAIN = Color3.fromRGB(245, 247, 250),
        TEXT_MUTED = Color3.fromRGB(120, 130, 150),
        STROKE = Color3.fromRGB(30, 36, 50),
        GLOW = Color3.fromRGB(0, 255, 170)
    },
    FONT = Enum.Font.GothamMedium,
    FONT_BOLD = Enum.Font.GothamBold,
    CULL_DISTANCE = 250,
    LOCK_RADIUS = 35
}

local State = {
    MenuOpen = true,
    EspEnabled = true,
    NoclipActive = false,
    LowGraphicsActive = false,
    InfinityJumpActive = false,
    LockOnActive = false,
    CoordsActive = false,
    CurrentTarget = nil,
    ActivePool = {},
    NoclipConnection = nil,
    JumpConnection = nil,
    LockOnConnection = nil,
    CoordsConnection = nil,
    CachedCharacterParts = {},
    OriginalCollisionStates = {}
}

-- ============================================================================
-- GIAO DIỆN CHÍNH & MÀN HÌNH KHỞI ĐỘNG ĐIỆN ẢNH (CINEMATIC INTRO 4S)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Kiradavn_Prime_Suite"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = CoreGui end)
if ScreenGui.Parent ~= CoreGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Cinematic Fullscreen Intro Background
local IntroFrame = Instance.new("Frame")
IntroFrame.Name = "IntroFrame"
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.BackgroundColor3 = CONFIG.THEME.BG
IntroFrame.BackgroundTransparency = 0
IntroFrame.BorderSizePixel = 0
IntroFrame.ZIndex = 50
IntroFrame.Parent = ScreenGui

-- Hiệu ứng Glow mờ ảo sau logo
local IntroGlow = Instance.new("Frame")
IntroGlow.Name = "IntroGlow"
IntroGlow.Size = UDim2.new(0, 140, 0, 140)
IntroGlow.AnchorPoint = Vector2.new(0.5, 0.5)
IntroGlow.Position = UDim2.new(0.5, 0, 0.42, 0)
IntroGlow.BackgroundColor3 = CONFIG.THEME.ACCENT
IntroGlow.BackgroundTransparency = 0.85
IntroGlow.BorderSizePixel = 0
IntroGlow.ZIndex = 51
IntroGlow.Parent = IntroFrame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(1, 0)
GlowCorner.Parent = IntroGlow

-- Logo 'k' xoay cực mượt
local IntroLogo = Instance.new("TextButton")
IntroLogo.Name = "IntroLogo"
IntroLogo.Size = UDim2.new(0, 76, 0, 76)
IntroLogo.AnchorPoint = Vector2.new(0.5, 0.5)
IntroLogo.Position = UDim2.new(0.5, 0, 0.42, 0)
IntroLogo.BackgroundColor3 = CONFIG.THEME.CONTAINER
IntroLogo.Text = "k"
IntroLogo.TextColor3 = CONFIG.THEME.ACCENT
IntroLogo.TextSize = 34
IntroLogo.Font = CONFIG.FONT_BOLD
IntroLogo.AutoButtonColor = false
IntroLogo.ZIndex = 52
IntroLogo.Parent = IntroFrame

local IntroLogoCorner = Instance.new("UICorner")
IntroLogoCorner.CornerRadius = UDim.new(0, 18)
IntroLogoCorner.Parent = IntroLogo

local IntroLogoStroke = Instance.new("UIStroke")
IntroLogoStroke.Color = CONFIG.THEME.ACCENT
IntroLogoStroke.Transparency = 0.1
IntroLogoStroke.Thickness = 2
IntroLogoStroke.Parent = IntroLogo

-- Tiêu đề Kirada Prime xuất hiện sau đó
local IntroText = Instance.new("TextLabel")
IntroText.Name = "IntroText"
IntroText.Size = UDim2.new(0, 320, 0, 40)
IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
IntroText.Position = UDim2.new(0.5, 0, 0.56, 0)
IntroText.BackgroundTransparency = 1
IntroText.Text = "KIRADA PRIME"
IntroText.TextColor3 = CONFIG.THEME.TEXT_MAIN
IntroText.TextSize = 18
IntroText.Font = CONFIG.FONT_BOLD
IntroText.TextTransparency = 1
IntroText.ZIndex = 52
IntroText.Parent = IntroFrame

-- Chạy Animation 4 giây hoàn hảo
task.spawn(function()
    local spinTween = TweenService:Create(IntroLogo, TweenInfo.new(3.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    spinTween:Play()

    TweenService:Create(IntroGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()

    task.wait(1.4)
    TweenService:Create(IntroText, TweenInfo.new(1.0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.wait(1.8)
    spinTween:Cancel()

    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(IntroFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroGlow, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroLogo, fadeInfo, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroLogoStroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(IntroText, fadeInfo, {TextTransparency = 1}):Play()

    task.wait(0.8)
    IntroFrame:Destroy()
end)

-- Giao diện điều khiển chính (Logo K thu nhỏ ngoài màn hình)
local LogoButton = Instance.new("TextButton")
LogoButton.Name = "LogoButton"
LogoButton.Size = UDim2.new(0, 42, 0, 42)
LogoButton.Position = UDim2.new(0.03, 0, 0.07, 0)
LogoButton.BackgroundColor3 = CONFIG.THEME.BG
LogoButton.Text = "k"
LogoButton.TextColor3 = CONFIG.THEME.ACCENT
LogoButton.TextSize = 18
LogoButton.Font = CONFIG.FONT_BOLD
LogoButton.AutoButtonColor = false
LogoButton.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 10)
LogoCorner.Parent = LogoButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = CONFIG.THEME.ACCENT
LogoStroke.Transparency = 0.4
LogoStroke.Thickness = 1.2
LogoStroke.Parent = LogoButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 340)
MainFrame.Position = UDim2.new(0.03, 52, 0.07, 0)
MainFrame.BackgroundColor3 = CONFIG.THEME.BG
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.THEME.STROKE
MainStroke.Transparency = 0.5
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = CONFIG.THEME.CONTAINER
TitleBar.BackgroundTransparency = 0.5
TitleBar.Text = "  KIRADAVN PRIME"
TitleBar.TextColor3 = CONFIG.THEME.TEXT_MAIN
TitleBar.TextSize = 11
TitleBar.Font = CONFIG.FONT_BOLD
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -12, 1, -44)
ContentScroll.Position = UDim2.new(0, 6, 0, 40)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 310)
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = CONFIG.THEME.ACCENT
ContentScroll.Parent = MainFrame

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(0, 108, 0, 62)
UIGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.Parent = ContentScroll

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
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    local targetSize = State.MenuOpen and UDim2.new(0, 360, 0, 340) or UDim2.new(0, 0, 0, 0)
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {Size = targetSize}):Play()
end)

local function createGridCard(name, defaultText, hasInput, placeholder, layoutOrder, onInputFocusLost)
    local card = Instance.new("Frame")
    card.Name = name
    card.Size = UDim2.new(0, 108, 0, 62)
    card.BackgroundColor3 = CONFIG.THEME.CONTAINER
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder
    card.Parent = ContentScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.THEME.WARNING
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = card

    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Size = hasInput and UDim2.new(1, -6, 0, 26) or UDim2.new(1, -6, 1, -6)
    btn.Position = UDim2.new(0, 3, 0, 3)
    btn.BackgroundColor3 = CONFIG.THEME.CONTAINER
    btn.Text = defaultText
    btn.TextColor3 = CONFIG.THEME.WARNING
    btn.TextSize = 9
    btn.Font = CONFIG.FONT_BOLD
    btn.AutoButtonColor = false
    btn.Parent = card

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local box = nil
    if hasInput then
        box = Instance.new("TextBox")
        box.Name = "InputBox"
        box.Size = UDim2.new(1, -6, 0, 24)
        box.Position = UDim2.new(0, 3, 0, 33)
        box.BackgroundColor3 = CONFIG.THEME.BG
        box.PlaceholderText = placeholder
        box.Text = ""
        box.TextColor3 = CONFIG.THEME.TEXT_MAIN
        box.PlaceholderColor3 = CONFIG.THEME.TEXT_MUTED
        box.TextSize = 8
        box.Font = CONFIG.FONT
        box.Parent = card

        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = box
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = CONFIG.THEME.STROKE
        boxStroke.Transparency = 0.5
        boxStroke.Thickness = 1
        boxStroke.Parent = box

        if onInputFocusLost then
            box.FocusLost:Connect(function(enter)
                if enter then onInputFocusLost(box.Text, box) end
            end)
        end
    end

    return btn, stroke, box, card
end

-- ============================================================================
-- CÁC TÍNH NĂNG TRONG HỆ THỐNG (ĐÃ DỊCH SANG TIẾNG VIỆT HOÀN TOÀN)
-- ============================================================================

-- 1. ESP Toggle
local EspBtn, EspStroke = createGridCard("EspCard", "NHÌN XUYÊN: BẬT", false, "", 1)
EspBtn.TextColor3 = CONFIG.THEME.SUCCESS
EspStroke.Color = CONFIG.THEME.SUCCESS

EspBtn.MouseButton1Click:Connect(function()
    State.EspEnabled = not State.EspEnabled
    if State.EspEnabled then
        EspBtn.Text = "NHÌN XUYÊN: BẬT"
        EspBtn.TextColor3 = CONFIG.THEME.SUCCESS
        EspStroke.Color = CONFIG.THEME.SUCCESS
    else
        EspBtn.Text = "NHÌN XUYÊN: TẮT"
        EspBtn.TextColor3 = CONFIG.THEME.WARNING
        EspStroke.Color = CONFIG.THEME.WARNING
        for _, data in pairs(State.ActivePool) do
            if data.Billboard then data.Billboard.Enabled = false end
        end
    end
end)

local function acquireESPNode(player)
    if State.ActivePool[player] then return State.ActivePool[player] end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 10
    textLabel.Font = CONFIG.FONT_BOLD
    textLabel.TextColor3 = CONFIG.THEME.ACCENT
    textLabel.Text = ""
    textLabel.Parent = billboard

    local nodeData = { Billboard = billboard, Label = textLabel }
    State.ActivePool[player] = nodeData
    return nodeData
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then acquireESPNode(player) end
end
Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then acquireESPNode(player) end end)
Players.PlayerRemoving:Connect(function(player)
    if State.ActivePool[player] then
        if State.ActivePool[player].Billboard then State.ActivePool[player].Billboard:Destroy() end
        State.ActivePool[player] = nil
    end
end)

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
                local dist = (localRoot.Position - root.Position).Magnitude
                if dist > CONFIG.CULL_DISTANCE then
                    data.Billboard.Enabled = false
                else
                    if State.EspEnabled then
                        if data.Billboard.Parent ~= head then data.Billboard.Parent = head end
                        data.Billboard.Enabled = true
                        data.Label.Text = string.format("%s [%.1fm]", player.Name, dist * CONFIG.STUDS_TO_METERS)
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

-- 2. Noclip Toggle
local NoclipBtn, NoclipStroke = createGridCard("NoclipCard", "XUYÊN TƯỜNG: TẮT", false, "", 2)
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
    task.defer(function() cacheCharacterParts(char); State.NoclipActive = false end)
end)
if LocalPlayer.Character then cacheCharacterParts(LocalPlayer.Character) end

NoclipBtn.MouseButton1Click:Connect(function()
    State.NoclipActive = not State.NoclipActive
    if State.NoclipActive then
        NoclipBtn.Text = "XUYÊN TƯỜNG: BẬT"
        NoclipBtn.TextColor3 = CONFIG.THEME.SUCCESS
        NoclipStroke.Color = CONFIG.THEME.SUCCESS
        if LocalPlayer.Character then cacheCharacterParts(LocalPlayer.Character) end
        State.NoclipConnection = RunService.Stepped:Connect(function()
            if not State.NoclipActive then return end
            for i = 1, #State.CachedCharacterParts do
                local part = State.CachedCharacterParts[i]
                if part and part.Parent and part.CanCollide then part.CanCollide = false end
            end
        end)
    else
        NoclipBtn.Text = "XUYÊN TƯỜNG: TẮT"
        NoclipBtn.TextColor3 = CONFIG.THEME.WARNING
        NoclipStroke.Color = CONFIG.THEME.WARNING
        if State.NoclipConnection then State.NoclipConnection:Disconnect(); State.NoclipConnection = nil end
        for i = 1, #State.CachedCharacterParts do
            local part = State.CachedCharacterParts[i]
            if part and part.Parent then
                part.CanCollide = State.OriginalCollisionStates[part] ~= nil and State.OriginalCollisionStates[part] or true
            end
        end
    end
end)

-- 3. Infinity Jump Toggle
local JumpBtn, JumpStroke = createGridCard("JumpCard", "NHẢY VÔ CỰC", false, "", 3)
JumpBtn.MouseButton1Click:Connect(function()
    State.InfinityJumpActive = not State.InfinityJumpActive
    if State.InfinityJumpActive then
        JumpBtn.Text = "NHẢY: BẬT"
        JumpBtn.TextColor3 = CONFIG.THEME.SUCCESS
        JumpStroke.Color = CONFIG.THEME.SUCCESS
        State.JumpConnection = UserInputService.JumpRequest:Connect(function()
            if not State.InfinityJumpActive then return end
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        JumpBtn.Text = "NHẢY VÔ CỰC"
        JumpBtn.TextColor3 = CONFIG.THEME.WARNING
        JumpStroke.Color = CONFIG.THEME.WARNING
        if State.JumpConnection then State.JumpConnection:Disconnect(); State.JumpConnection = nil end
    end
end)

-- 4. FPS Booster & Smart Render Toggle
local LagBtn, LagStroke = createGridCard("LagCard", "TỐI ƯU FPS: TẮT", false, "", 4)
local function isImportant(obj)
    if not obj then return false end
    local name = obj.Name:lower()
    if name:find("baseplate") or name:find("spawnlocation") or name:find("floor") or name:find("ground") or name:find("sàn") or name:find("checkpoint") or name:find("teleport") or name:find("plate") then
        return true
    end
    if obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) then return true end
    local ancestor = obj:FindFirstAncestorOfClass("Model")
    if ancestor and Players:GetPlayerFromCharacter(ancestor) then return true end
    return false
end

local function smartOptimizeObject(obj)
    if not obj or not obj.Parent then return end
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        if not isImportant(obj) then
            obj.CastShadow = false
            obj.Reflectance = 0
            if obj.Material ~= Enum.Material.SmoothPlastic then obj.Material = Enum.Material.SmoothPlastic end
            if obj:IsA("MeshPart") then obj.TextureID = "" end
        end
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
        obj:Destroy()
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        local parent = obj.Parent
        if parent and not isImportant(parent) then obj:Destroy() end
    end
end

LagBtn.MouseButton1Click:Connect(function()
    State.LowGraphicsActive = not State.LowGraphicsActive
    if State.LowGraphicsActive then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 999999
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") or child:IsA("BlurEffect") then
                    child.Enabled = false
                end
            end
        end)
        task.spawn(function()
            local descendants = Workspace:GetDescendants()
            local count = 0
            for i = 1, #descendants do
                smartOptimizeObject(descendants[i])
                count = count + 1
                if count >= 150 then count = 0; RunService.Heartbeat:Wait() end
            end
            pcall(function() collectgarbage("collect") end)
        end)
        LagBtn.Text = "FPS: BẬT"
        LagBtn.TextColor3 = CONFIG.THEME.SUCCESS
        LagStroke.Color = CONFIG.THEME.SUCCESS
    else
        Lighting.GlobalShadows = true
        LagBtn.Text = "TỐI ƯU FPS: TẮT"
        LagBtn.TextColor3 = CONFIG.THEME.WARNING
        LagStroke.Color = CONFIG.THEME.WARNING
    end
end)

-- 5. WalkSpeed Card
local SpeedBtn, SpeedStroke, SpeedBox = createGridCard("SpeedCard", "TỐC ĐỘ", true, "Nhập tốc độ...", 5, function(text)
    local val = tonumber(text)
    if val and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = val end
    end
end)
SpeedBtn.MouseButton1Click:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = val end
    end
end)

-- 6. Camera Lock-On Card
local ScopeCircle = Drawing.new("Circle")
ScopeCircle.Visible = false
ScopeCircle.Thickness = 1.5
ScopeCircle.NumSides = 64
ScopeCircle.Radius = CONFIG.LOCK_RADIUS
ScopeCircle.Filled = false
ScopeCircle.Color = CONFIG.THEME.SUCCESS
ScopeCircle.Transparency = 0.7

local LockBtn, LockStroke, LockRadiusBox = createGridCard("LockCard", "KHÓA MỤC TIÊU", true, "Bán kính...", 6, function(text)
    local val = tonumber(text)
    if val then
        if val > 360 then val = 360 elseif val < 0 then val = 0 end
        CONFIG.LOCK_RADIUS = val
        ScopeCircle.Radius = val
        LockRadiusBox.Text = tostring(val)
    end
end)

local function isVisible(targetPart, character)
    local localChar = LocalPlayer.Character
    if not localChar then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {localChar, character}
    rayParams.IgnoreWater = true
    return Workspace:Raycast(origin, direction, rayParams) == nil
end

local function getBestTarget()
    local closest, shortest = nil, CONFIG.LOCK_RADIUS
    local center = Camera.ViewportSize / 2
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= shortest and isVisible(head, char) then
                        shortest = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

local function onRenderStepped()
    ScopeCircle.Position = Camera.ViewportSize / 2
    if not State.LockOnActive then ScopeCircle.Visible = false; return end
    ScopeCircle.Visible = true

    if not State.CurrentTarget or not State.CurrentTarget.Parent or State.CurrentTarget.Parent:FindFirstChildOfClass("Humanoid").Health <= 0 then
        State.CurrentTarget = getBestTarget()
    end

    if State.CurrentTarget then
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, State.CurrentTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.25)
        ScopeCircle.Color = CONFIG.THEME.WARNING
    else
        ScopeCircle.Color = CONFIG.THEME.SUCCESS
    end
end

LockBtn.MouseButton1Click:Connect(function()
    State.LockOnActive = not State.LockOnActive
    if State.LockOnActive then
        LockBtn.Text = "KHÓA: BẬT"
        LockBtn.TextColor3 = CONFIG.THEME.SUCCESS
        LockStroke.Color = CONFIG.THEME.SUCCESS
        State.LockOnConnection = RunService.RenderStepped:Connect(onRenderStepped)
    else
        LockBtn.Text = "KHÓA MỤC TIÊU"
        LockBtn.TextColor3 = CONFIG.THEME.WARNING
        LockStroke.Color = CONFIG.THEME.WARNING
        if State.LockOnConnection then State.LockOnConnection:Disconnect(); State.LockOnConnection = nil end
        State.CurrentTarget = nil
        ScopeCircle.Visible = false
    end
end)

-- 7. Teleport Card
local TpButton, TpStroke, TeleportBox = createGridCard("TeleportCard", "DỊCH CHUYỂN", true, "Tên/ID...", 7, function() end)
TpButton.TextColor3 = CONFIG.THEME.ACCENT
TpStroke.Color = CONFIG.THEME.ACCENT
TpButton.Font = CONFIG.FONT_BOLD

TpButton.MouseButton1Click:Connect(function()
    local query = TeleportBox.Text:lower()
    if query == "" then return end
    local targetPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
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
        end
    end
end)

-- 8. Fly Script Card
local FlyBtn, FlyStroke = createGridCard("FlyCard", "BAY (FLY)", false, "", 8)
FlyBtn.TextColor3 = CONFIG.THEME.ACCENT
FlyStroke.Color = CONFIG.THEME.ACCENT

FlyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bodepzai8070-afk/kiradaprimefly/refs/heads/main/kiradafly.lua"))()
    end)
end)

-- ============================================================================
-- 9. YORU PRIME: TOẠ ĐỘ & NÚT SAO CHÉP THỦ CÔNG (CHỐNG SPAM / KHÔNG LAG)
-- ============================================================================
local CoordsBtn, CoordsStroke = createGridCard("CoordsCard", "TOẠ ĐỘ: TẮT", false, "", 9)

local YoruGui = Instance.new("ScreenGui")
YoruGui.Name = "YoruPrime_Coords"
YoruGui.ResetOnSpawn = false
YoruGui.Enabled = false
pcall(function() YoruGui.Parent = CoreGui end)
if YoruGui.Parent ~= CoreGui then
    YoruGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Khung hiển thị toạ độ tích hợp nút bấm sao chép thủ công
local CoordsFrame = Instance.new("Frame")
CoordsFrame.Size = UDim2.new(0, 240, 0, 115)
CoordsFrame.Position = UDim2.new(0.03, 0, 0.45, 0)
CoordsFrame.BackgroundColor3 = CONFIG.THEME.BG
CoordsFrame.BackgroundTransparency = 0.15
CoordsFrame.BorderSizePixel = 0
CoordsFrame.Parent = YoruGui

local CoordsCorner = Instance.new("UICorner")
CoordsCorner.CornerRadius = UDim.new(0, 10)
CoordsCorner.Parent = CoordsFrame

local CoordsStrokeUI = Instance.new("UIStroke")
CoordsStrokeUI.Color = CONFIG.THEME.ACCENT
CoordsStrokeUI.Transparency = 0.2
CoordsStrokeUI.Thickness = 1.5
CoordsStrokeUI.Parent = CoordsFrame

local CoordsTitle = Instance.new("TextLabel")
CoordsTitle.Size = UDim2.new(1, 0, 0, 26)
CoordsTitle.BackgroundColor3 = CONFIG.THEME.CONTAINER
CoordsTitle.BackgroundTransparency = 0.3
CoordsTitle.Text = "  YORU PRIME TOẠ ĐỘ"
CoordsTitle.TextColor3 = CONFIG.THEME.ACCENT
CoordsTitle.TextSize = 10
CoordsTitle.Font = CONFIG.FONT_BOLD
CoordsTitle.TextXAlignment = Enum.TextXAlignment.Left
CoordsTitle.Parent = CoordsFrame

local CoordsTitleCorner = Instance.new("UICorner")
CoordsTitleCorner.CornerRadius = UDim.new(0, 10)
CoordsTitleCorner.Parent = CoordsTitle

local CoordsTextLabel = Instance.new("TextLabel")
CoordsTextLabel.Size = UDim2.new(1, -16, 0, 32)
CoordsTextLabel.Position = UDim2.new(0, 8, 0, 30)
CoordsTextLabel.BackgroundTransparency = 1
CoordsTextLabel.Text = "X: 0.0 | Y: 0.0 | Z: 0.0"
CoordsTextLabel.TextColor3 = CONFIG.THEME.TEXT_MAIN
CoordsTextLabel.TextSize = 10
CoordsTextLabel.Font = CONFIG.FONT_BOLD
CoordsTextLabel.TextXAlignment = Enum.TextXAlignment.Left
CoordsTextLabel.Parent = CoordsFrame

-- Nút sao chép thủ công (Chỉ copy khi bạn nhấn nút, loại bỏ hoàn toàn tự động spam)
local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(1, -16, 0, 28)
CopyButton.Position = UDim2.new(0, 8, 0, 72)
CopyButton.BackgroundColor3 = CONFIG.THEME.CONTAINER
CopyButton.Text = "SAO CHÉP TOẠ ĐỘ"
CopyButton.TextColor3 = CONFIG.THEME.SUCCESS
CopyButton.TextSize = 9
CopyButton.Font = CONFIG.FONT_BOLD
CopyButton.AutoButtonColor = false
CopyButton.Parent = CoordsFrame

local CopyBtnCorner = Instance.new("UICorner")
CopyBtnCorner.CornerRadius = UDim.new(0, 6)
CopyBtnCorner.Parent = CopyButton

local CopyBtnStroke = Instance.new("UIStroke")
CopyBtnStroke.Color = CONFIG.THEME.SUCCESS
CopyBtnStroke.Transparency = 0.4
CopyBtnStroke.Thickness = 1
CopyBtnStroke.Parent = CopyButton

makeDraggable(CoordsFrame)

local latestPosString = "X: 0.0 | Y: 0.0 | Z: 0.0"

CopyButton.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(latestPosString)
            CopyButton.Text = "ĐÃ SAO CHÉP THÀNH CÔNG!"
            task.wait(1)
            CopyButton.Text = "SAO CHÉP TOẠ ĐỘ"
        end
    end)
end)

CoordsBtn.MouseButton1Click:Connect(function()
    State.CoordsActive = not State.CoordsActive
    if State.CoordsActive then
        CoordsBtn.Text = "TOẠ ĐỘ: BẬT"
        CoordsBtn.TextColor3 = CONFIG.THEME.SUCCESS
        CoordsStroke.Color = CONFIG.THEME.SUCCESS
        YoruGui.Enabled = true

        State.CoordsConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                latestPosString = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
                CoordsTextLabel.Text = latestPosString
            end
        end)
    else
        CoordsBtn.Text = "TOẠ ĐỘ: TẮT"
        CoordsBtn.TextColor3 = CONFIG.THEME.WARNING
        CoordsStroke.Color = CONFIG.THEME.WARNING
        YoruGui.Enabled = false
        if State.CoordsConnection then
            State.CoordsConnection:Disconnect()
            State.CoordsConnection = nil
        end
    end
end)
