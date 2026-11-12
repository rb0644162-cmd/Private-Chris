-- ==========================================
-- SCRIPT PRINCIPAL / LOADER CON DISCORD
-- ==========================================

local KeyCorrecta = "chris" -- Cambia esto por tu contraseña

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("White")

-- Ventana de Key con el botón de Discord integrado
local KeyWindow = WindUI:CreateWindow({
    Title = "Private Chris",
    Icon = "lock",
    Folder = "PrivateChris_Loader",
    Size = UDim2.fromOffset(400, 300),
    Theme = "Dark",
    
    KeySystem = {
        Title = "Acceso Restringido",
        Subtitle = "Introduce tu key para continuar",
        Note = "Únete a nuestro Discord para obtener la clave.",
        Key = { KeyCorrecta },
        SaveKey = true,
        
        -- Propiedad nativa para poner el enlace del Discord / Web
        Link = "https://discord.gg/GE2pzpffky", -- (Nota: Asegúrate de usar tu enlace de Discord real)
        
        Callback = function(Key)
            print("Key validada. Cargando script principal...")
            
            -- Cargamos el contenido de tu otro repositorio
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/TU_OTRO_REPOSITORIO/refs/heads/main/main.lua"))()
            end)
            
            if not success then
                warn("Error" .. tostring(err))
            end
        end
    }
})
