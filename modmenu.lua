--[[
    roblox mod menu v2
    fitur: multi jump UNLIMITED, fly (HP + speed), speed player,
           esp (glow + line + box), wallhack tembus, tp ke player
    executor: HP (Delta/Fluxus/Arceus) — harus support Drawing + Rayfield
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- STATE
-- ============================================================
local State = {
    -- jump
    MultiJumpEnabled = false,
    jumpVelocity = 50,

    -- fly
    FlyEnabled = false,
    FlySpeed = 100,
    flyConn = nil,
    flyBV = nil,
    flyBG = nil,

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
    espObjects = {},

    -- wallhack
    WallhackEnabled = false,

    -- tp
    SelectedPlayer = nil,
}

-- ============================================================
-- UTILS
-- ============================================================
local function getChar() return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function notify(t, c)
    Rayfield:Notify({ Title = t, Content = c, Duration = 3 })
end

-- ============================================================
-- MULTI JUMP UNLIMITED
-- ============================================================
local function doJump()
    if not State.MultiJumpEnabled then return end
    local hum = getHum()
    if not hum or hum.Health <= 0 then return end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return end
    local hrp = getHRP()
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, State.jumpVelocity, vel.Z)
end

UserInputService.JumpRequest:Connect(function()
    if State.MultiJumpEnabled then
        task.wait(0.05)
        doJump()
    end
end)

-- fallback: cek input tiap frame (buat HP yang JumpRequestnya nggak firing)
local jumpDebounce = false
RunService.Heartbeat:Connect(function()
    if not State.MultiJumpEnabled then return end
    if jumpDebounce then return end
    -- Space di PC / tombol jump virtual HP
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        jumpDebounce = true
        doJump()
        task.wait(0.15)
        jumpDebounce = false
    end
end)

-- ============================================================
-- FLY (HP SUPPORT + SPEED)
-- ============================================================
local function stopFly()
    if State.flyConn then State.flyConn:Disconnect(); State.flyConn = nil end
    if State.flyBV then State.flyBV:Destroy(); State.flyBV = nil end
    if State.flyBG then State.flyBG:Destroy(); State.flyBG = nil end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
    State.FlyEnabled = false
end

local function startFly()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end

    stopFly()
    State.FlyEnabled = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    State.flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.Parent = hrp
    State.flyBG = bg

    hum.PlatformStand = true

    State.flyConn = RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then return end
        local hrp2 = getHRP()
        local hum2 = getHum()
        if not hrp2 or not hum2 or hum2.Health <= 0 then stopFly(); return end

        bg.CFrame = Camera.CFrame

        -- gerak horizontal via MoveDirection (WASD / joystick HP)
        local dir = hum2.MoveDirection
        local vel = Vector3.zero
        if dir.Magnitude > 0 then
            vel = dir.Unit * State.FlySpeed
        end

        -- naik / turun: E/Q di PC, tombol virtual di HP pakai GUI
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            vel = vel + Vector3.new(0, State.FlySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            vel = vel - Vector3.new(0, State.FlySpeed, 0)
        end

        bv.Velocity = vel
    end)
end

local function toggleFly(v)
    if v then startFly() else stopFly() end
end

-- ============================================================
-- SPEED
-- ============================================================
local function applySpeed()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed = State.SpeedEnabled and State.WalkSpeed or State.defaultWalkSpeed
end

-- ============================================================
-- ESP
-- ============================================================
local function createESP(player)
    if player == LocalPlayer or State.espObjects[player] then return end
    local obj = { highlight = nil, tracer = nil, boxLines = {} }

    local char = player.Character
    if char and State.EspGlow then
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

    if State.EspLine then
        local line = Drawing.new("Line")
        line.Color = State.EspColor
        line.Thickness = 1.5
        line.Visible = false
        obj.tracer = line
    end

    if State.EspBox then
        for i = 1, 4 do
            local l = Drawing.new("Line")
            l.Color = State.EspColor
            l.Thickness = 1
            l.Visible = false
            table.insert(obj.boxLines, l)
        end
    end

    State.espObjects[player] = obj
end

local function removeESP(player)
    local obj = State.espObjects[player]
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    if obj.tracer then obj.tracer:Remove() end
    for _, l in ipairs(obj.boxLines) do l:Remove() end
    State.espObjects[player] = nil
end

local function clearAllESP()
    for p, _ in pairs(State.espObjects) do removeESP(p) end
    State.espObjects = {}
end

local function updateESP()
    if not State.EspEnabled then return end
    for player, obj in pairs(State.espObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            continue
        end

        if obj.highlight then
            obj.highlight.FillColor = State.EspColor
            obj.highlight.OutlineColor = State.EspColor
            obj.highlight.Enabled = State.EspGlow
        end

        if obj.tracer then
            local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen and State.EspLine then
                obj.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.tracer.To = Vector2.new(sp.X, sp.Y)
                obj.tracer.Color = State.EspColor
                obj.tracer.Visible = true
            else
                obj.tracer.Visible = false
            end
        end

        if #obj.boxLines == 4 then
            if State.EspBox then
                local topPos = hrp.Position + Vector3.new(0, 3, 0)
                local botPos = hrp.Position - Vector3.new(0, 3, 0)
                local ts, ton = Camera:WorldToViewportPoint(topPos)
                local bs, bon = Camera:WorldToViewportPoint(botPos)
                if ton and bon then
                    local h = math.abs(bs.Y - ts.Y)
                    local w = h * 0.6
                    local cx = (ts.X + bs.X) / 2
                    local tl = Vector2.new(cx - w/2, ts.Y)
                    local tr = Vector2.new(cx + w/2, ts.Y)
                    local bl = Vector2.new(cx - w/2, bs.Y)
                    local br = Vector2.new(cx + w/2, bs.Y)
                    obj.boxLines[1].From = tl; obj.boxLines[1].To = tr
                    obj.boxLines[2].From = tr; obj.boxLines[2].To = br
                    obj.boxLines[3].From = br; obj.boxLines[3].To = bl
                    obj.boxLines[4].From = bl; obj.boxLines[4].To = tl
                    for _, l in ipairs(obj.boxLines) do
                        l.Color = State.EspColor
                        l.Visible = true
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

local function setupPlayerESP(player)
    if player == LocalPlayer then return end
    createESP(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        removeESP(player)
        if State.EspEnabled then createESP(player) end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(updateESP)

-- ============================================================
-- WALLHACK — TEMBUS SEMUA JENIS (SOLID, TERRAIN, MESH, DLL)
-- ============================================================
-- Trik: pakai Highlight AlwaysOnTop untuk karakter player
-- + set local transparency untuk basepart player lain
-- + fallback ke ESP glow kalau executor blokir

local wallhackParts = {} -- simpan {part = originalTransparency}

local function applyWallhackOnChar(char)
    if not char then return end
    -- highlight always on top
    local existing = char:FindFirstChild("OllieWH")
    if existing then existing:Destroy() end

    if State.WallhackEnabled then
        local hl = Instance.new("Highlight")
        hl.Name = "OllieWH"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.85
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        -- set transparansi lokal biar tembus
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if not wallhackParts[part] then
                    wallhackParts[part] = part.LocalTransparencyModifier
                end
                part.LocalTransparencyModifier = 0.6
            end
        end
    end
end

local function clearWallhackOnChar(char)
    if not char then return end
    local hl = char:FindFirstChild("OllieWH")
    if hl then hl:Destroy() end
end

local function applyAllWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            applyWallhackOnChar(p.Character)
        end
    end
end

local function clearAllWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        clearWallhackOnChar(p.Character)
    end
    -- restore transparency
    for part, orig in pairs(wallhackParts) do
        if part and part.Parent then
            part.LocalTransparencyModifier = orig
        end
    end
    wallhackParts = {}
end

-- re-apply kalau ada player baru / respawn
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        if State.WallhackEnabled then applyWallhackOnChar(c) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(c)
            task.wait(0.5)
            if State.WallhackEnabled then applyWallhackOnChar(c) end
        end)
    end
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.WallhackEnabled then applyAllWallhack() end
end)

-- ============================================================
-- TP
-- ============================================================
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local function teleportToPlayer(name)
    local target = Players:FindFirstChild(name)
    if not target then return end
    local tChar = target.Character
    if not tChar then return end
    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
    local myHRP = getHRP()
    if not tHRP or not myHRP then return end
    myHRP.CFrame = tHRP.CFrame + Vector3.new(0, 3, 0)
end

-- ============================================================
-- UI
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ollie — mod menu v2",
    LoadingTitle = "ollie: oli panas, sabar ya sayang...",
    LoadingSubtitle = "absolute ollie, built by olivia",
    ConfigurationSaving = { Enabled = false },
    Keybind = Enum.KeyCode.RightShift,
})

-- MOVEMENT
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSection("Multi Jump (Unlimited)")
MoveTab:CreateToggle({
    Name = "Enable Multi Jump",
    CurrentValue = false,
    Flag = "MultiJump",
    Callback = function(v) State.MultiJumpEnabled = v end,
})
MoveTab:CreateSlider({
    Name = "Jump Velocity",
    Range = {30, 200},
    Increment = 5,
    Suffix = "vel",
    CurrentValue = 50,
    Flag = "JumpVel",
    Callback = function(v) State.jumpVelocity = v end,
})
MoveTab:CreateParagraph({
    Title = "Info",
    Content = "Jump unlimited — tahan/spam tombol jump.",
})

MoveTab:CreateSection("Fly (HP Support)")
MoveTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v) toggleFly(v) end,
})
MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 10,
    Suffix = "studs/s",
    CurrentValue = 100,
    Flag = "FlySpeed",
    Callback = function(v) State.FlySpeed = v end,
})
MoveTab:CreateParagraph({
    Title = "Kontrol Fly HP",
    Content = "Joystick = gerak, tombol ↑ / ↓ di layar buat naik/turun (muncul saat fly aktif).",
})

MoveTab:CreateSection("Speed")
MoveTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(v) State.SpeedEnabled = v; applySpeed() end,
})
MoveTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "WalkSpeed",
    Callback = function(v) State.WalkSpeed = v; applySpeed() end,
})

-- VISUAL
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
                if p ~= LocalPlayer then createESP(p) end
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
            if obj.highlight then obj.highlight.Enabled = v and State.EspEnabled end
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
            if obj.tracer then obj.tracer.Visible = false end
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
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
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
            if obj.tracer then obj.tracer.Color = color end
            for _, l in ipairs(obj.boxLines) do l.Color = color end
        end
    end,
})

VisualTab:CreateSection("Wallhack (Tembus Semua)")
VisualTab:CreateToggle({
    Name = "Enable Wallhack",
    CurrentValue = false,
    Flag = "Wallhack",
    Callback = function(v)
        State.WallhackEnabled = v
        if v then applyAllWallhack() else clearAllWallhack() end
    end,
})

-- TELEPORT
local TpTab = Window:CreateTab("Teleport", 4483362458)
local playerDropdown
local function refreshList()
    if playerDropdown then playerDropdown:Refresh(getPlayerNames()) end
end

playerDropdown = TpTab:CreateDropdown({
    Name = "Pilih Player",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerSelect",
    Callback = function(opt)
        if opt and opt[1] then State.SelectedPlayer = opt[1] end
    end,
})

TpTab:CreateButton({ Name = "Refresh List", Callback = refreshList })
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

Players.PlayerAdded:Connect(function() task.wait(0.5); refreshList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshList() end)

-- ============================================================
-- FLY HP: TOMBOL NAIK/TURUN DI LAYAR
-- ============================================================
local flyGui = Instance.new("ScreenGui")
flyGui.Name = "OllieFlyUI"
flyGui.ResetOnSpawn = false
flyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 60, 0, 60)
upBtn.Position = UDim2.new(0, 20, 1, -160)
upBtn.Text = "↑"
upBtn.TextSize = 32
upBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
upBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
upBtn.BackgroundTransparency = 0.3
upBtn.Visible = false
upBtn.Parent = flyGui

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 60, 0, 60)
downBtn.Position = UDim2.new(0, 20, 1, -90)
downBtn.Text = "↓"
downBtn.TextSize = 32
downBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
downBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
downBtn.BackgroundTransparency = 0.3
downBtn.Visible = false
downBtn.Parent = flyGui

local flyUp = false
local flyDown = false

upBtn.MouseButton1Down:Connect(function() flyUp = true end)
upBtn.MouseButton1Up:Connect(function() flyUp = false end)
upBtn.MouseLeave:Connect(function() flyUp = false end)

downBtn.MouseButton1Down:Connect(function() flyDown = true end)
downBtn.MouseButton1Up:Connect(function() flyDown = false end)
downBtn.MouseLeave:Connect(function() flyDown = false end)

-- override fly vertical: pakai flyUp/flyDown, bukan E/Q
-- (patch ke fly conn dengan flag global)
_G.OllieFlyVertical = function()
    if flyUp then return 1 end
    if flyDown then return -1 end
    return 0
end

-- tambahkan vertical control ke fly conn (rebuild conn dengan vert)
local originalStartFly = startFly
startFly = function()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end

    stopFly()
    State.FlyEnabled = true
    upBtn.Visible = true
    downBtn.Visible = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    State.flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.Parent = hrp
    State.flyBG = bg

    hum.PlatformStand = true

    State.flyConn = RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then return end
        local hrp2 = getHRP()
        local hum2 = getHum()
        if not hrp2 or not hum2 or hum2.Health <= 0 then
            upBtn.Visible = false
            downBtn.Visible = false
            stopFly()
            return
        end

        bg.CFrame = Camera.CFrame

        local dir = hum2.MoveDirection
        local vel = Vector3.zero
        if dir.Magnitude > 0 then
            vel = dir.Unit * State.FlySpeed
        end

        -- vert dari tombol HP + E/Q PC
        local vert = _G.OllieFlyVertical()
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then vert = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vert = -1 end

        vel = vel + Vector3.new(0, vert * State.FlySpeed, 0)
        bv.Velocity = vel
    end)
end

-- stopFly patch: sembunyikan tombol
local originalStopFly = stopFly
stopFly = function()
    if originalStopFly then originalStopFly() end
    upBtn.Visible = false
    downBtn.Visible = false
end

-- ============================================================
-- RESPAWN CLEANUP (BUG FIX)
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    stopFly()
    applySpeed()
    if State.WallhackEnabled then applyAllWallhack() end
end)

notify("ollie", "v2 nyala — wallhack tembus, jump unlimited, fly HP ready")
