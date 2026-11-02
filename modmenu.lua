--[[
    ByVoid — No system is safe
    fitur tunggal: wallhack noclip
      - tembus SEMUA block (solid, wedge, mesh, union, terrain)
      - player yang digendong/carry/grab ikut tembus
      - visual highlight AlwaysOnTop + color picker
    ui: WindUI (dark neon, animasi smooth)
    absolute ollie, built by olivia
--]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- STATE
-- ============================================================
local State = {
    NoclipEnabled = false,
    savedCollide = {},
    carriedParts = {},
    noclipConn = nil,
    VisualEnabled = false,
    VisualColor = Color3.fromRGB(255, 60, 60),
    wallhackObjects = {},
}

-- ============================================================
-- UTILS
-- ============================================================
local function getChar() return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- NOCLIP CORE
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

local function isAttachedToLocal(part)
    if not part or not part.Parent then return false end
    local char = getChar()
    if not char then return false end
    if part:IsDescendantOf(char) then return false end

    for _, joint in ipairs(part:GetJoints()) do
        local other = (joint.Part0 == part) and joint.Part1 or joint.Part0
        if other and other:IsDescendantOf(char) then return true end
    end

    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("WeldConstraint") then
            local other = (child.Part0 == part) and child.Part1 or child.Part0
            if other and other:IsDescendantOf(char) then return true end
        end
        if child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
            local att = child.Attachment0
            if att and att:IsDescendantOf(char) then return true end
        end
    end
    return false
end

local function setCarriedPartsNoclip()
    local char = getChar()
    if not char then return end
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and not part:IsDescendantOf(char) then
            if isAttachedToLocal(part) then
                if State.carriedParts[part] == nil then
                    State.carriedParts[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end
end

local function startNoclip()
    local char = getChar()
    if char then setNoclipParts(char) end
    setCarriedPartsNoclip()

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
        setCarriedPartsNoclip()
    end)
end

local function restoreCarriedParts()
    for part, orig in pairs(State.carriedParts) do
        if part and part.Parent then part.CanCollide = orig end
    end
    State.carriedParts = {}
end

local function stopNoclip()
    if State.noclipConn then State.noclipConn:Disconnect(); State.noclipConn = nil end
    for part, orig in pairs(State.savedCollide) do
        if part and part.Parent then part.CanCollide = orig end
    end
    State.savedCollide = {}
    restoreCarriedParts()
end

local function setNoclip(v)
    State.NoclipEnabled = v
    if v then startNoclip() else stopNoclip() end
end

-- ============================================================
-- VISUAL WALLHACK (highlight AlwaysOnTop)
-- ============================================================
local function createWallhackVisual(p)
    if p == LocalPlayer then return end
    local char = p.Character
    if not char then return end
    local old = char:FindFirstChild("ByVoidWH")
    if old then old:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "ByVoidWH"
    hl.FillColor = State.VisualColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char
    State.wallhackObjects[p] = hl
end

local function removeWallhackVisual(p)
    local char = p.Character
    if char then
        local hl = char:FindFirstChild("ByVoidWH")
        if hl then hl:Destroy() end
    end
    State.wallhackObjects[p] = nil
end

local function applyAllWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then createWallhackVisual(p) end
    end
end

local function clearAllWallhack()
    for _, p in ipairs(Players:GetPlayers()) do removeWallhackVisual(p) end
    State.wallhackObjects = {}
end

local function setVisual(v)
    State.VisualEnabled = v
    if v then applyAllWallhack() else clearAllWallhack() end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.VisualEnabled then createWallhackVisual(p) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if State.VisualEnabled then createWallhackVisual(p) end
        end)
    end
end

-- ============================================================
-- RESPAWN CLEANUP
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    State.savedCollide = {}
    State.carriedParts = {}
    if State.NoclipEnabled then startNoclip() end
    if State.VisualEnabled then applyAllWallhack() end
end)

-- ============================================================
-- UI — WINDUI
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "ByVoid",
    Subtitle = "No system is safe",
    Icon = "skull",
    Theme = "Dark",
    Size = UDim2.fromOffset(520, 400),
    Transparent = true,
    Resizable = true,
    Folder = "ByVoid",
    ToggleKeybind = Enum.KeyCode.RightShift,
})

local Tab = Window:Tab({
    Title = "Wallhack Noclip",
    Icon = "shield",
})

Tab:Toggle({
    Title = "Enable Noclip Wallhack",
    Description = "Tembus semua block. Player digendong ikut tembus.",
    Value = false,
    Callback = function(v) setNoclip(v) end,
})

Tab:Toggle({
    Title = "Visual Highlight",
    Description = "Sorot player lain lewat dinding (AlwaysOnTop).",
    Value = false,
    Callback = function(v) setVisual(v) end,
})

Tab:Colorpicker({
    Title = "Highlight Color",
    Default = Color3.fromRGB(255, 60, 60),
    Callback = function(color)
        State.VisualColor = color
        for _, hl in pairs(State.wallhackObjects) do
            if hl and hl.Parent then hl.FillColor = color end
        end
    end,
})

Tab:Paragraph({
    Title = "Info",
    Description = "Noclip: CanCollide = false di semua part karakter + part yang nempel (gendong/carry). Visual: Highlight AlwaysOnTop.",
})

WindUI:Notify({
    Title = "ByVoid",
    Content = "No system is safe — menu nyala",
    Icon = "check",
    Duration = 3,
})
