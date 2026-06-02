-- src/states/victory.lua
local Victory = {}
local Play = require "src.states.play"

local inputCooldown = 0

function Victory.load()
    -- Dá 1 segundo de tempo para o jogador absorver a vitória e largar os botões
    inputCooldown = 1.0 

    -- Carrega e toca a música de vitória em loop
    if not Victory.victoryMusic then
        if love and love.audio then
            Victory.victoryMusic = love.audio.newSource("assets/music/Planetoids.mp3", "stream")
            Victory.victoryMusic:setLooping(true)
            Victory.victoryMusic:setVolume(0.2)
        end
    end

    if Victory.victoryMusic then
        Victory.victoryMusic:stop()
        Victory.victoryMusic:play()
    end
end

function Victory.update(dt)
    -- Apenas reduzimos o temporizador de forma contínua a cada frame
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
    end
end

function Victory.keypressed(key)
    -- Se o temporizador ainda não chegou a zero, ignoramos qualquer botão
    if inputCooldown > 0 then 
        return 
    end
    -- Se o tempo já passou, o input é processado de forma segura
    if key == "return" then
        if Victory.victoryMusic then
            Victory.victoryMusic:stop()
        end
        Play.faseAtual = 1 -- Reiniciamos o progresso para uma futura jogada
        MudarEstado("menu")
    end
end

function Victory.draw()
    love.graphics.clear(0.05, 0.08, 0.15) -- Fundo espacial profundo
    love.graphics.setColor(0.2, 0.8, 1) -- Ciano brilhante (Cor da Aegis)
    love.graphics.printf("PROTOCOLO AEGIS CONCLUIDO", 0, 30, 640, "center")

    love.graphics.setColor(1, 1, 1)
    -- Quebras de linha (\n) para manter o texto legível
    local textoFinal = "O Silencio foi quebrado.\nO nucleo dos Ecos entrou em colapso.\n\nKael Nova sobrevive.\nA Unidade Aegis encontrou a sua redencao."
    love.graphics.printf(textoFinal, 10, 70, 300, "center")
    -- Texto intermitente (piscar) para dar um toque Arcade
    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("[ENTER] Retornar a Base", 0, 150, 640, "center")
    end
end

return Victory