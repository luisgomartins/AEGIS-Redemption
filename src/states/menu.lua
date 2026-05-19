-- src/states/menu.lua

local Menu = {}
local Play = require "src.states.play" -- Importando o estado de jogo para permitir a transição quando o jogador pressionar Enter

function Menu.load()
    -- Preparação de assets locais do menu (fontes, logos, músicas)
end

function Menu.update(dt)
    -- Transição de estado: de Menu para Play
end

function Menu.keypressed(key)
    if key == "return" then
        MudarEstado("play")
    end
end

function Menu.draw()
    -- O 'printf' com o limite de 320px (largura virtual) cuida da centralização automática
    love.graphics.printf("AEGIS: REDEMPTION", 0, 70, 320, "center")
    love.graphics.printf("Pressione ENTER para jogar", 0, 100, 320, "center")
end

return Menu