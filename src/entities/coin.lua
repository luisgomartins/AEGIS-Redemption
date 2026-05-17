-- src/entities/coin.lua
local Coin = {}

-- Tabela privada para armazenar todos os drops ativos na tela (moedas e curas)
local activeCoins = {}

-- Referência à altura da tela para o "Garbage Collection" (limpeza)
local VIRTUAL_HEIGHT = 180

-- Modificado: Agora aceita o tipo do drop ("coin" ou "heal")
function Coin.spawn(x, y, dropType)
    local t = dropType or "coin"
    
    local newDrop = {
        x = x,
        y = y,
        width = 6,
        height = 6,
        speed = 60, -- Um pouco mais lento na fase 2 para dar tempo de desviar e coletar
        type = t,
        value = (t == "coin") and 5 or 0, -- Moeda vale 5, Cura manipula HP diretamente
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
    for _, c in ipairs(activeCoins) do
        if c.type == "coin" then
            love.graphics.setColor(1, 0.8, 0) -- Amarelo Ouro para moedas
            love.graphics.rectangle("fill", c.x, c.y, c.width, c.height)
        elseif c.type == "heal" then
            love.graphics.setColor(0.2, 1, 0.2) -- Verde brilhante para Kit de Reparo (GDD)
            love.graphics.rectangle("fill", c.x, c.y, c.width, c.height)
        end
    end
    -- Reset padrão da cor do framework
    love.graphics.setColor(1, 1, 1)
end

function Coin.getAll()
    return activeCoins
end

function Coin.clear()
    activeCoins = {}
end

return Coin