-- src/states/play.lua
local Play = {}

-- Importando a entidade do jogador
local Player = require "src.entities.player"
-- Importando a entidade de projétil para que o jogador possa atirar
local Bullet = require "src.entities.bullet"

function Play.load()
    -- Inicializa as propriedades do jogador para esta partida
    Player.load()
end

function Play.update(dt)
    -- O estado Play delega a atualização para a entidade Player
    Player.update(dt)
    -- Atualiza os projéteis ativos
    Bullet.update(dt)
    
    -- Opção de Qualidade de Vida (QoL) para testes: Voltar ao menu
    if love.keyboard.isDown("backspace") then
        MudarEstado("menu")
    end
end

function Play.draw()
    -- Fundo temporário para contrastar com as ruínas (Cor de escombros/poeira)
    love.graphics.clear(0.15, 0.15, 0.18) 

    -- IMPORTANTE: A ordem de desenho (Z-Index). 
    -- Desenhamos os tiros primeiro, e o jogador depois. 
    -- Assim, visualmente, o tiro sai "de baixo" do tanque.
    Bullet.draw()
    Player.draw()
    
    -- HUD Temporário
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Fase 1: Ruínas de Neo-Cidade", 5, 5)
end

return Play