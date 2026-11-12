-- ==========================================
-- SCRIPT PRINCIPAL DE CONTENIDO (main.lua)
-- Subir a tu otro repositorio en GitHub
-- ==========================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("White")

-- Ventana Principal del Menú optimizada para móviles
local Window = WindUI:CreateWindow({
    Title = "Private Chris - Menú Principal",
    Icon = "smartphone",
    Author = "Versión 1.0",
    Folder = "PrivateChris_Mobile",
    Size = UDim2.fromOffset(480, 360), -- Tamaño responsivo para pantallas táctiles
    Theme = "Dark",
    HidePanelBackground = false,
    NewElements = false,
})

-- Botón flotante adaptado para móviles (sin icono, texto limpio y 100% arrastrable)
Window:EditOpenButton({
    Title = "CHRIS PAPASITO",
    Icon = nil, -- Sin icono como pediste
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("6A11CB"), 
        Color3.fromHex("2575FC")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true, -- ¡Permite moverlo con el dedo en celular para que no estorbe!
})

-- ==========================================
-- PESTAÑAS Y CONTENIDO DE TU SCRIPT
-- ==========================================

local MainTab = Window:Tab({
    Title = "Principal",
    Icon = "home",
})

local MainSection = MainTab:Section({
    Title = "Herramientas",
    Content = "Funciones principales"
})

MainSection:Button({
    Title = "Ejecutar Acción",
    Desc = "Prueba de funcionamiento del script",
    Callback = function()
        WindUI:Notify({
            Title = "¡Éxito!",
            Content = "El menú se cargó correctamente tras validar la key.",
            Duration = 3
        })
    end
})

MainSection:Toggle({
    Title = "Función Activa",
    Desc = "Interruptor de prueba",
    Default = false,
    Callback = function(State)
        if State then
            print("Activado")
        else
            print("Desactivado")
        end
    end
})
