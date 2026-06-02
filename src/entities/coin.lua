-- src/entities/coin.lua
local Coin = {}

-- Tabela privada para armazenar todos os drops ativos na tela (moedas e curas)
local activeCoins = {}

-- Referência à altura da tela para o "Garbage Collection" (limpeza)
local VIRTUAL_HEIGHT = 360

-- NOVO: Variáveis para armazenar as sprites na memória cache
local spriteCoin = nil
local spriteHeal = nil

-- Modificado: Agora aceita o tipo do drop ("coin" ou "heal")
function Coin.spawn(x, y, dropType)
    local t = dropType or "coin"
    
    local newDrop = {
        x = x,
        y = y,
        width = 6 * 2,  -- Hitbox de 12px
        height = 6 * 2, -- Hitbox de 12px
        speed = 60, -- Um pouco mais lento na fase 2 para dar tempo de desviar e coletar
        type = t,
        value = (t == "coin") and 10 or 0, -- Moeda vale 10, Cura manipula HP diretamente
        healAmount = (t == "heal") and 15 or 0 -- Cura recupera 15 de HP
    }
    table.insert(activeCoins, newDrop)
end

function Coin.update(dt)
    -- Iteração de trás para frente para remoção segura
    for i = #activeCoins, 1, -1 do
        local c = activeCoins[i]
        
        -- Aplica o movimento vertical para baixo
        c.y = c.y + c.speed * dt
        
        -- Limpeza automática ao sair da tela
        if c.y > VIRTUAL_HEIGHT then
            table.remove(activeCoins, i)
        end
    end
end

function Coin.draw()
    -- 1. Lazy Loading das Sprites
    -- Lembre-se: sempre utilizamos barras normais "/" para caminhos de arquivo!
    if not spriteCoin then
        spriteCoin = love.graphics.newImage("assets/sprites/Coin.png")
    end
    if not spriteHeal then
        spriteHeal = love.graphics.newImage("assets/sprites/Heal.png")
    end

    -- 2. Reseta a cor para branco puro (1, 1, 1) ANTES de desenhar as imagens.
    -- Se não fizermos isso, o LÖVE pode "tingir" a sprite com a cor do último desenho feito na tela.
    love.graphics.setColor(1, 1, 1)

    for _, c in ipairs(activeCoins) do
        -- 3. Define qual imagem usar baseada no tipo do drop
        local img = (c.type == "coin") and spriteCoin or spriteHeal
        
        -- 4. Coleta as dimensões originais da imagem escolhida
        local imgW = img:getWidth()
        local imgH = img:getHeight()
        
        -- 5. Escalonamento Dinâmico (Matemática: Tamanho Desejado / Tamanho Original)
        local scaleX = c.width / imgW
        local scaleY = c.height / imgH

        -- 6. Desenha a sprite na tela com a escala correta
        love.graphics.draw(img, c.x, c.y, 0, scaleX, scaleY)
    end
end

function Coin.getAll()
    return activeCoins
end

function Coin.clear()
    activeCoins = {}
end

return Coin