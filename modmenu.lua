--[[
    ByVoid — No system is safe
    fitur tunggal: wallhack noclip
      - tembus SEMUA block
      - player digendong/carry/grab IKUT tembus (fix)
      - visual highlight AlwaysOnTop
    ui: Fluent (dark, clean, modern)
    absolute ollie, built by olivia
--]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

local function getChar() return LocalPlayer.Character end

-- ============================================================
-- DETEKSI PART YANG NEMPEL KE KARAKTER LOKAL (FIX CARRY)
-- ============================================================
-- cek semua jenis joint/weld/constraint yang mungkin dipakai game
local function isAttachedToLocal(part)
    if not part or not part.Parent then return false end
    local char = getChar()
    if not char then return false end
    if part:IsDescendantOf(char) then return false end

    -- cek semua JointInstance (Weld, Motor6D, Snap, Rotate, dll)
    for _, joint in ipairs(part:GetJoints()) do
        local other = (joint.Part0 == part) and joint.Part1 or joint.Part0
        if other and other:IsDescendantOf(char) then return true end
    end

    -- cek child constraint (WeldConstraint, AlignPosition, AlignOrientation, dll)
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("WeldConstraint") then
            local other = (child.Part0 == part) and child.Part1 or child.Part0
            if other and other:IsDescendantOf(char) then return true end
        end
        if child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
            local att = child.Attachment0 or child.Attachment1
            if att and att:IsDescendantOf(char) then return true end
        end
        if child:IsA("Attachment") then
            for _, c2 in ipairs(child:GetChildren()) do
                if c2:IsA("AlignPosition") or c2:IsA("AlignOrientation") then
                    local att = c2.Attachment0 or c2.Attachment1
                    if att and att:IsDescendantOf(char) then return true end
                end
            end
        end
    end

    -- cek parent part juga (kadang constraint nempel di parent)
    local parent = part.Parent
    if parent and parent:IsA("Model") then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("WeldConstraint") then
                if child.Part0 == part or child.Part1 == part then
                    local other = (child.Part0 == part) and child.Part1 or child.Part0
                    if other and other:IsDescendantOf(char) then return true end
                end
            end
        end
    end

    return false
end

-- FALLBACK: cek jarak — kalau part deket banget ke HRP lokal, anggap digendong
local function isNearLocal(part)
    if not part or not part.Parent then return false end
    local char = getChar()
    if not char then return false end
    if part:IsDescendantOf(char) then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local dist = (part.Position - hrp.Position).Magnitude
    return dist < 6 -- radius 6 stud dari HRP = kemungkinan digendong
end

-- scan seluruh workspace, tandai part yang nempel ATAU deket karakter lokal
local function setCarriedPartsNoclip()
    local char = getChar()
    if not char then return end
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and not part:IsDescendantOf(char) then
            local attached = isAttachedToLocal(part)
            local near = false
            if not attached then
                near = isNearLocal(part)
            end
            if attached or near then
                if State.carriedParts[part] == nil then
                    State.carriedParts[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end
end

-- ============================================================
-- NOCLIP
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

local function restoreCarriedParts()
    for part, orig in pairs(State.carriedParts) do
        if part and part.Parent then part.CanCollide = orig end
    end
    State.carriedParts = {}
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
-- VISUAL
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

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    State.savedCollide = {}
    State.carriedParts = {}
    if State.NoclipEnabled then startNoclip() end
    if State.VisualEnabled then applyAllWallhack() end
end)

-- ============================================================
-- UI — FLUENT
-- ============================================================
local Window = Fluent:CreateWindow({
    Title = "ByVoid",
    SubTitle = "No system is safe",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift,
})

local Tabs = {
    Main = Window:AddTab({ Title = "Wallhack", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

Tabs.Main:AddToggle("NoclipToggle", {
    Title = "Enable Noclip Wallhack",
    Description = "Tembus semua block. Player digendong ikut tembus.",
    Default = false,
}):OnChanged(function(v) setNoclip(v) end)

Tabs.Main:AddToggle("VisualToggle", {
    Title = "Visual Highlight",
    Description = "Sorot player lain lewat dinding (AlwaysOnTop).",
    Default = false,
}):OnChanged(function(v) setVisual(v) end)

Tabs.Main:AddColorpicker("VisualColor", {
    Title = "Highlight Color",
    Default = Color3.fromRGB(255, 60, 60),
}):OnChanged(function(color)
    State.VisualColor = color
    for _, hl in pairs(State.wallhackObjects) do
        if hl and hl.Parent then hl.FillColor = color end
    end
end)

Tabs.Main:AddParagraph({
    Title = "Info",
    Content = "Noclip: CanCollide=false di karakter + part nempel/deket (gendong/carry). Visual: Highlight AlwaysOnTop.",
})

Tabs.Settings:AddParagraph({
    Title = "ByVoid",
    Content = "No system is safe.\nBuild by olivia.",
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ByVoid")
SaveManager:SetFolder("ByVoid/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

Fluent:Notify({
    Title = "ByVoid",
    Content = "No system is safe — menu nyala",
    Duration = 3,
})
