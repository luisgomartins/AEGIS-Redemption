-- conf.lua
function love.conf(t)
    t.identity = "aegis_redemption"
    t.window.title = "AEGIS: Redemption"
    
    t.window.width = 1280
    t.window.height = 720
    t.window.vsync = 1
    t.window.resizable = false
    
    -- Desativa antialiasing para manter os pixels nítidos
    t.window.msaa = 0
    
    -- Otimização: desativação de módulos não utilizados
    t.modules.joystick = false
    t.modules.physics = false 
end