--[[
  FIXTURE_TEMPLATE: Roblox Mod Menu (Ultimate Noclip)
  Fitur: TP List, God Mode, Walk Speed, Super Noclip, Fly, Multiple Jump, ESP
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. SETUP UI (MODERN DESIGN)
-- ==========================================
local Colors = {
    Background = Color3.fromRGB(30, 30, 36),
    TitleBar = Color3.fromRGB(24, 24, 28),
    Section = Color3.fromRGB(40, 40, 48),
    ButtonOff = Color3.fromRGB(200, 50, 60),
    ButtonOn = Color3.fromRGB(50, 200, 100),
    Text = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(88, 101, 242),
    SliderBg = Color3.fromRGB(60, 60, 70)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "ModMenu_GUI"
ScreenGui.ResetOnSpawn = false

local OpenIcon = Instance.new("TextButton")
OpenIcon.Parent = ScreenGui
OpenIcon.BackgroundColor3 = Colors.TitleBar
OpenIcon.Position = UDim2.new(0, 15, 0, 15)
OpenIcon.Size = UDim2.new(0, 45, 0, 45)
OpenIcon.Font = Enum.Font.GothamBold
OpenIcon.Text = "M"
OpenIcon.TextColor3 = Colors.Accent
OpenIcon.TextSize = 22
OpenIcon.Visible = false
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenIcon).Color = Colors.Accent
Instance.new("UIStroke", OpenIcon).Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -200)
MainFrame.Size = UDim2.new(0, 270, 0, 400)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 70)

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Colors.TitleBar
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Parent = TitleBar
TitleBarFix.BackgroundColor3 = Colors.TitleBar
TitleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "✨ Mobile Mod Menu"
Title.TextColor3 = Colors.Text
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 0)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 86)
CloseBtn.Position = UDim2.new(1, -35, 0, 12)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenIcon.Visible = true
end)

OpenIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenIcon.Visible = false
end)

-- Logika Dragging (Geser Menu)
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Size = UDim2.new(1, 0, 1, -55)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Colors.Accent

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = ScrollingFrame
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 10)

local function CreateSection(text)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Parent = ScrollingFrame
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Size = UDim2.new(0, 240, 0, 20)
    
    local SectionText = Instance.new("TextLabel")
    SectionText.Parent = SectionFrame
    SectionText.BackgroundTransparency = 1
    SectionText.Size = UDim2.new(1, 0, 1, 0)
    SectionText.Font = Enum.Font.GothamBold
    SectionText.Text = text
    SectionText.TextColor3 = Colors.Accent
    SectionText.TextSize = 13
    SectionText.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Colors.ButtonOff
    Button.Size = UDim2.new(0, 240, 0, 35)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name .. " [OFF]"
    Button.TextColor3 = Colors.Text
    Button.TextSize = 13
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Colors.ButtonOn
            Button.Text = name .. " [ON]"
        else
            Button.BackgroundColor3 = Colors.ButtonOff
            Button.Text = name .. " [OFF]"
        end
        callback(state)
    end)
end

local function CreateSlider(name, minVal, maxVal, defaultVal, callback)
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Parent = ScrollingFrame
    SliderContainer.BackgroundColor3 = Colors.Section
    SliderContainer.Size = UDim2.new(0, 240, 0, 50)
    Instance.new("UICorner", SliderContainer).CornerRadius = UDim.new(0, 6)

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = SliderContainer
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.Text = name .. ": " .. defaultVal
    SliderLabel.TextColor3 = Colors.Text
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBar = Instance.new("TextButton")
    SliderBar.Parent = SliderContainer
    SliderBar.BackgroundColor3 = Colors.SliderBg
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.Size = UDim2.new(0, 220, 0, 10)
    SliderBar.Text = ""
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

    local FillBar = Instance.new("Frame")
    FillBar.Parent = SliderBar
    FillBar.BackgroundColor3 = Colors.Accent
    FillBar.Size = UDim2.new(0, 0, 1, 0)
    FillBar.BorderSizePixel = 0
    Instance.new("UICorner", FillBar).CornerRadius = UDim.new(1, 0)

    local isDragging = false
    local currentVal = defaultVal
    
    local initialPercent = (defaultVal - minVal) / (maxVal - minVal)
    FillBar.Size = UDim2.new(initialPercent, 0, 1, 0)

    SliderBar.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = false 
        end 
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local mouseX = UserInputService:GetMouseLocation().X
            local sliderX = SliderBar.AbsolutePosition.X
            local sliderW = SliderBar.AbsoluteSize.X
            
            local percent = math.clamp((mouseX - sliderX) / sliderW, 0, 1)
            currentVal = math.floor(percent * (maxVal - minVal)) + minVal
            
            SliderLabel.Text = name .. ": " .. currentVal
            FillBar.Size = UDim2.new(percent, 0, 1, 0)
            callback(currentVal)
        end
    end)
end

-- ==========================================
-- 2. LOGIKA FITUR
-- ==========================================

-- [ SECTION 1: TELEPORT ]
CreateSection("👤 Teleport Pemain")
local TeleportFrame = Instance.new("Frame")
TeleportFrame.Parent = ScrollingFrame
TeleportFrame.BackgroundColor3 = Colors.Section
TeleportFrame.Size = UDim2.new(0, 240, 0, 30)
Instance.new("UICorner", TeleportFrame).CornerRadius = UDim.new(0, 6)

local TeleportTitle = Instance.new("TextLabel")
TeleportTitle.Parent = TeleportFrame
TeleportTitle.BackgroundTransparency = 1
TeleportTitle.Size = UDim2.new(1, -45, 1, 0)
TeleportTitle.Font = Enum.Font.GothamSemibold
TeleportTitle.Text = "List Pemain"
TeleportTitle.TextColor3 = Colors.Text
TeleportTitle.TextSize = 12
TeleportTitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportTitle.Position = UDim2.new(0, 10, 0, 0)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Parent = TeleportFrame
RefreshBtn.BackgroundColor3 = Colors.Accent
RefreshBtn.Size = UDim2.new(0, 25, 0, 20)
RefreshBtn.Position = UDim2.new(1, -32, 0, 5)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Text = "R"
RefreshBtn.TextColor3 = Colors.Text
RefreshBtn.TextSize = 12
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Parent = ScrollingFrame
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.Size = UDim2.new(0, 240, 0, 5)
PlayerListFrame.AutomaticSize = Enum.AutomaticSize.Y

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = PlayerListFrame
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

local function RefreshPlayerList()
    PlayerListFrame:ClearAllChildren()
    local newLayout = Instance.new("UIListLayout")
    newLayout.Parent = PlayerListFrame
    newLayout.SortOrder = Enum.SortOrder.LayoutOrder
    newLayout.Padding = UDim.new(0, 5)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Parent = PlayerListFrame
            pBtn.BackgroundColor3 = Colors.SliderBg
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.Font = Enum.Font.Gotham
            pBtn.Text = "➔ " .. p.Name
            pBtn.TextColor3 = Colors.Text
            pBtn.TextSize = 12
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            
            pBtn.MouseButton1Click:Connect(function()
                local targetChar = p.Character
                local myChar = LocalPlayer.Character
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end
end

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
task.spawn(RefreshPlayerList)


-- [ SECTION 2: MOVEMENT ]
CreateSection("🏃 Movement")

local currentWalkSpeed = 16
CreateSlider("Walk Speed", 16, 200, 16, function(val)
    currentWalkSpeed = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end)

-- Super Noclip & Noclip Speed Slider
local noclipSpeed = 2
CreateSlider("Noclip Push Speed", 1, 10, 2, function(val)
    noclipSpeed = val
end)

local wallHackActive = false
local noclipConnection

CreateToggle("Super Noclip (All Blocks)", function(state)
    wallHackActive = state
    local char = LocalPlayer.Character
    if not char then return end

    if wallHackActive then
        noclipConnection = RunService.Stepped:Connect(function(time, deltaTime)
            if not wallHackActive then return end
            local myChar = LocalPlayer.Character
            if myChar then
                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                local humanoid = myChar:FindFirstChild("Humanoid")
                if hrp and humanoid then
                    -- 1. Matikan tabrakan & raycast
                    for _, part in pairs(myChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.CanQuery = false
                        end
                    end
                    
                    -- 2. Paksa Maju (CFrame Push) untuk menembus dinding
                    local moveDir = humanoid.MoveDirection
                    if moveDir.Magnitude > 0 then
                        -- Menggunakan CFrame + deltaTime agar mulus
                        hrp.CFrame = hrp.CFrame + (moveDir * noclipSpeed)
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        -- Kembalikan CanCollide saat Noclip dimatikan
        local myChar = LocalPlayer.Character
        if myChar then
            for _, part in pairs(myChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- Fly Speed
local flySpeed = 50
CreateSlider("Fly Speed", 10, 160, 50, function(val)
    flySpeed = val
end)

local flyActive = false
local flyConnection
local bodyVelocity
CreateToggle("Fly (Geser Kamera)", function(state)
    flyActive = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyActive then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = hrp
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)

        local camera = workspace.CurrentCamera
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyActive or not bodyVelocity or not bodyVelocity.Parent then return end
            local moveDir = camera.CFrame.LookVector
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            bodyVelocity.Velocity = moveDir * flySpeed
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end)

local jumpActive = false
local maxJumps = 999
local jumpCount = 0
CreateToggle("Multiple Jump", function(state)
    jumpActive = state
    if not state then jumpCount = 0 end
end)
UserInputService.JumpRequest:Connect(function()
    if jumpActive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Landed or humanoid:GetState() == Enum.HumanoidStateType.Running then
                jumpCount = 0
            end
            if jumpCount < maxJumps then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                jumpCount = jumpCount + 1
            end
        end
    end
end)


-- [ SECTION 3: SURVIVAL & MISC ]
CreateSection("🛡️ Survival & Misc")

local godModeActive = false
local godModeConnection
CreateToggle("God Mode (Auto Heal)", function(state)
    godModeActive = state
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    if godModeActive then
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not godModeActive or not char.Parent then return end
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    else
        if godModeConnection then godModeConnection:Disconnect() end
    end
end)

local espActive = false
local espObjects = {}
CreateToggle("ESP (Highlight)", function(state)
    espActive = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Colors.ButtonOff
                highlight.OutlineColor = Colors.Text
                table.insert(espObjects, highlight)
            end
        end
    else
        for _, highlight in pairs(espObjects) do
            if highlight then highlight:Destroy() end
        end
        espObjects = {}
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = currentWalkSpeed
    end
end)
