--[[
  FIXTURE_TEMPLATE: Roblox Mod Menu (Mobile Optimized)
  Fitur: Wall Hack (Tembus), Fly Kamera, Fly Hold, Multiple Jump, ESP
  Environment: Client-Side Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. SETUP UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ToggleBtn = Instance.new("TextButton") -- Tombol buka/tutup menu

-- Tombol Kecil untuk buka menu (biar gak makan layar)
ToggleBtn.Parent = game:GetService("CoreGui")
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "ModMenu_GUI"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175) -- Posisi di tengah
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Mobile Mod Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

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

-- Fungsi Toggle Menu
local menuOpen = true
ToggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
end)

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
-- 2. LOGIKA FITUR (MOBILE OPTIMIZED)
-- ==========================================

-- A. WALL HACK (Tembus Dinding)
local wallHackActive = false
CreateToggle("Wall Hack (Tembus)", function(state)
    wallHackActive = state
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state -- Jika ON, tabrakan dimatikan
            end
        end
    end
end)
-- Update saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if wallHackActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- B. FLY (Bisa dikontrol di HP dengan menggeser layar / kamera)
local flyActive = false
local flyConnection
local flySpeed = 2

CreateToggle("Fly (Geser Kamera)", function(state)
    flyActive = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyActive then
        local camera = workspace.CurrentCamera
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyActive or not hrp.Parent then return end
            -- Terbang mengikuti arah kamera secara perlahan
            local moveDir = camera.CFrame.LookVector
            hrp.CFrame = hrp.CFrame + (moveDir * flySpeed)
            
            -- Opsional: Kalau layar disentuh, naik ke atas
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, flySpeed, 0)
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
    end
end)

-- C. MULTIPLE JUMP (Spam Lompat di Udara)
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
            -- Reset hitungan jika menyentuh tanah
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

-- D. FLY HOLD (Tahan Tombol Layar / Spasi untuk Naik)
local holdActive = false
local holdConnection
local holdSpeed = 0.5

CreateToggle("Fly Hold (Naik)", function(state)
    holdActive = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if holdActive then
        holdConnection = RunService.Heartbeat:Connect(function()
            if not holdActive or not hrp.Parent then return end
            -- Jika layar disentuh atau spasi ditekan, karakter naik
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, holdSpeed, 0)
            end
        end)
    else
        if holdConnection then holdConnection:Disconnect() end
    end
end)

-- E. ESP (Highlight Player)
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
