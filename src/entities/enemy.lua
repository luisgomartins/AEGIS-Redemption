-- src/entities/enemy.lua

local Enemy = {}
local EnemyBullet = require "src.entities.enemy_bullet" 
local Player = require "src.entities.player"

local VIRTUAL_WIDTH = 640 
local VIRTUAL_HEIGHT = 360 

function Enemy.load(fase)
    Enemy.faseAtual = fase 
    
    if fase == 1 then
        Enemy.width = 64 * 2 
        Enemy.height = 32 * 2
        Enemy.x = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2)
        Enemy.y = 10 
        Enemy.speed = 100 
        Enemy.maxHp = 1000 
        Enemy.hp = Enemy.maxHp 
        Enemy.direction = 1 
        Enemy.isEnraged = false
        
        Enemy.shootTimer = 0
        Enemy.shootCooldown = 0.5 
        Enemy.shotCount = 0 
        -- Carrega a sprite do boss (Eco) para a fase 1, independente do estado enraged
        if not Enemy.sprite then
            if love and love.graphics then
                Enemy.sprite = love.graphics.newImage("assets/sprites/Eco1.png")
                -- calcula escala para encaixar na hitbox do boss
                local sw = Enemy.sprite:getWidth()
                local sh = Enemy.sprite:getHeight()
                Enemy.spriteScaleX = Enemy.width / sw
                Enemy.spriteScaleY = Enemy.height / sh
            end
        end
    
    elseif fase == 2 then
        -- Configurações do Eco 2: Nave Mãe / Bullet Hell
        Enemy.width = 48 * 2 
        Enemy.height = 48 * 2
        Enemy.x = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2)
        Enemy.y = 20 
        Enemy.speed = 60 
        Enemy.maxHp = 2000 
        Enemy.hp = Enemy.maxHp 
        
        -- Máquina de Estados da Fase 2
        Enemy.phase2State = "normal" -- "normal", "diving", "horizontal_laser", "ascending"
        
        -- Movimento Normal
        Enemy.vx = 0 
        Enemy.vy = 0 
        Enemy.moveTimer = 0 
        
        -- Tiros Normais (Espiral e Radial)
        Enemy.shootTimer = 0
        Enemy.shootCooldown = 0.1 
        Enemy.patternTimer = 0    
        Enemy.currentPattern = 1  
        Enemy.spiralAngle = 0     

        -- Varredura Horizontal (O rasante no limite inferior)
        Enemy.horizontalCooldown = 14 -- A cada 14 segundos ele faz essa mecânica
        Enemy.targetX = 0
        Enemy.targetY = 0
        Enemy.laserDirection = 1 -- 1 atira pra direita, -1 atira pra esquerda
        Enemy.laserActiveTimer = 0   
        Enemy.laserSpawnTick = 0
        
    elseif fase == 3 then
        -- Configurações do Eco 3: O Núcleo de Comando
        Enemy.width = 64 * 2
        Enemy.height = 64 * 2
        Enemy.x = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2)
        Enemy.y = 15 
        Enemy.maxHp = 4500 -- Máximo de resistência (GDD)
        Enemy.hp = Enemy.maxHp 
        
        -- Variáveis da Curva de Lissajous (Movimentação)
        Enemy.moveTime = 0
        
        -- Controle de Padrões de Tiro
        Enemy.attackTimer = 0
        Enemy.patternIndex = 1
        Enemy.spiralAngle = 0
        Enemy.shootTimer = 0
        
        Enemy.enraged = false
    end   
end

function Enemy.update(dt)
    if Enemy.faseAtual == 1 then
    
        -- ==========================================
        -- IA FASE 1: Ping-Pong Linear e Enrage
        -- ==========================================
        if Enemy.hp <= (Enemy.maxHp / 2) and not Enemy.isEnraged then
            Enemy.isEnraged = true
            Enemy.shootCooldown = 0.35
            print("ECO 1 ENFURECIDO!")
        end

        Enemy.x = Enemy.x + (Enemy.speed * Enemy.direction) * dt
        
        if Enemy.x <= 0 then
            Enemy.x = 0; Enemy.direction = 1 
        elseif Enemy.x + Enemy.width >= VIRTUAL_WIDTH then
            Enemy.x = VIRTUAL_WIDTH - Enemy.width; Enemy.direction = -1 
        end

        Enemy.shootTimer = Enemy.shootTimer - dt 
        if Enemy.shootTimer <= 0 then 
            local spawnX = Enemy.x + (Enemy.width / 2) - 3 
            local spawnY = Enemy.y + Enemy.height 
            
            Enemy.shotCount = Enemy.shotCount + 1
            
            if Enemy.shotCount % 2 ~= 0 then
                EnemyBullet.spawn(spawnX, spawnY, 0, 1.2, 18)
            else
                EnemyBullet.spawn(spawnX, spawnY, -0.4, 0.8, 12)
                EnemyBullet.spawn(spawnX, spawnY, 0.4, 0.8, 12)
            end
            Enemy.shootTimer = Enemy.shootCooldown 
        end

    elseif Enemy.faseAtual == 2 then
        -- ==========================================
        -- IA FASE 2: Máquina de Estados
        -- ==========================================
        
        if Enemy.phase2State == "normal" then
            -- 1. Controle de Movimento Errático
            Enemy.moveTimer = Enemy.moveTimer - dt
            if Enemy.moveTimer <= 0 then
                local randomAngle = love.math.random() * (math.pi * 2)
                Enemy.vx = math.cos(randomAngle) * Enemy.speed
                Enemy.vy = math.sin(randomAngle) * Enemy.speed
                Enemy.moveTimer = love.math.random() * 1.5 + 0.5
            end

            Enemy.x = Enemy.x + Enemy.vx * dt
            Enemy.y = Enemy.y + Enemy.vy * dt

            -- 2. Limites de Tela
            if Enemy.x <= 0 then Enemy.x = 0; Enemy.vx = -Enemy.vx 
            elseif Enemy.x + Enemy.width >= VIRTUAL_WIDTH then Enemy.x = VIRTUAL_WIDTH - Enemy.width; Enemy.vx = -Enemy.vx end
            if Enemy.y <= 0 then Enemy.y = 0; Enemy.vy = -Enemy.vy 
            elseif Enemy.y + Enemy.height >= VIRTUAL_HEIGHT / 2 then Enemy.y = (VIRTUAL_HEIGHT / 2) - Enemy.height; Enemy.vy = -Enemy.vy end

            -- Gatilho para o Rasante Horizontal
            Enemy.horizontalCooldown = Enemy.horizontalCooldown - dt
            if Enemy.horizontalCooldown <= 0 then
                Enemy.phase2State = "diving"
                
                -- Decide pra qual canto ir com base na posição atual dele
                if Enemy.x < VIRTUAL_WIDTH / 2 then
                    Enemy.targetX = 5 -- Canto esquerdo
                    Enemy.laserDirection = 1 -- Atira pra direita
                else
                    Enemy.targetX = VIRTUAL_WIDTH - Enemy.width - 5 -- Canto direito
                    Enemy.laserDirection = -1 -- Atira pra esquerda
                end
                
                -- Alvo Y: Desce até a parte inferior, quase encostando no fundo
                Enemy.targetY = VIRTUAL_HEIGHT - Enemy.height - 10 
            end

            -- ==========================================
            -- Padrões 1 e 2 (Espiral e Radial) - Mais lentos
            -- ==========================================
            local centroX = Enemy.x + (Enemy.width / 2)
            local centroY = Enemy.y + (Enemy.height / 2)
            
            Enemy.patternTimer = Enemy.patternTimer + dt
            if Enemy.patternTimer >= 4 then
                Enemy.currentPattern = Enemy.currentPattern == 1 and 2 or 1
                Enemy.patternTimer = 0
            end

            Enemy.shootTimer = Enemy.shootTimer - dt 
            if Enemy.shootTimer <= 0 then 
                if Enemy.currentPattern == 1 then
                    Enemy.shootCooldown = 0.08 
                    Enemy.spiralAngle = Enemy.spiralAngle + 0.35 
                    for i = 0, 1 do 
                        EnemyBullet.spawn(centroX, centroY, math.cos(Enemy.spiralAngle + (i * math.pi)) * 0.6, math.sin(Enemy.spiralAngle + (i * math.pi)) * 0.6, 16)
                    end
                elseif Enemy.currentPattern == 2 then
                    Enemy.shootCooldown = 1.2 
                    for i = 1, 14 do
                        local angulo = (i / 14) * (math.pi * 2)
                        EnemyBullet.spawn(centroX, centroY, math.cos(angulo) * 0.5, math.sin(angulo) * 0.5, 12)
                    end
                end
                Enemy.shootTimer = Enemy.shootCooldown 
            end

        -- ==========================================
        -- ESTADO: Mergulhando para o canto
        -- ==========================================
        elseif Enemy.phase2State == "diving" then
            local diveSpeed = 180 -- Boss desce muito rápido
            
            -- Move gradativamente em direção ao alvo
            if Enemy.x < Enemy.targetX then Enemy.x = math.min(Enemy.x + diveSpeed * dt, Enemy.targetX) end
            if Enemy.x > Enemy.targetX then Enemy.x = math.max(Enemy.x - diveSpeed * dt, Enemy.targetX) end
            if Enemy.y < Enemy.targetY then Enemy.y = math.min(Enemy.y + diveSpeed * dt, Enemy.targetY) end
            
            -- Se chegou no ponto (margem de 2 pixels), ativa o laser horizontal
            if math.abs(Enemy.x - Enemy.targetX) < 2 and math.abs(Enemy.y - Enemy.targetY) < 2 then
                Enemy.phase2State = "horizontal_laser"
                Enemy.laserActiveTimer = 3 -- O laser horizontal dura 3 segundos
                Enemy.laserSpawnTick = 0
                print("PERIGO: VARREDURA INFERIOR!")
            end

        -- ==========================================
        -- ESTADO: Atirando Laser Horizontal
        -- ==========================================
        elseif Enemy.phase2State == "horizontal_laser" then
            Enemy.laserActiveTimer = Enemy.laserActiveTimer - dt
            Enemy.laserSpawnTick = Enemy.laserSpawnTick - dt
            
            if Enemy.laserSpawnTick <= 0 then
                -- Decide de qual lado do boss o laser vai sair
                local spawnX = Enemy.laserDirection == 1 and (Enemy.x + Enemy.width) or Enemy.x
                
                -- Cria a parede sólida através de toda a ALTURA do boss, indo de lado
                for py = Enemy.y, Enemy.y + Enemy.height - 6, 6 do
                    -- dx ganha a direção e velocidade 3 (extremamente rápido), dy é 0
                    EnemyBullet.spawn(spawnX, py, Enemy.laserDirection * 3.0, 0, 24, 120)
                end
                Enemy.laserSpawnTick = 0.03
            end
            
            if Enemy.laserActiveTimer <= 0 then
                Enemy.phase2State = "ascending"
                -- Define o alvo de retorno para o meio do teto
                Enemy.targetX = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2)
                Enemy.targetY = 20
            end

        -- ==========================================
        -- ESTADO: Voltando para o topo
        -- ==========================================
        elseif Enemy.phase2State == "ascending" then
            local ascendSpeed = 100 
            
            if Enemy.x < Enemy.targetX then Enemy.x = math.min(Enemy.x + ascendSpeed * dt, Enemy.targetX) end
            if Enemy.x > Enemy.targetX then Enemy.x = math.max(Enemy.x - ascendSpeed * dt, Enemy.targetX) end
            if Enemy.y > Enemy.targetY then Enemy.y = math.max(Enemy.y - ascendSpeed * dt, Enemy.targetY) end
            
            -- Voltou pro topo? Retoma o padrão normal
            if math.abs(Enemy.x - Enemy.targetX) < 2 and math.abs(Enemy.y - Enemy.targetY) < 2 then
                Enemy.phase2State = "normal"
                Enemy.horizontalCooldown = 14 -- Reseta o timer pro próximo rasante
            end
        end

    elseif Enemy.faseAtual == 3 then
        -- ==========================================
        -- IA FASE 3: Curva de Lissajous e Bullet Hell Extremo
        -- ==========================================
        
        -- Verificação de Enrage (50% de HP)
        if Enemy.hp <= (Enemy.maxHp / 2) and not Enemy.enraged then
            Enemy.enraged = true
            Enemy.patternIndex = 3
            Enemy.attackTimer = 0
            print("ECO 3 ENFURECIDO! NOVO PADRÃO ATIVADO!")
        end
        
        -- 1. Movimentação (Curva do Infinito)
        Enemy.moveTime = Enemy.moveTime + dt
        Enemy.x = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2) + math.sin(Enemy.moveTime) * 110
        Enemy.y = 15 + math.sin(Enemy.moveTime * 2) * 10
        
        -- 2. Transição de Padrões (Muda a cada 5 segundos)
        Enemy.attackTimer = Enemy.attackTimer + dt
        if Enemy.attackTimer >= 5 then
            Enemy.attackTimer = 0
            if Enemy.enraged then
                -- Em enraged, alterna entre padrões 1, 2 e 3
                if Enemy.patternIndex == 1 then
                    Enemy.patternIndex = 2
                elseif Enemy.patternIndex == 2 then
                    Enemy.patternIndex = 3
                else
                    Enemy.patternIndex = 1
                end
            else
                -- Em normal, alterna entre padrões 1 e 2
                Enemy.patternIndex = Enemy.patternIndex == 1 and 2 or 1
            end
            -- Limpa os tiros toda vez que muda o padrão para dar um respiro pro jogador
            EnemyBullet.clear()
        end
        
        local cx = Enemy.x + (Enemy.width / 2)
        local cy = Enemy.y + (Enemy.height / 2)
        
        -- 4. Disparo de Padrões
        Enemy.shootTimer = Enemy.shootTimer - dt
        if Enemy.shootTimer <= 0 then
            
            if Enemy.patternIndex == 1 then
                -- PADRÃO 1: Vórtice de Vácuo (Espiral Dupla de alto dano)
                Enemy.shootCooldown = 0.04 -- Muito rápido
                Enemy.spiralAngle = Enemy.spiralAngle + 0.3
                
                -- Espiral Horária
                EnemyBullet.spawn(cx, cy, math.cos(Enemy.spiralAngle) * 1.5, math.sin(Enemy.spiralAngle) * 1.5, 40, 100)
                -- Espiral Anti-horária
                EnemyBullet.spawn(cx, cy, math.cos(-Enemy.spiralAngle) * 1.5, math.sin(-Enemy.spiralAngle) * 1.5, 40, 100)
            elseif Enemy.patternIndex == 2 then
                
                -- PADRÃO 2: Matriz de Aniquilação (Explosão Radial Densa)
                Enemy.shootCooldown = 1
                for i = 1, 24 do -- 24 tiros simultâneos criando um anel
                    local angulo = (i / 24) * (math.pi * 2)
                    EnemyBullet.spawn(cx, cy, math.cos(angulo) * 1.8, math.sin(angulo) * 1.8, 30, 175)
                end
            elseif Enemy.patternIndex == 3 then
                -- PADRÃO 3: Fragmentação (3 tiros para baixo que se dividem enquanto viajam)
                Enemy.shootCooldown = 0.8
                
                -- 3 tiros principais apontando para baixo (60°, 90°, 120°)
                local angles = {math.pi / 2 - math.pi / 6, math.pi / 2, math.pi / 2 + math.pi / 6}
                for _, angle in ipairs(angles) do
                    local dx = math.cos(angle)
                    local dy = math.sin(angle)
                    EnemyBullet.spawn(cx, cy, dx, dy, 35, 130, 0.8, 0)
                end
            end
            
            Enemy.shootTimer = Enemy.shootCooldown
        end
    end
end

function Enemy.draw()
    if Enemy.faseAtual == 1 then
        -- Desenha a sprite definida para o boss na fase 1, independente de enraged
        if Enemy.sprite then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(Enemy.sprite, Enemy.x, Enemy.y, 0, Enemy.spriteScaleX or 1, Enemy.spriteScaleY or 1)
        else
            -- Fallback: retângulo colorido caso a sprite não esteja disponível
            if Enemy.isEnraged then
                love.graphics.setColor(1, 0.4, 0)
            else
                love.graphics.setColor(1, 0.2, 0.2)
            end
            love.graphics.rectangle("fill", Enemy.x, Enemy.y, Enemy.width, Enemy.height)
        end
    elseif Enemy.faseAtual == 2 then
        -- Dicas Visuais (Telegrafar os ataques)
        if Enemy.phase2State == "diving" then
            -- Piscando amarelo para avisar que ele tá descendo com tudo!
            if math.floor(love.timer.getTime() * 10) % 2 == 0 then
                love.graphics.setColor(1, 1, 0) 
            else
                love.graphics.setColor(0.8, 0.1, 0.8)
            end
        elseif Enemy.phase2State == "horizontal_laser" then
            love.graphics.setColor(0, 1, 1) -- Fica Ciano brilhante enquanto joga o raio de lado
        else
            love.graphics.setColor(0.8, 0.1, 0.8) -- Roxo normal
        end
        love.graphics.rectangle("fill", Enemy.x, Enemy.y, Enemy.width, Enemy.height)
    elseif Enemy.faseAtual == 3 then
        -- O Núcleo pulsa mudando de cor dependendo do padrão de tiro
        if Enemy.patternIndex == 1 then
            love.graphics.setColor(1, 0, 0.2) -- Carmesim/Rosa Escuro (Vórtice)
        else
            love.graphics.setColor(1, 0.5, 0) -- Laranja Intenso (Matriz)
        end
        love.graphics.rectangle("fill", Enemy.x, Enemy.y, Enemy.width, Enemy.height)
    end
end

return Enemy
