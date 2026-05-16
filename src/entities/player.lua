-- src/entities/player.lua
-- Este módulo define a entidade do jogador, incluindo suas propriedades, comportamentos de movimentação e renderização. Ele é projetado para ser
-- simples e modular, permitindo fácil expansão no futuro com sprites, animações e mecânicas adicionais.
local Player = {}
-- Importa a entidade de projétil para que o jogador possa atirar
local Bullet = require "src.entities.bullet"

-- Constante local para a largura da tela baseada na sua configuração
local VIRTUAL_WIDTH = 320 

function Player.load()
    -- Dimensões temporárias (Hitbox) até termos o sprite final do tanque
    Player.width = 24
    Player.height = 16
    
    -- Posicionamento inicial: Centro da tela no eixo X, base da tela no eixo Y
    -- Subtraímos a altura do jogador e uma margem de segurança (10px) do fundo
    Player.x = (VIRTUAL_WIDTH / 2) - (Player.width / 2)
    Player.y = 180 - Player.height - 10 
    
    -- Atributos baseados no GDD
    Player.speed = 120 -- Pixels por segundo
    Player.maxHp = 100 -- Valor máximo de HP para referência em cura e UI
    Player.hp = Player.maxHp -- Inicializa o HP do jogador com o valor máximo
    Player.coins = 0   -- Variável para a loja pós-chefe
    
    Player.energy = 0
    Player.form = "tank" -- Fase 1

    -- SISTEMA DE ENERGIA (GDD)
    Player.energy = 0 -- Energia inicial do jogador
    Player.maxEnergy = 100 -- Limite máximo da barra

    -- Variáveis para controle de tiro
    Player.shootTimer = 0
    Player.shootCooldown = 0.15 -- Tempo em segundos entre cada tiro (150ms)
end

function Player.update(dt)
    -- 1. Movimentação Linear (Desvio Lateral)
    -- Multiplicamos a velocidade por 'dt' (Delta Time) para garantir que a 
    -- movimentação seja independente da taxa de quadros (FPS) do computador.
    if love.keyboard.isDown("a") then
        Player.x = Player.x - Player.speed * dt
    end
    
    if love.keyboard.isDown("d") then
        Player.x = Player.x + Player.speed * dt
    end

    -- 2. Clamping (Restrição de Limites da Tela)
    -- Garante que o tanque não saia da área visível (0 a 320 pixels)
    if Player.x < 0 then
        Player.x = 0
    elseif Player.x + Player.width > VIRTUAL_WIDTH then
        Player.x = VIRTUAL_WIDTH - Player.width
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
        
        -- Reseta a energia (Esgotamento de Foco)
        Player.energy = 0
        print("PODER ESPECIAL LANÇADO!")
    end
end

function Player.draw()
    -- Renderização temporária (um retângulo) para debug visual
    -- Branco: love.graphics.setColor(1, 1, 1) é o padrão no LÖVE 11+
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
end

return Player