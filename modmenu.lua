--[[
    ByVoid — No system is safe
    update: ESP BRUTAL
      - fallback scan Workspace (nangkep player yang Character di-unparent)
      - 2D box + 3D box
      - line dari atas + nama + distance + health bar
      - glow Highlight
      - auto re-scan tiap 1s
    fitur lama SEMUA UTUH:
      1. multi jump UNLIMITED — tahan
      2. fly (speed sendiri) — HP + PC
      3. speed player
      4. ESP (glow + line + box + nama + 3D + health + dist)
      5. wallhack noclip (tembus) + wallhack glow (visual) — dipisah
      6. tp ke player
    executor: HP (Delta/Fluxus/Arceus) — Rayfield UI
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

    -- ESP brutal
    EspEnabled = false,
    EspGlow = false,
    EspLine = false,
    EspBox = false,
    EspName = false,
    EspHealth = false,
    EspDistance = false,
    EspBox3D = false,
    EspFallbackScan = true,     -- scan Workspace buat player yang Character unparent
    EspColor = Color3.fromRGB(0, 255, 100),
    EspMaxDist = 1000,
    espObjects = {},            -- [player] = {...}
    espScanTick = 0,

    -- wallhack
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

-- helper: cari RootPart dari player, termasuk fallback
local function getPlayerRoot(p)
    local char = p.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp, char end
    end
    -- fallback: scan Workspace cari Humanoid yang parent-nya punya nama player
    if State.EspFallbackScan then
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("Humanoid") and d.Parent then
                local model = d.Parent
                if model.Name == p.Name or model:FindFirstChild("HumanoidRootPart") then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp, model end
                end
            end
        end
    end
    return nil, nil
end

-- ============================================================
-- 1. MULTI JUMP — TAHAN
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
    if jumpHoldThread then task.cancel(jumpHoldThread); jumpHoldThread = nil end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not State.MultiJumpEnabled then return end
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
        startJumpHold()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
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
        if input.UserInputType == Enum.UserInputType.Touch and State.MultiJumpEnabled then startJumpHold() end
    end)
    jumpBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then stopJumpHold() end
    end)
    jumpBtn.MouseButton1Down:Connect(function()
        if State.MultiJumpEnabled then startJumpHold() end
    end)
    jumpBtn.MouseButton1Up:Connect(function() stopJumpHold() end)
end
task.spawn(hookTouchJumpButton)
LocalPlayer.CharacterAdded:Connect(function() task.wait(2); task.spawn(hookTouchJumpButton) end)

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
        if dir.Magnitude > 0 then vel = dir.Unit * State.FlySpeed end
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
local function removeESP(p)
    local obj = State.espObjects[p]
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    if obj.tracer then obj.tracer:Remove() end
    for _, l in ipairs(obj.boxLines or {}) do l:Remove() end
    for _, l in ipairs(obj.box3DLines or {}) do l:Remove() end
    if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
    if obj.healthBg and obj.healthBg.Parent then obj.healthBg:Destroy() end
    State.espObjects[p] = nil
end

local function clearAllESP()
    for p, _ in pairs(State.espObjects) do removeESP(p) end
    State.espObjects = {}
end

local function createESP(p)
    if p == LocalPlayer then return end
    if State.espObjects[p] then removeESP(p) end
    if not State.EspEnabled then return end

    local obj = {
        highlight = nil,
        tracer = nil,
        boxLines = {},
        box3DLines = {},
        billboard = nil,
        nameLabel = nil,
        distLabel = nil,
        healthBg = nil,
        healthFg = nil,
        cachedChar = nil,
    }

    local char = p.Character

    -- GLOW
    if State.EspGlow and char then
        local hl = Instance.new("Highlight")
        hl.Name = "OllieESP"
        hl.FillColor = State.EspColor
        hl.OutlineColor = State.EspColor
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char
        obj.highlight = hl
    end

    -- NAMA + DISTANCE (Billboard)
    if State.EspName or State.EspDistance then
        local head = char and char:FindFirstChild("Head")
        if head then
            local bb = Instance.new("BillboardGui")
            bb.Name = "OllieESPName"
            bb.Adornee = head
            bb.Size = UDim2.new(0, 220, 0, 60)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent = head

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = p.Name
            nameLabel.TextColor3 = State.EspColor
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Visible = State.EspName
            nameLabel.Parent = bb
            obj.nameLabel = nameLabel

            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0.5, 0)
            distLabel.Position = UDim2.new(0, 0, 0.5, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = ""
            distLabel.TextColor3 = State.EspColor
            distLabel.TextStrokeTransparency = 0
            distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            distLabel.TextScaled = true
            distLabel.Font = Enum.Font.Gotham
            distLabel.Visible = State.EspDistance
            distLabel.Parent = bb
            obj.distLabel = distLabel

            obj.billboard = bb
        end
    end

    -- HEALTH BAR (Billboard terpisah)
    if State.EspHealth and char then
        local head = char:FindFirstChild("Head")
        if head then
            local hb = Instance.new("BillboardGui")
            hb.Name = "OllieESPHealth"
            hb.Adornee = head
            hb.Size = UDim2.new(0, 50, 0, 6)
            hb.StudsOffset = Vector3.new(0, 3.2, 0)
            hb.AlwaysOnTop = true
            hb.Parent = head

            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            bg.BorderSizePixel = 1
            bg.BorderColor3 = Color3.new(0, 0, 0)
            bg.Parent = hb

            local fg = Instance.new("Frame")
            fg.Size = UDim2.new(1, 0, 1, 0)
            fg.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            fg.BorderSizePixel = 0
            fg.Parent = bg

            obj.healthBg = bg
            obj.healthFg = fg
        end
    end

    -- LINE 2D
    if State.EspLine then
        local ok, line = pcall(function() return Drawing.new("Line") end)
        if ok and line then
            line.Color = State.EspColor
            line.Thickness = 1.5
            line.Visible = false
            obj.tracer = line
        end
    end

    -- BOX 2D
    if State.EspBox then
        for i = 1, 4 do
            local ok, l = pcall(function() return Drawing.new("Line") end)
            if ok and l then
                l.Color = State.EspColor
                l.Thickness = 1
                l.Visible = false
                table.insert(obj.boxLines, l)
            end
        end
    end

    -- BOX 3D (12 garis kubus)
    if State.EspBox3D then
        for i = 1, 12 do
            local ok, l = pcall(function() return Drawing.new("Line") end)
            if ok and l then
                l.Color = State.EspColor
                l.Thickness = 1
                l.Visible = false
                table.insert(obj.box3DLines, l)
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

-- update bounding box 3D: 8 titik kubus di sekitar root
local function drawBox3D(obj, hrp)
    if #obj.box3DLines ~= 12 then return end
    local size = Vector3.new(3, 6, 3)
    local pos = hrp.Position
    local cf = CFrame.new(pos)
    local corners = {}
    local half = size / 2
    local offsets = {
        Vector3.new(-half.X, -half.Y, -half.Z), Vector3.new( half.X, -half.Y, -half.Z),
        Vector3.new( half.X,  half.Y, -half.Z), Vector3.new(-half.X,  half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y,  half.Z), Vector3.new( half.X, -half.Y,  half.Z),
        Vector3.new( half.X,  half.Y,  half.Z), Vector3.new(-half.X,  half.Y,  half.Z),
    }
    for i = 1, 8 do
        local wp = (cf + offsets[i]).Position
        local sp, on = Camera:WorldToViewportPoint(wp)
        corners[i] = {sp = sp, on = on}
    end
    -- 12 edge: 0-1,1-2,2-3,3-0,4-5,5-6,6-7,7-4,0-4,1-5,2-6,3-7
    local edges = {
        {1,2},{2,3},{3,4},{4,1},
        {5,6},{6,7},{7,8},{8,5},
        {1,5},{2,6},{3,7},{4,8},
    }
    for i, e in ipairs(edges) do
        local a = corners[e[1]]
        local b = corners[e[2]]
        local l = obj.box3DLines[i]
        if a and b and a.on and b.on then
            l.From = Vector2.new(a.sp.X, a.sp.Y)
            l.To = Vector2.new(b.sp.X, b.sp.Y)
            l.Color = State.EspColor
            l.Visible = true
        else
            l.Visible = false
        end
    end
end

local function updateESP()
    if not State.EspEnabled then return end

    -- auto-scan tiap 1s buat player baru / unparent char
    State.espScanTick = State.espScanTick + 1
    if State.espScanTick >= 60 then
        State.espScanTick = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not State.espObjects[p] then
                if State.EspFallbackScan then
                    local hrp, char = getPlayerRoot(p)
                    if hrp then createESP(p) end
                else
                    if p.Character then createESP(p) end
                end
            end
        end
    end

    local myHRP = getHRP()
    local myPos = myHRP and myHRP.Position or Vector3.zero

    for p, obj in pairs(State.espObjects) do
        local hrp, char = getPlayerRoot(p)
        -- refresh char cache kalau beda
        if char and obj.cachedChar ~= char then
            obj.cachedChar = char
            -- rebind highlight adornee
            if obj.highlight then obj.highlight.Adornee = char end
            -- rebind billboard ke head
            local head = char:FindFirstChild("Head")
            if head and obj.billboard then obj.billboard.Adornee = head end
            if head and obj.healthBg and obj.healthBg.Parent and obj.healthBg.Parent:IsA("BillboardGui") then
                obj.healthBg.Parent.Adornee = head
            end
        end

        if not hrp then
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            for _, l in ipairs(obj.box3DLines) do l.Visible = false end
            if obj.nameLabel then obj.nameLabel.TextTransparency = 1 end
            if obj.distLabel then obj.distLabel.TextTransparency = 1 end
            if obj.highlight then obj.highlight.Enabled = false end
            if obj.healthFg then obj.healthFg.Visible = false end
            continue
        end

        -- jarak
        local dist = (hrp.Position - myPos).Magnitude
        if dist > State.EspMaxDist then
            if obj.tracer then obj.tracer.Visible = false end
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            for _, l in ipairs(obj.box3DLines) do l.Visible = false end
            if obj.nameLabel then obj.nameLabel.Visible = false end
            if obj.distLabel then obj.distLabel.Visible = false end
            if obj.highlight then obj.highlight.Enabled = false end
            continue
        end

        -- glow
        if obj.highlight then
            obj.highlight.FillColor = State.EspColor
            obj.highlight.OutlineColor = State.EspColor
            obj.highlight.Enabled = State.EspGlow
        end

        -- nama
        if obj.nameLabel then
            obj.nameLabel.Visible = State.EspName
            obj.nameLabel.TextColor3 = State.EspColor
            obj.nameLabel.Text = p.Name
        end

        -- distance
        if obj.distLabel then
            obj.distLabel.Visible = State.EspDistance
            obj.distLabel.TextColor3 = State.EspColor
            obj.distLabel.Text = string.format("[%d]", math.floor(dist))
        end

        -- health bar
        if obj.healthFg then
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                obj.healthFg.Size = UDim2.new(ratio, 0, 1, 0)
                local r = 1 - ratio
                local g = ratio
                obj.healthFg.BackgroundColor3 = Color3.new(r, g, 0)
                obj.healthFg.Visible = State.EspHealth
            end
        end

        -- line 2D
        if obj.tracer then
            local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen and State.EspLine then
                obj.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                obj.tracer.To = Vector2.new(sp.X, sp.Y)
                obj.tracer.Color = State.EspColor
                obj.tracer.Visible = true
            else
                obj.tracer.Visible = false
            end
        end

        -- box 2D
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

        -- box 3D
        if #obj.box3DLines == 12 then
            if State.EspBox3D then
                drawBox3D(obj, hrp)
            else
                for _, l in ipairs(obj.box3DLines) do l.Visible = false end
            end
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
                if State.savedCollide[part] == nil then State.savedCollide[part] = true end
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if State.noclipConn then State.noclipConn:Disconnect(); State.noclipConn = nil end
    for part, orig in pairs(State.savedCollide) do
        if part and part.Parent then part.CanCollide = orig end
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
    for _, p in ipairs(Players:GetPlayers()) do removeWallhackGlow(p) end
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
    local tHRP = getPlayerRoot(target)
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
-- UI RAYFIELD — ByVoid
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ByVoid",
    LoadingTitle = "ByVoid",
    LoadingSubtitle = "No system is safe",
    ConfigurationSaving = { Enabled = false },
    Keybind = Enum.KeyCode.RightShift,
})

-- MOVEMENT
local MoveTab = Window:CreateTab("Movement", 4483362458)
MoveTab:CreateSection("Multi Jump (Unlimited — Tahan)")
MoveTab:CreateToggle({
    Name = "Enable Multi Jump",
    CurrentValue = false, Flag = "MultiJump",
    Callback = function(v) setMultiJump(v) end,
})
MoveTab:CreateSlider({
    Name = "Jump Velocity", Range = {30, 200}, Increment = 5, Suffix = "vel",
    CurrentValue = 50, Flag = "JumpVel",
    Callback = function(v) State.jumpVelocity = v end,
})
MoveTab:CreateSlider({
    Name = "Jump Spam Interval", Range = {0.03, 0.5}, Increment = 0.01, Suffix = "s",
    CurrentValue = 0.08, Flag = "JumpInterval",
    Callback = function(v) State.JumpHoldInterval = v end,
})

MoveTab:CreateSection("Fly")
MoveTab:CreateToggle({
    Name = "Enable Fly", CurrentValue = false, Flag = "Fly",
    Callback = function(v) toggleFly(v) end,
})
MoveTab:CreateSlider({
    Name = "Fly Speed", Range = {10, 500}, Increment = 10, Suffix = "studs/s",
    CurrentValue = 100, Flag = "FlySpeed",
    Callback = function(v) State.FlySpeed = v end,
})

MoveTab:CreateSection("Speed")
MoveTab:CreateToggle({
    Name = "Enable Speed", CurrentValue = false, Flag = "Speed",
    Callback = function(v) State.SpeedEnabled = v; applySpeed() end,
})
MoveTab:CreateSlider({
    Name = "Walk Speed", Range = {16, 300}, Increment = 1, Suffix = "studs/s",
    CurrentValue = 50, Flag = "WalkSpeed",
