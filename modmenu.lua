--========================================
-- BYVOID MOD MENU V1
-- Roblox Studio - LocalScript
--========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
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

local ESPObjects = {}
local OriginalCollision = {}

--========================================
-- GUI
--========================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "ByVoidModMenu"
GUI.ResetOnSpawn = false
GUI.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(290, 440)
Main.Position = UDim2.new(0.5, -145, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(19, 22, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -45, 0, 45)
Header.Position = UDim2.fromOffset(12, 0)
Header.BackgroundTransparency = 1
Header.Text = "BYVOID  |  MOD MENU"
Header.TextColor3 = Color3.fromRGB(90, 255, 135)
Header.TextSize = 17
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 15
Close.Parent = Main

local Open = Instance.new("TextButton")
Open.Size = UDim2.fromOffset(105, 38)
Open.Position = UDim2.fromOffset(12, 120)
Open.Text = "BYVOID OPEN"
Open.TextColor3 = Color3.fromRGB(90, 255, 135)
Open.BackgroundColor3 = Color3.fromRGB(19, 22, 20)
Open.Font = Enum.Font.GothamBold
Open.TextSize = 13
Open.Visible = false
Open.Parent = GUI

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Open.Visible = true
end)

Open.MouseButton1Click:Connect(function()
    Main.Visible = true
    Open.Visible = false
end)

--========================================
-- SCROLL MENU
--========================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -60)
Scroll.Position = UDim2.fromOffset(8, 52)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new()
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.Parent = Scroll

local function Section(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -5, 0, 28)
    Label.BackgroundTransparency = 1
    Label.Text = "  " .. text
    Label.TextColor3 = Color3.fromRGB(90, 255, 135)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Scroll
end

local function Button(text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -5, 0, 36)
    B.BackgroundColor3 = Color3.fromRGB(38, 43, 39)
    B.TextColor3 = Color3.new(1, 1, 1)
    B.TextSize = 13
    B.Font = Enum.Font.Gotham
    B.Text = text
    B.Parent = Scroll

    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 5)

    B.MouseButton1Click:Connect(callback)
    return B
end

local function Input(title, default, callback)
    local B = Instance.new("TextBox")
    B.Size = UDim2.new(1, -5, 0, 36)
    B.BackgroundColor3 = Color3.fromRGB(38, 43, 39)
    B.TextColor3 = Color3.new(1, 1, 1)
    B.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    B.TextSize = 13
    B.Font = Enum.Font.Gotham
    B.Text = tostring(default)
    B.PlaceholderText = title
    B.ClearTextOnFocus = false
    B.Parent = Scroll

    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 5)

    B.FocusLost:Connect(function()
        local value = tonumber(B.Text)
        if value then
            callback(value)
        else
            B.Text = tostring(default)
        end
    end)

    return B
end

local function Toggle(title, key)
    Button(title .. " : OFF", function()
        Settings[key] = not Settings[key]
    end).MouseButton1Click:Connect(function()
        -- Status diperbarui oleh tombol berikutnya.
    end)

    local B = Scroll:GetChildren()[#Scroll:GetChildren()]

    -- Tombol toggle dengan status
    local target = B
    target.MouseButton1Click:Connect(function()
        target.Text = title .. (Settings[key] and " : ON" or " : OFF")
    end)
end

--========================================
-- MULTIPLE JUMP
--========================================

Section("MOVEMENT")

local JumpButton = Button("MULTIPLE JUMP : OFF", function()
    Settings.MultiJump = not Settings.MultiJump
    JumpButton.Text = "MULTIPLE JUMP : " ..
        (Settings.MultiJump and "ON" or "OFF")
end)

Input("Maximum Jump", 3, function(v)
    Settings.MaxJump = math.clamp(math.floor(v), 1, 20)
end)

UIS.JumpRequest:Connect(function()
    if not Settings.MultiJump then return end

    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum and Settings.JumpCount < Settings.MaxJump then
        Settings.JumpCount += 1
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function ResetJump()
    Settings.JumpCount = 0
end

local function CharacterSetup(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Landed then
            ResetJump()
        end
    end)
end

if Player.Character then
    CharacterSetup(Player.Character)
end

Player.CharacterAdded:Connect(CharacterSetup)

--========================================
-- PLAYER SPEED
--========================================

Input("Player Speed (16 = normal)", 16, function(v)
    Settings.WalkSpeed = math.clamp(v, 0, 200)

    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

--========================================
-- FLY
--========================================

Section("FLY SYSTEM")

local FlyButton = Button("FLY : OFF", function()
    Settings.Fly = not Settings.Fly
    FlyButton.Text = "FLY : " .. (Settings.Fly and "ON" or "OFF")
end)

Input("Fly Speed", 50, function(v)
    Settings.FlySpeed = math.clamp(v, 1, 200)
end)

local UpButton = Button("FLY UP : OFF", function()
    Settings.FlyUp = not Settings.FlyUp
    UpButton.Text = "FLY UP : " .. (Settings.FlyUp and "ON" or "OFF")
end)

local DownButton = Button("FLY DOWN : OFF", function()
    Settings.FlyDown = not Settings.FlyDown
    DownButton.Text = "FLY DOWN : " .. (Settings.FlyDown and "ON" or "OFF")
end)

--========================================
-- NOCLIP
--========================================

Section("NOCLIP")

local NoclipButton = Button("NOCLIP : OFF", function()
    Settings.Noclip = not Settings.Noclip
    NoclipButton.Text = "NOCLIP : " ..
        (Settings.Noclip and "ON" or "OFF")
end)

--========================================
-- ESP
--========================================

Section("PLAYER ESP")

local function ESPButton(title, key)
    local B
    B = Button(title .. " : OFF", function()
        Settings[key] = not Settings[key]
        B.Text = title .. " : " ..
            (Settings[key] and "ON" or "OFF")
    end)
end

ESPButton("GLOW / HIGHLIGHT", "Glow")
ESPButton("ESP LINE", "ESPLine")
ESPButton("ESP BOX", "ESPBox")
ESPButton("ESP NAME", "ESPName")

--========================================
-- PLAYER TELEPORT
--========================================

Section("PLAYER TELEPORT")

local SelectedPlayer = nil

local PlayerList = Instance.new("Frame")
PlayerList.Size = UDim2.new(1, -5, 0, 110)
PlayerList.BackgroundColor3 = Color3.fromRGB(29, 33, 30)
PlayerList.Parent = Scroll

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
            local B = Instance.new("TextButton")
            B.Size = UDim2.new(1, -5, 0, 30)
            B.BackgroundColor3 = Color3.fromRGB(45, 52, 46)
            B.TextColor3 = Color3.new(1, 1, 1)
            B.TextSize = 12
            B.Text = target.DisplayName .. " (@" .. target.Name .. ")"
            B.Parent = PlayerList

            B.MouseButton1Click:Connect(function()
                SelectedPlayer = target
                B.Text = "SELECTED: " .. target.Name
            end)
        end
    end

    PlayerList.AutomaticSize = Enum.AutomaticSize.Y
end

Button("REFRESH PLAYER LIST", RefreshPlayers)

Button("TELEPORT TO SELECTED PLAYER", function()
    if not SelectedPlayer then return end

    local char = Player.Character
    local target = SelectedPlayer.Character

    local root = char and char:FindFirstChild("HumanoidRootPart")
    local targetRoot = target and target:FindFirstChild("HumanoidRootPart")

    if root and targetRoot then
        char:PivotTo(targetRoot.CFrame * CFrame.new(3, 0, 0))
    end
end)

RefreshPlayers()

Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(function(target)
    if SelectedPlayer == target then
        SelectedPlayer = nil
    end
    RefreshPlayers()
end)

--========================================
-- MOVEMENT UPDATE
--========================================

local FlyVelocity
local FlyGyro

RunService.RenderStepped:Connect(function()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not root or not hum then return end

    if Settings.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCollision[part] == nil then
                    OriginalCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, value in pairs(OriginalCollision) do
            if part and part.Parent then
                part.CanCollide = value
            end
        end
        table.clear(OriginalCollision)
    end

    if Settings.Fly then
        if not FlyVelocity then
            FlyVelocity = Instance.new("BodyVelocity")
            FlyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            FlyVelocity.Parent = root

            FlyGyro = Instance.new("BodyGyro")
            FlyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            FlyGyro.P = 10000
            FlyGyro.Parent = root
        end

        local move = hum.MoveDirection
        local vertical = 0

        if Settings.FlyUp then vertical += 1 end
        if Settings.FlyDown then vertical -= 1 end

        FlyVelocity.Velocity =
            move * Settings.FlySpeed +
            Vector3.new(0, vertical * Settings.FlySpeed, 0)

        FlyGyro.CFrame = Camera.CFrame
    else
        if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
        if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
    end
end)

--========================================
-- ESP RENDER
--========================================

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ByVoidESP"
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = Player:WaitForChild("PlayerGui")

local function CreateESP(target)
    if ESPObjects[target] then return end

    local folder = Instance.new("Folder")
    folder.Parent = ESPGui

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(90, 255, 135)
    box.Visible = false
    box.Parent = folder

    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(90, 255, 135)
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = folder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(90, 255, 135)
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.Visible = false
    label.Parent = folder

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(70, 255, 120)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Enabled = false
    highlight.Parent = workspace

    ESPObjects[target] = {
        Folder = folder,
        Box = box,
        Line = line,
        Label = label,
        Highlight = highlight
    }
end

local function RemoveESP(target)
    local data = ESPObjects[target]
    if data then
        data.Folder:Destroy()
        data.Highlight:Destroy()
        ESPObjects[target] = nil
    end
end

RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= Player then
            CreateESP(target)

            local data = ESPObjects[target]
            local char = target.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            data.Highlight.Enabled = Settings.Glow and char ~= nil
            data.Highlight.Adornee = char

            if root then
                local pos, visible = Camera:WorldToViewportPoint(root.Position)

                data.Box.Visible = Settings.ESPBox and visible
                data.Line.Visible = Settings.ESPLine and visible
                data.Label.Visible = Settings.ESPName and visible

                if visible then
                    local _, size = char:GetBoundingBox()
                    local height = size.Y * viewport.Y / (pos.Z * 1.5)
                    local width = size.X * viewport.X / (pos.Z * 1.5)

                    data.Box.Position = UDim2.fromOffset(
                        pos.X - width / 2,
                        pos.Y - height / 2
                    )
                    data.Box.Size = UDim2.fromOffset(width, height)

                    local origin = Vector2.new(viewport.X / 2, 0)
                    local destination = Vector2.new(pos.X, pos.Y)
                    local delta = destination - origin

                    data.Line.Position = UDim2.fromOffset(
                        origin.X,
                        origin.Y
                    )
                    data.Line.Size = UDim2.fromOffset(
                        2,
                        delta.Magnitude
                    )
                    data.Line.Rotation =
                        math.deg(math.atan2(delta.Y, delta.X)) - 90

                    local distance = math.floor(
                        (root.Position -
                        Camera.CFrame.Position).Magnitude
                    )

                    data.Label.Text = target.Name .. " | " ..
                        distance .. " studs"

                    data.Label.Position = UDim2.fromOffset(
                        pos.X - 90,
                        pos.Y - height / 2 - 22
                    )
                    data.Label.Size = UDim2.fromOffset(180, 20)
                end
            else
                data.Box.Visible = false
                data.Line.Visible = false
                data.Label.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

print("ByVoid Mod Menu loaded successfully")
