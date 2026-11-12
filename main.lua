-- ==========================================
-- SCRIPT PRINCIPAL DE CONTENIDO (main.lua)
-- Estilo: Rojo Rubí y Negro (Todas las pestañas visibles y tiempo real)
-- ==========================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Configuración de diseño y transparencia
WindUI.TransparencyValue = 0.35
WindUI:SetTheme("Dark")

-- Ventana Principal del Menú optimizada para móviles
local Window = WindUI:CreateWindow({
    Title = "Christian y Nyxa - Menú Principal",
    Icon = "smartphone",
    Author = "Versión 1.0",
    Folder = "PrivateChris_Mobile",
    Size = UDim2.fromOffset(480, 360), 
    Theme = "Dark",
    HidePanelBackground = false,
    NewElements = false,
})

-- Botón flotante adaptado para móviles (Degradado Rojo Rubí a Negro, arrastrable)
Window:EditOpenButton({
    Title = "Abrir Menú",
    Icon = nil,
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("990000"), -- Rojo Rubí intenso
        Color3.fromHex("1A1A1A")  -- Negro elegante
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- ==========================================
-- SERVICIOS Y VARIABLES GLOBALES
-- ==========================================
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local statsService = game:GetService("Stats")
local lighting = game:GetService("Lighting")
local virtualInputManager = game:GetService("VirtualInputManager")
local workspaceService = game:GetService("Workspace")
local starterGui = game:GetService("StarterGui")
local userInputService = game:GetService("UserInputService")
local virtualUser = game:GetService("VirtualUser")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

-- Formateador de números grandes (Qi, Qa, T, B, M, K)
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

-- ==========================================
-- SISTEMA DE BARRAS DE SALUD FLOTANTES
-- ==========================================
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
        frame2.BackgroundColor3 = Color3.fromRGB(153, 0, 0) -- Rojo Rubí
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
-- 1. PESTAÑA: SPEED FARM
-- ==========================================
local speedFarmTab = Window:Tab({ Title = "Speed Farm", Icon = "zap" })
local speedSection = speedFarmTab:Section({ Title = "Estadísticas y Control", Content = "Información en tiempo real" })

local fastRepTimeLbl = speedSection:Paragraph({ Title = "Fast Rep Time", Desc = "0d 0h 0m 0s" })
local strengthRateLbl = speedSection:Paragraph({ Title = "Strength Rate", Desc = "0 /Hour | 0 /Day" })
local durabilityRateLbl = speedSection:Paragraph({ Title = "Durability Rate", Desc = "0 /Hour | 0 /Day" })

speedSection:Paragraph({ Title = "Stats Actuales", Desc = "Progreso en tiempo real" })
local strengthStatsLbl = speedSection:Paragraph({ Title = "Strength", Desc = "0 | Gained: 0" })
local durabilityStatsLbl = speedSection:Paragraph({ Title = "Durability", Desc = "0 | Gained: 0" })

local repSpeedVal = 55
speedSection:Input({
    Title = "Velocidad de Reps",
    Desc = "Cantidad de reps por ciclo",
    Value = "55",
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

-- Loop de Fast Rep
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

-- Monitoreo en tiempo real de estadísticas (Actualización fluida cada 1-2 segundos)
local leaderstats = localPlayer:WaitForChild("leaderstats")
local strength = leaderstats:WaitForChild("Strength")
local durability = localPlayer:WaitForChild("Durability")

local initialStrength = strength.Value
local initialDurability = durability.Value
local startTimeTick = tick()
local strHistory, durHistory = {}, {}

task.spawn(function()
    local lastUpdate = tick()
    while true do
        local currentTime = tick()
        local currentStr = strength.Value
        local currentDur = durability.Value
        local elapsed = currentTime - startTimeTick
        
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        -- Refresco en tiempo real (mostrando fuerza y durabilidad ganada de forma exacta)
        fastRepTimeLbl:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))
        strengthStatsLbl:SetDesc("Strength: " .. formatNum(currentStr) .. " | Gained: " .. formatNum(currentStr - initialStrength))
        durabilityStatsLbl:SetDesc("Durability: " .. formatNum(currentDur) .. " | Gained: " .. formatNum(currentDur - initialDur))
        
        table.insert(strHistory, { time = currentTime, value = currentStr })
        table.insert(durHistory, { time = currentTime, value = currentDur })
        
        while #strHistory > 0 and currentTime - strHistory[1].time > 10 do table.remove(strHistory, 1) end
        while #durHistory > 0 and currentTime - durHistory[1].time > 10 do table.remove(durHistory, 1) end
        
        if currentTime - lastUpdate >= 2 then -- Actualiza tasas cada 2 segundos para evitar lag visual
            lastUpdate = currentTime
            if #strHistory >= 2 then
                local rate = (strHistory[#strHistory].value - strHistory[1].value) / 2
                strengthRateLbl:SetDesc(string.format("%s/Hour | %s/Day", formatNum(math.floor(rate * 3600)), formatNum(math.floor(rate * 86400))))
            end
            if #durHistory >= 2 then
                local rate = (durHistory[#durHistory].value - durHistory[1].value) / 2
                durabilityRateLbl:SetDesc(string.format("%s/Hour | %s/Day", formatNum(math.floor(rate * 3600)), formatNum(math.floor(rate * 86400))))
            end
        end
        task.wait(1) -- Ciclo exacto de 1 segundo para mostrar cambios en tiempo real
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
                local backpack = localPlayer:WaitForChild("Backpack")
                local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local event = localPlayer:FindFirstChild("muscleEvent")
                local proteinEgg = backpack:FindFirstChild("Protein Egg") or char:FindFirstChild("Protein Egg")
                if proteinEgg and event then
                    if proteinEgg.Parent ~= char then proteinEgg.Parent = char end
                    event:FireServer("proteinEgg", proteinEgg)
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
        local hrp = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
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
        WindUI:Notify({ Title = "Anti Lag", Content = "Optimización aplicada con éxito.", Duration = 4 })
    end
})


-- ==========================================
-- 2. PESTAÑA: REBIRTHS (Unificada: Pets + Normal)
-- ==========================================
local rebirthsTab = Window:Tab({ Title = "Rebirths", Icon = "repeat" })

-- Sección 1: Fast Rebirth con Mascotas
local rbSectionPets = rebirthsTab:Section({ Title = "Fast Rebirth (Con Mascotas)", Content = "Gestión con Eclipse Devourer" })

local rebirthsStat = leaderstats:WaitForChild("Rebirths")
local bestPets = { "Swift Samurai", "Omega Overlord", "Mythic Boss Pet", "Legendary Boss Pet", "Rainbow Boss Pet", "Epic Boss Pet", "Rare Boss Pet", "Common Boss Pet", "Zeus Spark", "Ares Ironfang" }
local eclipsePets = { "Tribal Overlord", "Titanium Hydra", "Eclipse Devourer" }

local rbTimeLbl = rbSectionPets:Paragraph({ Title = "Tiempo", Desc = "0d 0h 0m 0s" })
local rbStatsLbl = rbSectionPets:Paragraph({ Title = "Renacimientos", Desc = "0 | Ganados: 0" })
local reqStrengthLbl = rbSectionPets:Paragraph({ Title = "Fuerza Necesaria", Desc = "0" })

local function getRequiredStrength()
    return math.floor(5000 + 2500 * rebirthsStat.Value)
end

local sessionStartRebirths = rebirthsStat.Value
local rbStartTime = tick()

task.spawn(function()
    while true do
        local elapsed = tick() - rbStartTime
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        rbTimeLbl:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))
        local g = rebirthsStat.Value - sessionStartRebirths
        rbStatsLbl:SetDesc("Renacimientos: " .. formatNum(rebirthsStat.Value) .. " | Ganados: " .. formatNum(g))
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
rbSectionPets:Toggle({
    Title = "Fast Rebirth (Con Mascotas)",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarming = state
        if state then
            task.spawn(function()
                unequipAllPets()
                equipSpecificPets(bestPets, 12)
                while getgenv().AutoFarming do
                    local req = getRequiredStrength()
                    while strength.Value < req and getgenv().AutoFarming do
                        for _ = 1, 31 do
                            localPlayer.muscleEvent:FireServer("rep")
                        end
                        task.wait()
                    end
                    if not getgenv().AutoFarming then break end
                    unequipAllPets()
                    equipSpecificPets(eclipsePets, 12)
                    local currentRb = rebirthsStat.Value
                    repeat
                        replicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.2)
                    until rebirthsStat.Value > currentRb or not getgenv().AutoFarming
                    if getgenv().AutoFarming then
                        unequipAllPets()
                        equipSpecificPets(bestPets, 12)
                    end
                end
            end)
        end
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
        local hrp = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
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

-- Sección 2: Fast Rebirth Normal (Dentro de la misma pestaña Rebirths)
local rbSectionNormal = rebirthsTab:Section({ Title = "Fast Rebirth Normal", Content = "Sin cambio de mascotas" })

local startTimeNew = tick()
local sessionRebirthsNew = rebirthsStat.Value

local timeLabelNew = rbSectionNormal:Paragraph({ Title = "Time", Desc = "0d 0h 0m 0s" })
local gainedLabelNew = rbSectionNormal:Paragraph({ Title = "Gained Rebirths", Desc = "0" })
local fuerzaNecesariaNew = rbSectionNormal:Paragraph({ Title = "Fuerza Necesaria", Desc = "0" })

task.spawn(function()
    while true do
        local elapsed = tick() - startTimeNew
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        timeLabelNew:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))

        local gainedRebirths = rebirthsStat.Value - sessionRebirthsNew
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
                    if backpack then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:find("Bar") or tool.Name:find("Weight") or tool.Name:find("Bottle") or tool.Name:find("Pushups") or tool.Name:find("Handstands")) then
                                tool.Parent = character
                            end
                        end
                    end

                    local rounded19 = getRequiredStrength()
                    while strength.Value < rounded19 and getgenv().AutoFarmingNormal do
                        for n = 1, 31 do
                            localPlayer.muscleEvent:FireServer("rep")
                        end
                        task.wait()
                    end
                    if not getgenv().AutoFarmingNormal then break end
                    local value20 = rebirthsStat.Value
                    repeat
                        replicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.2)
                        v26 = rebirthsStat.Value > value20 or not getgenv().AutoFarmingNormal
                    until v26
                end
            end)
        end
    end
})


-- ==========================================
-- 3. PESTAÑA: EXTRAS & UTILIDADES
-- ==========================================
local extrasTab = Window:Tab({ Title = "Extras", Icon = "settings" })
local extrasSection = extrasTab:Section({ Title = "Misc y Utilidades", Content = "Funciones adicionales" })

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
            WindUI:Notify({ Title = "Anti AFK", Content = "Activado correctamente.", Duration = 4 })
        else
            if getgenv().AntiAfkConnection then
                getgenv().AntiAfkConnection:Disconnect()
                getgenv().AntiAfkConnection = nil
            end
            WindUI:Notify({ Title = "Anti AFK", Content = "Desactivado.", Duration = 4 })
        end
    end
})

-- Walk on Water
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

-- Limpiar inventario
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
