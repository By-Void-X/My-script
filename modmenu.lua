
--==================================================
-- BYVOID MOD MENU V2
-- Roblox Studio | LocalScript
-- Mobile + PC
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    MultiJump = false,
    MaxJump = 3,
    JumpCount = 0,

    Fly = false,
    FlySpeed = 50,
    FlyUp = false,
    FlyDown = false,

    WalkSpeed = 16,
    Noclip = false,

    Glow = false,
    ESPLine = false,
    ESPBox = false,
    ESPName = false
}

local SelectedPlayer = nil
local ESPData = {}
local OriginalCollision = {}

local GREEN = Color3.fromRGB(100, 230, 130)
local PANEL = Color3.fromRGB(25, 29, 26)
local BUTTON = Color3.fromRGB(43, 49, 44)
local WHITE = Color3.fromRGB(245, 245, 245)

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "ByVoidModMenu"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 440)
Main.Position = UDim2.new(0.5, -150, 0.5, -220)
Main.BackgroundColor3 = PANEL
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 7)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(32, 39, 33)
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "BYVOID  /  MOD MENU"
Title.TextColor3 = GREEN
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(130, 50, 50)
Close.Text = "X"
Close.TextColor3 = WHITE
Close.Font = Enum.Font.GothamBold
Close.TextSize = 15
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)

local Open = Instance.new("TextButton")
Open.Size = UDim2.fromOffset(115, 38)
Open.Position = UDim2.new(0, 12, 0.5, -19)
Open.BackgroundColor3 = PANEL
Open.Text = "BYVOID  +"
Open.TextColor3 = GREEN
Open.Font = Enum.Font.GothamBold
Open.TextSize = 13
Open.Visible = false
Open.Parent = GUI

Instance.new("UICorner", Open).CornerRadius = UDim.new(0, 5)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Open.Visible = true
end)

Open.MouseButton1Click:Connect(function()
    Main.Visible = true
    Open.Visible = false
end)

--==================================================
-- DRAG SUPPORT
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--==================================================
-- SCROLL MENU
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Position = UDim2.fromOffset(8, 53)
Scroll.Size = UDim2.new(1, -16, 1, -61)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = GREEN
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new()
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local function Section(name)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = GREEN
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = Scroll
    return label
end

local function MakeButton(name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 36)
    button.BackgroundColor3 = BUTTON
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = WHITE
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = true
    button.Parent = Scroll

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 5)

    button.MouseButton1Click:Connect(callback)
    return button
end

local function MakeInput(name, default, callback)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -4, 0, 36)
    input.BackgroundColor3 = BUTTON
    input.BorderSizePixel = 0
    input.Text = tostring(default)
    input.PlaceholderText = name
    input.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    input.TextColor3 = WHITE
    input.TextSize = 12
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = Scroll

    Instance.new("UICorner", input).CornerRadius =
        UDim.new(0, 5)

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)

        if value then
            callback(value)
        else
            input.Text = tostring(default)
        end
    end)

    return input
end

local function MakeToggle(name, key, callback)
    local button

    button = MakeButton(name .. " : OFF", function()
        Config[key] = not Config[key]

        button.Text = name .. " : " ..
            (Config[key] and "ON" or "OFF")

        if callback then
            callback(Config[key])
        end
    end)

    return button
end

--==================================================
-- MOVEMENT
--==================================================

Section("MOVEMENT")

MakeToggle("MULTIPLE JUMP", "MultiJump")

MakeInput("Maximum Jump", Config.MaxJump, function(value)
    Config.MaxJump = math.clamp(math.floor(value), 1, 20)
    Config.JumpCount = 0
end)

MakeInput("Player Speed", Config.WalkSpeed, function(value)
    Config.WalkSpeed = math.clamp(value, 0, 200)

    local character = Player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

--==================================================
-- MULTIPLE JUMP
--==================================================

UIS.JumpRequest:Connect(function()
    if not Config.MultiJump then return end

    local character = Player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then return end

    if Config.JumpCount < Config.MaxJump then
        Config.JumpCount += 1
        humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

local function SetupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")

    Config.JumpCount = 0
    humanoid.WalkSpeed = Config.WalkSpeed

    humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Landed then
            Config.JumpCount = 0
        end
    end)
end

if Player.Character then
    task.spawn(SetupCharacter, Player.Character)
end

Player.CharacterAdded:Connect(SetupCharacter)

--==================================================
-- FLY
--==================================================

Section("FLY SYSTEM")

local FlyButton = MakeToggle("FLY", "Fly")

MakeInput("Fly Speed", Config.FlySpeed, function(value)
    Config.FlySpeed = math.clamp(value, 1, 200)
end)

local UpButton = MakeToggle("FLY UP", "FlyUp")
local DownButton = MakeToggle("FLY DOWN", "FlyDown")

-- Tombol keyboard:
-- Space = naik
-- LeftControl = turun

local function UpdateKeyboardFly(input, state)
    if input.KeyCode == Enum.KeyCode.Space then
        Config.FlyUp = state
        UpButton.Text = "FLY UP : " .. (state and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        Config.FlyDown = state
        DownButton.Text = "FLY DOWN : " .. (state and "ON" or "OFF")
    end
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    UpdateKeyboardFly(input, true)
end)

UIS.InputEnded:Connect(function(input)
    UpdateKeyboardFly(input, false)
end)

local flyVelocity
local flyGyro
local flyAttachment

local function StopFly()
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end
end

local function StartFly(root)
    flyAttachment = Instance.new("Attachment")
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.MaxForce = 1000000
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("AlignOrientation")
    flyGyro.Attachment0 = flyAttachment
    flyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyGyro.MaxTorque = 1000000
    flyGyro.Responsiveness = 15
    flyGyro.Parent = root
end

--==================================================
-- NOCLIP
--==================================================

Section("NOCLIP")

MakeToggle("NOCLIP", "Noclip")

local function RestoreCollision()
    for part, oldValue in pairs(OriginalCollision) do
        if part and part.Parent then
            part.CanCollide = oldValue
        end
    end

    table.clear(OriginalCollision)
end

--==================================================
-- ESP
--==================================================

Section("PLAYER ESP")

MakeToggle("GLOW / HIGHLIGHT", "Glow")
MakeToggle("ESP LINE", "ESPLine")
MakeToggle("ESP BOX", "ESPBox")
MakeToggle("ESP NAME", "ESPName")

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ByVoidESP"
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = Player:WaitForChild("PlayerGui")

local function CreateESP(target)
    if ESPData[target] then return end

    local folder = Instance.new("Folder")
    folder.Parent = ESPGui

    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0)
    line.BackgroundColor3 = GREEN
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = folder

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = GREEN
    box.Visible = false
    box.Parent = folder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.TextColor3 = GREEN
    label.TextStrokeTransparency = 0
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Visible = false
    label.Parent = folder

    local highlight = Instance.new("Highlight")
    highlight.FillColor = GREEN
    highlight.OutlineColor = WHITE
    highlight.FillTransparency = 0.7
    highlight.Enabled = false
    highlight.Parent = workspace

    ESPData[target] = {
        Folder = folder,
        Line = line,
        Box = box,
        Label = label,
        Highlight = highlight
    }
end

local function RemoveESP(target)
    local data = ESPData[target]

    if data then
        data.Folder:Destroy()
        data.Highlight:Destroy()
        ESPData[target] = nil
    end
end

local function GetScreenBounds(character)
    local cf, size = character:GetBoundingBox()

    local corners = {}

    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local point = cf:PointToWorldSpace(
                    Vector3.new(
                        size.X * x / 2,
                        size.Y * y / 2,
                        size.Z * z / 2
                    )
                )

                local screen, visible =
                    Camera:WorldToViewportPoint(point)

                if screen.Z > 0 then
                    table.insert(corners, Vector2.new(
                        screen.X,
                        screen.Y
                    ))
                end
            end
        end
    end

    if #corners == 0 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge

    for _, point in ipairs(corners) do
        minX = math.min(minX, point.X)
        minY = math.min(minY, point.Y)
        maxX = math.max(maxX, point.X)
        maxY = math.max(maxY, point.Y)
    end

    return minX, minY, maxX, maxY
end

--==================================================
-- PLAYER LIST
--==================================================

Section("PLAYER TELEPORT")

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -4, 0, 115)
PlayerList.BackgroundColor3 = BUTTON
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 3
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.CanvasSize = UDim2.new()
PlayerList.Parent = Scroll

Instance.new("UICorner", PlayerList).CornerRadius =
    UDim.new(0, 5)

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Padding = UDim.new(0, 3)
PlayerLayout.Parent = PlayerList

local function RefreshPlayers()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= Player then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -6, 0, 30)
            button.BackgroundColor3 = Color3.fromRGB(54, 62, 55)
            button.BorderSizePixel = 0
            button.TextColor3 = WHITE
            button.TextSize = 11
            button.Font = Enum.Font.Gotham
            button.Text = target.DisplayName .. " (@" ..
                target.Name .. ")"
            button.Parent = PlayerList

            button.MouseButton1Click:Connect(function()
                SelectedPlayer = target

                for _, item in ipairs(PlayerList:GetChildren()) do
                    if item:IsA("TextButton") then
                        item.BackgroundColor3 =
                            Color3.fromRGB(54, 62, 55)
                    end
                end

                button.BackgroundColor3 =
                    Color3.fromRGB(48, 105, 60)
            end)
        end
    end
end

MakeButton("REFRESH PLAYER LIST", RefreshPlayers)

MakeButton("TELEPORT TO SELECTED", function()
    if not SelectedPlayer or
        not SelectedPlayer.Parent then return end

    local character = Player.Character
    local targetCharacter = SelectedPlayer.Character

    local root = character and
        character:FindFirstChild("HumanoidRootPart")

    local targetRoot = targetCharacter and
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if root and targetRoot then
        character:PivotTo(
            targetRoot.CFrame * CFrame.new(3, 0, 0)
        )
    end
end)

RefreshPlayers()

Players.PlayerAdded:Connect(RefreshPlayers)

Players.PlayerRemoving:Connect(function(target)
    RemoveESP(target)

    if SelectedPlayer == target then
        SelectedPlayer = nil
    end

    RefreshPlayers()
end)

--==================================================
-- MAIN UPDATE
--==================================================

RunService.Heartbeat:Connect(function()
    local character = Player.Character
    local root = character and
        character:FindFirstChild("HumanoidRootPart")

    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        StopFly()
        RestoreCollision()
        return
    end

    -- NOCLIP
    if Config.Noclip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCollision[part] == nil then
                    OriginalCollision[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end
    else
        RestoreCollision()
    end

    -- FLY
    if Config.Fly then
        if not flyVelocity then
            StartFly(root)
        end

        local direction = humanoid.MoveDirection
        local vertical = 0

        if Config.FlyUp then
            vertical += 1
        end

        if Config.FlyDown then
            vertical -= 1
        end

        flyVelocity.VectorVelocity =
            direction * Config.FlySpeed +
            Vector3.new(0, vertical * Config.FlySpeed, 0)

        flyGyro.CFrame = Camera.CFrame
    else
        StopFly()
    end
end)

--==================================================
-- ESP UPDATE
--==================================================

RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= Player then
            CreateESP(target)

            local data = ESPData[target]
            local character = target.Character
            local root = character and
                character:FindFirstChild("HumanoidRootPart")

            data.Highlight.Adornee = character
            data.Highlight.Enabled =
                Config.Glow and character ~= nil

            local bounds = character and GetScreenBounds(character)

            if root and bounds then
                local minX, minY, maxX, maxY = bounds

                local centerX = (minX + maxX) / 2
                local centerY = (minY + maxY) / 2

                local _, visible =
                    Camera:WorldToViewportPoint(root.Position)

                data.Box.Visible = Config.ESPBox and visible
                data.Line.Visible = Config.ESPLine and visible
                data.Label.Visible = Config.ESPName and visible

                if visible then
                    data.Box.Position = UDim2.fromOffset(minX, minY)
                    data.Box.Size = UDim2.fromOffset(
                        maxX - minX,
                        maxY - minY
                    )

                    local startPoint = Vector2.new(viewport.X / 2, 0)
                    local endPoint = Vector2.new(centerX, centerY)
                    local delta = endPoint - startPoint

                    data.Line.Position = UDim2.fromOffset(
                        startPoint.X,
                        startPoint.Y
                    )

                    data.Line.Size = UDim2.fromOffset(
                        2,
                        delta.Magnitude
                    )

                    data.Line.Rotation =
                        math.deg(math.atan2(delta.Y, delta.X)) - 90

                    local distance = math.floor(
                        (root.Position - Camera.CFrame.Position).Magnitude
                    )

                    data.Label.Text = target.Name ..
                        " | " .. distance .. " studs"

                    data.Label.Position = UDim2.fromOffset(
                        centerX - 90,
                        minY - 20
                    )

                    data.Label.Size = UDim2.fromOffset(180, 18)
                end
            else
                data.Box.Visible = false
                data.Line.Visible = false
                data.Label.Visible = false
            end
        end
    end
end)

print("ByVoid Mod Menu V2 Loaded")
