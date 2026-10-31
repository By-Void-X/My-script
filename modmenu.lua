--[[
  FIXTURE_TEMPLATE: Roblox Mod Menu (True Noclip)
  Fitur: True Noclip (Tembus Semua), Fly Speed Slider, Multiple Jump, ESP
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

-- ==========================================
-- 2. LOGIKA FITUR
-- ==========================================

-- A. TRUE NOCLIP (Tembus Semua Block & Pembatas)
local wallHackActive = false
CreateToggle("True Noclip (All Blocks)", function(state)
    wallHackActive = state
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end)

-- Loop untuk memaksa tembus (termasuk Anchor/Visual Block)
RunService.Stepped:Connect(function()
    if wallHackActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if wallHackActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- B. FLY SPEED (Slider & Kontrol)
local flyActive = false
local flyConnection
local bodyVelocity
local flySpeed = 50

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
SliderLabel.Text = "Fly Speed: " .. flySpeed
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
        flySpeed = math.floor(percent * 150) + 10
        SliderLabel.Text = "Fly Speed: " .. flySpeed
    end
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

-- C. MULTIPLE JUMP (Tidak diubah)
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

-- D. ESP (Highlight Player)
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
