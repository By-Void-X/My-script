--[[
  FIXTURE_TEMPLATE: Roblox Mod Menu (GUI)
  Fitur: Fly, Wall Hack, Multiple Jumps, ESP
  Environment: Client-Side Executor (Delta/Codex)
]]

-- ==========================================
-- 1. SETUP UI (User Interface)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "ModMenu_GUI"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 10)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Mod Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Center

local TitleCorner = Instance.new("UICorner")
TitleCorner.Parent = Title
TitleCorner.CornerRadius = UDim.new(0, 10)

ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fungsi Pembuat Tombol
local function CreateToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah (Mati)
    Button.Size = UDim2.new(0, 220, 0, 35)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name .. " [OFF]"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.Parent = Button
    
    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Hijau (Nyala)
            Button.Text = name .. " [ON]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah (Mati)
            Button.Text = name .. " [OFF]"
        end
        callback(state)
    end)
end

-- ==========================================
-- 2. LOGIKA FITUR
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- A. WALL HACK (X-Ray)
CreateToggle("Wall Hack", function(state)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            if obj.Name == "Terrain" then continue end
            if state then
                obj.LocalTransparencyModifier = 0.5
            else
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end)

-- B. MULTIPLE JUMPS
local jumpCount = 0
local maxJumps = 10
local isMultipleJumpOn = false

CreateToggle("Multiple Jumps", function(state)
    isMultipleJumpOn = state
    if not state then jumpCount = 0 end
end)

UserInputService.JumpRequest:Connect(function()
    if isMultipleJumpOn then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                jumpCount = 0
            end
            
            if jumpCount < maxJumps then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                jumpCount = jumpCount + 1
            end
        end
    end
end)

-- C. FLY (Superman & Hold)
local flyActive = false
local flyMode = "Superman" -- Opsi: "Superman", "Hold", "HoldV2"
local flySpeed = 50
local flyConnection
local bodyVelocity

CreateToggle("Fly (Superman)", function(state)
    flyMode = "Superman"
    flyActive = state
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if flyActive and hrp then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = hrp
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        
        local camera = workspace.CurrentCamera
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyActive then return end
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            
            bodyVelocity.Velocity = moveDir * flySpeed
        end)
    end
end)

CreateToggle("Fly (Hold / HoldV2)", function(state)
    flyMode = "HoldV2"
    flyActive = state
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if flyActive and hrp then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = hrp
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyActive then return end
            -- Logika Hold (bergerak naik saat tahan spasi / layar)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService.TouchEnabled then
                bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end
end)

-- D. ESP (Highlight Player)
local espActive = false
local espObjects = {}

local function ToggleESP(state)
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
end

CreateToggle("ESP (Player Highlight)", function(state)
    ToggleESP(state)
end)

-- Tambahan: ESP untuk player yang baru join
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if espActive then
            local highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            table.insert(espObjects, highlight)
        end
    end)
end)
