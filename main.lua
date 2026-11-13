
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI.TransparencyValue = 0.35
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "Christian Priv",
    Author = "Versión 1.0",
    Folder = "PrivateChris_Mobile",
    Size = UDim2.fromOffset(480, 360), 
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
local starterGui = game:GetService("StarterGui")
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
        
        fastRepTimeLbl:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))
        strengthStatsLbl:SetDesc("Strength: " .. formatNum(currentStr) .. " | Gained: " .. formatNum(currentStr - initialStrength))
        durabilityStatsLbl:SetDesc("Durability: " .. formatNum(currentDur) .. " | Gained: " .. formatNum(currentDur - initialDur))
        
        table.insert(strHistory, { time = currentTime, value = currentStr })
        table.insert(durHistory, { time = currentTime, value = currentDur })
        
        while #strHistory > 0 and currentTime - strHistory[1].time > 10 do table.remove(strHistory, 1) end
        while #durHistory > 0 and currentTime - durHistory[1].time > 10 do table.remove(durHistory, 1) end
        
        if currentTime - lastUpdate >= 2 then 
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



