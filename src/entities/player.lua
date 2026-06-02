-- src/entities/player.lua

-- Este módulo define a entidade do jogador, incluindo suas propriedades, comportamentos de movimentação e renderização. Ele é projetado para ser
-- simples e modular, permitindo fácil expansão no futuro com sprites, animações e mecânicas adicionais.
local Player = {}
-- Importa a entidade de projétil para que o jogador possa atirar
local Bullet = require "src.entities.bullet"

-- Constante local para a largura da tela baseada na sua configuração
local VIRTUAL_WIDTH = 640
local VIRTUAL_HEIGHT = 360

-- Variáveis para animação da sprite do tank
local tankSpriteSheet = nil
local tankQuads = {} -- Array com os 3 quads da spritesheet
local tankCurrentFrame = 1 -- Frame atual (1, 2, ou 3)
local tankAnimationTimer = 0
local tankAnimationSpeed = 0.1 -- Tempo entre frames (em segundos)

function Player.load()

    Player.width = 24 * 2
    Player.height = 16 * 2
    Player.x = (VIRTUAL_WIDTH / 2) - (Player.width / 2)
    Player.y = VIRTUAL_HEIGHT - Player.height - 85 
    Player.speed = 120 * 2 -- Pixels por segundo
    Player.maxHp = 10000 -- Valor máximo de HP para referência em cura e UI
    Player.hp = Player.maxHp -- Inicializa o HP do jogador com o valor máximo
    Player.coins = 0   -- Variável para a loja pós-chefe
    Player.form = "tank" -- Fase 1
    Player.energy = 0 -- Energia inicial do jogador
    Player.maxEnergy = 100 -- Limite máximo da barra
    Player.shootTimer = 0 -- Timer para controle de tiro
    Player.shootCooldown = 0.15 -- Tempo em segundos entre cada tiro (150ms)
    
    -- Carrega a spritesheet do tank
    if not tankSpriteSheet then
        tankSpriteSheet = love.graphics.newImage("assets/sprites/Tank_SpriteSheet.png")
        -- A spritesheet tem 3 frames horizontalmente (lado a lado)
        local frameWidth = tankSpriteSheet:getWidth() / 3
        local frameHeight = tankSpriteSheet:getHeight()
        
        -- Cria os 3 quads para cada frame
        tankQuads[1] = love.graphics.newQuad(0, 0, frameWidth, frameHeight, tankSpriteSheet)
        tankQuads[2] = love.graphics.newQuad(frameWidth, 0, frameWidth, frameHeight, tankSpriteSheet)
        tankQuads[3] = love.graphics.newQuad(frameWidth * 2, 0, frameWidth, frameHeight, tankSpriteSheet)
    end
    
    -- Carrega o som do laser (reproduz enquanto a tecla estiver pressionada)
    if not Player.shootSound then
        if love and love.audio then
            Player.shootSound = love.audio.newSource("assets/sfx/laserRetro_004.ogg", "static")
            Player.shootSound:setLooping(true)
            Player.shootSound:setVolume(0.04)
        end
    end
    -- Carrega o som do poder especial (executa uma vez ao ativar)
    if not Player.specialSound then
        if love and love.audio then
            Player.specialSound = love.audio.newSource("assets/sfx/laserLarge_001.ogg", "static")
            Player.specialSound:setVolume(0.4)
        end
    end
end

function Player.update(dt)
    -- 1. Movimentação Linear (Desvio Lateral)
    -- Multiplicamos a velocidade por 'dt' (Delta Time) para garantir que a 
    -- movimentação seja independente da taxa de quadros (FPS) do computador.
    if love.keyboard.isDown("a") then
        Player.x = Player.x - Player.speed * dt
        -- Animação do tank: avança o frame (1 → 2 → 3 → 1)
        if Player.form == "tank" then
            tankAnimationTimer = tankAnimationTimer + dt
            if tankAnimationTimer >= tankAnimationSpeed then
                tankCurrentFrame = tankCurrentFrame + 1
                if tankCurrentFrame > 3 then
                    tankCurrentFrame = 1
                end
                tankAnimationTimer = 0
            end
        end
    end
    if love.keyboard.isDown("d") then
        Player.x = Player.x + Player.speed * dt
        -- Animação do tank: volta o frame (3 → 2 → 1 → 3)
        if Player.form == "tank" then
            tankAnimationTimer = tankAnimationTimer + dt
            if tankAnimationTimer >= tankAnimationSpeed then
                tankCurrentFrame = tankCurrentFrame - 1
                if tankCurrentFrame < 1 then
                    tankCurrentFrame = 3
                end
                tankAnimationTimer = 0
            end
        end
    end
    
    -- Movimentação Vertical (Fase 2: Nave)
    if Player.form == "nave" then
        if love.keyboard.isDown("w") then Player.y = Player.y - Player.speed * dt end
        if love.keyboard.isDown("s") then Player.y = Player.y + Player.speed * dt end
    end
    -- 2. Clamping (Restrição de Limites da Tela)
    
    -- Garante que o tanque não saia da área visível (0 a 640 pixels)
    if Player.x < 0 then
        Player.x = 0
    elseif Player.x + Player.width > VIRTUAL_WIDTH then
        Player.x = VIRTUAL_WIDTH - Player.width
    end
    
    -- Clamping Eixo Y (Restrição de borda superior/inferior)
    if Player.form == "nave" then
        if Player.y < 0 then 
            Player.y = 0
        elseif Player.y + Player.height > VIRTUAL_HEIGHT then 
            Player.y = VIRTUAL_HEIGHT - Player.height 
        end
    end

    -- 3. Controle de Tiro (Cooldown)
    -- Reduz o timer de tiro se ele estiver ativo
    if Player.shootTimer > 0 then
        Player.shootTimer = Player.shootTimer - dt
    end

    -- Verifica se a tecla Espaço está pressionada e se o cooldown zerou
    if love.keyboard.isDown("space") and Player.shootTimer <= 0 then
        -- Calcula o centro do tanque para o tiro sair alinhado
        local bulletX = Player.x + (Player.width / 2) - 2 -- 2 é a metade da largura do tiro
        local bulletY = Player.y
        -- Instancia o tiro e reseta o cronômetro
        Bullet.spawn(bulletX, bulletY)
        Player.shootTimer = Player.shootCooldown

    end
    -- TIRO ESPECIAL (Tecla F)
    -- Condição: A tecla F deve ser pressionada E a energia tem que estar no máximo
    if love.keyboard.isDown("f") and Player.energy >= Player.maxEnergy then -- 
        local specialX = Player.x + (Player.width / 2) - 8 -- Centraliza o tiro de 16px
        
        -- Dispara o Especial
        Bullet.spawnSpecial(specialX, Player.y)
        -- Toca o som do especial
        if Player.specialSound then
            Player.specialSound:stop()
            Player.specialSound:play()
        end

        -- Reseta a energia (Esgotamento de Foco)
        Player.energy = 0
        print("PODER ESPECIAL LANÇADO!")
    end

    -- Controle do som de tiro: toca em loop enquanto a tecla Espaço estiver segurada
    if Player.shootSound then
        if love.keyboard.isDown("space") then
            if not Player.shootSound:isPlaying() then
                Player.shootSound:play()
            end
        else
            if Player.shootSound:isPlaying() then
                Player.shootSound:stop()
            end
        end
    end
end

function Player.draw()
    love.graphics.setColor(1, 1, 1)
    
    -- Se a forma for tank, desenha a sprite animada
    if Player.form == "tank" and tankSpriteSheet then
        love.graphics.draw(
            tankSpriteSheet,
            tankQuads[tankCurrentFrame],
            Player.x,
            Player.y,
            0, -- rotação
            1.1, 1.1
        )
    else
        -- Renderização temporária (um retângulo) para debug visual
        -- Branco: love.graphics.setColor(1, 1, 1) é o padrão no LÖVE 11+
        love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
    end
end

return Player