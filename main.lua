-- ==========================================
-- SCRIPT COMPLETO - CHRISTIAN PRIV (MOBILE)
-- ==========================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Separador
-- CONFIGURACIÓN DE TEMA ROJIZO Y TRANSPARENCIA
-- Separador

WindUI:AddTheme({
    Name = "RedTranslucent",
    Accent = Color3.fromHex("B30000"),
    Background = Color3.fromHex("1F0505"),
    Outline = Color3.fromHex("990000"),
    Text = Color3.fromHex("FFFFFF"),
    Placeholder = Color3.fromHex("CCCCCC"),
    Button = Color3.fromHex("4D0808"),
    Icon = Color3.fromHex("FF3333"),
})

WindUI.TransparencyValue = 0.45
WindUI:SetTheme("RedTranslucent")

local Window = WindUI:CreateWindow({
    Title = "Christian Priv",
    Folder = "PrivateChris_Mobile",
    Size = UDim2.fromOffset(500, 420),
    Theme = "RedTranslucent",
    Transparent = true,
    HidePanelBackground = false,
    NewElements = false,
})

Window:EditOpenButton({
    Title = "Priv Chris",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("990000"), -- Rojo
        Color3.fromHex("1A1A1A")  -- Negro
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Separador
-- SERVICIOS Y VARIABLES GLOBALES
-- Separador

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local statsService = game:GetService("Stats")
local lighting = game:GetService("Lighting")
local virtualInputManager = game:GetService("VirtualInputManager")
local workspaceService = game:GetService("Workspace")
local userInputService = game:GetService("UserInputService")
local virtualUser = game:GetService("VirtualUser")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local RS = replicatedStorage

-- Estados para Alien y Pets
local state = {
    AutoPunch = false,
    AutoFarmAlienBoss = false,
    AutoAlienMachines = false,
    AutoBuyAlienShop = false
}

local autoSell = {
    Enabled = false,
    Conn = nil,
    SellInterval = 0.3,
    LastSell = 0,
    Status = "Idle",
    Sold = 0,
    TargetPets = { UFOBot = true, CosmicInvader = false, AlienSlime = false },
    KeepOneUFOBot = false,
}

local alienShopItems = {
    { Name = "Lunar Slug", Key = "LunarSlug", Price = 2400 },
    { Name = "UFO Axolotl", Key = "UFOAxolotl", Price = 4800 },
    { Name = "Alien Serum", Key = "AlienSerum", Price = 3000 },
    { Name = "Plasma Dumbbell", Key = "PlasmaDumbbell", Price = 200 },
    { Name = "Alien Bar", Key = "AlienBar", Price = 250 },
    { Name = "Alien Pull-Up Bar", Key = "AlienPullUpBar", Price = 300 },
    { Name = "Alien Treadmill", Key = "AlienTreadmill", Price = 350 }
}
local selectedShopItems = {}

local punchTask = nil
local alienBossTask = nil
local alienMachineTask = nil
local alienShopTask = nil

-- Separador
-- FUNCIONES AUXILIARES
-- Separador

local function getCharacter()
    return localPlayer.Character
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function jitter(base, variance)
    base = base or 0.01
    variance = variance or 0.005
    return base + (math.random() * variance * 2 - variance)
end

local function updatePara(paraObj, text)
    if not paraObj then return end
    pcall(function()
        if type(paraObj.SetDesc) == "function" then
            paraObj:SetDesc(tostring(text))
            return
        end
        if paraObj.Desc and type(paraObj.Desc) == "userdata" and paraObj.Desc.Text ~= nil then
            paraObj.Desc.Text = tostring(text)
            return
        end
        if paraObj.TextLabel and paraObj.TextLabel.Text ~= nil then
            paraObj.TextLabel.Text = tostring(text)
        end
    end)
end

local function formatNum(p1)
    local list = {
        { "Qi", 1e18 },
        { "Qa", 1e15 },
        { "T", 1e12 },
        { "B", 1e9 },
        { "M", 1e6 },
        { "K", 1e3 },
    }
    for _, value in ipairs(list) do
        if p1 >= value[2] then
            return string.format("%.2f%s", p1 / value[2], value[1])
        end
    end
    return tostring(math.floor(p1))
end

local function fmtRate(r)
    return "Per second: " .. formatNum(r) ..
        "\nPer minute: " .. formatNum(r * 60) ..
        "\nPer hour: " .. formatNum(r * 3600) ..
        "\nPer day: " .. formatNum(r * 86400) ..
        "\nPer week: " .. formatNum(r * 604800)
end

local function getStats()
    local ls = localPlayer:FindFirstChild("leaderstats")
    if not ls then return { Str = 0, Dur = 0, Reb = 0 } end
    local s = ls:FindFirstChild("Strength")
    local d = ls:FindFirstChild("Durability")
    local r = ls:FindFirstChild("Rebirths")
    return {
        Str = s and s.Value or 0,
        Dur = d and d.Value or 0,
        Reb = r and r.Value or 0,
    }
end

local function startAutoPunch()
    if state.AutoPunch then return end
    state.AutoPunch = true
    punchTask = task.spawn(function()
        while state.AutoPunch do
            local char = localPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local ev = localPlayer:FindFirstChild("muscleEvent") or localPlayer:FindFirstChild("MuscleEvent")
                if ev then
                    pcall(function()
                        ev:FireServer("punch", "leftHand")
                        ev:FireServer("punch", "rightHand")
                    end)
                end
            end
            runService.Heartbeat:Wait()
        end
    end)
end

-- Separador
-- BILLBOARD DE VIDA (HP)
-- Separador

task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    task.wait(1)
    
    local function makeTextLabel(humanoid, instance)
        if not instance:FindFirstChild("Head") then return end
        local hpBILLBOARD = instance:FindFirstChild("HP_BILLBOARD")
        if hpBILLBOARD then hpBILLBOARD:Destroy() end
        
        local hpBILLBOARD2 = Instance.new("BillboardGui")
        hpBILLBOARD2.Name = "HP_BILLBOARD"
        hpBILLBOARD2.Size = UDim2.new(6, 0, 1.2, 0)
        hpBILLBOARD2.StudsOffset = Vector3.new(0, 3.5, 0)
        hpBILLBOARD2.AlwaysOnTop = true
        hpBILLBOARD2.MaxDistance = 200
        hpBILLBOARD2.Parent = instance.Head
        
        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.3
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.Parent = hpBILLBOARD2
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = frame
        
        local frame2 = Instance.new("Frame")
        frame2.BackgroundColor3 = Color3.fromRGB(153, 0, 0)
        frame2.Size = UDim2.new(1, 0, 1, 0)
        frame2.BorderSizePixel = 0
        frame2.Parent = frame
        
        local uiGradient = Instance.new("UIGradient")
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(153, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        })
        uiGradient.Parent = frame2
        
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 18
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = frame
        
        local function updateHealth()
            if humanoid and humanoid.Parent then
                local health = humanoid.Health
                local maxHealth = humanoid.MaxHealth
                frame2.Size = UDim2.new(math.clamp(health / maxHealth, 0, 1), 0, 1, 0)
                textLabel.Text = formatNum(health) .. " / " .. formatNum(maxHealth)
            end
        end
        humanoid.HealthChanged:Connect(updateHealth)
        updateHealth()
    end

    local function setupCharacter(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then makeTextLabel(humanoid, character) end
    end

    for _, p in ipairs(players:GetPlayers()) do
        if p.Character then setupCharacter(p.Character) end
        p.CharacterAdded:Connect(setupCharacter)
    end
    players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(setupCharacter)
    end)
end)

-- Separador
-- AUTOMATIZACIÓN DE BOSSES
-- Separador

local REGULAR_BOSS_NAMES = {"Boss1", "Boss2", "Boss3", "Boss4", "Boss5", "RainbowBoss"}
local REGULAR_BOSS_FULL = {
    ["Boss1"]="Common Boss", ["Boss2"]="Rare Boss", ["Boss3"]="Epic Boss",
    ["Boss4"]="Legendary Boss", ["Boss5"]="Mythical Boss", ["RainbowBoss"]="Rainbow Boss"
}

local SelectedBosses = {}
for _, n in ipairs(REGULAR_BOSS_NAMES) do SelectedBosses[n] = true end

local BossState = { AutoFarmBoss = false, CurrentBoss = "None" }
local BossCache = { Arena = nil, LastCheck = 0 }

local function getBossTargets()
    local bosses, seen = {}, {}
    local myChar = localPlayer.Character
    local function add(m)
        if m and m:IsA("Model") and m ~= myChar and not seen[m] and m:IsDescendantOf(workspaceService) then
            if not SelectedBosses[m.Name] then return end
            seen[m] = true; table.insert(bosses, m)
        end
    end
    if (not BossCache.Arena or not BossCache.Arena.Parent) and tick() - (BossCache.LastCheck or 0) >= 2 then
        BossCache.LastCheck = tick()
        local events = workspaceService:FindFirstChild("Events")
        BossCache.Arena = events and events:FindFirstChild("BossArena")
        if not BossCache.Arena then
            for _, v in ipairs(workspaceService:GetDescendants()) do
                if v.Name == "BossArena" and v:IsA("Folder") then BossCache.Arena = v; break end
            end
        end
    end
    if BossCache.Arena then for _, obj in ipairs(BossCache.Arena:GetChildren()) do if SelectedBosses[obj.Name] then add(obj) end end end
    for _, m in ipairs(game:GetService("CollectionService"):GetTagged("BossEventBoss")) do if SelectedBosses[m.Name] then add(m) end end
    return bosses
end

local function ensureBossHitbox(model)
    if not model then return nil end
    local existing = model:FindFirstChild("Hitbox")
    if existing and existing:IsA("BasePart") then return existing end
    local rootPart = model:FindFirstChild("BossDamageHitbox", true) or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return nil end
    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"; hitbox.Size = Vector3.new(12, 12, 12); hitbox.Transparency = 1
    hitbox.CanCollide = false; hitbox.CanQuery = true; hitbox.CanTouch = true; hitbox.Massless = true; hitbox.Anchored = false
    hitbox.CFrame = rootPart.CFrame
    local weld = Instance.new("WeldConstraint"); weld.Part0 = rootPart; weld.Part1 = hitbox; weld.Parent = hitbox
    hitbox.Parent = model
    return hitbox
end

local function readBossHealth(model)
    local stats = model:FindFirstChild("stats")
    local hp = stats and stats:FindFirstChild("Health")
    local mx = stats and stats:FindFirstChild("MaxHealth")
    if hp and hp:IsA("ValueBase") and type(hp.Value) == "number" then return hp.Value, (mx and tonumber(mx.Value)) or hp.Value end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    local attr = tonumber(model:GetAttribute("Health"))
    if attr then return attr, tonumber(model:GetAttribute("MaxHealth")) or attr end
    return nil, nil
end

local function bossAttackOnce(model, hitbox)
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local backpack = localPlayer:FindFirstChild("Backpack")
    local punch = character:FindFirstChild("Punch") or (backpack and backpack:FindFirstChild("Punch"))
    if punch and punch.Parent == backpack then humanoid:EquipTool(punch) end
    local head = model:FindFirstChild("Head", true)
    local headPos = head and head.Position or (hitbox.Position + Vector3.new(0, hitbox.Size.Y * 0.35, 0))
    root.CFrame = CFrame.lookAt(headPos + Vector3.new(0, 8, 0), headPos)
    root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
    local leftHand = character:FindFirstChild("LeftHand"); local rightHand = character:FindFirstChild("RightHand")
    if leftHand and rightHand then
        pcall(function()
            firetouchinterest(hitbox, rightHand, 0); firetouchinterest(hitbox, rightHand, 1)
            firetouchinterest(hitbox, leftHand, 0); firetouchinterest(hitbox, leftHand, 1)
        end)
    end
    local ev = localPlayer:FindFirstChild("muscleEvent") or localPlayer:FindFirstChild("MuscleEvent")
    if ev then pcall(function() ev:FireServer("punch", "leftHand"); ev:FireServer("punch", "rightHand") end) end
    if punch and punch.Parent == character then pcall(function() punch:Activate() end) end
end

local claimedBossChests = setmetatable({}, { __mode = "k" })
local function findBossChest()
    for _, c in ipairs(game:GetService("CollectionService"):GetTagged("BossEventChest")) do
        if c:IsDescendantOf(workspaceService) and not claimedBossChests[c] then
            local prompt = c:FindFirstChild("bossChestPrompt", true)
            local part = (prompt and prompt.Parent) or (c:IsA("BasePart") and c) or (c:IsA("Model") and (c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart", true)))
            if part and part:IsA("BasePart") then return c, prompt, part end
        end
    end
    for _, d in ipairs(workspaceService:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Name == "bossChestPrompt" then
            local p = d.Parent
            if p and p:IsA("Attachment") then p = p.Parent end
            if p and p:IsA("BasePart") and not claimedBossChests[p] then return p, d, p end
        end
    end
    return nil
end

local function claimBossChest(chest, prompt, part)
    claimedBossChests[chest] = true
    task.wait(0.3)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and part.Parent then pcall(function() root.CFrame = CFrame.lookAt(part.Position + Vector3.new(0, 3, 4), part.Position); root.AssemblyLinearVelocity = Vector3.zero end) end
    task.wait(0.2)
    local attempts = 0
    while BossState.AutoFarmBoss and chest.Parent and attempts < 6 do
        attempts = attempts + 1
        local fired = false
        if prompt and prompt.Parent and type(fireproximityprompt) == "function" then fired = pcall(fireproximityprompt, prompt) end
        if not fired then pcall(function() virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end) end
        task.wait(0.5)
    end
end

local function startAutoFarmBoss()
    if BossState.AutoFarmBoss then return end
    BossState.AutoFarmBoss = true
    local lastChestCheck = 0
    task.spawn(function()
        while BossState.AutoFarmBoss do
            pcall(function()
                local chest, prompt, part
                if tick() - lastChestCheck >= 1 then lastChestCheck = tick(); chest, prompt, part = findBossChest() end
                if chest and part and chest:GetAttribute("BossChestEmerging") ~= true then
                    BossState.CurrentBoss = "Claiming chest..."
                    claimBossChest(chest, prompt, part); return
                end
                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local target, bestDist = nil, math.huge
                for _, m in ipairs(getBossTargets()) do
                    local hp = readBossHealth(m)
                    if hp == nil or hp > 0 then
                        local part2 = m:FindFirstChild("BossDamageHitbox", true) or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
                        local d = (hrp and part2) and (hrp.Position - part2.Position).Magnitude or 0
                        if d < bestDist then target, bestDist = m, d end
                    end
                end
                if not target then BossState.CurrentBoss = "Waiting for boss..."; return end
                local hitbox = target:FindFirstChild("BossDamageHitbox", true)
                if not (hitbox and hitbox:IsA("BasePart")) then hitbox = ensureBossHitbox(target) end
                if not hitbox then return end
                BossState.CurrentBoss = REGULAR_BOSS_FULL[target.Name] or target.Name
                bossAttackOnce(target, hitbox)
            end)
            task.wait(0.01)
        end
    end)
end

local function stopAutoFarmBoss()
    BossState.AutoFarmBoss = false; BossState.CurrentBoss = "None"
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then pcall(function() hrp.Anchored = false end) end
    local arena = BossCache.Arena
    if arena then for _, obj in ipairs(arena:GetChildren()) do if obj:IsA("Model") then local hb = obj:FindFirstChild("Hitbox"); if hb then hb:Destroy() end end end end
end

-- Separador
-- FUNCIONES DE ALIEN (BOSS, MÁQUINAS Y TIENDA)
-- Separador

local function findAlienBoss()
    local boss = workspace:FindFirstChild("Alien Boss")
    if boss and boss:IsA("Model") then
        local hpVal = boss:FindFirstChild("alienBossHealth", true)
        local hum = boss:FindFirstChildOfClass("Humanoid")
        if hpVal and hpVal:IsA("ValueBase") and hpVal.Value <= 0 then return nil end
        if hum and hum.Health <= 0 then return nil end
        return boss
    end
    local globalHp = workspace:FindFirstChild("alienBossHealth", true)
    if globalHp and globalHp:IsA("ValueBase") and globalHp.Value > 0 then
        local model = globalHp:FindFirstAncestorOfClass("Model")
        if model then return model end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            if (string.find(nameLower, "alien boss") or string.find(nameLower, "alienboss")) and not string.find(nameLower, "arena") then
                local hpVal = obj:FindFirstChild("alienBossHealth", true)
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hpVal and hpVal:IsA("ValueBase") and hpVal.Value <= 0 then
                elseif hum and hum.Health <= 0 then
                else
                    return obj
                end
            end
        end
    end
    return nil
end

local function claimAlienChest()
    local char = getCharacter()
    local root = getRoot()
    if not char or not root then return end
    local chest = workspace:FindFirstChild("Alien Chest", true)
    if not chest then
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), "chest") then
                chest = obj
                break
            end
        end
    end
    if chest then
        local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart", true)
        if part then
            root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 4))
            task.wait(0.2)
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            local click = chest:FindFirstChildWhichIsA("ClickDetector", true)
            if prompt then
                local origDist = prompt.MaxActivationDistance
                prompt.MaxActivationDistance = 999999
                pcall(fireproximityprompt, prompt)
                prompt.MaxActivationDistance = origDist
            elseif click then
                pcall(fireclickdetector, click)
            else
                pcall(function()
                    firetouchinterest(part, root, 0)
                    firetouchinterest(part, root, 1)
                end)
            end
        end
    end
    task.wait(0.5)
    for _, btn in ipairs(PlayerGui:GetDescendants()) do
        if btn:IsA("TextButton") and btn.Visible then
            local txt = string.lower(btn.Text)
            if string.find(txt, "open") then
                if getconnections then
                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                        if conn.Fire then
                            pcall(function() conn:Fire() end)
                        end
                    end
                else
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    pcall(function()
                        virtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, game, 0)
                        virtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, game, 0)
                    end)
                end
            end
        end
    end
end

local function startAlienBossFarm()
    state.AutoFarmAlienBoss = true
    if alienBossTask then task.cancel(alienBossTask) end
    alienBossTask = task.spawn(function()
        local bossWasPresent = false
        while state.AutoFarmAlienBoss do
            pcall(function()
                local boss = findAlienBoss()
                if boss then
                    bossWasPresent = true
                    if getgenv().AlienStatusLbl then
                        updatePara(getgenv().AlienStatusLbl, "Attacking: " .. boss.Name)
                    end
                    local hitbox = boss:FindFirstChild("BossDamageHitbox", true)
                    if not (hitbox and hitbox:IsA("BasePart")) then
                        hitbox = ensureBossHitbox(boss)
                    end
                    if hitbox then
                        bossAttackOnce(boss, hitbox)
                    end
                else
                    if bossWasPresent then
                        if getgenv().AlienStatusLbl then
                            updatePara(getgenv().AlienStatusLbl, "Boss dead! Claiming chest...")
                        end
                        task.wait(1)
                        claimAlienChest()
                        task.wait(2)
                        bossWasPresent = false
                    else
                        if getgenv().AlienStatusLbl then
                            updatePara(getgenv().AlienStatusLbl, "Waiting for boss...")
                        end
                    end
                end
            end)
            task.wait(jitter(0.05, 0.01))
        end
    end)
end

local function stopAlienBossFarm()
    state.AutoFarmAlienBoss = false
    if alienBossTask then
        task.cancel(alienBossTask)
        alienBossTask = nil
    end
    if getgenv().AlienStatusLbl then
        updatePara(getgenv().AlienStatusLbl, "Idle")
    end
end

local function startAutoAlienMachines()
    if alienMachineTask then task.cancel(alienMachineTask) end
    alienMachineTask = task.spawn(function()
        while state.AutoAlienMachines do
            pcall(function()
                local char = getCharacter()
                local root = getRoot()
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum then
                    task.wait(1)
                    return
                end
                local machine = nil
                local machinesFolder = workspace:FindFirstChild("machinesFolder")
                if machinesFolder then
                    for _, obj in ipairs(machinesFolder:GetChildren()) do
                        local n = string.lower(obj.Name)
                        if string.find(n, "alien") or string.find(n, "plasma") then
                            machine = obj
                            break
                        end
                    end
                end
                if not machine then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") then
                            local n = string.lower(obj.Name)
                            local isAlien = string.find(n, "alien") or string.find(n, "plasma")
                            local isGym = string.find(n, "bar") or string.find(n, "treadmill") or string.find(n, "dumbbell") or string.find(n, "pullup") or string.find(n, "pull%-up") or string.find(n, "machine") or string.find(n, "bench")
                            if isAlien and isGym then
                                machine = obj
                                break
                            end
                        end
                    end
                end
                if machine then
                    local prompt = machine:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local seat = machine:FindFirstChildWhichIsA("Seat", true) or machine:FindFirstChildWhichIsA("VehicleSeat", true)
                    local targetPart = nil
                    if prompt then
                        if prompt.Parent:IsA("BasePart") then
                            targetPart = prompt.Parent
                        elseif prompt.Parent:IsA("Attachment") then
                            targetPart = prompt.Parent.Parent
                        end
                    end
                    if not targetPart then
                        targetPart = seat or machine:FindFirstChildWhichIsA("BasePart", true)
                    end
                    if targetPart and not hum.Sit then
                        if root.Anchored then root.Anchored = false end
                        root.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                        local bp = localPlayer:FindFirstChild("Backpack")
                        if bp then
                            for _, tool in ipairs(bp:GetChildren()) do
                                if tool:IsA("Tool") then
                                    local tName = string.lower(tool.Name)
                                    if string.find(tName, "alien") or string.find(tName, "plasma") then
                                        pcall(function() hum:EquipTool(tool) end)
                                        break
                                    end
                                end
                            end
                        end
                        if prompt then
                            local origDist = prompt.MaxActivationDistance
                            prompt.MaxActivationDistance = 999999
                            pcall(fireproximityprompt, prompt)
                            task.wait(0.1)
                            prompt.MaxActivationDistance = origDist
                        end
                        if seat then
                            pcall(function() hum.Sit = true end)
                        end
                        pcall(function()
                            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end)
                    end
                end
                if not state.AutoPunch then
                    startAutoPunch()
                end
            end)
            task.wait(1)
        end
    end)
end

local function startAutoBuyAlienShop()
    if alienShopTask then task.cancel(alienShopTask) end
    alienShopTask = task.spawn(function()
        while state.AutoBuyAlienShop do
            pcall(function()
                local pkg = RS:FindFirstChild("packages")
                local net = pkg and pkg:FindFirstChild("Net")
                local rf = net and net:FindFirstChild("RF/AlienShop")
                if rf and rf:IsA("RemoteFunction") then
                    for _, item in pairs(selectedShopItems) do
                        if not state.AutoBuyAlienShop then break end
                        pcall(function() rf:InvokeServer(item.Key) end)
                        task.wait(0.5)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- Separador
-- FUNCIONES DE PETS (AUTO SELL PETS)
-- Separador

local function normalizeName(str)
    return string.lower(str):gsub("[%s_%-%.]", "")
end

local function findSellRemote()
    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        for _, name in ipairs({"sellPetEvent", "sellPetRemote", "sellPet", "sellPetsEvent", "sellPetFunction"}) do
            local obj = rEvents:FindFirstChild(name)
            if obj and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                return obj, "rEvents." .. name
            end
        end
        for _, obj in ipairs(rEvents:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = string.lower(obj.Name)
                if string.find(n, "sell") and string.find(n, "pet") then
                    return obj, "rEvents." .. obj.Name
                end
            end
        end
    end
    local pkg = RS:FindFirstChild("packages")
    local net = pkg and pkg:FindFirstChild("Net")
    if net then
        for _, obj in ipairs(net:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = string.lower(obj.Name)
                if string.find(n, "sell") and string.find(n, "pet") then
                    return obj, "Net." .. obj.Name
                end
            end
        end
    end
    return nil, nil
end

local function sellPet(remote, petInstance)
    if not remote or not petInstance or not petInstance.Parent then return false end
    local ok = pcall(function()
        if remote:IsA("RemoteFunction") then
            remote:InvokeServer("sellPet", petInstance)
        else
            remote:FireServer("sellPet", petInstance)
        end
    end)
    return ok
end

local function getPetsToSell()
    local toSell = {}
    local petsFolder = localPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return toSell end
    local ufoBots, cosmicInvaders, alienSlimes = {}, {}, {}
    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                local n = normalizeName(pet.Name)
                if n == "ufobot" then
                    table.insert(ufoBots, pet)
                elseif n == "cosmicinvader" then
                    table.insert(cosmicInvaders, pet)
                elseif n == "alienslime" then
                    table.insert(alienSlimes, pet)
                end
            end
        end
    end
    if autoSell.TargetPets.UFOBot then
        local count = #ufoBots
        if autoSell.KeepOneUFOBot then
            count = math.max(0, count - 1)
        end
        for i = 1, count do
            table.insert(toSell, ufoBots[i])
        end
    end
    if autoSell.TargetPets.CosmicInvader then
        for _, pet in ipairs(cosmicInvaders) do
            table.insert(toSell, pet)
        end
    end
    if autoSell.TargetPets.AlienSlime then
        for _, pet in ipairs(alienSlimes) do
            table.insert(toSell, pet)
        end
    end
    return toSell
end

local function startAutoSell()
    if autoSell.Enabled then return end
    autoSell.Enabled = true
    autoSell.Sold = 0
    autoSell.LastSell = 0
    if autoSell.Conn then task.cancel(autoSell.Conn) end
    autoSell.Conn = task.spawn(function()
        local remote, remoteName = findSellRemote()
        if not remote then
            autoSell.Status = "❌ No sell remote found"
            autoSell.Enabled = false
            return
        end
        autoSell.Status = "Using " .. remoteName
        while autoSell.Enabled do
            pcall(function()
                local now = tick()
                if now - autoSell.LastSell >= autoSell.SellInterval then
                    local pets = getPetsToSell()
                    if #pets > 0 then
                        for _, pet in ipairs(pets) do
                            if not autoSell.Enabled then break end
                            if sellPet(remote, pet) then
                                autoSell.Sold = autoSell.Sold + 1
                            end
                            task.wait(0.03)
                        end
                        autoSell.Status = "💰 Total sold: " .. autoSell.Sold
                    else
                        autoSell.Status = "⏳ Waiting for target pets..."
                    end
                    autoSell.LastSell = tick()
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function stopAutoSell()
    autoSell.Enabled = false
    if autoSell.Conn then
        task.cancel(autoSell.Conn)
        autoSell.Conn = nil
    end
    autoSell.Status = "Idle"
end

-- Separador
-- 1. PESTAÑA: SPEED FARM
-- Separador

local speedFarmTab = Window:Tab({ Title = "Speed Farm", Icon = "zap" })
local speedSection = speedFarmTab:Section({ Title = "Estadísticas y Control" })

local fastRepTimeLbl = speedSection:Paragraph({ Title = "Fast Rep Time", Desc = "0d 0h 0m 0s" })
local strengthRateLbl = speedSection:Paragraph({ Title = "Strength Rate", Desc = fmtRate(0) })
local durabilityRateLbl = speedSection:Paragraph({ Title = "Durability Rate", Desc = fmtRate(0) })

local strengthStatsLbl = speedSection:Paragraph({ Title = "Strength", Desc = "0 | Gained: 0" })
local durabilityStatsLbl = speedSection:Paragraph({ Title = "Durability", Desc = "0 | Gained: 0" })

local repSpeedVal = 55
speedSection:Input({
    Title = "Velocidad de Reps",
    Value = "50",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then repSpeedVal = num end
    end
})

speedSection:Toggle({
    Title = "Fast Rep",
    Default = false,
    Callback = function(state)
        getgenv()._AutoRepFarmEnabled = state
    end
})

local autoEquipWeightActive = false
speedSection:Toggle({
    Title = "Auto Equip Weight",
    Default = false,
    Callback = function(state)
        autoEquipWeightActive = state
        if state then
            task.spawn(function()
                while autoEquipWeightActive do
                    local char = localPlayer.Character
                    local backpack = localPlayer:FindFirstChild("Backpack")
                    if char and backpack then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "weight") then
                                tool.Parent = char
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

task.spawn(function()
    local flag = false
    while true do
        if getgenv()._AutoRepFarmEnabled then
            local ok, ping = pcall(function()
                return statsService.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            local p = ok and ping or 999
            if p > 5000 then flag = true elseif p <= 300 then flag = false end
            if not flag and localPlayer:FindFirstChild("muscleEvent") then
                for m = 1, repSpeedVal do
                    if not getgenv()._AutoRepFarmEnabled then break end
                    localPlayer.muscleEvent:FireServer("rep")
                end
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    task.wait(2)
    local initialStats = getStats()
    local initialStrength = initialStats.Str
    local initialDurability = initialStats.Dur
    local startTimeTick = tick()

    local lastSampleTime = tick()
    local lastSampleStr = initialStrength
    local lastSampleDur = initialDurability

    while true do
        local currentTime = tick()
        local stats = getStats()
        local currentStr = stats.Str
        local currentDur = stats.Dur
        local elapsed = currentTime - startTimeTick
        
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        fastRepTimeLbl:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))
        strengthStatsLbl:SetDesc("Strength: " .. formatNum(currentStr) .. " | Gained: " .. formatNum(currentStr - initialStrength))
        durabilityStatsLbl:SetDesc("Durability: " .. formatNum(currentDur) .. " | Gained: " .. formatNum(currentDur - initialDurability))
        
        local dt = currentTime - lastSampleTime
        if dt >= 10 then
            local strPerSec = (currentStr - lastSampleStr) / dt
            local durPerSec = (currentDur - lastSampleDur) / dt
            strengthRateLbl:SetDesc(fmtRate(strPerSec))
            durabilityRateLbl:SetDesc(fmtRate(durPerSec))
            lastSampleTime = currentTime
            lastSampleStr = currentStr
            lastSampleDur = currentDur
        end
        task.wait(1) 
    end
end)

local autoEggActive = false
speedSection:Toggle({
    Title = "Auto Egg 30 Minuts",
    Default = false,
    Callback = function(state) autoEggActive = state end
})

task.spawn(function()
    while true do
        if autoEggActive then
            pcall(function()
                local backpack = localPlayer:FindFirstChild("Backpack")
                local char = localPlayer.Character
                local event = localPlayer:FindFirstChild("muscleEvent")
                if backpack and char and event then
                    local proteinEgg = backpack:FindFirstChild("Protein Egg") or char:FindFirstChild("Protein Egg")
                    if proteinEgg then
                        if proteinEgg.Parent ~= char then proteinEgg.Parent = char end
                        event:FireServer("proteinEgg", proteinEgg)
                    end
                end
            end)
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)

local selectedSquat = "Industrial Squat"
speedSection:Dropdown({
    Title = "Seleccionar Squat",
    Values = { "Industrial Squat", "Jungle Squat", "Zero Degrees Squat 1", "Zero Degrees Squat 2" },
    Default = "Industrial Squat",
    Callback = function(v) selectedSquat = v end
})

speedSection:Button({
    Title = "Usar Squat Seleccionado",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if selectedSquat == "Industrial Squat" then
            hrp.CFrame = CFrame.new(-5217.11523, 61.0028, 5418.07715)
        elseif selectedSquat == "Jungle Squat" then
            hrp.CFrame = CFrame.new(-8371.4336, 6.7981, 2858.8853)
        elseif selectedSquat == "Zero Degrees Squat 1" then
            hrp.CFrame = CFrame.new(-5304.29443, 43.5012, 11121.3379)
        elseif selectedSquat == "Zero Degrees Squat 2" then
            hrp.CFrame = CFrame.new(-5099.27734, 43.5012, 11096.1963)
        end
        task.wait(0.2)
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
})

speedSection:Button({
    Title = "Anti Lag",
    Callback = function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0
        settings().Rendering.QualityLevel = 1
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        end
        WindUI:Notify({ Title = "Anti Lag Activado", Duration = 4 })
    end
})

-- Separador
-- 2. PESTAÑA: REBIRTHS
-- Separador

local rebirthsTab = Window:Tab({ Title = "Rebirths", Icon = "repeat" })
local rbSectionPets = rebirthsTab:Section({ Title = "Fast Rebirth (Con Mascotas)" })

local bestPets = { "Swift Samurai", "Omega Overlord", "Mythic Boss Pet", "Legendary Boss Pet", "Rainbow Boss Pet", "Zeus Spark", "Ares Ironfang" }
local eclipsePets = { "Tribal Overlord", "Titanium Hydra", "Eclipse Devourer" }

local rbTimeLbl = rbSectionPets:Paragraph({ Title = "Tiempo", Desc = "0d 0h 0m 0s" })
local rbStatsLbl = rbSectionPets:Paragraph({ Title = "Renacimientos", Desc = "0 | Ganados: 0" })
local reqStrengthLbl = rbSectionPets:Paragraph({ Title = "Fuerza Necesaria", Desc = "0" })

local function getRequiredStrength()
    return math.floor(5000 + 2500 * getStats().Reb)
end

task.spawn(function()
    task.wait(2)
    local sessionStartRebirths = getStats().Reb
    local rbStartTime = tick()
    while true do
        local elapsed = tick() - rbStartTime
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        rbTimeLbl:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))
        local currentReb = getStats().Reb
        local g = currentReb - sessionStartRebirths
        rbStatsLbl:SetDesc("Renacimientos: " .. formatNum(currentReb) .. " | Ganados: " .. formatNum(g))
        reqStrengthLbl:SetDesc("Fuerza Necesaria: " .. formatNum(getRequiredStrength()))
        task.wait(1)
    end
end)

local function unequipAllPets()
    local petsFolder = localPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                replicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

local function equipSpecificPets(petList, limit)
    local petsFolder = localPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    local count = 0
    for _, petName in ipairs(petList) do
        for _, folder in pairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in pairs(folder:GetChildren()) do
                    if pet.Name == petName then
                        replicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                        count = count + 1
                        if count >= limit then return end
                    end
                end
            end
        end
    end
end

getgenv().AutoFarming = false

task.spawn(function()
    while true do
        if getgenv().AutoFarming or getgenv().RebirthsBrawlActive then
            pcall(function()
                unequipAllPets()
                equipSpecificPets(bestPets, 12)
                
                while (getgenv().AutoFarming or getgenv().RebirthsBrawlActive) do
                    if inBrawlSession then
                        task.wait(0.5)
                    else
                        local req = getRequiredStrength()
                        while getStats().Str < req and (getgenv().AutoFarming or getgenv().RebirthsBrawlActive) and not inBrawlSession do
                            if localPlayer:FindFirstChild("muscleEvent") then
                                for _ = 1, 31 do
                                    localPlayer.muscleEvent:FireServer("rep")
                                end
                            end
                            task.wait()
                        end
                        
                        if not (getgenv().AutoFarming or getgenv().RebirthsBrawlActive) then break end
                        if not inBrawlSession then
                            unequipAllPets()
                            equipSpecificPets(eclipsePets, 12)
                            local currentRb = getStats().Reb
                            repeat
                                replicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                                task.wait(0.2)
                            until getStats().Reb > currentRb or not (getgenv().AutoFarming or getgenv().RebirthsBrawlActive) or inBrawlSession
                            
                            if (getgenv().AutoFarming or getgenv().RebirthsBrawlActive) and not inBrawlSession then
                                unequipAllPets()
                                equipSpecificPets(bestPets, 12)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

rbSectionPets:Toggle({
    Title = "Fast Rebirth (Con Mascotas)",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarming = state
    end
})

local selectedLift = "Industrial Lift"
rbSectionPets:Dropdown({
    Title = "Seleccionar Lift",
    Values = { "Industrial Lift", "Zero Degrees Bar Lift 1", "Jungle Lift" },
    Default = "Industrial Lift",
    Callback = function(v) selectedLift = v end
})

rbSectionPets:Button({
    Title = "Usar Lift Seleccionado",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if selectedLift == "Industrial Lift" then
            hrp.CFrame = CFrame.new(-5492.70068, 61.0028, 4643.64258)
        elseif selectedLift == "Zero Degrees Bar Lift 1" then
            hrp.CFrame = CFrame.new(-5374.86719, 43.5012, 10321.7617)
        elseif selectedLift == "Jungle Lift" then
            hrp.CFrame = CFrame.new(-8652.8672, 29.2667, 2089.2617)
        end
        task.wait(0.2)
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
})

local lockRunning = false
local lockConnection = nil
local savedCFrame = nil
rbSectionPets:Toggle({
    Title = "Bloquear posición 🚫",
    Default = false,
    Callback = function(state)
        lockRunning = state
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if state then
            if hrp then savedCFrame = hrp.CFrame end
            if lockConnection then lockConnection:Disconnect() end
            lockConnection = runService.Heartbeat:Connect(function()
                if not lockRunning then return end
                local currentCharacter = localPlayer.Character
                if not currentCharacter then return end
                local currentHrp = currentCharacter:FindFirstChild("HumanoidRootPart")
                local humanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
                if not currentHrp or not humanoid or humanoid.Health <= 0 then return end
                if not savedCFrame then savedCFrame = currentHrp.CFrame end
                if humanoid.WalkSpeed < 50 then humanoid.WalkSpeed = 250 end
                if humanoid.JumpPower == 0 then humanoid.JumpPower = 50 end
                currentHrp.AssemblyLinearVelocity = Vector3.zero
                currentHrp.AssemblyAngularVelocity = Vector3.zero
                currentHrp.CFrame = savedCFrame
            end)
        else
            savedCFrame = nil
            if lockConnection then
                lockConnection:Disconnect()
                lockConnection = nil
            end
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 250
                hum.JumpPower = 50
            end
        end
    end
})

local rbSectionNormal = rebirthsTab:Section({ Title = "Fast Rebirth Normal" })

local timeLabelNew = rbSectionNormal:Paragraph({ Title = "Time", Desc = "0d 0h 0m 0s" })
local gainedLabelNew = rbSectionNormal:Paragraph({ Title = "Gained Rebirths", Desc = "0" })
local fuerzaNecesariaNew = rbSectionNormal:Paragraph({ Title = "Fuerza Necesaria", Desc = "0" })

task.spawn(function()
    task.wait(2)
    local startTimeNew = tick()
    local sessionRebirthsNew = getStats().Reb
    while true do
        local elapsed = tick() - startTimeNew
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        timeLabelNew:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))

        local gainedRebirths = getStats().Reb - sessionRebirthsNew
        gainedLabelNew:SetDesc(tostring(gainedRebirths))
        fuerzaNecesariaNew:SetDesc(formatNum(getRequiredStrength()))
        
        task.wait(1)
    end
end)

getgenv().AutoFarmingNormal = false
rbSectionNormal:Toggle({
    Title = "Fast Rebirth (Normal)",
    Default = false,
    Callback = function(autoFarmingNormal)
        getgenv().AutoFarmingNormal = autoFarmingNormal
        if autoFarmingNormal then
            task.spawn(function()
                local v26
                while getgenv().AutoFarmingNormal do
                    local backpack = localPlayer:FindFirstChild("Backpack")
                    local character = localPlayer.Character
                    if backpack and character then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:find("Bar") or tool.Name:find("Weight") or tool.Name:find("Bottle") or tool.Name:find("Pushups") or tool.Name:find("Handstands")) then
                                tool.Parent = character
                            end
                        end
                    end

                    local rounded19 = getRequiredStrength()
                    while getStats().Str < rounded19 and getgenv().AutoFarmingNormal do
                        if localPlayer:FindFirstChild("muscleEvent") then
                            for n = 1, 31 do
                                localPlayer.muscleEvent:FireServer("rep")
                            end
                        end
                        task.wait()
                    end
                    if not getgenv().AutoFarmingNormal then break end
                    local value20 = getStats().Reb
                    repeat
                        replicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.2)
                        v26 = getStats().Reb > value20 or not getgenv().AutoFarmingNormal
                    until v26
                end
            end)
        end
    end
})

-- Separador
-- 3. PESTAÑA: ALIEN
-- Separador

local tabAlien = Window:Tab({ Title = "Alien", Icon = "crosshair" })
local alienAutoSection = tabAlien:Section({ Title = "Alien Automation", TextXAlignment = "Left" })

getgenv().AlienStatusLbl = alienAutoSection:Paragraph({ Title = "Status", Desc = "Idle" })

alienAutoSection:Toggle({
    Title = "Auto Farm Alien Boss & Chest",
    Default = false,
    Callback = function(val)
        if val then
            startAlienBossFarm()
        else
            stopAlienBossFarm()
        end
    end
})

alienAutoSection:Toggle({
    Title = "Auto Alien Machines (Unoccupied)",
    Default = false,
    Callback = function(val)
        state.AutoAlienMachines = val
        if val then
            startAutoAlienMachines()
        end
    end
})

local alienShopSection = tabAlien:Section({ Title = "Alien Shop", TextXAlignment = "Left" })

for _, item in ipairs(alienShopItems) do
    alienShopSection:Toggle({
        Title = item.Name .. "  (" .. item.Price .. ")",
        Default = false,
        Callback = function(val)
            if val then
                selectedShopItems[item.Name] = item
            else
                selectedShopItems[item.Name] = nil
            end
        end
    })
end

alienShopSection:Toggle({
    Title = "Enable Auto Buy Alien Shop",
    Default = false,
    Callback = function(val)
        state.AutoBuyAlienShop = val
        if val then
            startAutoBuyAlienShop()
        end
    end
})

-- Separador
-- 4. PESTAÑA: PETS (AUTO SELL + AUTO CRYSTALS + COMPRAS DE PETS/AURAS)
-- Separador

local tabPets = Window:Tab({ Title = "Pets", Icon = "paw-print" })

-- Sección 1: Auto Sell Pets
local petsSellSection = tabPets:Section({ Title = "Auto Sell Pets", TextXAlignment = "Left" })
local petsStatusLbl = petsSellSection:Paragraph({ Title = "Status", Desc = "Idle" })

petsSellSection:Toggle({
    Title = "Sell UFO Bot",
    Default = true,
    Callback = function(val)
        autoSell.TargetPets.UFOBot = val
    end
})

petsSellSection:Toggle({
    Title = "Keep 1 UFO Bot (sell extras only)",
    Default = false,
    Callback = function(val)
        autoSell.KeepOneUFOBot = val
    end
})

petsSellSection:Toggle({
    Title = "Sell Cosmic Invader",
    Default = false,
    Callback = function(val)
        autoSell.TargetPets.CosmicInvader = val
    end
})

petsSellSection:Toggle({
    Title = "Sell Alien Slime",
    Default = false,
    Callback = function(val)
        autoSell.TargetPets.AlienSlime = val
    end
})

petsSellSection:Toggle({
    Title = "Enable Auto Sell",
    Default = false,
    Callback = function(val)
        if val then
            startAutoSell()
        else
            stopAutoSell()
        end
    end
})

task.spawn(function()
    while true do
        updatePara(petsStatusLbl, autoSell.Status)
        task.wait(0.5)
    end
end)

-- Sección 2: Auto Crystals (Apertura Automática de Cristales)
local crystalSection = tabPets:Section({ Title = "Auto Crystals" })

local crystalValuesList = {
    "Blue Crystal", "Green Crystal", "Frost Crystal", "Mythical Crystal", 
    "Inferno Crystal", "Legends Crystal", "Muscle Elite Crystal", 
    "Galaxy Oracle Crystal", "Jungle Crystal", "Zero Degrees Crystal", 
    "Alien Crystal", "Industrial Crystal"
}

local selectedCrystalForOpen = ""

crystalSection:Dropdown({
    Title = "Seleccionar Cristal",
    Values = crystalValuesList,
    Default = "",
    Callback = function(text)
        selectedCrystalForOpen = text
        print("Crystal selected for opening: " .. text)
    end
})

crystalSection:Toggle({
    Title = "Auto Open Crystal",
    Default = false,
    Callback = function(bool)
        _G.AutoOpenCrystal = bool
        if bool then
            if selectedCrystalForOpen == "" then
                print("Please select a crystal first!")
                return
            end
            print("Auto open crystal started for: " .. selectedCrystalForOpen)
            task.spawn(function()
                while _G.AutoOpenCrystal and selectedCrystalForOpen ~= "" do
                    pcall(function()
                        local args = {
                            [1] = "openCrystal",
                            [2] = selectedCrystalForOpen
                        }
                        local remote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("openCrystalRemote")
                        if remote then
                            remote:InvokeServer(unpack(args))
                        else
                            local altRemote = RS:FindFirstChild("packages") and RS.packages:FindFirstChild("Net") and RS.packages.Net:FindFirstChild("RF/OpenCrystal")
                            if altRemote then
                                altRemote:InvokeServer(selectedCrystalForOpen)
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        else
            print("Auto open crystal stopped")
        end
    end
})

-- Sección 3: Cristales y Compras Automáticas de Pets/Auras
local petsSection = tabPets:Section({ Title = "Gestión de Cristales y Mascotas" })

local crystalData = { 
    ["Blue Crystal"] = { 
        {name = "Blue Birdie", rarity = "Basic"}, 
        {name = "Orange Hedgehog", rarity = "Basic"}, 
        {name = "Blue Aura", rarity = "Basic"}, 
        {name = "Red Kitty", rarity = "Basic"}, 
        {name = "Dark Vampy", rarity = "Advanced"}, 
        {name = "Blue Bunny", rarity = "Basic"}, 
        {name = "Red Aura", rarity = "Basic"}, 
        {name = "Green Aura", rarity = "Basic"}, 
        {name = "Purple Aura", rarity = "Basic"}, 
        {name = "Yellow Aura", rarity = "Basic"} 
    }, 
    ["Green Crystal"] = { 
        {name = "Silver Dog", rarity = "Basic"}, 
        {name = "Green Aura", rarity = "Advanced"}, 
        {name = "Dark Golem", rarity = "Advanced"}, 
        {name = "Green Butterfly", rarity = "Advanced"}, 
        {name = "Crimson Falcon", rarity = "Rare"}, 
        {name = "Red Aura", rarity = "Basic"}, 
        {name = "Blue Aura", rarity = "Basic"}, 
        {name = "Purple Aura", rarity = "Basic"}, 
        {name = "Yellow Aura", rarity = "Basic"} 
    }, 
    ["Frost Crystal"] = { 
        {name = "Yellow Butterfly", rarity = "Advanced"}, 
        {name = "Purple Dragon", rarity = "Rare"}, 
        {name = "Blue Pheonix", rarity = "Epic"}, 
        {name = "Orange Pegasus", rarity = "Rare"}, 
        {name = "Lightning", rarity = "Rare"}, 
        {name = "Electro", rarity = "Advanced"} 
    }, 
    ["Mythical Crystal"] = { 
        {name = "Purple Falcon", rarity = "Rare"}, 
        {name = "Red Dragon", rarity = "Rare"}, 
        {name = "Blue Firecaster", rarity = "Epic"}, 
        {name = "Golden Pheonix", rarity = "Epic"}, 
        {name = "Power Lightning", rarity = "Rare"}, 
        {name = "Dark Lightning", rarity = "Epic"} 
    }, 
    ["Inferno Crystal"] = { 
        {name = "Red Firecaster", rarity = "Epic"}, 
        {name = "Infernal Dragon", rarity = "Unique"}, 
        {name = "White Pegasus", rarity = "Rare"}, 
        {name = "Golden Pheonix", rarity = "Epic"}, 
        {name = "Inferno", rarity = "Epic"}, 
        {name = "Dark Storm", rarity = "Unique"} 
    }, 
    ["Legends Crystal"] = { 
        {name = "Ultra Birdie", rarity = "Unique"}, 
        {name = "Magic Butterfly", rarity = "Unique"}, 
        {name = "Green Firecaster", rarity = "Epic"}, 
        {name = "White Pheonix", rarity = "Epic"}, 
        {name = "Supernova", rarity = "Epic"}, 
        {name = "Purple Nova", rarity = "Unique"} 
    }, 
    ["Muscle Elite Crystal"] = { 
        {name = "Frostwave Legends Penguin", rarity = "Rare"}, 
        {name = "Phantom Genesis Dragon", rarity = "Rare"}, 
        {name = "Dark Legends Manticore", rarity = "Epic"}, 
        {name = "Ultimate Supernova Pegasus", rarity = "Epic"}, 
        {name = "Aether Spirit Bunny", rarity = "Unique"}, 
        {name = "Cybernetic Showdown Dragon", rarity = "Unique"} 
    }, 
    ["Galaxy Oracle Crystal"] = { 
        {name = "Eternal Strike Leviathan", rarity = "Rare"}, 
        {name = "Lightning Strike Phantom", rarity = "Epic"}, 
        {name = "Darkstar Hunter", rarity = "Unique"}, 
        {name = "Muscle King", rarity = "Unique"}, 
        {name = "Azure Tundra", rarity = "Epic"}, 
        {name = "Ultra Inferno", rarity = "Rare"} 
    }, 
    ["Jungle Crystal"] = { 
        {name = "Entropic Blast", rarity = "Unique"}, 
        {name = "Muscle Sensei", rarity = "Unique"}, 
        {name = "Grand Supernova", rarity = "Epic"}, 
        {name = "Neon Guardian", rarity = "Unique"}, 
        {name = "Eternal Megastrike", rarity = "Unique"}, 
        {name = "Golden Viking", rarity = "Epic"}, 
        {name = "Astral Electro", rarity = "Epic"}, 
        {name = "Dark Electro", rarity = "Epic"}, 
        {name = "Enchanted Mirage", rarity = "Epic"}, 
        {name = "Ultra Mirage", rarity = "Unique"}, 
        {name = "Unstable Mirage", rarity = "Unique"} 
    },
    ["Zero Degrees Crystal"] = {
        {name = "Rime Fox", rarity = "Basic"},
        {name = "Tuskfrost", rarity = "Advanced"},
        {name = "Polaris Owl", rarity = "Rare"},
        {name = "Glacier Lynx", rarity = "Epic"},
        {name = "Tricefrost Hydra", rarity = "Unique"},
        {name = "Aurora Sovereign", rarity = "Legendary"}
    },
    ["Alien Crystal"] = {
        {name = "Spore Beast", rarity = "Basic"},
        {name = "Rift Hydra", rarity = "Advanced"},
        {name = "Phase Mantis", rarity = "Rare"},
        {name = "Nebula Moth", rarity = "Epic"},
        {name = "Orbit Jelly", rarity = "Unique"},
        {name = "Eclipse Wyrm", rarity = "Legendary"}
    },
    ["Industrial Crystal"] = {
        {name = "Core Pup", rarity = "Basic"},
        {name = "Volt Talon", rarity = "Advanced"},
        {name = "Reactor Beast", rarity = "Rare"},
        {name = "Plasma Ravager", rarity = "Epic"},
        {name = "Titan Reactor", rarity = "Unique"},
        {name = "Apex Overlord", rarity = "Legendary"}
    }
} 

local function findCrystalForItem(itemName) 
    for crystalName, petsTable in pairs(crystalData) do 
        for _, pet in ipairs(petsTable) do 
            if pet.name == itemName then 
                return crystalName 
            end 
        end 
    end 
    return nil 
end 

local selectedPet = "" 
local selectedAura = "" 

petsSection:Paragraph({ Title = "=== Buy pets and auras ===", Desc = "Selecciona tu mascota o aura para compra automática" })

local petValuesList = {
    "Blue Birdie (Basic)", "Orange Hedgehog (Basic)", "Red Kitty (Basic)", "Blue Bunny (Basic)", "Silver Dog (Basic)", "Rime Fox (Basic)", "Spore Beast (Basic)", "Core Pup (Basic)",
    "Dark Vampy (Advanced)", "Dark Golem (Advanced)", "Green Butterfly (Advanced)", "Yellow Butterfly (Advanced)", "Tuskfrost (Advanced)", "Rift Hydra (Advanced)", "Volt Talon (Advanced)",
    "Crimson Falcon (Rare)", "Purple Dragon (Rare)", "Orange Pegasus (Rare)", "Purple Falcon (Rare)", "Red Dragon (Rare)", "White Pegasus (Rare)", "Frostwave Legends Penguin (Rare)", "Phantom Genesis Dragon (Rare)", "Eternal Strike Leviathan (Rare)", "Polaris Owl (Rare)", "Phase Mantis (Rare)", "Reactor Beast (Rare)",
    "Blue Pheonix (Epic)", "Blue Firecaster (Epic)", "Golden Pheonix (Epic)", "Red Firecaster (Epic)", "Green Firecaster (Epic)", "White Pheonix (Epic)", "Dark Legends Manticore (Epic)", "Ultimate Supernova Pegasus (Epic)", "Lightning Strike Phantom (Epic)", "Golden Viking (Epic)", "Glacier Lynx (Epic)", "Nebula Moth (Epic)", "Plasma Ravager (Epic)",
    "Infernal Dragon (Unique)", "Ultra Birdie (Unique)", "Magic Butterfly (Unique)", "Aether Spirit Bunny (Unique)", "Cybernetic Showdown Dragon (Unique)", "Darkstar Hunter (Unique)", "Muscle Sensei (Unique)", "Neon Guardian (Unique)", "Tricefrost Hydra (Unique)", "Orbit Jelly (Unique)", "Titan Reactor (Unique)",
    "Aurora Sovereign (Legendary)", "Eclipse Wyrm (Legendary)", "Apex Overlord (Legendary)"
}

petsSection:Dropdown({
    Title = "Select pet",
    Values = petValuesList,
    Default = "",
    Callback = function(text) 
        selectedPet = text 
        local crystal = findCrystalForItem(text) 
        print("Pet selected: " .. text .. " (Found in: " .. (crystal or "Unknown") .. ")") 
    end
})

local auraValuesList = {
    "Blue Aura (Basic)", "Green Aura (Basic)", "Purple Aura (Basic)", "Red Aura (Basic)", "Yellow Aura (Basic)", "Ultra Inferno (Rare)", "Azure Tundra (Epic)", "Grand Supernova (Epic)", "Muscle King (Unique)", "Entropic Blast (Unique)", "Eternal Megastrike (Unique)"
}

petsSection:Dropdown({
    Title = "Select Aura",
    Values = auraValuesList,
    Default = "",
    Callback = function(text) 
        selectedAura = text 
        local crystal = findCrystalForItem(text) 
        print("Aura selected: " .. text .. " (Found in: " .. (crystal or "Unknown") .. ")") 
    end
})

petsSection:Paragraph({ Title = "=== System to buys ===", Desc = "Activadores automáticos" })

petsSection:Toggle({
    Title = "Auto Buy Pet",
    Default = false,
    Callback = function(bool) 
        _G.AutoBuyPet = bool 
        if bool then 
            if selectedPet == "" then 
                print("Please select a pet first!") 
                return 
            end 
            local petName = selectedPet:match("^(.-)%s*%(") 
            if not petName then 
                petName = selectedPet 
            end 
            local crystal = findCrystalForItem(petName) 
            if not crystal then 
                print("Could not find crystal for pet: " .. petName) 
                return 
            end 
            print("Auto buy pet started for: " .. petName .. " from " .. crystal) 
            task.spawn(function() 
                while _G.AutoBuyPet and selectedPet ~= "" do 
                    local petToBuy = ReplicatedStorage.cPetShopFolder:FindFirstChild(petName) 
                    if petToBuy then 
                        ReplicatedStorage.cPetShopRemote:InvokeServer(petToBuy) 
                        print("Bought pet: " .. petName) 
                    else 
                        print("Pet not found: " .. petName) 
                    end 
                    task.wait(0.1) 
                end 
            end) 
        else 
            print("Auto buy pet stopped") 
        end 
    end
})

petsSection:Toggle({
    Title = "Auto buy Aura",
    Default = false,
    Callback = function(bool) 
        _G.AutoBuyAura = bool 
        if bool then 
            if selectedAura == "" then 
                print("Please select an aura first!") 
                return 
            end 
            local auraName = selectedAura:match("^(.-)%s*%(") 
            if not auraName then 
                auraName = selectedAura 
            end 
            local crystal = findCrystalForItem(auraName) 
            if not crystal then 
                print("Could not find crystal for aura: " .. auraName) 
                return 
            end 
            print("Auto buy aura started for: " .. auraName .. " from " .. crystal) 
            task.spawn(function() 
                while _G.AutoBuyAura and selectedAura ~= "" do 
                    local auraToBuy = ReplicatedStorage.cPetShopFolder:FindFirstChild(auraName) 
                    if auraToBuy then 
                        ReplicatedStorage.cPetShopRemote:InvokeServer(auraToBuy) 
                        print("Bought aura: " .. auraName) 
                    else 
                        print("Aura not found: " .. auraName) 
                    end 
                    task.wait(0.1) 
                end 
            end) 
        else 
            print("Auto buy aura stopped") 
        end 
    end
})

-- Separador
-- 5. PESTAÑA: BOSSES
-- Separador

local bossesTab = Window:Tab({ Title = "Bosses", Icon = "crown" })
local bossSectionMain = bossesTab:Section({ Title = "Boss Automation" })

local bossStatusLbl = bossSectionMain:Paragraph({ Title = "Current Boss", Desc = "None" })

task.spawn(function()
    while true do
        if BossState.AutoFarmBoss then
            bossStatusLbl:SetDesc(BossState.CurrentBoss)
        end
        task.wait(0.5)
    end
end)

bossSectionMain:Toggle({
    Title = "Auto Farm Arena Bosses",
    Default = false,
    Callback = function(v)
        if v then startAutoFarmBoss() else stopAutoFarmBoss() end
    end
})

local bossSectionSelect = bossesTab:Section({ Title = "Arena Boss Selection" })
for _, bossName in ipairs(REGULAR_BOSS_NAMES) do
    local exactName = REGULAR_BOSS_FULL[bossName] or bossName
    bossSectionSelect:Toggle({
        Title = exactName,
        Default = SelectedBosses[bossName] == true,
        Callback = function(v) SelectedBosses[bossName] = v end
    })
end

-- Separador
-- 6. PESTAÑA: AUTO BRAWL
-- Separador

local brawlTab = Window:Tab({ Title = "Auto Brawl", Icon = "swords" })
local brawlSection = brawlTab:Section({ Title = "Configuración de Brawl" })

getgenv().AutoJoinBrawl = false
brawlSection:Toggle({
    Title = "Auto Entrar a Brawl (Modo Inteligente)",
    Default = false,
    Callback = function(state)
        getgenv().AutoJoinBrawl = state
    end
})

getgenv().OnlyAutoJoinBrawl = false
brawlSection:Toggle({
    Title = "Solo Auto Entrar (AFK)",
    Default = false,
    Callback = function(state)
        getgenv().OnlyAutoJoinBrawl = state
    end
})

getgenv().RebirthsBrawlActive = false
brawlSection:Toggle({
    Title = "Rebirths+Brawl",
    Default = false,
    Callback = function(state)
        getgenv().RebirthsBrawlActive = state
    end
})

getgenv().AutoBrawlKill = false
local targetPlayerNameInput = ""

brawlSection:Input({
    Title = "Cuenta Prioritaria (Opcional)",
    Value = "",
    Callback = function(v)
        targetPlayerNameInput = v
    end
})

brawlSection:Toggle({
    Title = "Auto Matar en Ring (Automático)",
    Default = false,
    Callback = function(state)
        getgenv().AutoBrawlKill = state
    end
})

local wildWizardPets = { "Wild Wizard", "Wild Wizards" }
local function equipWildWizards()
    local petsFolder = localPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    local count = 0
    local folderList = petsFolder:GetChildren()
    for i = 1, #folderList do
        local folder = folderList[i]
        if folder:IsA("Folder") then
            local petsInFolder = folder:GetChildren()
            for j = 1, #petsInFolder do
                local pet = petsInFolder[j]
                for k = 1, #wildWizardPets do
                    if string.find(string.lower(pet.Name), string.lower(wildWizardPets[k])) then
                        replicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                        count = count + 1
                        if count >= 12 then return end
                    end
                end
            end
        end
    end
end

local function getBrawlTarget()
    if not inBrawlSession then return nil end

    if targetPlayerNameInput ~= "" then
        local specific = players:FindFirstChild(targetPlayerNameInput)
        if specific and specific ~= localPlayer and specific.Character then
            local hum = specific.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return specific
            end
        end
    end

    local myChar = localPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    local playerList = players:GetPlayers()
    for i = 1, #playerList do
        local p = playerList[i]
        if p ~= localPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local inBrawlFlag = p:FindFirstChild("inBrawl") or p:GetAttribute("inBrawl")
                local isEnemyInBrawl = (inBrawlFlag == true or (typeof(inBrawlFlag) == "Instance" and inBrawlFlag.Value == true))
                
                if isEnemyInBrawl or (myHrp and (myHrp.Position - hrp.Position).Magnitude < 130) then
                    return p
                end
            end
        end
    end
    return nil
end

inBrawlSession = false
local previousState = {
    SavedPosition = nil,
    ActiveToolName = nil
}

replicatedStorage.rEvents.brawlEvent.OnClientEvent:Connect(function(action)
    if action == "brawlStarting" then
        if getgenv().OnlyAutoJoinBrawl and not getgenv().AutoJoinBrawl then
            local char = localPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            task.wait(0.05)
            pcall(function()
                replicatedStorage.rEvents.brawlEvent:FireServer("joinBrawl")
            end)
            return
        end

        if (getgenv().AutoJoinBrawl or getgenv().RebirthsBrawlActive) and not inBrawlSession then
            inBrawlSession = true

            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if hrp then
                previousState.SavedPosition = hrp.CFrame
            end

            previousState.ActiveToolName = nil
            if char then
                local charChildren = char:GetChildren()
                for i = 1, #charChildren do
                    local item = charChildren[i]
                    if item:IsA("Tool") then
                        previousState.ActiveToolName = item.Name
                        item.Parent = localPlayer:FindFirstChild("Backpack")
                        break
                    end
                end
            end

            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            pcall(function()
                replicatedStorage.rEvents.brawlEvent:FireServer("joinBrawl")
            end)

            if getgenv().RebirthsBrawlActive then
                task.wait(0.6)
                unequipAllPets()
                equipWildWizards()
            end
        end

    elseif action == "endBrawl" and inBrawlSession then
        task.wait(1.5)
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp and previousState.SavedPosition then
            hrp.CFrame = previousState.SavedPosition
            hrp.AssemblyLinearVelocity = Vector3.zero
        end

        task.wait(0.3)

        if previousState.ActiveToolName then
            local backpack = localPlayer:FindFirstChild("Backpack")
            local tool = backpack and backpack:FindFirstChild(previousState.ActiveToolName)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if tool and humanoid then
                humanoid:EquipTool(tool)
            end
        end

        if getgenv().RebirthsBrawlActive then
            task.wait(0.2)
            unequipAllPets()
            task.wait(0.1)
            equipSpecificPets(bestPets, 12)
        end

        inBrawlSession = false
    end
end)

task.spawn(function()
    while true do
        if getgenv().AutoBrawlKill and inBrawlSession then
            pcall(function()
                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local targetPlayer = getBrawlTarget()
                
                if hrp and targetPlayer and targetPlayer.Character then
                    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        
                        local backpack = localPlayer:FindFirstChild("Backpack")
                        local punch = char:FindFirstChild("Punch") or (backpack and backpack:FindFirstChild("Punch"))
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        
                        if punch and punch.Parent == backpack and humanoid then
                            humanoid:EquipTool(punch)
                        end
                        if punch and punch.Parent == char then
                            punch:Activate()
                        end
                        
                        local ev = localPlayer:FindFirstChild("muscleEvent")
                        if ev then
                            ev:FireServer("punch", "leftHand")
                            ev:FireServer("punch", "rightHand")
                        end
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- Separador
-- 7. PESTAÑA: KILLS
-- Separador

local killsTab = Window:Tab({ Title = "Kills", Icon = "skull" })
local killsSection = killsTab:Section({ Title = "Automatización de Kills y PvP" })

local map = {}
local list10 = {}
local v42 = false
local v43 = false
local v44 = false
local name2
local name3
local map2 = {}
local v45 = {}

local v48 = false
killsSection:Toggle({
    Title = "Auto Lista Blanca Amigos",
    Default = false,
    Callback = function(p21)
        v48 = p21
        if p21 then
            for _, value35 in ipairs(players:GetPlayers()) do
                if value35 ~= localPlayer and localPlayer:IsFriendsWith(value35.UserId) then
                    map[value35.Name] = true
                end
            end
            players.PlayerAdded:Connect(function(player3)
                if v48 and player3 ~= localPlayer and localPlayer:IsFriendsWith(player3.UserId) then
                    map[player3.Name] = true
                end
            end)
        else
            for key in pairs(map) do
                local findFirstChild3 = players:FindFirstChild(key)
                if findFirstChild3 and localPlayer:IsFriendsWith(findFirstChild3.UserId) then
                    map[key] = nil
                end
            end
        end
    end
})

killsSection:Input({
    Title = "Whitelist",
    Value = "",
    Callback = function(p22)
        local findFirstChild4 = players:FindFirstChild(p22)
        if findFirstChild4 then
            map[findFirstChild4.Name] = true
        end
    end
})

killsSection:Input({
    Title = "UnWhitelist",
    Value = "",
    Callback = function(p23)
        local findFirstChild5 = players:FindFirstChild(p23)
        if findFirstChild5 then
            map[findFirstChild5.Name] = nil
        end
    end
})

killsSection:Toggle({
    Title = "Auto Kill 👹",
    Default = false,
    Callback = function(p24)
        v42 = p24
        task.spawn(function()
            local v49 = 0
            local instance3
            while v42 do
                local character11 = localPlayer.Character
                local humanoidRootPart6 = character11 and character11:FindFirstChild("HumanoidRootPart")
                local rightHand3 = character11 and character11:FindFirstChild("RightHand")
                local leftHand3 = character11 and character11:FindFirstChild("LeftHand")
                local punch = localPlayer.Backpack:FindFirstChild("Punch") or character11 and character11:FindFirstChild("Punch")
                if punch and character11 then
                    if punch.Parent ~= character11 then
                        punch.Parent = character11
                    end
                    if punch:FindFirstChild("attackTime") then
                        punch.attackTime.Value = 0
                    end
                    punch:Activate()
                end
                if character11 and humanoidRootPart6 and rightHand3 and leftHand3 then
                    local character12 = instance3 and instance3.Character
                    local humanoidRootPart7 = character12 and character12:FindFirstChild("HumanoidRootPart")
                    local humanoid4 = character12 and character12:FindFirstChildOfClass("Humanoid")
                    if not (instance3 and instance3.Parent and not map[instance3.Name] and humanoidRootPart7 and humanoid4 and humanoid4.Health > 0) or tick() - v49 >= 2 then
                        instance3 = nil
                        for _, value36 in ipairs(players:GetPlayers()) do
                            if value36 ~= localPlayer and not map[value36.Name] then
                                local character13 = value36.Character
                                local humanoidRootPart8 = character13 and character13:FindFirstChild("HumanoidRootPart")
                                local humanoid5 = character13 and character13:FindFirstChildOfClass("Humanoid")
                                if humanoidRootPart8 and humanoid5 and humanoid5.Health > 0 then
                                    instance3 = value36
                                    v49 = tick()
                                    humanoidRootPart7 = humanoidRootPart8
                                    break
                                end
                            end
                        end
                    end
                    if instance3 and humanoidRootPart7 then
                        pcall(function()
                            humanoidRootPart6.CFrame = humanoidRootPart7.CFrame * CFrame.new(0, 0, 2)
                            firetouchinterest(rightHand3, humanoidRootPart7, 1)
                            firetouchinterest(leftHand3, humanoidRootPart7, 1)
                            firetouchinterest(rightHand3, humanoidRootPart7, 0)
                            firetouchinterest(leftHand3, humanoidRootPart7, 0)
                        end)
                    end
                end
                task.wait(0.01)
            end
            local punch2 = localPlayer.Character and localPlayer.Character:FindFirstChild("Punch")
            if punch2 then
                punch2.Parent = localPlayer.Backpack
            end
        end)
    end
})

local dropdownTargetNames = {}
for _, p in ipairs(players:GetPlayers()) do
    if p ~= localPlayer then
        table.insert(dropdownTargetNames, p.DisplayName)
        map2[p.Name] = p.DisplayName
    end
end

killsSection:Dropdown({
    Title = "Seleccionar objetivo 💀",
    Values = dropdownTargetNames,
    Default = "",
    Callback = function(p25)
        for _, value37 in ipairs(players:GetPlayers()) do
            if value37.DisplayName == p25 then
                if not table.find(list10, value37.Name) then
                    table.insert(list10, value37.Name)
                end
                name2 = value37.Name
                break
            end
        end
    end
})

players.PlayerAdded:Connect(function(player4)
    if player4 ~= localPlayer then
        map2[player4.Name] = player4.DisplayName
    end
end)

players.PlayerRemoving:Connect(function(player5)
    if map2[player5.Name] then
        map2[player5.Name] = nil
    end
    for i7 = #list10, 1, -1 do
        if list10[i7] == player5.Name then
            table.remove(list10, i7)
        end
    end
end)

killsSection:Button({
    Title = "Remove Selected Target",
    Callback = function()
        if name2 then
            for index2, value40 in ipairs(list10) do
                if value40 == name2 then
                    table.remove(list10, index2)
                    break
                end
            end
            name2 = nil
        end
    end
})

killsSection:Toggle({
    Title = "Start Kill Target",
    Default = false,
    Callback = function(p26)
        v43 = p26
        task.spawn(function()
            while v43 do
                local character14 = localPlayer.Character
                local humanoid6 = character14 and character14:FindFirstChildOfClass("Humanoid")
                local humanoidRootPart9 = character14 and character14:FindFirstChild("HumanoidRootPart")
                local rightHand4 = character14 and character14:FindFirstChild("RightHand")
                local leftHand4 = character14 and character14:FindFirstChild("LeftHand")
                
                if character14 and humanoidRootPart9 and humanoid6 and humanoid6.Health > 0 then
                    local punch3 = localPlayer.Backpack:FindFirstChild("Punch")
                    if punch3 then
                        punch3.Parent = character14
                    end
                    local punch4 = character14:FindFirstChild("Punch")
                    if punch4 then
                        if punch4:FindFirstChild("attackTime") then
                            punch4.attackTime.Value = 0
                        end
                        punch4:Activate()
                    end
                    
                    if rightHand4 and leftHand4 then
                        for _, value41 in ipairs(list10) do
                            local findFirstChild6 = players:FindFirstChild(value41)
                            if findFirstChild6 and findFirstChild6 ~= localPlayer and findFirstChild6.Character then
                                local character15 = findFirstChild6.Character
                                local humanoidRootPart10 = character15:FindFirstChild("HumanoidRootPart")
                                local humanoid7 = character15:FindFirstChildOfClass("Humanoid")
                                
                                if humanoidRootPart10 and humanoid7 and humanoid7.Health > 0 then
                                    pcall(function()
                                        humanoidRootPart9.CFrame = humanoidRootPart10.CFrame * CFrame.new(0, 0, 2)
                                        firetouchinterest(rightHand4, humanoidRootPart10, 1)
                                        firetouchinterest(leftHand4, humanoidRootPart10, 1)
                                        firetouchinterest(rightHand4, humanoidRootPart10, 0)
                                        firetouchinterest(leftHand4, humanoidRootPart10, 0)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.01)
            end
            
            local punch5 = localPlayer.Character and localPlayer.Character:FindFirstChild("Punch")
            if punch5 then
                punch5.Parent = localPlayer.Backpack
            end
        end)
    end
})

local dropdownSpectateNames = {}
for _, p in ipairs(players:GetPlayers()) do
    if p ~= localPlayer then
        table.insert(dropdownSpectateNames, p.DisplayName)
        v45[p.Name] = p.DisplayName
    end
end

killsSection:Dropdown({
    Title = "Seleccionar Ver objetivo 👁️",
    Values = dropdownSpectateNames,
    Default = "",
    Callback = function(p27)
        for _, value42 in ipairs(players:GetPlayers()) do
            if value42.DisplayName == p27 then
                name3 = value42.Name
                break
            end
        end
    end
})

killsSection:Toggle({
    Title = "Ver jugador",
    Default = false,
    Callback = function(p28)
        v44 = p28
        if not v44 then
            workspace.CurrentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") or localPlayer
            return
        end
        task.spawn(function()
            while v44 do
                local findFirstChild7 = players:FindFirstChild(name3)
                if findFirstChild7 and findFirstChild7 ~= localPlayer then
                    local humanoid8 = findFirstChild7.Character and findFirstChild7.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid8 then
                        workspace.CurrentCamera.CameraSubject = humanoid8
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- Separador
-- 8. PESTAÑA: EMOTES (BOTÓN ÚNICO CLICABLE)
-- Separador

local emotesTab = Window:Tab({ Title = "Emotes", Icon = "smile" })
local emotesSection = emotesTab:Section({ Title = "Abrir Menú de Emotes" })

emotesSection:Button({
    Title = "Abrir Menú Emotes",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/rb0644162-cmd/Private-Chris/refs/heads/main/emotes"))()
            WindUI:Notify({ Title = "Menú de Emotes", Content = "¡Abierto correctamente!", Duration = 3 })
        end)
    end
})

-- Separador
-- 9. PESTAÑA: EXTRAS & UTILIDADES
-- Separador

local extrasTab = Window:Tab({ Title = "Extras", Icon = "settings" })
local extrasSection = extrasTab:Section({ Title = "Misc y Utilidades" })

extrasSection:Toggle({
    Title = "Spin Fortune Wheel",
    Default = false,
    Callback = function(state)
        _G.AutoSpinWheel = state
        if state then
            task.spawn(function()
                while _G.AutoSpinWheel and task.wait(0.1) do
                    pcall(function()
                        replicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", replicatedStorage.shared.catalogs.fortuneWheelChances["Fortune Wheel"])
                    end)
                end
            end)
        end
    end
})

extrasSection:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        _G.InfiniteJump = state
        if state then
            userInputService.JumpRequest:Connect(function()
                if _G.InfiniteJump and localPlayer.Character then
                    local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        end
    end
})

extrasSection:Toggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(state)
        if state then
            local genv = getgenv()
            genv.AntiAfkConnection = localPlayer.Idled:Connect(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
            WindUI:Notify({ Title = "Anti AFK Activado", Duration = 4 })
        else
            if getgenv().AntiAfkConnection then
                getgenv().AntiAfkConnection:Disconnect()
                getgenv().AntiAfkConnection = nil
            end
            WindUI:Notify({ Title = "Anti AFK Desactivado", Duration = 4 })
        end
    end
})

local waterParts = {}
task.spawn(function()
    local rounded = math.ceil(24.4140625)
    local basePos = Vector3.new(-2, -9.5, -2)
    for i = 0, rounded - 1 do
        for j = 0, rounded - 1 do
            local function createPart(pos, name)
                local part = Instance.new("Part")
                part.Size = Vector3.new(2048, 1, 2048)
                part.Position = pos
                part.Anchored = true
                part.Transparency = 1
                part.CanCollide = false
                part.Name = name
                part.Parent = workspaceService
                return part
            end
            table.insert(waterParts, createPart(basePos + Vector3.new(i * 2048, 0, j * 2048), "WaterPart_"..i.."_"..j))
            table.insert(waterParts, createPart(basePos + Vector3.new(-i * 2048, 0, j * 2048), "WaterPart_"..i.."_"..j))
        end
    end
end)

extrasSection:Toggle({
    Title = "Walk on Water",
    Default = false,
    Callback = function(state)
        for _, p in ipairs(waterParts) do
            if p and p.Parent then p.CanCollide = state end
        end
    end
})

extrasSection:Toggle({
    Title = "Limpiar Inventario",
    Default = false,
    Callback = function(state)
        cleaningInventory = state
        if state then
            task.spawn(function()
                while cleaningInventory do
                    pcall(function()
                        local char = localPlayer.Character
                        local backpack = localPlayer:FindFirstChild("Backpack")
                        for _, itemName in ipairs(foodItems) do
                            local item = (char and char:FindFirstChild(itemName)) or (backpack and backpack:FindFirstChild(itemName))
                            if item and localPlayer:FindFirstChild("muscleEvent") then
                                local localCamel = itemName:gsub("%s+", "")
                                localPlayer.muscleEvent:FireServer(localCamel:sub(1,1):lower() .. localCamel:sub(2), item)
                            end
                        end
                    end)
                    task.wait(0.005)
                end
            end)
        end
    end
})

extrasSection:Dropdown({
    Title = "Change Time",
    Values = { "Night", "Day", "Midnight" },
    Default = "Day",
    Callback = function(v)
        if v == "Night" then lighting.ClockTime = 0
        elseif v == "Day" then lighting.ClockTime = 12
        elseif v == "Midnight" then lighting.ClockTime = 6 end
    end
})
