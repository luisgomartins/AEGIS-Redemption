-- src/states/menu.lua

local Menu = {}
local Play = require "src.states.play"

-- Configurações de Resolução Virtual
local VIRTUAL_WIDTH = 640
local VIRTUAL_HEIGHT = 360

-- Variáveis para armazenar o Fundo
local bgImage = nil
local bgScaleX = 1
local bgScaleY = 1

-- Variáveis para a Logo Animada
local logoSheet = nil
local logoQuads = {}
local logoCurrentFrame = 1
local logoTimer = 0
local logoAnimSpeed = 0.5 -- Tempo em segundos para a logo "piscar" (altere a gosto)

function Menu.load()
    -- 1. Carrega o Background e calcula a escala para preencher a tela 640x360
    bgImage = love.graphics.newImage("assets/backgrounds/Menu.png")
    bgScaleX = VIRTUAL_WIDTH / bgImage:getWidth()
    bgScaleY = VIRTUAL_HEIGHT / bgImage:getHeight()

    -- 2. Carrega a Spritesheet da Logo
    logoSheet = love.graphics.newImage("assets/sprites/Logo.png")
    
    -- A logo tem 2 frames lado a lado, então dividimos a largura total por 2
    local frameWidth = logoSheet:getWidth() / 2
    local frameHeight = logoSheet:getHeight()

    -- Cria os dois recortes (Quads)
    logoQuads[1] = love.graphics.newQuad(0, 0, frameWidth, frameHeight, logoSheet)
    logoQuads[2] = love.graphics.newQuad(frameWidth, 0, frameWidth, frameHeight, logoSheet)
end

function Menu.update(dt)
    -- Animação da Logo usando o operador Módulo (%)
    logoTimer = logoTimer + dt
    if logoTimer >= logoAnimSpeed then
        -- O módulo (%) retorna o resto da divisão. 
        -- Isso faz o frame alternar perfeitamente entre 1 e 2 num loop contínuo.
        logoCurrentFrame = (logoCurrentFrame % 2) + 1 
        logoTimer = 0
    end
end

function Menu.keypressed(key)
    if key == "return" then
        MudarEstado("play")
    end
end

function Menu.draw()
    -- Garante que a cor base é branca para não alterar a cor original das imagens
    love.graphics.setColor(1, 1, 1)

    -- 1. Desenha o Fundo primeiro (Algoritmo do Pintor)
    if bgImage then
        love.graphics.draw(bgImage, 0, 0, 0, bgScaleX, bgScaleY)
    end

    -- 2. Desenha a Logo Centralizada
    if logoSheet then
        local frameWidth = logoSheet:getWidth() / 2
        
        -- Matemática de Centralização: (Metade da Tela) - (Metade da Imagem)
        local logoX = (VIRTUAL_WIDTH / 2) - (frameWidth / 2)
        local logoY = 40 -- Distância do topo da tela
        
        love.graphics.draw(logoSheet, logoQuads[logoCurrentFrame], logoX, logoY)
    end

    -- 3. Texto interativo
    -- Movido para o Y = 280 (mais para baixo) para não cobrir o tanque do background
    love.graphics.printf("Pressione ENTER para jogar", 0, 260, VIRTUAL_WIDTH, "center")
end

return Menu