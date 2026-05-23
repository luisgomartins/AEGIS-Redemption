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
        speed = 60,
        type = t,
        value = (t == "coin") and 10 or 0,
        healAmount = (t == "heal") and 15 or 0
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
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.rectangle("fill", c.x, c.y, c.width, c.height)
        elseif c.type == "heal" then
            love.graphics.setColor(0.2, 1, 0.2)
            love.graphics.rectangle("fill", c.x, c.y, c.width, c.height)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function Coin.getAll()
    return activeCoins
end

function Coin.clear()
    activeCoins = {}
end

return Coin