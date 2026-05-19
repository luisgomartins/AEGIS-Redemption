-- src/ui/hud.lua

local Hud = {} -- Módulo para a interface de usuário (HUD)

local BAR_WIDTH = 50 -- Largura total da barra de vida/energia
local BAR_HEIGHT = 5 -- Altura da barra

function Hud.draw(player, enemy) -- Recebe o jogador e o inimigo para acessar seus atributos e renderizar as barras de vida e energia, além do contador de moedas
    -- 1. Barra de Vida do Jogador (Canto inferior esquerdo)
    local playerHpRatio = math.max(0, player.hp) / player.maxHp -- Calcula a proporção de HP restante, garantindo que não seja negativa
    
    -- Fundo escuro da barra
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 5, 10, BAR_WIDTH, BAR_HEIGHT)
    
    -- Preenchimento verde (Vida)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", 5, 10, BAR_WIDTH * playerHpRatio, BAR_HEIGHT)
    

    -- 2. Barra de Energia/Foco do Jogador (Abaixo da Vida)
    local playerEnergyRatio = math.max(0, player.energy) / player.maxEnergy -- Calcula a proporção de energia restante, garantindo que não seja negativa
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 5, 15, BAR_WIDTH, BAR_HEIGHT)
    
    -- Preenchimento ciano (Energia)
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.rectangle("fill", 5, 15, BAR_WIDTH * playerEnergyRatio, BAR_HEIGHT)
    
    -- 3. Contador de Moedas (Canto inferior direito)
    love.graphics.setColor(1, 0.8, 0) -- Amarelo ouro
    love.graphics.print("Moedas: " .. player.coins, 250, 10)
    -- Kael
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Kael", 5, 10)

    -- 4. Barra de Vida do Chefe (Topo central)
    -- Só renderiza se o inimigo estiver vivo e referenciado
    if enemy and enemy.hp > 0 then
        local enemyHpRatio = math.max(0, enemy.hp) / enemy.maxHp
        local bossBarWidth = 150
        local startX = (320 / 2) - (bossBarWidth / 2) -- Centralizado na resolução virtual de 320
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", startX, 10, bossBarWidth, BAR_HEIGHT)
        
        love.graphics.setColor(0.8, 0.1, 0.1) -- Vermelho
        love.graphics.rectangle("fill", startX, 10, bossBarWidth * enemyHpRatio, BAR_HEIGHT)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ECO", 0, 0, 320, "center")
    end
    
    -- Resetar a cor para não afetar as próximas renderizações no main loop
    love.graphics.setColor(1, 1, 1)
end

return Hud