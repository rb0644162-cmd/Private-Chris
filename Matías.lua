local library
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/matiasNss/scirpt-matias/refs/heads/main/libreria"))()
    end)
    if ok and type(lib) == "table" then
        library = lib
    else
        warn("[Mxtias Hub] Error cargando la librería remota:", tostring(lib))
        return
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local displayName = LocalPlayer.DisplayName or LocalPlayer.Name

local window = library:AddWindow("Mxtias hub 777  | - Hola crack " .. displayName, {
    main_color = Color3.fromRGB(255, 212, 42),
    min_size = Vector2.new(520, 420),
    can_resize = true,
})

if not window then
    warn("[Mxtias Hub] No se pudo crear la ventana principal.")
    return
end

local AutoFarm = window:AddTab("Farm")

-- ==========================================
-- STRENGTH OP (> 250 MS)
-- ==========================================
getgenv()._AutoRepFarmEnabled = false

AutoFarm:AddSwitch("Strength Op (Use it if your minimum ping is 250 ms)", function(state)
    getgenv()._AutoRepFarmEnabled = state
    warn("[Auto Rep Farm] Estado cambiado a:", state and "ON" or "OFF")
end)

local PET_NAME = "Swift Samurai"
local ROCK_NAME = "Rock5M"
local PROTEIN_EGG_NAME = "ProteinEgg"
local PROTEIN_EGG_INTERVAL = 30 * 60
local REPS_PER_CYCLE = 10
local REP_DELAY = 0.01
local ROCK_INTERVAL = 5
local MAX_PING = 450
local MIN_PING = 250

local HumanoidRootPart
local lastProteinEggTime = 0
local lastRockTime = 0

local function getPing()
    local success, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return success and ping or 999
end

local function updateCharacterRefs()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
end

local function equipPet()
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if petsFolder and petsFolder:FindFirstChild("Unique") then
        for _, pet in pairs(petsFolder.Unique:GetChildren()) do
            if pet.Name == PET_NAME then
                pcall(function()
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                end)
                break
            end
        end
    end
end

local function eatProteinEgg()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item.Name == PROTEIN_EGG_NAME then
                pcall(function()
                    ReplicatedStorage.rEvents.eatEvent:FireServer("eat", item)
                end)
                break
            end
        end
    end
end

local function hitRock()
    local rock = workspace:FindFirstChild(ROCK_NAME)
    if rock and HumanoidRootPart then
        pcall(function()
            HumanoidRootPart.CFrame = rock.CFrame * CFrame.new(0, 0, -5)
            ReplicatedStorage.rEvents.hitEvent:FireServer("hit", rock)
        end)
    end
end

task.spawn(function()
    updateCharacterRefs()
    equipPet()
    lastProteinEggTime = tick()
    lastRockTime = tick()

    local farmingPaused = false

    while true do
        if getgenv()._AutoRepFarmEnabled then
            local ping = getPing()

            if ping > MAX_PING and not farmingPaused then
                warn("[Auto Rep Farm] Ping alto (" .. math.floor(ping) .. "ms), pausando farmeo...")
                farmingPaused = true
            end

            if ping <= MIN_PING and farmingPaused then
                warn("[Auto Rep Farm] Ping bajo (" .. math.floor(ping) .. "ms), reanudando farmeo...")
                farmingPaused = false
            end

            if not farmingPaused then
                local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    for _ = 1, REPS_PER_CYCLE do
                        muscleEvent:FireServer("rep")
                    end
                end

                if tick() - lastProteinEggTime >= PROTEIN_EGG_INTERVAL then
                    eatProteinEgg()
                    lastProteinEggTime = tick()
                end

                if tick() - lastRockTime >= ROCK_INTERVAL then
                    hitRock()
                    lastRockTime = tick()
                end
            end
        end

        task.wait(REP_DELAY)
    end
end)

-- ==========================================
-- STRENGTH OP (< 150 MS)
-- ==========================================
getgenv()._AutoRepFarmFastEnabled = false

AutoFarm:AddSwitch("Strength Op (Use it if your minimum ping is less than 150 ms)", function(state)
    getgenv()._AutoRepFarmFastEnabled = state
    warn("[Auto Rep Farm Fast] Estado cambiado a:", state and "ON" or "OFF")
end)

local FAST_REPS_PER_CYCLE = 40
local FAST_REP_DELAY = 0.01
local FAST_ROCK_INTERVAL = 5
local FAST_MAX_PING = 5000
local FAST_MIN_PING = 100

local fastLastProteinEggTime = 0
local fastLastRockTime = 0

task.spawn(function()
    fastLastProteinEggTime = tick()
    fastLastRockTime = tick()

    local fastFarmingPaused = false

    while true do
        if getgenv()._AutoRepFarmFastEnabled then
            local ping = getPing()

            if ping > FAST_MAX_PING and not fastFarmingPaused then
                warn("[Auto Rep Farm Fast] Ping alto (" .. math.floor(ping) .. "ms), pausando farmeo...")
                fastFarmingPaused = true
            end

            if ping <= FAST_MIN_PING and fastFarmingPaused then
                warn("[Auto Rep Farm Fast] Ping bajo (" .. math.floor(ping) .. "ms), reanudando farmeo...")
                fastFarmingPaused = false
            end

            if not fastFarmingPaused then
                local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    for _ = 1, FAST_REPS_PER_CYCLE do
                        muscleEvent:FireServer("rep")
                    end
                end

                if tick() - fastLastProteinEggTime >= PROTEIN_EGG_INTERVAL then
                    eatProteinEgg()
                    fastLastProteinEggTime = tick()
                end

                if tick() - fastLastRockTime >= FAST_ROCK_INTERVAL then
                    hitRock()
                    fastLastRockTime = tick()
                end
            end
        end

        task.wait(FAST_REP_DELAY)
    end
end)

-- ==========================================
-- AUTO EAT EGG & EXTRAS
-- ==========================================
local autoEatEnabled = false

local function eatProteinEggAlt()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if not backpack or not character then return end

    local egg = backpack:FindFirstChild("Protein Egg") or backpack:FindFirstChild("ProteinEgg")
    if egg then
        egg.Parent = character
        pcall(function()
            egg:Activate()
        end)
    end
end

task.spawn(function()
    while true do
        if autoEatEnabled then
            eatProteinEggAlt()
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)

AutoFarm:AddSwitch("Auto Eat Egg 30 Minuts", function(state)
    autoEatEnabled = state
end)

AutoFarm:AddSwitch("Spin Fortune Wheel", function(state)
    _G.AutoSpinWheel = state

    if state then
        task.spawn(function()
            while _G.AutoSpinWheel do
                pcall(function()
                    ReplicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer(
                        "openFortuneWheel",
                        ReplicatedStorage.fortuneWheelChances["Fortune Wheel"]
                    )
                end)
                task.wait(0.1)
            end
        end)
    end
end)

AutoFarm:AddSwitch("Hide All Frames", function(bool)
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj.Name:match("Frame$") and obj:IsA("GuiObject") then
            obj.Visible = not bool
        end
    end
end)

AutoFarm:AddButton("Anti Lag", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            local parent = v.Parent
            local parentParent = parent and parent.Parent
            if not ((parent and parent:FindFirstChild("Humanoid")) or (parentParent and parentParent:FindFirstChild("Humanoid"))) then
                v.Reflectance = 0
            end
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    pcall(function()
        settings().Rendering.QualityLevel = 1
    end)

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "anti lag activado",
            Text = "Full optimization applied!",
            Duration = 5
        })
    end)
end)

AutoFarm:AddButton("Full Optimization", function()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui:Destroy()
            end
        end
    end

    local function darkenSky()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end

        local darkSky = Instance.new("Sky")
        darkSky.Name = "DarkSky"
        darkSky.SkyboxBk = "rbxassetid://0"
        darkSky.SkyboxDn = "rbxassetid://0"
        darkSky.SkyboxFt = "rbxassetid://0"
        darkSky.SkyboxLf = "rbxassetid://0"
        darkSky.SkyboxRt = "rbxassetid://0"
        darkSky.SkyboxUp = "rbxassetid://0"
        darkSky.Parent = Lighting

        Lighting.Brightness = 0
        Lighting.ClockTime = 0
        Lighting.TimeOfDay = "00:00:00"
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.FogColor = Color3.new(0, 0, 0)
        Lighting.FogEnd = 100

        task.spawn(function()
            while true do
                task.wait(5)
                if not Lighting:FindFirstChild("DarkSky") then
                    darkSky:Clone().Parent = Lighting
                end
                Lighting.Brightness = 0
                Lighting.ClockTime = 0
                Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                Lighting.Ambient = Color3.new(0, 0, 0)
                Lighting.FogColor = Color3.new(0, 0, 0)
                Lighting.FogEnd = 100
            end
        end)
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()
        end
    end

    darkenSky()
end)

AutoFarm:AddButton("Equip Swift Samurai", function()
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end

    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)

    local equipped = 0
    local maxEquip = 8
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                if pet.Name == "Swift Samurai" then
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                    equipped += 1
                    if equipped >= maxEquip then
                        return
                    end
                end
            end
        end
    end
end)

AutoFarm:AddButton("Jungle Squat", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(-8371.4336, 6.7981, 2858.8853)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end)

AutoFarm:AddButton("Jungle lift", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(-8652.8672, 29.2667, 2089.2617)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end)

AutoFarm:AddLabel("Rebiths Gained").TextSize = 23

-- ==========================================
-- REBIRTHS PACKS (CON CAMBIO DE PETS)
-- ==========================================
local fastStrengthFolder = AutoFarm:AddFolder("Rebirths Packs")

local bestPets = {
    "Swift Samurai", "Omega Overlord", "Mythic Boss Pet",
    "Legendary Boss Pet", "Rainbow Boss Pet", "Zeus Spark", "Epic Boss Pet"
}
local eclipsePets = { "Tribal Overlord", "Titanium Hydra", "Eclipse Devourer" }

local function formatPacksNum(p1)
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

local function getRbStats()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return { Str = 0, Reb = 0 } end
    local s = ls:FindFirstChild("Strength")
    local r = ls:FindFirstChild("Rebirths")
    return {
        Str = s and s.Value or 0,
        Reb = r and r.Value or 0,
    }
end

local function getRequiredStrength()
    return math.floor(5000 + 2500 * getRbStats().Reb)
end

local function unequipAllPets()
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

local function equipSpecificPets(petList, limit)
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    local count = 0
    for _, petName in ipairs(petList) do
        for _, folder in pairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in pairs(folder:GetChildren()) do
                    if pet.Name == petName then
                        ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                        count = count + 1
                        if count >= limit then return end
                    end
                end
            end
        end
    end
end

local rbTimeLbl = fastStrengthFolder:AddLabel("Tiempo: 0d 0h 0m 0s")
rbTimeLbl.TextSize = 18
local rbStatsLbl = fastStrengthFolder:AddLabel("Renacimientos: 0 | Ganados: 0")
rbStatsLbl.TextSize = 18
local reqStrengthLbl = fastStrengthFolder:AddLabel("Fuerza Necesaria: 0")
reqStrengthLbl.TextSize = 18

task.spawn(function()
    task.wait(2)
    local sessionStartRebirths = getRbStats().Reb
    local rbStartTime = tick()
    while true do
        local elapsed = tick() - rbStartTime
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)

        rbTimeLbl.Text = "Tiempo: " .. string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
        local currentReb = getRbStats().Reb
        local g = currentReb - sessionStartRebirths
        rbStatsLbl.Text = "Renacimientos: " .. formatPacksNum(currentReb) .. " | Ganados: " .. formatPacksNum(g)
        reqStrengthLbl.Text = "Fuerza Necesaria: " .. formatPacksNum(getRequiredStrength())
        task.wait(1)
    end
end)

getgenv().AutoFarming = false

fastStrengthFolder:AddSwitch("Rebirths Packs", function(state)
    getgenv().AutoFarming = state
end)

task.spawn(function()
    while true do
        if getgenv().AutoFarming then
            pcall(function()
                unequipAllPets()
                equipSpecificPets(bestPets, 12)

                while getgenv().AutoFarming do
                    local req = getRequiredStrength()
                    while getRbStats().Str < req and getgenv().AutoFarming do
                        local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            for _ = 1, 31 do
                                muscleEvent:FireServer("rep")
                            end
                        end
                        task.wait()
                    end

                    if not getgenv().AutoFarming then break end
                    unequipAllPets()
                    equipSpecificPets(eclipsePets, 12)

                    local currentRb = getRbStats().Reb
                    repeat
                        ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.2)
                    until getRbStats().Reb > currentRb or not getgenv().AutoFarming

                    if getgenv().AutoFarming then
                        unequipAllPets()
                        equipSpecificPets(bestPets, 12)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ==========================================
-- REBIRTHS WITHOUT PACKS
-- ==========================================
local rebirthFolder = AutoFarm:AddFolder("Rebiths Without Packs")

local targetRebirthAmount = nil
local farmingTarget = false
local repSpeed = 10

rebirthFolder:AddTextBox("Target number of Rebirths", function(value)
    local amount = tonumber(value)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local rebirthsStat = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local currentRebirths = rebirthsStat and rebirthsStat.Value or 0
    if amount and amount >= currentRebirths then
        targetRebirthAmount = amount
    end
end, { clear = false })

local targetRebirthToggle
targetRebirthToggle = rebirthFolder:AddSwitch("Start", function(enabled)
    farmingTarget = enabled
    if enabled then
        task.spawn(function()
            while farmingTarget do
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                local rebirthsStat = leaderstats and leaderstats:FindFirstChild("Rebirths")
                local strengthStat = leaderstats and leaderstats:FindFirstChild("Strength")
                if not rebirthsStat or not strengthStat then
                    task.wait(0.5)
                    continue
                end

                local currentRebirths = rebirthsStat.Value
                local requiredStrength = 10000 + 5000 * currentRebirths

                if targetRebirthAmount and currentRebirths >= targetRebirthAmount then
                    pcall(function() targetRebirthToggle:Set(false) end)
                    farmingTarget = false
                    break
                end

                if strengthStat.Value >= requiredStrength then
                    pcall(function()
                        ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                    end)
                    task.wait(0.7)
                else
                    local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                    if muscleEvent then
                        for _ = 1, repSpeed do
                            muscleEvent:FireServer("rep")
                        end
                    end
                end

                task.wait(0.1)
            end
        end)
    end
end)

rebirthFolder:AddSwitch("Auto Teleport to the king", function(enabled)
    _G.AutoTeleportKing = enabled
    if enabled then
        local targetPosition = Vector3.new(-8750.1318359375, 124.37654876708984, -5861.2666015625)
        task.spawn(function()
            while _G.AutoTeleportKing do
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(targetPosition)
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    rootPart.AssemblyAngularVelocity = Vector3.zero
                end
                task.wait(0.1)
            end
        end)
    end
end)

rebirthFolder:AddSwitch("Auto size 2", function(enabled)
    _G.AutoSize2 = enabled
    if enabled then
        task.spawn(function()
            while _G.AutoSize2 do
                pcall(function()
                    ReplicatedStorage:WaitForChild("rEvents")
                        :WaitForChild("changeSpeedSizeRemote")
                        :InvokeServer("changeSize", 2)
                end)
                task.wait(1)
            end
        end)
    end
end)

-- ==========================================
-- AUTO TOOLS
-- ==========================================
local autoEquipToolsFolder = AutoFarm:AddFolder("Auto Tools")

autoEquipToolsFolder:AddButton("Gamepass AutoLift", function()
    local gamepassFolder = ReplicatedStorage:FindFirstChild("gamepassIds")
    local ownedGamepasses = LocalPlayer:FindFirstChild("ownedGamepasses")
    if gamepassFolder and ownedGamepasses then
        for _, gamepass in pairs(gamepassFolder:GetChildren()) do
            local value = Instance.new("IntValue")
            value.Name = gamepass.Name
            value.Value = gamepass.Value
            value.Parent = ownedGamepasses
        end
    end
end)

local function createAutoToolSwitch(toolName, globalVar)
    autoEquipToolsFolder:AddSwitch("Auto " .. toolName, function(Value)
        _G[globalVar] = Value

        if Value then
            local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if tool and hum then
                hum:EquipTool(tool)
            end
        else
            local character = LocalPlayer.Character
            local equipped = character and character:FindFirstChild(toolName)
            if equipped then
                equipped.Parent = LocalPlayer.Backpack
            end
        end

        task.spawn(function()
            while _G[globalVar] do
                local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    muscleEvent:FireServer("rep")
                end
                task.wait(0.1)
            end
        end)
    end)
end

createAutoToolSwitch("Weight", "AutoWeight")
createAutoToolSwitch("Pushups", "AutoPushups")
createAutoToolSwitch("Handstands", "AutoHandstands")
createAutoToolSwitch("Situps", "AutoSitups")

autoEquipToolsFolder:AddSwitch("Auto Punch", function(Value)
    _G.fastHitActive = Value

    if Value then
        task.spawn(function()
            while _G.fastHitActive do
                local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch and LocalPlayer.Character then
                    punch.Parent = LocalPlayer.Character
                    if punch:FindFirstChild("attackTime") then
                        punch.attackTime.Value = 0
                    end
                end
                task.wait(0.1)
            end
        end)

        task.spawn(function()
            while _G.fastHitActive do
                local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    muscleEvent:FireServer("punch", "rightHand")
                    muscleEvent:FireServer("punch", "leftHand")
                end

                local character = LocalPlayer.Character
                local punchTool = character and character:FindFirstChild("Punch")
                if punchTool then
                    pcall(function()
                        punchTool:Activate()
                    end)
                end
                task.wait()
            end
        end)
    else
        local character = LocalPlayer.Character
        local equipped = character and character:FindFirstChild("Punch")
        if equipped then
            equipped.Parent = LocalPlayer.Backpack
        end
    end
end)

autoEquipToolsFolder:AddSwitch("Fast Tools", function(Value)
    _G.FastTools = Value

    local toolSettings = {
        { "Punch", "attackTime", Value and 0 or 0.35 },
        { "Ground Slam", "attackTime", Value and 0 or 6 },
        { "Stomp", "attackTime", Value and 0 or 7 },
        { "Handstands", "repTime", Value and 0 or 1 },
        { "Pushups", "repTime", Value and 0 or 1 },
        { "Weight", "repTime", Value and 0 or 1 },
        { "Situps", "repTime", Value and 0 or 1 },
    }

    local backpack = LocalPlayer:WaitForChild("Backpack")

    for _, toolInfo in ipairs(toolSettings) do
        local tool = backpack:FindFirstChild(toolInfo[1])
        if tool and tool:FindFirstChild(toolInfo[2]) then
            tool[toolInfo[2]].Value = toolInfo[3]
        end

        local equippedTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(toolInfo[1])
        if equippedTool and equippedTool:FindFirstChild(toolInfo[2]) then
            equippedTool[toolInfo[2]].Value = toolInfo[3]
        end
    end
end)

-- ==========================================
-- STATS & VER VIDA
-- ==========================================
local estadisticas = window:AddTab("Stats")

local SelectPlayerName = ""

local PlayerDrop = estadisticas:AddDropdown("Select Player", function(Value)
    SelectPlayerName = Value:match("| (.+)") or Value
end)

for _, Plr in pairs(Players:GetPlayers()) do
    PlayerDrop:Add(Plr.DisplayName .. " | " .. Plr.Name)
end

local function FormatNumberWithCommas(number)
    local formatted = tostring(math.floor(number)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return formatted:gsub("^,", "")
end

local function FormatAbbreviated(number)
    local abbreviations = { "", "K", "M", "B", "T", "Qa", "Qi" }
    local abbreviationIndex = 1
    while number >= 1000 and abbreviationIndex < #abbreviations do
        number = number / 1000
        abbreviationIndex = abbreviationIndex + 1
    end
    return string.format("%.2f", number) .. abbreviations[abbreviationIndex]
end

local function FormatDisplay(value)
    local normal = FormatNumberWithCommas(value)
    local abbreviated = FormatAbbreviated(value)
    return "[ " .. normal .. " | " .. abbreviated .. " ]"
end

local Update = estadisticas:AddLabel("")
local Update1 = estadisticas:AddLabel("")
local Update2 = estadisticas:AddLabel("")
local Update3 = estadisticas:AddLabel("")
local Update4 = estadisticas:AddLabel("")
local Update5 = estadisticas:AddLabel("")
local Update6 = estadisticas:AddLabel("")
local Update9 = estadisticas:AddLabel("")
local Update10 = estadisticas:AddLabel("")
local Update11 = estadisticas:AddLabel("")
local Update12 = estadisticas:AddLabel("")
local Update13 = estadisticas:AddLabel("")

task.spawn(function()
    while task.wait(0.1) do
        if SelectPlayerName ~= "" then
            local target = Players:FindFirstChild(SelectPlayerName)
            if target then
                if target:FindFirstChild("Gems") then
                    Update1.Text = "Gems: " .. FormatDisplay(target.Gems.Value)
                end
                if target:FindFirstChild("Agility") then
                    Update3.Text = "Agility: " .. FormatDisplay(target.Agility.Value)
                end
                if target:FindFirstChild("Durability") then
                    Update4.Text = "Durability: " .. FormatDisplay(target.Durability.Value)
                end
                if target:FindFirstChild("muscleKingTime") then
                    Update6.Text = "Muscle King Time: " .. FormatDisplay(target.muscleKingTime.Value)
                end
                if target:FindFirstChild("customSize") then
                    Update10.Text = "Custom Size: " .. FormatDisplay(target.customSize.Value)
                end
                if target:FindFirstChild("customSpeed") then
                    Update11.Text = "Custom Speed: " .. FormatDisplay(target.customSpeed.Value)
                end
                if target:FindFirstChild("evilKarma") then
                    Update12.Text = "Evil Karma: " .. FormatDisplay(target.evilKarma.Value)
                end
                if target:FindFirstChild("goodKarma") then
                    Update13.Text = "Good Karma: " .. FormatDisplay(target.goodKarma.Value)
                end

                local leaderstats = target:FindFirstChild("leaderstats")
                if leaderstats then
                    if leaderstats:FindFirstChild("Strength") then
                        Update.Text = "Strength: " .. FormatDisplay(leaderstats.Strength.Value)
                    end
                    if leaderstats:FindFirstChild("Rebirths") then
                        Update2.Text = "Rebirth: " .. FormatDisplay(leaderstats.Rebirths.Value)
                    end
                    if leaderstats:FindFirstChild("Kills") then
                        Update5.Text = "Kills: " .. FormatDisplay(leaderstats.Kills.Value)
                    end
                end

                if target:FindFirstChild("currentMap") then
                    Update9.Text = "Current Map: " .. tostring(target.currentMap.Value)
                else
                    Update9.Text = "Current Map: Sin datos"
                end
            end
        end
    end
end)

estadisticas:AddLabel("————————————————————————————")
estadisticas:AddLabel("stats advanced:").TextSize = 24

local enemyHealthLabel = estadisticas:AddLabel("Enemy Health: N/A")
enemyHealthLabel.TextSize = 20
enemyHealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local playerDamageLabel = estadisticas:AddLabel("Your Damage: N/A")
playerDamageLabel.TextSize = 20
playerDamageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local hitsToKillLabel = estadisticas:AddLabel("Hits to Kill: N/A")
hitsToKillLabel.TextSize = 20
hitsToKillLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local function calculateEnemyHealth(targetPlayer)
    if not targetPlayer then return 0 end
    local baseDura = 0
    local durabilityStat =
        targetPlayer:FindFirstChild("Durability")
        or (targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Durability"))
    if durabilityStat then
        baseDura = durabilityStat.Value
    end

    local totalMultiplier = 1
    local ultFolder = targetPlayer:FindFirstChild("ultimatesFolder")
    if ultFolder then
        local infernalHealth = ultFolder:FindFirstChild("Infernal Health")
        if infernalHealth then
            totalMultiplier = totalMultiplier + 0.15 * (infernalHealth.Value or 0)
        end
    end

    local backpack = targetPlayer:FindFirstChild("Backpack")
    if backpack then
        local equippedPets = backpack:FindFirstChild("EquippedPets") or backpack:FindFirstChild("equippedPets")
        if equippedPets then
            for _, pet in ipairs(equippedPets:GetChildren()) do
                local petStr = string.lower(tostring(pet))
                if petStr:match("mighty") and petStr:match("monster") then
                    totalMultiplier = totalMultiplier + 0.5
                    break
                end
            end
        end
    end

    return baseDura * totalMultiplier
end

local function calculateLocalPlayerDamage()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local strengthStat = leaderstats and leaderstats:FindFirstChild("Strength")
    if not strengthStat then return 0 end

    local baseDamage = strengthStat.Value * 0.0667
    local totalMultiplier = 1
    local ultFolder = LocalPlayer:FindFirstChild("ultimatesFolder")
    if ultFolder then
        local demonDamage = ultFolder:FindFirstChild("Demon Damage")
        if demonDamage then
            totalMultiplier = totalMultiplier + math.min(0.1 * (demonDamage.Value or 0), 0.5)
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local equippedPets = backpack:FindFirstChild("EquippedPets") or backpack:FindFirstChild("equippedPets")
        if equippedPets then
            for _, pet in ipairs(equippedPets:GetChildren()) do
                local petStr = string.lower(tostring(pet))
                if petStr:match("wild") and petStr:match("wizard") then
                    totalMultiplier = totalMultiplier + 0.5
                    break
                end
            end
        end
    end

    return baseDamage * totalMultiplier
end

local function calculateHitsToKill(health, damage)
    if damage <= 0 then return "∞" end
    local hits = math.ceil(health / damage)
    if hits > 50 then
        return "∞"
    elseif hits < 1 then
        return 1
    else
        return hits
    end
end

local function updateAdvancedStats(targetPlayer)
    if not targetPlayer then
        enemyHealthLabel.Text = "vida del enemigo: N/A"
        playerDamageLabel.Text = "Tu daño: N/A"
        hitsToKillLabel.Text = "Hits to Kill: N/A"
        return
    end
    local enemyHealth = calculateEnemyHealth(targetPlayer)
    local playerDamage = calculateLocalPlayerDamage()
    local hitsToKill = calculateHitsToKill(enemyHealth, playerDamage)
    enemyHealthLabel.Text = "life of the enemy: " .. FormatDisplay(enemyHealth)
    playerDamageLabel.Text = "You damage: " .. FormatDisplay(playerDamage)
    hitsToKillLabel.Text = "Golpes para matarlo: " .. tostring(hitsToKill)
end

task.spawn(function()
    while true do
        local selectedPlayer = Players:FindFirstChild(SelectPlayerName)
        if selectedPlayer then
            updateAdvancedStats(selectedPlayer)
        else
            updateAdvancedStats(nil)
        end
        task.wait(0.2)
    end
end)

-- 1. VER VIDA (BILLBOARD HEALTH BARS)
estadisticas:AddLabel("————————————————————————————")
estadisticas:AddLabel("Ver Vida (Health Bars):").TextSize = 22

getgenv().ShowHealthBars = true

estadisticas:AddSwitch("Mostrar Barra de Vida", function(state)
    getgenv().ShowHealthBars = state
end)

local function formatHealthNum(p1)
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

task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    task.wait(1)

    local function makeTextLabel(humanoid, instance)
        if not instance:FindFirstChild("Head") then return end
        local oldBillboard = instance.Head:FindFirstChild("HP_BILLBOARD")
        if oldBillboard then oldBillboard:Destroy() end

        local hpBILLBOARD2 = Instance.new("BillboardGui")
        hpBILLBOARD2.Name = "HP_BILLBOARD"
        hpBILLBOARD2.Size = UDim2.new(6, 0, 1.3, 0)
        hpBILLBOARD2.StudsOffset = Vector3.new(0, 3.8, 0)
        hpBILLBOARD2.AlwaysOnTop = true
        hpBILLBOARD2.MaxDistance = 200
        hpBILLBOARD2.Parent = instance.Head

        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.BackgroundTransparency = 0.25
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.Parent = hpBILLBOARD2

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 6)
        uiCorner.Parent = frame

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(120, 0, 0)
        uiStroke.Transparency = 0.4
        uiStroke.Thickness = 1.5
        uiStroke.Parent = frame

        local fillFrame = Instance.new("Frame")
        fillFrame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        fillFrame.Size = UDim2.new(1, 0, 1, 0)
        fillFrame.BorderSizePixel = 0
        fillFrame.Parent = frame

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 6)
        fillCorner.Parent = fillFrame

        local uiGradient = Instance.new("UIGradient")
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 0)),
        })
        uiGradient.Parent = fillFrame

        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16
        textLabel.TextStrokeTransparency = 0.3
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.ZIndex = 2
        textLabel.Parent = frame

        local function updateHealth()
            if humanoid and humanoid.Parent then
                local health = humanoid.Health
                local maxHealth = math.max(humanoid.MaxHealth, 1)
                fillFrame.Size = UDim2.new(math.clamp(health / maxHealth, 0, 1), 0, 1, 0)
                textLabel.Text = formatHealthNum(health) .. " / " .. formatHealthNum(maxHealth)
            end
        end

        humanoid.HealthChanged:Connect(updateHealth)
        updateHealth()

        task.spawn(function()
            while hpBILLBOARD2 and hpBILLBOARD2.Parent do
                hpBILLBOARD2.Enabled = getgenv().ShowHealthBars
                task.wait(0.5)
            end
        end)
    end

    local function setupCharacter(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then makeTextLabel(humanoid, character) end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then setupCharacter(p.Character) end
        p.CharacterAdded:Connect(setupCharacter)
    end
    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(setupCharacter)
    end)
end)

-- ==========================================
-- CALCULADORA 2
-- ==========================================
local Calculadora = window:AddTab("Calculadora 2", Color3.fromRGB(200, 100, 100))

local baseStrength = 0
local resultadoLabelsDamage = {}

local FolderDamage = Calculadora:AddFolder("Pack Damage Calculator")

FolderDamage:AddTextBox("Base Strongth (ej: 1.27Qa, T, B)", function(text)
    local unidades = { ["T"] = 1e12, ["Q"] = 1e15, ["B"] = 1e9 }
    text = text:upper()
    for u, m in pairs(unidades) do
        if text:find(u) then
            local num = tonumber(text:match("(%d+%.?%d*)"))
            if num then
                baseStrength = num * m
                return
            end
        end
    end
    baseStrength = tonumber(text:match("(%d+%.?%d*)")) or 0
end)

local mensajeLabelDamage = FolderDamage:AddLabel("")

for i = 1, 8 do
    resultadoLabelsDamage[i] = FolderDamage:AddLabel(string.format("%d pack(s): -", i))
end

FolderDamage:AddButton("Calculate Damage", function()
    if baseStrength <= 0 then
        mensajeLabelDamage.Text = "Enter a valid value."
        for i = 1, 8 do
            resultadoLabelsDamage[i].Text = string.format("%d pack(s): -", i)
        end
        return
    end

    mensajeLabelDamage.Text = ""
    local danoAjustado = baseStrength * 0.10
    local incremento = 0.335

    for pack = 1, 8 do
        local mult = 1 + (pack * incremento)
        local valor = danoAjustado * mult

        local disp
        if valor >= 1e15 then
            disp = string.format("%.3f Qa", valor / 1e15)
        elseif valor >= 1e12 then
            disp = string.format("%.2f T", valor / 1e12)
        elseif valor >= 1e9 then
            disp = string.format("%.2f B", valor / 1e9)
        else
            disp = tostring(math.floor(valor))
        end

        resultadoLabelsDamage[pack].Text = string.format("%d pack(s): %s", pack, disp)
    end
end)

local baseDurabilidad = 0
local resultadoLabelsDurabilidad = {}

local FolderDurabilidad = Calculadora:AddFolder("Pack Durability Calculator")

FolderDurabilidad:AddTextBox("Base durability (ej: 1.27Qa, T, B)", function(text)
    local unidades = { ["T"] = 1e12, ["Q"] = 1e15, ["B"] = 1e9 }
    text = text:upper()
    for u, m in pairs(unidades) do
        if text:find(u) then
            local num = tonumber(text:match("(%d+%.?%d*)"))
            if num then
                baseDurabilidad = num * m
                return
            end
        end
    end
    baseDurabilidad = tonumber(text:match("(%d+%.?%d*)")) or 0
end)

local mensajeLabelDurabilidad = FolderDurabilidad:AddLabel("")

for i = 1, 8 do
    resultadoLabelsDurabilidad[i] = FolderDurabilidad:AddLabel(string.format("%d pack(s): -", i))
end

FolderDurabilidad:AddButton("Calculate Durability", function()
    if baseDurabilidad <= 0 then
        mensajeLabelDurabilidad.Text = "Enter a valid value."
        for i = 1, 8 do
            resultadoLabelsDurabilidad[i].Text = string.format("%d pack(s): -", i)
        end
        return
    end

    mensajeLabelDurabilidad.Text = ""
    local incremento = 0.335
    local adicional = 1.5

    for pack = 1, 8 do
        local mult = 1 + (pack * incremento)
        local valor = baseDurabilidad * mult * adicional

        local disp
        if valor >= 1e15 then
            disp = string.format("%.3f Qa", valor / 1e15)
        elseif valor >= 1e12 then
            disp = string.format("%.2f T", valor / 1e12)
        elseif valor >= 1e9 then
            disp = string.format("%.2f B", valor / 1e9)
        else
            disp = tostring(math.floor(valor))
        end

        resultadoLabelsDurabilidad[pack].Text = string.format("%d pack(s): %s", pack, disp)
    end
end)

-- ==========================================
-- CALCULATE STATS
-- ==========================================
local features = window:AddTab("Calculate Stats")
features:Show()

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local strengthStat = leaderstats:WaitForChild("Strength")
local durabilityStat = LocalPlayer:WaitForChild("Durability")

local function formatNumber(number)
    local isNegative = number < 0
    number = math.abs(number)
    if number >= 1e15 then
        return (isNegative and "-" or "") .. string.format("%.2fQa", number / 1e15)
    elseif number >= 1e12 then
        return (isNegative and "-" or "") .. string.format("%.2fT", number / 1e12)
    elseif number >= 1e9 then
        return (isNegative and "-" or "") .. string.format("%.2fB", number / 1e9)
    elseif number >= 1e6 then
        return (isNegative and "-" or "") .. string.format("%.2fM", number / 1e6)
    elseif number >= 1e3 then
        return (isNegative and "-" or "") .. string.format("%.2fK", number / 1e3)
    else
        return (isNegative and "-" or "") .. string.format("%.2f", number)
    end
end

local stopwatchLabel = features:AddLabel("Fast Rep Time: 0d 0h 0m 0s")
stopwatchLabel.TextSize = 20

local projectedStrengthLabel = features:AddLabel("Strength Rate: 0 /Hour | 0 /Day | 0 /Week | 0 /Month")
projectedStrengthLabel.TextSize = 20

local projectedDurabilityLabel = features:AddLabel("Durability Rate: 0 /Hour | 0 /Day | 0 /Week | 0 /Month")
projectedDurabilityLabel.TextSize = 20

features:AddLabel("").TextSize = 10

local statsLabel = features:AddLabel("Stats:")
statsLabel.TextSize = 24

local strengthLabel = features:AddLabel("Strength: 0 | Gained: 0")
strengthLabel.TextSize = 20

local durabilityLabel = features:AddLabel("Durability: 0 | Gained: 0")
durabilityLabel.TextSize = 20

local startTime = tick()
local initialStrength = strengthStat.Value
local initialDurability = durabilityStat.Value
local trackingStarted = false

local strengthHistory = {}
local durabilityHistory = {}
local calculationInterval = 10

task.spawn(function()
    local lastCalcTime = tick()
    while true do
        local currentTime = tick()
        local currentStrength = strengthStat.Value
        local currentDurability = durabilityStat.Value

        if not trackingStarted and (currentStrength - initialStrength) >= 100e9 then
            trackingStarted = true
            startTime = tick()
            strengthHistory = {}
            durabilityHistory = {}
        end

        if trackingStarted then
            local elapsedTime = currentTime - startTime
            local days = math.floor(elapsedTime / (24 * 3600))
            local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
            local minutes = math.floor((elapsedTime % 3600) / 60)
            local seconds = math.floor(elapsedTime % 60)

            stopwatchLabel.Text = string.format("Fast Rep Time: %dd %dh %dm %ds", days, hours, minutes, seconds)

            local sessionStrengthDelta = currentStrength - initialStrength
            local sessionDurabilityDelta = currentDurability - initialDurability

            strengthLabel.Text = "Strength: " .. formatNumber(currentStrength) .. " | Gained: " .. formatNumber(sessionStrengthDelta)
            durabilityLabel.Text = "Durability: " .. formatNumber(currentDurability) .. " | Gained: " .. formatNumber(sessionDurabilityDelta)

            table.insert(strengthHistory, { time = currentTime, value = currentStrength })
            table.insert(durabilityHistory, { time = currentTime, value = currentDurability })

            while #strengthHistory > 0 and currentTime - strengthHistory[1].time > calculationInterval do
                table.remove(strengthHistory, 1)
            end
            while #durabilityHistory > 0 and currentTime - durabilityHistory[1].time > calculationInterval do
                table.remove(durabilityHistory, 1)
            end

            if currentTime - lastCalcTime >= calculationInterval then
                lastCalcTime = currentTime

                if #strengthHistory >= 2 then
                    local strengthDelta = strengthHistory[#strengthHistory].value - strengthHistory[1].value
                    local strengthPerSecond = strengthDelta / calculationInterval
                    local strengthPerHour = math.floor(strengthPerSecond * 3600)
                    local strengthPerDay = math.floor(strengthPerSecond * 86400)
                    local strengthPerWeek = math.floor(strengthPerSecond * 604800)
                    local strengthPerMonth = math.floor(strengthPerSecond * 2592000)

                    projectedStrengthLabel.Text = "Strength Rate: " .. formatNumber(strengthPerHour) .. "/Hour | " .. formatNumber(strengthPerDay) .. "/Day | " .. formatNumber(strengthPerWeek) .. "/Week | " .. formatNumber(strengthPerMonth) .. "/Month"
                end

                if #durabilityHistory >= 2 then
                    local durabilityDelta = durabilityHistory[#durabilityHistory].value - durabilityHistory[1].value
                    local durabilityPerSecond = durabilityDelta / calculationInterval
                    local durabilityPerHour = math.floor(durabilityPerSecond * 3600)
                    local durabilityPerDay = math.floor(durabilityPerSecond * 86400)
                    local durabilityPerWeek = math.floor(durabilityPerSecond * 604800)
                    local durabilityPerMonth = math.floor(durabilityPerSecond * 2592000)

                    projectedDurabilityLabel.Text = "Durability Rate: " .. formatNumber(durabilityPerHour) .. "/Hour | " .. formatNumber(durabilityPerDay) .. "/Day | " .. formatNumber(durabilityPerWeek) .. "/Week | " .. formatNumber(durabilityPerMonth) .. "/Month"
                end
            end
        end

        task.wait(0.05)
    end
end)
