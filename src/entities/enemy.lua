-- src/entities/enemy.lua

local Enemy = {}
local EnemyBullet = require "src.entities.enemy_bullet" 
local Player = require "src.entities.player"

local VIRTUAL_WIDTH = 320 
local VIRTUAL_HEIGHT = 180 

function Enemy.load(fase)
    Enemy.faseAtual = fase 
    
    if fase == 1 then
        Enemy.width = 64 
        Enemy.height = 32
        Enemy.x = (VIRTUAL_WIDTH / 2) - (Enemy.width / 2)
        Enemy.y = 10 
        Enemy.speed = 50 
        Enemy.maxHp = 1000 
        Enemy.hp = Enemy.maxHp 
        Enemy.direction = 1 
        Enemy.isEnraged = false
        
        Enemy.shootTimer = 0
        Enemy.shootCooldown = 0.5 
        Enemy.shotCount = 0 
    
    elseif fase == 2 then
        -- Configurações do Eco 2: Nave Mãe / Bullet Hell
        Enemy.width = 48 
        Enemy.height = 48
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
                EnemyBullet.spawn(spawnX, spawnY, 0, 1.2) 
            else
                EnemyBullet.spawn(spawnX, spawnY, -0.4, 0.8) 
                EnemyBullet.spawn(spawnX, spawnY, 0.4, 0.8)  
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
                        EnemyBullet.spawn(centroX, centroY, math.cos(Enemy.spiralAngle + (i * math.pi)) * 0.6, math.sin(Enemy.spiralAngle + (i * math.pi)) * 0.6)
                    end
                elseif Enemy.currentPattern == 2 then
                    Enemy.shootCooldown = 1.2 
                    for i = 1, 14 do
                        local angulo = (i / 14) * (math.pi * 2)
                        EnemyBullet.spawn(centroX, centroY, math.cos(angulo) * 0.5, math.sin(angulo) * 0.5)
                    end
                end
                Enemy.shootTimer = Enemy.shootCooldown 
            end

        -- ==========================================
        -- ESTADO: Mergulhando para o canto
        -- ==========================================
        elseif Enemy.phase2State == "diving" then
            local diveSpeed = 150 -- Boss desce muito rápido
            
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
                    EnemyBullet.spawn(spawnX, py, Enemy.laserDirection * 3.0, 0)
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
    end
end

function Enemy.draw()
    if Enemy.faseAtual == 1 then
        if Enemy.isEnraged then
            love.graphics.setColor(1, 0.4, 0) 
        else
            love.graphics.setColor(1, 0.2, 0.2) 
        end
        love.graphics.rectangle("fill", Enemy.x, Enemy.y, Enemy.width, Enemy.height)
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
    end
end

return Enemy
