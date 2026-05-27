-- src/states/gameover.lua
local GameOver = {}
local Play = require "src.states.play"
local EnemyBullet = require "src.entities.enemy_bullet"
local PlayerLoad = require "src.entities.player"

local inputCooldown = 0

function GameOver.load()
    -- Bloqueia o input por meio segundo para evitar que pule a tela sem querer
    inputCooldown = 0.5 
end

function GameOver.update(dt)
    -- O update continua sendo responsável por reduzir o timer a cada frame
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
    end
end

function GameOver.keypressed(key)
    -- Se o timer ainda não zerou, ignoramos o clique e saímos da função!
    if inputCooldown > 0 then 
        return 
    end

    -- Se o timer zerou, aceitamos o input normalmente:
    if key == "r" then
        EnemyBullet.clear() 
        PlayerLoad.hp = PlayerLoad.maxHp
        MudarEstado("play")
    elseif key == "return" or key == "backspace" then
        Play.faseAtual = 1
        EnemyBullet.clear() 
        MudarEstado("menu")
    end
end

function GameOver.draw()
    love.graphics.clear(0.15, 0.02, 0.02)

    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("SISTEMAS CRITICOS FALHARAM", 0, 60, 640, "center")

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("A Maquina foi destruida.", 0, 90, 640, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("[R] Tentar Novamente   [ENTER] Menu", 0, 140, 640, "center")
end

return GameOver
