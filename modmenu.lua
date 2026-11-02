--[[
    ByVoid — No system is safe
    update: ESP brutal
      - 3 mode deteksi: Character normal / Humanoid scan / Model name match
      - health bar di box
      - jarak (studs) di label
      - status [HIDDEN] kalau Character unparent / transparent
      - fallback scan tiap 0.5s buat player yang di-hide game
    fitur lain sama persis v3.5
    absolute ollie, built by olivia
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
    MultiJumpEnabled = false,
    jumpVelocity = 50,
    JumpHoldInterval = 0.08,
    jumpInputActive = false,

    FlyEnabled = false,
    FlySpeed = 100,
    flyConn = nil,
    flyBV = nil,
    flyBG = nil,
    flyUp = false,
    flyDown = false,

    SpeedEnabled = false,
    WalkSpeed = 50,
    defaultWalkSpeed = 16,

    EspEnabled = false,
    EspGlow = false,
    EspLine = false,
    EspBox = false,
    EspName = false,
    EspHealthBar = false,
    EspDistance = false,
    EspHiddenTag = true,
    EspScanFallback = true,
    EspColor = Color3.fromRGB(0, 255, 100),
    EspHiddenColor = Color3.fromRGB(255, 0, 255),
    espObjects = {},
    scanConn = nil,

    NoclipEnabled = false,
    WallhackGlowEnabled = false,
    WallhackColor = Color3.fromRGB(255, 60, 60),
    wallhackObjects = {},
    savedCollide = {},
    noclipConn = nil,

    SelectedPlayer = nil,
}

local Toggles = {}

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
-- 1. MULTI JUMP
-- ============================================================
local jumpHolding = false
local jumpHoldThread = nil

local function doJump()
    if not State.MultiJumpEnabled then return end
    if not State.jumpInputActive then return end
    local hum = getHum()
    if not hum or hum.Health <= 0 then return end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return end
    local hrp = getHRP()
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, State.jumpVelocity, vel.Z)
end

local function startJumpHold()
    if not State.MultiJumpEnabled then return end
    if jumpHolding then return end
    jumpHolding = true
    State.jumpInputActive = true
    if jumpHoldThread then task.cancel(jumpHoldThread); jumpHoldThread = nil end
    jumpHoldThread = task.spawn(function()
        while jumpHolding and State.jumpInputActive do
            doJump()
            task.wait(State.JumpHoldInterval)
        end
        jumpHolding = false
    end)
end

local function stopJumpHold()
    State.jumpInputActive = false
    jumpHolding = false
    if jumpHoldThread then
        task.cancel(jumpHoldThread)
        jumpHoldThread = nil
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not State.MultiJumpEnabled then return end
    if input.KeyCode == Enum.KeyCode.Space
        or input.KeyCode == Enum.KeyCode.ButtonA then
        startJumpHold()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space
        or input.KeyCode == Enum.KeyCode.ButtonA then
        stopJumpHold()
    end
end)

local function hookTouchJumpButton()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then return end
    local touchGui = playerGui:WaitForChild("TouchGui", 10)
    if not touchGui then return end
    local frame = touchGui:WaitForChild("TouchControlFrame", 10)
    if not frame then return end
    local jumpBtn = frame:WaitForChild("JumpButton", 10)
    if not jumpBtn then return end

    jumpBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if State.MultiJumpEnabled then startJumpHold() end
        end
    end)
    jumpBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            stopJumpHold()
        end
    end)
    jumpBtn.MouseButton1Down:Connect(function()
        if State.MultiJumpEnabled then startJumpHold() end
    end)
    jumpBtn.MouseButton1Up:Connect(function()
        stopJumpHold()
    end)
end

task.spawn(hookTouchJumpButton)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    task.spawn(hookTouchJumpButton)
end)

local function setMultiJump(v)
    State.MultiJumpEnabled = v
    if not v then stopJumpHold() end
end

-- ============================================================
-- 2. FLY
-- ============================================================
local function stopFly()
    if State.flyConn then State.flyConn:Disconnect(); State.flyConn = nil end
    if State.flyBV then State.flyBV:Destroy(); State.flyBV = nil end
    if State.flyBG then State.flyBG:Destroy(); State.flyBG = nil end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
    State.FlyEnabled = false
    State.flyUp = false
    State.flyDown = false
    if _G.OllieFlyUI then _G.OllieFlyUI.hide() end
end

local function startFly()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end

    stopFly()
    State.FlyEnabled = true
    if _G.OllieFlyUI then _G.OllieFlyUI.show() end

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

        local dir = hum2.MoveDirection
        local vel = Vector3.zero
        if dir.Magnitude > 0 then
            vel = dir.Unit * State.FlySpeed
        end

        local vert = 0
        if State.flyUp or UserInputService:IsKeyDown(Enum.KeyCode.E) then vert = 1 end
        if State.flyDown or UserInputService:IsKeyDown(Enum.KeyCode.Q) then vert = -1 end

        vel = vel + Vector3.new(0, vert * State.FlySpeed, 0)
        bv.Velocity = vel
    end)
end

local function toggleFly(v)
    if v then startFly() else stopFly() end
end

-- ============================================================
-- 3. SPEED
-- ============================================================
local function applySpeed()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed = State.SpeedEnabled and State.WalkSpeed or State.defaultWalkSpeed
end

-- ============================================================
-- 4. ESP BRUTAL
-- ============================================================
-- Struktur: espObjects[player] = {
--   highlight, tracer, boxLines (4), nameTag, healthBar, distanceLabel,
--   resolvedChar (Model), resolvedHRP, resolvedHum, isHidden
-- }

local function removeESP(p)
    local obj = State.espObjects[p]
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    if obj.tracer then obj.tracer:Remove() end
    for _, l in ipairs(obj.boxLines) do l:Remove() end
    if obj.nameTag and obj.nameTag.Parent then obj.nameTag.Parent:Destroy() end
    if obj.healthBar and obj.healthBar.Parent then obj.healthBar.Parent:Destroy() end
    if obj.distanceLabel and obj.distanceLabel.Parent then obj.distanceLabel.Parent:Destroy() end
    State.espObjects[p] = nil
end

local function clearAllESP()
    for p, _ in pairs(State.espObjects) do removeESP(p) end
    State.espObjects = {}
end

-- resolve character: 3 mode deteksi
local function resolveChar(p)
    -- 1. normal
    local char = p.Character
    if char and char.Parent and char:FindFirstChild("HumanoidRootPart") then
        return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid"), false
    end

    -- 2. scan Workspace cari Humanoid yang Player-nya cocok (mode fallback)
    if State.EspScanFallback then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent then
                local root = obj.Parent:FindFirstChild("HumanoidRootPart") or obj.Parent:FindFirstChild("Torso")
                if root then
                    local owner = Players:GetPlayerFromCharacter(obj.Parent)
                    if owner == p then
                        return obj.Parent, root, obj, true
                    end
                end
            end
        end
    end

    -- 3. scan Model dengan nama mirip username
    if State.EspScanFallback then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find(p.Name:lower(), 1, true) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    return obj, root, hum, true
                end
            end
        end
    end

    return nil, nil, nil, false
end

local function makeLabel(adornee, offsetY, sizeX, sizeY, textColor)
    local bb = Instance.new("BillboardGui")
    bb.Name = "OllieESPBB"
    bb.Adornee = adornee
    bb.Size = UDim2.new(0, sizeX, 0, sizeY)
    bb.StudsOffset = Vector3.new(0, offsetY, 0)
    bb.AlwaysOnTop = true
    bb.Parent = adornee

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = textColor
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bb
    return bb, label
end

local function createESP(p)
    if p == LocalPlayer then return end
    if State.espObjects[p] then removeESP(p) end
    if not State.EspEnabled then return end

    local char, hrp, hum, isHidden = resolveChar(p)

    local obj = {
        highlight = nil,
        tracer = nil,
        boxLines = {},
        nameTag = nil,
        healthBar = nil,
        distanceLabel = nil,
        resolvedChar = char,
        resolvedHRP = hrp,
        resolvedHum = hum,
        isHidden = isHidden,
    }

    local color = isHidden and State.EspHiddenColor or State.EspColor

    -- glow
    if State.EspGlow and char then
        local hl = Instance.new("Highlight")
        hl.Name = "OllieESP"
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char
        obj.highlight = hl
    end

    -- nama + jarak + hidden tag
    if State.EspName and char then
        local adornee = char:FindFirstChild("Head") or hrp
        if adornee then
            local text = p.Name
            if State.EspHiddenTag and isHidden then
                text = text .. " [HIDDEN]"
            end
            local bb, label = makeLabel(adornee, 3.2, 260, 40, color)
            label.Text = text
            obj.nameTag = label
        end
    end

    -- jarak (label kecil di bawah nama)
    if State.EspDistance and char then
        local adornee = char:FindFirstChild("Head") or hrp
        if adornee then
            local bb, label = makeLabel(adornee, 2.2, 120, 24, color)
            label.Text = "0m"
            obj.distanceLabel = label
        end
    end

    -- health bar (frame 2D di atas head pakai BillboardGui)
    if State.EspHealthBar and char then
        local adornee = char:FindFirstChild("Head") or hrp
        if adornee then
            local bb = Instance.new("BillboardGui")
            bb.Name = "OllieESPHealth"
            bb.Adornee = adornee
            bb.Size = UDim2.new(0, 200, 0, 8)
            bb.StudsOffset = Vector3.new(0, 3.8, 0)
            bb.AlwaysOnTop = true
            bb.Parent = adornee

            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            bg.BorderSizePixel = 0
            bg.Parent = bb

            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Size = UDim2.new(1, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            fill.BorderSizePixel = 0
            fill.Parent = bg

            obj.healthBar = fill
        end
    end

    -- line
    if State.EspLine then
        local ok, line = pcall(function() return Drawing.new("Line") end)
        if ok and line then
            line.Color = color
            line.Thickness = 1.5
            line.Visible = false
            obj.tracer = line
        end
    end

    -- box
    if State.EspBox then
        for i = 1, 4 do
            local ok, l = pcall(function() return Drawing.new("Line") end)
            if ok and l then
                l.Color = color
                l.Thickness = 1
                l.Visible = false
                table.insert(obj.boxLines, l)
            end
        end
    end

    State.espObjects[p] = obj
end

local function rebuildAllESP()
    clearAllESP()
    if not State.EspEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then createESP(p) end
    end
end

local function updateESP()
    if not State.EspEnabled then return end
    for p, obj in pairs(State.espObjects) do
        -- re-resolve tiap frame kalau char ilang / hidden
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not char.Parent then
            local c2, h2, hum2, hidden2 = resolveChar(p)
            if c2 then
                char = c2; hrp = h2
                obj.resolvedChar = c2
                obj.resolvedHRP = h2
                obj.resolvedHum = hum2
                obj.isHidden = hidden2
                if obj.highlight then obj.highlight.Adornee = c2 end
            end
        else
            obj.resolvedChar = char
            obj.resolvedHRP = hrp
            obj.resolvedHum = char:FindFirstChildOfClass("Humanoid")
            obj.isHidden = false
        end

        if not hrp then
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            if obj.nameTag then obj.nameTag.TextTransparency = 1 end
            if obj.highlight then obj.highlight.Enabled = false end
            if obj.healthBar then obj.healthBar.Parent.Parent.Enabled = false end
            if obj.distanceLabel then obj.distanceLabel.TextTransparency = 1 end
            continue
        end

        local color = obj.isHidden and State.EspHiddenColor or State.EspColor

        -- highlight
        if obj.highlight then
            obj.highlight.FillColor = color
            obj.highlight.OutlineColor = color
            obj.highlight.Enabled = State.EspGlow
            if obj.resolvedChar then obj.highlight.Adornee = obj.resolvedChar end
        end

        -- nama + hidden tag
        if obj.nameTag then
            local text = p.Name
            if State.EspHiddenTag and obj.isHidden then
                text = text .. " [HIDDEN]"
            end
            obj.nameTag.Text = text
            obj.nameTag.TextColor3 = color
            obj.nameTag.TextTransparency = State.EspName and 0 or 1
        end

        -- jarak
        if obj.distanceLabel then
            if State.EspDistance then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                obj.distanceLabel.Text = string.format("%.0fm", dist)
                obj.distanceLabel.TextColor3 = color
                obj.distanceLabel.TextTransparency = 0
            else
                obj.distanceLabel.TextTransparency = 1
            end
        end

        -- health bar
        if obj.healthBar and obj.resolvedHum then
            local hpPct = math.clamp(obj.resolvedHum.Health / obj.resolvedHum.MaxHealth, 0, 1)
            obj.healthBar.Size = UDim2.new(hpPct, 0, 1, 0)
            obj.healthBar.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - hpPct)),
                math.floor(255 * hpPct),
                0
            )
        end

        -- line
        if obj.tracer then
            local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen and State.EspLine then
                obj.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                obj.tracer.To = Vector2.new(sp.X, sp.Y)
                obj.tracer.Color = color
                obj.tracer.Visible = true
            else
                obj.tracer.Visible = false
            end
        end

        -- box
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
                        l.Color = color
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

-- fallback scan loop: tiap 0.5s, cek player yang belum ke-track
local function fallbackScan()
    if not State.EspEnabled or not State.EspScanFallback then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not State.espObjects[p] then
            -- belum ke-track? coba create
            local c, h = resolveChar(p)
            if c and h then createESP(p) end
        end
    end
end

local function setupPlayerESP(p)
    if p == LocalPlayer then return end
    if State.EspEnabled then createESP(p) end
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        removeESP(p)
        if State.EspEnabled then createESP(p) end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(updateESP)
task.spawn(function()
    while true do
        task.wait(0.5)
        fallbackScan()
    end
end)

-- ============================================================
-- 5A. NOCLIP
-- ============================================================
local function setNoclipParts(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if State.savedCollide[part] == nil then
                State.savedCollide[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

local function startNoclip()
    local char = getChar()
    if char then setNoclipParts(char) end

    if State.noclipConn then State.noclipConn:Disconnect() end
    State.noclipConn = RunService.Stepped:Connect(function()
        if not State.NoclipEnabled then return end
        local c = getChar()
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if State.savedCollide[part] == nil then
                    State.savedCollide[part] = true
                end
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if State.noclipConn then State.noclipConn:Disconnect(); State.noclipConn = nil end
    for part, orig in pairs(State.savedCollide) do
        if part and part.Parent then
            part.CanCollide = orig
        end
    end
    State.savedCollide = {}
end

-- ============================================================
-- 5B. WALLHACK GLOW
-- ============================================================
local function createWallhackGlow(p)
    if p == LocalPlayer then return end
    local char = p.Character
    if not char then return end

    local old = char:FindFirstChild("OllieWH")
    if old then old:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "OllieWH"
    hl.FillColor = State.WallhackColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char
    State.wallhackObjects[p] = hl
end

local function removeWallhackGlow(p)
    local char = p.Character
    if char then
        local hl = char:FindFirstChild("OllieWH")
        if hl then hl:Destroy() end
    end
    State.wallhackObjects[p] = nil
end

local function applyAllWallhackGlow()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then createWallhackGlow(p) end
    end
end

local function clearAllWallhackGlow()
    for _, p in ipairs(Players:GetPlayers()) do
        removeWallhackGlow(p)
    end
    State.wallhackObjects = {}
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.WallhackGlowEnabled then createWallhackGlow(p) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if State.WallhackGlowEnabled then createWallhackGlow(p) end
        end)
    end
end

-- ============================================================
-- 6. TP
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
-- FLY UI
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

upBtn.MouseButton1Down:Connect(function() State.flyUp = true end)
upBtn.MouseButton1Up:Connect(function() State.flyUp = false end)
upBtn.MouseLeave:Connect(function() State.flyUp = false end)
downBtn.MouseButton1Down:Connect(function() State.flyDown = true end)
downBtn.MouseButton1Up:Connect(function() State.flyDown = false end)
downBtn.MouseLeave:Connect(function() State.flyDown = false end)

_G.OllieFlyUI = {
    show = function() upBtn.Visible = true; downBtn.Visible = true end,
    hide = function() upBtn.Visible = false; downBtn.Visible = false end,
}

-- ============================================================
-- UI
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ByVoid",
    LoadingTitle = "ByVoid",
    LoadingSubtitle = "No system is safe",
    ConfigurationSaving = { Enabled = false },
    Keybind = Enum.KeyCode.RightShift,
})

local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSection("Multi Jump (Unlimited — Tahan)")
MoveTab:CreateToggle({
    Name = "Enable Multi Jump",
    CurrentValue = false,
    Flag = "MultiJump",
    Callback = function(v) setMultiJump(v) end,
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
MoveTab:CreateSlider({
    Name = "Jump Spam Interval",
    Range = {0.03, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.08,
    Flag = "JumpInterval",
    Callback = function(v) State.JumpHoldInterval = v end,
})

MoveTab:CreateSection("Fly")
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

VisualTab:CreateSection("ESP Brutal")
Toggles.Esp = VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v)
        State.EspEnabled = v
        if v then
            if not (State.EspGlow or State.EspLine or State.EspBox or State.EspName) then
                notify("ByVoid", "pilih dulu: Glow / Line / Box / Nama")
            end
            rebuildAllESP()
        else
            clearAllESP()
        end
    end,
})
Toggles.Glow = VisualTab:CreateToggle({
    Name = "ESP Glow",
    CurrentValue = false,
    Flag = "ESPGlow",
    Callback = function(v) State.EspGlow = v; if State.EspEnabled then rebuildAllESP() end end,
})
Toggles.Line = VisualTab:CreateToggle({
    Name = "ESP Line (dari atas)",
    CurrentValue = false,
    Flag = "ESPLine",
    Callback = function(v) State.EspLine = v; if State.EspEnabled then rebuildAllESP() end end,
})
Toggles.Box = VisualTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Flag = "ESPBox",
    Callback = function(v) State.EspBox = v; if State.EspEnabled then rebuildAllESP() end end,
})
Toggles.Name = VisualTab:CreateToggle({
    Name = "ESP Nama",
    CurrentValue = false,
    Flag = "ESPName",
    Callback = function(v) State.EspName = v; if State.EspEnabled then rebuildAllESP() end end,
})
Toggles.Health = VisualTab:CreateToggle({
    Name = "ESP Health Bar",
    CurrentValue = false,
    Flag = "ESPHealth",
    Callback = function(v) State.EspHealthBar = v; if State.EspEnabled then rebuildAllESP() end end,
})
Toggles.Distance = VisualTab:CreateToggle({
    Name = "ESP Jarak (studs)",
    CurrentValue = false,
    Flag = "ESPDistance",
    Callback = function(v) State.EspDistance = v; if State.EspEnabled then rebuildAllESP() end end,
})
Toggles.HiddenTag = VisualTab:CreateToggle({
    Name = "Tag [HIDDEN]",
    CurrentValue = true,
    Flag = "ESPHiddenTag",
    Callback = function(v) State.EspHiddenTag = v end,
})
Toggles.ScanFallback = VisualTab
