-- src/states/gameover.lua
local GameOver = {}
local Play = require "src.states.play"

local inputCooldown = 0

function GameOver.load()
    -- Bloqueia o input por meio segundo para evitar que pule a tela sem querer
    inputCooldown = 0.5 
    
    -- Carrega e toca a música de game over (sem loop, apenas uma vez)
    if not GameOver.gameOverMusic then
        if love and love.audio then
            GameOver.gameOverMusic = love.audio.newSource("assets/music/Game Over.mp3", "stream")
            GameOver.gameOverMusic:setLooping(false)
            GameOver.gameOverMusic:setVolume(0.3)
        end
    end
    
    -- Para qualquer música que estava tocando e toca a do game over
    if GameOver.gameOverMusic then
        GameOver.gameOverMusic:stop()
        GameOver.gameOverMusic:play()
    end
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
        if GameOver.gameOverMusic then
            GameOver.gameOverMusic:stop()
        end
        MudarEstado("play") 
    elseif key == "return" or key == "backspace" then
        if GameOver.gameOverMusic then
            GameOver.gameOverMusic:stop()
        end
        Play.faseAtual = 1
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
