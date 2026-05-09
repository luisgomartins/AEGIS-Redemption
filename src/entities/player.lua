-- src/entities/player.lua
-- Este módulo define a entidade do jogador, incluindo suas propriedades, comportamentos de movimentação e renderização. Ele é projetado para ser
-- simples e modular, permitindo fácil expansão no futuro com sprites, animações e mecânicas adicionais.
local Player = {}

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
    Player.hp = 100
    Player.energy = 0
    Player.form = "tank" -- Fase 1
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
end

function Player.draw()
    -- Renderização temporária (um retângulo) para debug visual
    -- Branco: love.graphics.setColor(1, 1, 1) é o padrão no LÖVE 11+
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
end

return Player