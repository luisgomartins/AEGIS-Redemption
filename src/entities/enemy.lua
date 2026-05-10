-- src/entities/enemy.lua
local Enemy = {}

local EnemyBullet = require "src.entities.enemy_bullet" -- Importando o módulo de tiros inimigos para que o Boss possa atirar

local VIRTUAL_WIDTH = 320 

function Enemy.load()
    -- Proporções colossais em relação ao jogador (24x16)
    Enemy.width = 64 
    Enemy.height = 32
    
    -- Centralizado no eixo X, posicionado no topo da tela (margem de 10px)
    Enemy.x = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2)
    Enemy.y = 10 
    
    Enemy.speed = 50 -- Movimentação mais pesada/lenta que a do Kael
    Enemy.hp = 1000  -- Boss precisa de uma barra de vida robusta
    
    -- Vetor de direção: 1 para Direita, -1 para Esquerda
    Enemy.direction = 1 
    
    Enemy.shootTimer = 0
    Enemy.shootCooldown = 0.8 -- O Boss atira a cada 0.8 segundos, um pouco mais lento que o jogador para dar tempo de reação
end

function Enemy.update(dt)
    -- 1. Movimentação Cíclica (Ping-Pong)
    -- Multiplicar pela direção (1 ou -1) inverte a soma matematicamente
    -- Assim, o inimigo se move para a direita enquanto direction for 1, e para a esquerda quando for -1.
    Enemy.x = Enemy.x + (Enemy.speed * Enemy.direction) * dt
    
    -- 2. Detecção de Colisão com as Bordas (Clamping e Inversão)
    if Enemy.x <= 0 then
        Enemy.x = 0
        Enemy.direction = 1 -- Bateu na esquerda, vai para a direita
    elseif Enemy.x + Enemy.width >= VIRTUAL_WIDTH then
        Enemy.x = VIRTUAL_WIDTH - Enemy.width
        Enemy.direction = -1 -- Bateu na direita, vai para a esquerda
    end

    -- Lógica de Disparo do Boss
    Enemy.shootTimer = Enemy.shootTimer - dt -- Decrementa o timer a cada frame
    if Enemy.shootTimer <= 0 then -- Se o timer zerar ou for negativo, é hora de atirar
        -- Calcula o centro inferior do Boss para instanciar o tiro
        local spawnX = Enemy.x + (Enemy.width / 2) - 3 -- 3 é metade da largura do tiro inimigo
        local spawnY = Enemy.y + Enemy.height -- O tiro começa na base do Boss
        
        EnemyBullet.spawn(spawnX, spawnY) -- Chama a função de spawn do tiro inimigo, passando as coordenadas calculadas
        Enemy.shootTimer = Enemy.shootCooldown -- Reseta o timer
    end

end

function Enemy.draw()
    -- Vermelho ameaçador para representar o Eco 1 (temporário)
    love.graphics.setColor(1, 0.2, 0.2) 
    love.graphics.rectangle("fill", Enemy.x, Enemy.y, Enemy.width, Enemy.height)
end

return Enemy