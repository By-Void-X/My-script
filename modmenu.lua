--[[
    roblox mod menu
    fitur: multi jump, fly (speed sendiri), speed player,
           esp (glow + line + box), wallhack, tp ke player
    executor: harus support Drawing API + loadstring
    ui: Rayfield
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- STATE
-- ============================================================
local State = {
    -- jump
    MultiJumpEnabled = false,
    JumpPower = 50,
    MaxJumps = 3,
    jumpCount = 0,
    canJump = false,

    -- fly
    FlyEnabled = false,
    FlySpeed = 100,
    flyConnection = nil,
    flyBodyVelocity = nil,
    flyBodyGyro = nil,

    -- speed
    SpeedEnabled = false,
    WalkSpeed = 50,
    defaultWalkSpeed = 16,

    -- esp
    EspEnabled = false,
    EspGlow = true,
    EspLine = true,
    EspBox = true,
    EspColor = Color3.fromRGB(0, 255, 100),
    espObjects = {}, -- [player] = { highlights = {}, drawings = {} }

    -- wallhack
    WallhackEnabled = false,
    wallhackHighlights = {},

    -- tp
    SelectedPlayer = nil,
}

-- ============================================================
-- UTILS
-- ============================================================
local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getHum()
    local char = getChar()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function notify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
    })
end

-- ============================================================
-- MULTI JUMP
-- ============================================================
local function resetJumpCount()
    State.jumpCount = 0
end

local function onJumpRequest()
    if not State.MultiJumpEnabled then return end
    local hum = getHum()
    if not hum or hum:GetState() == Enum.HumanoidStateType.Dead then return end
    if State.jumpCount < State.MaxJumps then
        State.jumpCount = State.jumpCount + 1
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function bindMultiJump()
    local hum = getHum()
    if not hum then return end
    hum.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Landed then
            resetJumpCount()
        end
    end)
end

UserInputService.JumpRequest:Connect(onJumpRequest)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    resetJumpCount()
    bindMultiJump()
end)

if getChar() then
    bindMultiJump()
end

-- ============================================================
-- FLY (dengan speed sendiri)
-- ============================================================
local function stopFly()
    if State.flyConnection then
        State.flyConnection:Disconnect()
        State.flyConnection = nil
    end
    if State.flyBodyVelocity then
        State.flyBodyVelocity:Destroy()
        State.flyBodyVelocity = nil
    end
    if State.flyBodyGyro then
        State.flyBodyGyro:Destroy()
        State.flyBodyGyro = nil
    end
    local hum = getHum()
    if hum then
        hum.PlatformStand = false
    end
    State.FlyEnabled = false
end

local function startFly()
    local char = getChar()
    local hrp = getHRP()
    local hum = getHum()
    if not char or not hrp or not hum then return end

    stopFly()
    State.FlyEnabled = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    State.flyBodyVelocity = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.Parent = hrp
    State.flyBodyGyro = bg

    hum.PlatformStand = true

    State.flyConnection = RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then return end
        local char2 = getChar()
        local hrp2 = getHRP()
        local hum2 = getHum()
        if not char2 or not hrp2 or not hum2 then
            stopFly()
            return
        end

        bg.CFrame = Camera.CFrame

        local moveDir = hum2.MoveDirection
        local velocity = Vector3.zero

        if moveDir.Magnitude > 0 then
            velocity = moveDir.Unit * State.FlySpeed
        end

        -- naik / turun pakai E / Q
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            velocity = velocity + Vector3.new(0, State.FlySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            velocity = velocity - Vector3.new(0, State.FlySpeed, 0)
        end

        bv.Velocity = velocity
    end)
end

local function toggleFly(enabled)
    if enabled then
        startFly()
    else
        stopFly()
    end
end

-- ============================================================
-- SPEED
-- ============================================================
local function applySpeed()
    local hum = getHum()
    if not hum then return end
    if State.SpeedEnabled then
        hum.WalkSpeed = State.WalkSpeed
    else
        hum.WalkSpeed = State.defaultWalkSpeed
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

-- ============================================================
-- ESP (GLOW + LINE + BOX)
-- ============================================================
local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    if State.espObjects[player] then return end

    local obj = {
        highlight = nil,
        tracer = nil,
        boxLines = {},
    }

    -- glow (Highlight)
    if State.EspGlow then
        local char = player.Character
        if char then
            local hl = Instance.new("Highlight")
            hl.Name = "OllieESP"
            hl.FillColor = State.EspColor
            hl.OutlineColor = State.EspColor
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
            obj.highlight = hl
        end
    end

    -- line + box pakai Drawing
    if State.EspLine then
        local line = Drawing.new("Line")
        line.Color = State.EspColor
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
        obj.tracer = line
    end

    if State.EspBox then
        for i = 1, 4 do
            local l = Drawing.new("Line")
            l.Color = State.EspColor
            l.Thickness = 1
            l.Transparency = 1
            l.Visible = false
            table.insert(obj.boxLines, l)
        end
    end

    State.espObjects[player] = obj
end

local function removeESPForPlayer(player)
    local obj = State.espObjects[player]
    if not obj then return end

    if obj.highlight then
        obj.highlight:Destroy()
    end
    if obj.tracer then
        obj.tracer:Remove()
    end
    for _, l in ipairs(obj.boxLines) do
        l:Remove()
    end

    State.espObjects[player] = nil
end

local function clearAllESP()
    for player, _ in pairs(State.espObjects) do
        removeESPForPlayer(player)
    end
    State.espObjects = {}
end

local function updateESP()
    if not State.EspEnabled then
        -- sembunyikan semua drawing kalau ESP off
        for _, obj in pairs(State.espObjects) do
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
        end
        return
    end

    for player, obj in pairs(State.espObjects) do
        local char = player.Character
        if not char then
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            continue
        end

        -- update glow color kalau berubah
        if obj.highlight then
            obj.highlight.FillColor = State.EspColor
            obj.highlight.OutlineColor = State.EspColor
            obj.highlight.Enabled = State.EspGlow
        end

        -- tracer dari bawah layar ke posisi player
        if obj.tracer then
            if State.EspLine then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    obj.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    obj.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    obj.tracer.Visible = true
                else
                    obj.tracer.Visible = false
                end
            else
                obj.tracer.Visible = false
            end
        end

        -- box 2D di sekitar player
        if #obj.boxLines == 4 then
            if State.EspBox then
                local rootPos = hrp.Position
                local topPos = rootPos + Vector3.new(0, 3, 0)
                local bottomPos = rootPos - Vector3.new(0, 3, 0)

                local topScreen, topOn = Camera:WorldToViewportPoint(topPos)
                local bottomScreen, bottomOn = Camera:WorldToViewportPoint(bottomPos)

                if topOn and bottomOn then
                    local height = math.abs(bottomScreen.Y - topScreen.Y)
                    local width = height * 0.6
                    local centerX = (topScreen.X + bottomScreen.X) / 2

                    local tl = Vector2.new(centerX - width/2, topScreen.Y)
                    local tr = Vector2.new(centerX + width/2, topScreen.Y)
                    local bl = Vector2.new(centerX - width/2, bottomScreen.Y)
                    local br = Vector2.new(centerX + width/2, bottomScreen.Y)

                    obj.boxLines[1].From = tl; obj.boxLines[1].To = tr; obj.boxLines[1].Visible = true
                    obj.boxLines[2].From = tr; obj.boxLines[2].To = br; obj.boxLines[2].Visible = true
                    obj.boxLines[3].From = br; obj.boxLines[3].To = bl; obj.boxLines[3].Visible = true
                    obj.boxLines[4].From = bl; obj.boxLines[4].To = tl; obj.boxLines[4].Visible = true

                    for _, l in ipairs(obj.boxLines) do
                        l.Color = State.EspColor
                    end
                else
                    for _, l in ipairs(obj.boxLines) do l.Visible = false end
                end
            else
                for _, l in ipairs(obj.boxLines) do l.Visible = false end
            end
        end
    end
end

-- pasang ESP ke semua player yang ada + yang join
local function setupPlayerESP(player)
    if player == LocalPlayer then return end
    createESPForPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        removeESPForPlayer(player)
        if State.EspEnabled then
            createESPForPlayer(player)
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    setupPlayerESP(p)
end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(function(p)
    removeESPForPlayer(p)
end)

RunService.RenderStepped:Connect(updateESP)

-- ============================================================
-- WALLHACK (nembus semua yang di depan)
-- ============================================================
local function applyWallhack()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end

        local existing = char:FindFirstChild("OllieWallhack")
        if existing then existing:Destroy() end

        if State.WallhackEnabled then
            local hl = Instance.new("Highlight")
            hl.Name = "OllieWallhack"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
            State.wallhackHighlights[player] = hl
        else
            State.wallhackHighlights[player] = nil
        end
    end
end

local function clearWallhack()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local hl = char:FindFirstChild("OllieWallhack")
            if hl then hl:Destroy() end
        end
    end
    State.wallhackHighlights = {}
end

-- ============================================================
-- TP KE PLAYER (dengan list nama)
-- ============================================================
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local function teleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if not target then return end
    local targetChar = target.Character
    if not targetChar then return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myHRP = getHRP()
    if not targetHRP or not myHRP then return end
    myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
end

-- ============================================================
-- UI (RAYFIELD)
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ollie — mod menu",
    LoadingTitle = "ollie: oli panas, sabar ya sayang...",
    LoadingSubtitle = "absolute ollie, built by olivia",
    ConfigurationSaving = {
        Enabled = false,
    },
    Keybind = Enum.KeyCode.RightShift,
})

-- TAB: MOVEMENT
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSection("Multi Jump")
MoveTab:CreateToggle({
    Name = "Enable Multi Jump",
    CurrentValue = false,
    Flag = "MultiJump",
    Callback = function(v)
        State.MultiJumpEnabled = v
        if not v then resetJumpCount() end
    end,
})
MoveTab:CreateSlider({
    Name = "Max Jumps",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 3,
    Flag = "MaxJumps",
    Callback = function(v)
        State.MaxJumps = v
    end,
})

MoveTab:CreateSection("Fly")
MoveTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v)
        toggleFly(v)
    end,
})
MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 10,
    Suffix = "studs/s",
    CurrentValue = 100,
    Flag = "FlySpeed",
    Callback = function(v)
        State.FlySpeed = v
    end,
})
MoveTab:CreateParagraph({
    Title = "Fly Controls",
    Content = "WASD = gerak, E = naik, Q = turun",
})

MoveTab:CreateSection("Speed")
MoveTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(v)
        State.SpeedEnabled = v
        applySpeed()
    end,
})
MoveTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "WalkSpeed",
    Callback = function(v)
        State.WalkSpeed = v
        applySpeed()
    end,
})

-- TAB: VISUAL
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v)
        State.EspEnabled = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    if not State.espObjects[p] then
                        createESPForPlayer(p)
                    end
                end
            end
        else
            clearAllESP()
        end
    end,
})
VisualTab:CreateToggle({
    Name = "ESP Glow",
    CurrentValue = true,
    Flag = "ESPGlow",
    Callback = function(v)
        State.EspGlow = v
        for _, obj in pairs(State.espObjects) do
            if obj.highlight then
                obj.highlight.Enabled = v and State.EspEnabled
            end
        end
    end,
})
VisualTab:CreateToggle({
    Name = "ESP Line (dari atas)",
    CurrentValue = true,
    Flag = "ESPLine",
    Callback = function(v)
        State.EspLine = v
        for _, obj in pairs(State.espObjects) do
            if obj.tracer then
                obj.tracer.Visible = false
            end
        end
    end,
})
VisualTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = true,
    Flag = "ESPBox",
    Callback = function(v)
        State.EspBox = v
        for _, obj in pairs(State.espObjects) do
            for _, l in ipairs(obj.boxLines) do
                l.Visible = false
            end
        end
    end,
})
VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(0, 255, 100),
    Flag = "ESPColor",
    Callback = function(color)
        State.EspColor = color
        for _, obj in pairs(State.espObjects) do
            if obj.highlight then
                obj.highlight.FillColor = color
                obj.highlight.OutlineColor = color
            end
            if obj.tracer then
                obj.tracer.Color = color
            end
            for _, l in ipairs(obj.boxLines) do
                l.Color = color
            end
        end
    end,
})

VisualTab:CreateSection("Wallhack")
VisualTab:CreateToggle({
    Name = "Enable Wallhack (nembus semua)",
    CurrentValue = false,
    Flag = "Wallhack",
    Callback = function(v)
        State.WallhackEnabled = v
        if v then
            applyWallhack()
        else
            clearWallhack()
        end
    end,
})

-- update wallhack pas ada player baru / respawn
Players.PlayerAdded:Connect(function()
    task.wait(1)
    if State.WallhackEnabled then applyWallhack() end
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.2)
    if State.WallhackEnabled then applyWallhack() end
end)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.WallhackEnabled then applyWallhack() end
end)

-- TAB: TELEPORT
local TpTab = Window:CreateTab("Teleport", 4483362458)

local playerDropdown
local function refreshPlayerDropdown()
    if playerDropdown then
        playerDropdown:Refresh(getPlayerNames())
    end
end

playerDropdown = TpTab:CreateDropdown({
    Name = "Pilih Player",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerSelect",
    Callback = function(option)
        if option and option[1] then
            State.SelectedPlayer = option[1]
        end
    end,
})

TpTab:CreateButton({
    Name = "Refresh List",
    Callback = function()
        refreshPlayerDropdown()
    end,
})

TpTab:CreateButton({
    Name = "Teleport ke Player",
    Callback = function()
        if not State.SelectedPlayer then
            notify("ollie", "pilih player dulu, sayang")
            return
        end
        teleportToPlayer(State.SelectedPlayer)
    end,
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshPlayerDropdown()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    refreshPlayerDropdown()
end)

-- ============================================================
-- CLEANUP SAAT SCRIPT DIMATIKAN / RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    -- reset state fly karena character baru
    stopFly()
    -- reset speed
    applySpeed()
    -- re-apply wallhack
    if State.WallhackEnabled then applyWallhack() end
    -- re-bind multi jump
    bindMultiJump()
end)

notify("ollie", "menu udah nyala — right shift buat buka/tutup")
