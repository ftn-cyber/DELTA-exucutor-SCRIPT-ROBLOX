--[[
    NEX GUI by NEXMO proratels
    Game : Steal an Egg (Roblox)
    Exec : Delta Executor
    Tema : Hijau + Biru Langit
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ================= CONFIG =================
local THEME = {
    Main    = Color3.fromRGB(20, 45, 40),   -- hijau gelap
    Second  = Color3.fromRGB(30, 70, 60),
    Accent1 = Color3.fromRGB(0, 200, 100),  -- hijau
    Accent2 = Color3.fromRGB(120, 200, 255),-- biru langit
    Text    = Color3.fromRGB(240, 255, 250),
    Off     = Color3.fromRGB(80, 80, 80),
}

local state = {
    FakeAdmin   = false,
    SafeZone    = false,
    Speed       = false,
    CosmicTP    = false,
    SpawnEgg    = false,
    CageLimit   = false,
}

-- ================= UI BUILDER =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NEXGUI_" .. math.random(1000,9999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 420)
Main.Position = UDim2.new(0.5, -160, 0.5, -210)
Main.BackgroundColor3 = THEME.Main
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = THEME.Accent2
Stroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "⚡ NEX GUI"
Title.TextColor3 = THEME.Accent2
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Main

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 16)
SubTitle.Position = UDim2.new(0, 0, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "by NEXMO proratels | Steal an Egg"
SubTitle.TextColor3 = THEME.Accent1
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    state.Speed = false
    state.CageLimit = false
    if Humanoid then Humanoid.WalkSpeed = 16 end
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -70)
Scroll.Position = UDim2.new(0, 8, 0, 58)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fungsi tombol toggle
local function createToggle(name, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 38)
    btn.BackgroundColor3 = THEME.Second
    btn.Text = "  " .. name .. "  [OFF]"
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", btn)
    st.Color = THEME.Off
    st.Thickness = 2

    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        local on = state[key]
        btn.Text = "  " .. name .. (on and "  [ON]" or "  [OFF]")
        st.Color = on and THEME.Accent1 or THEME.Off
        btn.BackgroundColor3 = on and THEME.Accent1 or THEME.Second
        if on then
            spawn(callback)
        end
    end)
end

-- ================= HELPER =================
local function getChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return Character
end

local function findBaseFolder()
    -- cari folder/map base
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Folder") or v:IsA("Model") then
            local n = string.lower(v.Name)
            if n:find("base") or n:find("plot") or n:find("cage") or n:find("kandang") then
                return v
            end
        end
    end
    return nil
end

local function fireRemote(...)
    local args = {...}
    -- coba remote umum di game
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            local n = string.lower(obj.Name)
            if n:find("egg") or n:find("spawn") or n:find("buy") or n:find("request") then
                pcall(function() obj:FireServer(unpack(args)) end)
            end
        end
    end
end

-- ================= FITUR 1 : FAKE ADMIN =================
createToggle("👑 Admin Palsu", "FakeAdmin", function()
    -- chat fake admin + badge palsu
    local ok, err = pcall(function()
        local msg = "[ADMIN SYSTEM]: " .. LocalPlayer.Name .. " has joined as ADMIN 🔒"
        local Chat = game:GetService("TextChatService")
        if Chat.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = Chat:FindFirstChild("TextChannels") and Chat.TextChannels:FindFirstChild("RBXGeneral")
            if channel then channel:DisplaySystemMessage(msg) end
        end
    end)
    if state.FakeAdmin then
        -- tampilkan tag ADMIN di atas kepala
        local ch = getChar()
        local head = ch:FindFirstChild("Head")
        if head and not head:FindFirstChild("NexAdminTag") then
            local bb = Instance.new("BillboardGui", head)
            bb.Name = "NexAdminTag"
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            local tl = Instance.new("TextLabel", bb)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = "👑 ADMIN"
            tl.TextColor3 = THEME.Accent1
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextStrokeTransparency = 0
        end
    else
        local ch = getChar()
        local head = ch:FindFirstChild("Head")
        if head then
            local t = head:FindFirstChild("NexAdminTag")
            if t then t:Destroy() end
        end
    end
end)

-- ================= FITUR 2 : TELEPORT ZONA AMAN =================
createToggle("🛡️ Teleport Zona Aman", "SafeZone", function()
    if state.SafeZone then
        -- cari / buat zona aman
        local safePart = workspace:FindFirstChild("NEX_SafeZone")
        if not safePart then
            safePart = Instance.new("Part")
            safePart.Name = "NEX_SafeZone"
            safePart.Size = Vector3.new(30, 1, 30)
            safePart.Position = Vector3.new(0, 500, 0)
            safePart.Anchored = true
            safePart.CanCollide = true
            safePart.Color = THEME.Accent1
            safePart.Material = Enum.Material.Neon
            safePart.Transparency = 0.3
            safePart.Parent = workspace
        end
        getChar():PivotTo(CFrame.new(safePart.Position + Vector3.new(0, 5, 0)))
    else
        local safePart = workspace:FindFirstChild("NEX_SafeZone")
        if safePart then
            getChar():PivotTo(CFrame.new(0, 50, 0))
        end
    end
end)

-- ================= FITUR 3 : UNLIMITED SPEED =================
createToggle("⚡ Unlimited Speed", "Speed", function()
    if state.Speed then
        -- loop dijalankan terus selama toggle ON (global, Client-side movement)
        spawn(function()
            while state.Speed do
                pcall(function()
                    local hum = getChar():FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 300
                        hum.UseJumpPower = true
                        hum.JumpPower = 120
                    end
                end)
                task.wait(0.2)
            end
        end)
    end
end)

-- ================= FITUR 4 : TELEPORT KE COSMIC =================
createToggle("🌌 Teleport ke Cosmic", "CosmicTP", function()
    if not state.CosmicTP then return end
    local cosmic = nil
    -- cari area Cosmic
    for _, v in pairs(workspace:GetDescendants()) do
        local n = string.lower(v.Name or "")
        if n:find("cosmic") or n:find("space") or n:find("galaxy") then
            if v:IsA("BasePart") or v:IsA("Model") then
                cosmic = v
                break
            end
        end
    end
    if cosmic then
        local pos = cosmic:IsA("Model")
            and cosmic:GetPivot().Position
            or cosmic.Position
        getChar():PivotTo(CFrame.new(pos + Vector3.new(0, 8, 0)))
    else
        -- fallback: teleport tinggi dengan efek cosmic
        getChar():PivotTo(CFrame.new(0, 1000, 0))
    end
end)

-- ================= FITUR 5 : SPAWN EGG =================
createToggle("🥚 Spawn Egg", "SpawnEgg", function()
    if not state.SpawnEgg then return end
    spawn(function()
        while state.SpawnEgg do
            pcall(function()
                -- coba remote spawn egg yang ada di game
                fireRemote("SpawnEgg")
                fireRemote("SpawnEggRequest")
                fireRemote("RequestEgg")
                -- fallback: buat egg visual + sinyal ke server
                local ch = getChar()
                local egg = Instance.new("Part")
                egg.Name = "NEX_Egg"
                egg.Shape = Enum.PartType.Egg -- fallback jadi ball jika tidak ada
                egg.Size = Vector3.new(1.5, 2, 1.5)
                egg.Material = Enum.Material.Neon
                egg.Color = Color3.fromRGB(0, 255, 120)
                egg.CFrame = ch:GetPivot() + Vector3.new(0, 5, 0)
                egg.Anchored = false
                egg.CanCollide = false
                egg.Parent = workspace
                game:GetService("Debris"):AddItem(egg, 10)
            end)
            task.wait(1)
        end
    end)
end)

-- ================= FITUR 6 : UNLIMITED BATAS KANDANG =================
createToggle("🏠 Unlimited Batas Kandang", "CageLimit", function()
    if state.CageLimit then
        -- nonaktifkan limit lokal + kunci base/cage
        spawn(function()
            while state.CageLimit do
                pcall(function()
                    -- hapus semua barier/pagar yang jadi limit
                    local base = findBaseFolder()
                    if base then
                        for _, v in pairs(base:GetDescendants()) do
                            if v:IsA("BasePart") then
                                local n = string.lower(v.Name)
                                if n:find("wall") or n:find("barrier") or n:find("limit") or n:find("fence") or n:find("border") then
                                    v.CanCollide = false
                                    v.Transparency = 0.7
                                end
                            end
                        end
                    end
                    -- coba remote untuk unlimited slots (ke server)
                    fireRemote("MaxSlots")
                    fireRemote("UpgradeCage")
                    fireRemote("BuySlot")
                end)
                task.wait(1)
            end
        end)
    end
end)

-- ================= AUTO RE-APPLY SETIAP RESPAWN =================
LocalPlayer.CharacterAdded:Connect(function(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid")
    if state.FakeAdmin then
        task.wait(1)
        getChar()
        local head = Character:FindFirstChild("Head")
        if head and not head:FindFirstChild("NexAdminTag") then
            local bb = Instance.new("BillboardGui", head)
            bb.Name = "NexAdminTag"
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            local tl = Instance.new("TextLabel", bb)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = "👑 ADMIN"
            tl.TextColor3 = THEME.Accent1
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextStrokeTransparency = 0
        end
    end
    if state.Speed then
        Humanoid.WalkSpeed = 300
    end
end)

print("✅ NEX GUI by NEXMO proratels loaded! - Steal an Egg")
