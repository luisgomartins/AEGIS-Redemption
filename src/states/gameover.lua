-- src/states/gameover.lua
local GameOver = {}
local Play = require "src.states.play"

local inputCooldown = 0

-- NOVO: Variáveis para o background do Game Over
local bgImage = nil
local bgScaleX = 1
local bgScaleY = 1

function GameOver.load()
    -- Bloqueia o input por meio segundo para evitar que pule a tela sem querer
    inputCooldown = 0.5 
    
    -- 1. Carrega o Background do Game Over e calcula a escala para 640x360
    if not bgImage then
        bgImage = love.graphics.newImage("assets/backgrounds/GameOver.png")
        bgScaleX = 640 / bgImage:getWidth()
        bgScaleY = 360 / bgImage:getHeight()
    end

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
    -- Limpa a tela com um fallback escuro (caso a imagem demore 1 frame para carregar)
    love.graphics.clear(0.15, 0.02, 0.02)

    -- 2. Desenha a Imagem de Fundo primeiro (Algoritmo do Pintor)
    if bgImage then
        -- Reseta para branco para que a imagem não seja tingida pelas cores dos textos
        love.graphics.setColor(1, 1, 1) 
        love.graphics.draw(bgImage, 0, 0, 0, bgScaleX, bgScaleY)
    end

    -- 3. Textos do Game Over desenhados por cima do fundo
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("[R] Tentar Novamente   [ENTER] Menu", 0, 140, 640, "center")
end

return GameOver