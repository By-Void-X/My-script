--[[
  FIXTURE_TEMPLATE: Roblox Mod Menu (Teleport List Added)
  Fitur: TP Player List, God Mode, Walk Speed, Noclip, Fly, Multiple Jump, ESP
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. SETUP UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "ModMenu_GUI"
ScreenGui.ResetOnSpawn = false

local OpenIcon = Instance.new("TextButton")
OpenIcon.Parent = ScreenGui
OpenIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenIcon.Position = UDim2.new(0, 10, 0, 10)
OpenIcon.Size = UDim2.new(0, 45, 0, 45)
OpenIcon.Font = Enum.Font.GothamBold
OpenIcon.Text = "M"
OpenIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenIcon.TextSize = 20
OpenIcon.Visible = false
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenIcon).Color = Color3.fromRGB(255, 255, 255)

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 60)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Mobile Mod Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 0)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Button.Size = UDim2.new(0, 220, 0, 35)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name .. " [OFF]"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)
    
    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            Button.Text = name .. " [ON]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            Button.Text = name .. " [OFF]"
        end
        callback(state)
    end)
end

local function CreateSlider(name, minVal, maxVal, defaultVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = ScrollingFrame
    SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SliderFrame.Size = UDim2.new(0, 220, 0, 50)
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 5)

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.Text = name .. ": " .. defaultVal
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 12

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Parent = SliderFrame
    SliderBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SliderBtn.Position = UDim2.new(0, 10, 0, 25)
    SliderBtn.Size = UDim2.new(0, 200, 0, 15)
    SliderBtn.Text = ""
    Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

    local isDragging = false
    local currentVal = defaultVal
    
    SliderBtn.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = false 
        end 
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local mouseX = UserInputService:GetMouseLocation().X
            local sliderX = SliderBtn.AbsolutePosition.X
            local sliderW = SliderBtn.AbsoluteSize.X
            
            local percent = math.clamp((mouseX - sliderX) / sliderW, 0, 1)
            currentVal = math.floor(percent * (maxVal - minVal)) + minVal
            SliderLabel.Text = name .. ": " .. currentVal
            callback(currentVal)
        end
    end)
end

-- ==========================================
-- 2. LOGIKA FITUR
-- ==========================================

-- A. TELEPORT PLAYER LIST
local TeleportFrame = Instance.new("Frame")
TeleportFrame.Parent = ScrollingFrame
TeleportFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TeleportFrame.Size = UDim2.new(0, 220, 0, 30)
Instance.new("UICorner", TeleportFrame).CornerRadius = UDim.new(0, 5)

local TeleportTitle = Instance.new("TextLabel")
TeleportTitle.Parent = TeleportFrame
TeleportTitle.BackgroundTransparency = 1
TeleportTitle.Size = UDim2.new(1, -40, 1, 0)
TeleportTitle.Font = Enum.Font.GothamBold
TeleportTitle.Text = "Teleport ke Pemain"
TeleportTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportTitle.TextSize = 12
TeleportTitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportTitle.Position = UDim2.new(0, 10, 0, 0)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Parent = TeleportFrame
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RefreshBtn.Size = UDim2.new(0, 30, 0, 20)
RefreshBtn.Position = UDim2.new(1, -35, 0, 5)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Text = "R"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 12
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 5)

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Parent = ScrollingFrame
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PlayerListFrame.Size = UDim2.new(0, 220, 0, 10)
PlayerListFrame.AutomaticSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 5)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = PlayerListFrame
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

local ListPadding = Instance.new("UIPadding")
ListPadding.Parent = PlayerListFrame
ListPadding.PaddingTop = UDim.new(0, 5)
ListPadding.PaddingBottom = UDim.new(0, 5)
ListPadding.PaddingLeft = UDim.new(0, 10)
ListPadding.PaddingRight = UDim.new(0, 10)

local function TeleportToPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            -- Teleport dengan jarak sedikit di belakang pemain target (agar tidak bertumpuk)
            myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end

local function RefreshPlayerList()
    PlayerListFrame:ClearAllChildren()
    local newLayout = Instance.new("UIListLayout")
    newLayout.Parent = PlayerListFrame
    newLayout.SortOrder = Enum.SortOrder.LayoutOrder
    newLayout.Padding = UDim.new(0, 5)
    
    local newPadding = Instance.new("UIPadding")
    newPadding.Parent = PlayerListFrame
    newPadding.PaddingTop = UDim.new(0, 5)
    newPadding.PaddingBottom = UDim.new(0, 5)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Parent = PlayerListFrame
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.Font = Enum.Font.Gotham
            pBtn.Text = "TP: " .. p.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 12
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)
            
            pBtn.MouseButton1Click:Connect(function()
                TeleportToPlayer(p.Name)
            end)
        end
    end
end

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
task.spawn(RefreshPlayerList) -- Panggil saat script dimuat

-- B. GOD MODE (Auto Heal)
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

-- C. WALK SPEED (Kecepatan Jalan)
local currentWalkSpeed = 16
CreateSlider("Walk Speed", 16, 200, 16, function(val)
    currentWalkSpeed = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = currentWalkSpeed
    end
end)

-- D. TRUE NOCLIP (Anti-Stuck)
local wallHackActive = false
local noclipConnection

CreateToggle("True Noclip (Normal Speed)", function(state)
    wallHackActive = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    if wallHackActive then
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not wallHackActive or not char.Parent then return end
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanQuery = false 
                end
            end
            
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local velocity = hrp.AssemblyLinearVelocity
                local horizVel = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
                local threshold = currentWalkSpeed * 0.5
                
                if horizVel < threshold then
                    hrp.CFrame = hrp.CFrame + (moveDir * 1.5)
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end)

-- E. FLY SPEED (Slider & Kontrol)
local flyActive = false
local flyConnection
local bodyVelocity
local flySpeed = 50

CreateSlider("Fly Speed", 10, 160, 50, function(val)
    flySpeed = val
end)

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

-- F. MULTIPLE JUMP
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

-- G. ESP (Highlight Player)
local espActive = false
local espObjects = {}

CreateToggle("ESP (Highlight)", function(state)
    espActive = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
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
