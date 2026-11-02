--[[
  FIXTURE_TEMPLATE: Roblox Mod Menu (Fixed Jump & ESP)
  Fitur: Draggable UI, TP, Speed, Noclip (Gravity Lock), Fly, Dual ESP
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. SETUP UI
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

local ResizeGrip = Instance.new("TextButton")
ResizeGrip.Parent = MainFrame
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.Size = UDim2.new(0, 30, 0, 30)
ResizeGrip.Position = UDim2.new(1, -30, 1, -30)
ResizeGrip.Font = Enum.Font.GothamBold
ResizeGrip.Text = "◢"
ResizeGrip.TextColor3 = Colors.Accent
ResizeGrip.TextSize = 24
ResizeGrip.ZIndex = 2

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenIcon.Visible = true
end)

-- Logika Geser Ikon Bulat
local iconDragging = false
local iconDragStart, iconStartPos
local iconMoved = false
OpenIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconMoved = false
        iconDragStart = input.Position
        iconStartPos = OpenIcon.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                iconDragging = false 
                if not iconMoved then
                    MainFrame.Visible = true
                    OpenIcon.Visible = false
                end
            end
        end)
    end
end)
OpenIcon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if iconDragging then
            local delta = input.Position - iconDragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                iconMoved = true
            end
            if iconMoved then
                OpenIcon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
            end
        end
    end
end)

-- Logika Geser Menu
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

-- Logika Resize Menu
local resizing = false
local resizeStart, resizeStartSize
ResizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        resizeStartSize = MainFrame.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizing = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local newWidth = math.clamp(resizeStartSize.X + delta.X, 250, 500)
        local newHeight = math.clamp(resizeStartSize.Y + delta.Y, 300, 600)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
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
    SectionFrame.Size = UDim2.new(0, 220, 0, 20)
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
    Button.Size = UDim2.new(0, 220, 0, 35)
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
    SliderContainer.Size = UDim2.new(0, 220, 0, 50)
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
    SliderBar.Size = UDim2.new(0, 200, 0, 10)
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
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end 
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

CreateSection("👤 Teleport Pemain")
local TPDropdownBtn = Instance.new("TextButton")
TPDropdownBtn.Parent = ScrollingFrame
TPDropdownBtn.BackgroundColor3 = Colors.Section
TPDropdownBtn.Size = UDim2.new(0, 220, 0, 35)
TPDropdownBtn.Font = Enum.Font.GothamSemibold
TPDropdownBtn.Text = "Buka List Pemain [▼]"
TPDropdownBtn.TextColor3 = Colors.Text
TPDropdownBtn.TextSize = 13
Instance.new("UICorner", TPDropdownBtn).CornerRadius = UDim.new(0, 6)

local PlayerListContainer = Instance.new("Frame")
PlayerListContainer.Parent = ScrollingFrame
PlayerListContainer.BackgroundColor3 = Colors.Section
PlayerListContainer.Size = UDim2.new(0, 220, 0, 0)
PlayerListContainer.ClipsDescendants = true
Instance.new("UICorner", PlayerListContainer).CornerRadius = UDim.new(0, 6)

local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Parent = PlayerListContainer
ListScroll.BackgroundTransparency = 1
ListScroll.Size = UDim2.new(1, 0, 1, 0)
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListScroll.ScrollBarThickness = 3

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ListScroll
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)

local ListPadding = Instance.new("UIPadding")
ListPadding.Parent = ListScroll
ListPadding.PaddingTop = UDim.new(0, 5)
ListPadding.PaddingBottom = UDim.new(0, 5)

local isDropdownOpen = false
TPDropdownBtn.MouseButton1Click:Connect(function()
    isDropdownOpen = not isDropdownOpen
    if isDropdownOpen then
        TPDropdownBtn.Text = "Tutup List Pemain [▲]"
        TweenService:Create(PlayerListContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 220, 0, 150)}):Play()
    else
        TPDropdownBtn.Text = "Buka List Pemain [▼]"
        TweenService:Create(PlayerListContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 220, 0, 0)}):Play()
    end
end)

local function RefreshPlayerList()
    ListScroll:ClearAllChildren()
    local newLayout = Instance.new("UIListLayout")
    newLayout.Parent = ListScroll
    newLayout.SortOrder = Enum.SortOrder.LayoutOrder
    newLayout.Padding = UDim.new(0, 4)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Parent = ListScroll
            pBtn.BackgroundColor3 = Colors.SliderBg
            pBtn.Size = UDim2.new(1, -10, 0, 30)
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

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
task.spawn(RefreshPlayerList)


CreateSection("🏃 Movement")
local currentWalkSpeed = 16
CreateSlider("Walk Speed", 16, 200, 16, function(val)
    currentWalkSpeed = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end)

local noclipSpeed = 2
CreateSlider("Noclip Push Speed", 1, 5, 2, function(val)
    noclipSpeed = val
end)

local wallHackActive = false
local noclipConnection
CreateToggle("Super Noclip (Brookhaven Bypass)", function(state)
    wallHackActive = state
    local char = LocalPlayer.Character
    if not char then return end

    if wallHackActive then
        noclipConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if not wallHackActive then return end
            local myChar = LocalPlayer.Character
            if myChar then
                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                local humanoid = myChar:FindFirstChild("Humanoid")
                if hrp and humanoid then
                    for _, part in pairs(myChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.CanQuery = false
                            part.CanTouch = false
                        end
                    end
                    local moveDir = humanoid.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local speed = currentWalkSpeed * deltaTime
                        hrp.CFrame = hrp.CFrame + (moveDir * speed)
                    end
                    
                    -- Gravity Lock (Mencegah TP keluar di Brookhaven saat tidak melompat)
                    -- Jika karakter tidak melompat, tarik sedikit ke bawah agar dianggap menapak tanah
                    if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, -15, hrp.Velocity.Z)
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        local myChar = LocalPlayer.Character
        if myChar then
            for _, part in pairs(myChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CanQuery = true
                    part.CanTouch = true
                end
            end
        end
    end
end)

-- Lompat sudah dikembalikan (tidak diblokir)

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

-- ==========================================
-- 3. FITUR DUAL ESP (CLEAN VERSION)
-- ==========================================
CreateSection("👁️ ESP System (2 Types)")

local espHighlightActive = false
local espHighlights = {}
local function UpdateESPHighlight()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not espHighlights[player] then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Colors.ButtonOn
                highlight.OutlineColor = Colors.Text
                highlight.FillTransparency = 0.5
                espHighlights[player] = highlight
            end
        end
    end
end

CreateToggle("ESP Highlight (Growing)", function(state)
    espHighlightActive = state
    if state then
        UpdateESPHighlight()
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                if espHighlightActive then UpdateESPHighlight() end
            end)
        end)
    else
        for _, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
        end
        espHighlights = {}
    end
end)

local espBoxActive = false
local espDrawings = {}

CreateToggle("ESP Box (Line, Text, Health)", function(state)
    espBoxActive = state
    if not state then
        for player, d in pairs(espDrawings) do
            if d then
                for _, obj in pairs(d) do
                    if obj then 
                        pcall(function()
                            obj.Visible = false
                            obj:Remove() 
                        end)
                    end
                end
            end
        end
        espDrawings = {}
    end
end)

RunService.RenderStepped:Connect(function()
    if not espBoxActive or not Drawing then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local rootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            local humanoid = char:FindFirstChild("Humanoid")
            
            if rootPart and humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    if not espDrawings[player] then
                        espDrawings[player] = {
                            Box = Drawing.new("Square"),
                            Name = Drawing.new("Text"),
                            Health = Drawing.new("Text"),
                            Distance = Drawing.new("Text"),
                            Tracer = Drawing.new("Line")
                        }
                        local d = espDrawings[player]
                        d.Box.Thickness = 1
                        d.Box.Color = Color3.fromRGB(255, 0, 0)
                        d.Box.Filled = false
                        d.Name.Size = 14
                        d.Name.Center = true
                        d.Name.Outline = true
                        d.Name.Color = Color3.fromRGB(255, 255, 255)
                        d.Health.Size = 12
                        d.Health.Center = true
                        d.Health.Outline = true
                        d.Distance.Size = 12
                        d.Distance.Center = true
                        d.Distance.Outline = true
                        d.Distance.Color = Color3.fromRGB(200, 200, 200)
                        d.Tracer.Thickness = 1
                        d.Tracer.Color = Color3.fromRGB(255, 255, 255)
                    end
                    
                    local d = espDrawings[player]
                    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (Camera.CFrame.Position - rootPart.Position).Magnitude or 0
                    local scale = math.clamp(1000 / distance, 20, 200)
                    local height = scale
                    local width = scale / 2
                    local x = pos.X - (width / 2)
                    local y = pos.Y - (height / 2)
                    
                    d.Box.Size = Vector2.new(width, height)
                    d.Box.Position = Vector2.new(x, y)
                    d.Box.Visible = true
                    
                    d.Name.Text = player.Name
                    d.Name.Position = Vector2.new(pos.X, y - 16)
                    d.Name.Visible = true
                    
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    d.Health.Text = "HP: " .. healthPercent .. "%"
                    d.Health.Position = Vector2.new(pos.X, y + height + 2)
                    d.Health.Color = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
                    d.Health.Visible = true
                    
                    d.Distance.Text = "[" .. math.floor(distance) .. "m]"
                    d.Distance.Position = Vector2.new(pos.X, y + height + 16)
                    d.Distance.Visible = true
                    
                    d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    d.Tracer.To = Vector2.new(pos.X, pos.Y)
                    d.Tracer.Visible = true
                    
                else
                    if espDrawings[player] then
                        for _, obj in pairs(espDrawings[player]) do
                            obj.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espDrawings[player] then
        for _, obj in pairs(espDrawings[player]) do
            if obj then 
                pcall(function()
                    obj.Visible = false
                    obj:Remove() 
                end)
            end
        end
        espDrawings[player] = nil
    end
    if espHighlights[player] then
        if espHighlights[player] then espHighlights[player]:Destroy() end
        espHighlights[player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = currentWalkSpeed
    end
end)
