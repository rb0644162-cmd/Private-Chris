-- ==========================================
-- SCRIPT COMPLETO - CHRISTIAN PRIV (MOBILE)
-- ==========================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI.TransparencyValue = 0.35
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "Christian Priv",
    Folder = "PrivateChris_Mobile",
    Size = UDim2.fromOffset(500, 420),
    Theme = "Dark",
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

-- ==========================================
-- AUTOMATIZACIÓN DE BOSSES
-- ==========================================
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

-- ==========================================
-- 1. PESTAÑA: SPEED FARM
-- ==========================================
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

-- ==========================================
-- 2. PESTAÑA: REBIRTHS
-- ==========================================
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

-- FUNCIÓN DE FAST REBIRTH CON MASCOTAS (CON PAUSA FLUIDA PARA BRAWL)
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

-- ==========================================
-- 3. PESTAÑA: BOSSES
-- ==========================================
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

-- ==========================================
-- 4. PESTAÑA: AUTO BRAWL (NUEVA E INTEGRADA)
-- ==========================================
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

-- Detección estricta de rivales dentro del ring de Brawl
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

            -- 1. Guardar posición actual
            if hrp then
                previousState.SavedPosition = hrp.CFrame
            end

            -- 2. Guardar y desequipar la pesa de la mano a la mochila
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

            -- 3. Brinco rápido por si estabas en máquina
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            -- 4. Entrar al Brawl INMEDIATAMENTE
            pcall(function()
                replicatedStorage.rEvents.brawlEvent:FireServer("joinBrawl")
            end)

            -- 5. Si está activo Rebirths+Brawl, equipar Wild Wizards en el ring
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
        
        -- 1. Regresar a la posición exacta donde estabas antes del Brawl
        if hrp and previousState.SavedPosition then
            hrp.CFrame = previousState.SavedPosition
            hrp.AssemblyLinearVelocity = Vector3.zero
        end

        task.wait(0.3)

        -- 2. Volver a equipar la pesa en la mano
        if previousState.ActiveToolName then
            local backpack = localPlayer:FindFirstChild("Backpack")
            local tool = backpack and backpack:FindFirstChild(previousState.ActiveToolName)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if tool and humanoid then
                humanoid:EquipTool(tool)
            end
        end

        -- 3. Si Rebirths+Brawl está activo, forzar inmediatamente desequipar todo y reequipar las mascotas de repetición (bestPets)
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

-- ==========================================
-- 5. PESTAÑA: EXTRAS & UTILIDADES
-- ==========================================
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

local cleaningInventory = false
local foodItems = { "Energy Shake", "Protein Bar", "TOUGH Bar", "Protein Shake", "ULTRA Shake", "Energy Bar" }
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
