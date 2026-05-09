-- src/entities/bullet.lua
local Bullet = {}

-- Esta tabela privada guardará todos os projéteis ativos no momento
local activeBullets = {}

-- Função de "Fábrica" (Factory): cria um novo tiro na posição informada
function Bullet.spawn(x, y)
    local newBullet = {
        x = x,
        y = y,
        width = 4,
        height = 10,
        speed = 400, -- Mais rápido que o jogador, pois é um projétil
        damage = 10  -- Dano base definido no GDD
    }
    table.insert(activeBullets, newBullet)
end

function Bullet.update(dt)
    -- ATENÇÃO AQUI: Quando removemos itens de uma tabela no Lua, 
    -- devemos iterar de trás para frente. Se iterarmos do início ao fim (1 ao #)
    -- e removermos o índice 2, o índice 3 vira 2, e o loop pula uma verificação.
    for i = #activeBullets, 1, -1 do
        local b = activeBullets[i]
        
        -- Movimenta o tiro para cima (eixo Y negativo)
        b.y = b.y - b.speed * dt
        
        -- Otimização: Se o tiro sair completamente pelo topo da tela (y < 0),
        -- nós o removemos da tabela para liberar memória.
        if b.y + b.height < 0 then
            table.remove(activeBullets, i)
        end
    end
end

function Bullet.draw()
    -- Verde claro temporário para o laser do tanque
    love.graphics.setColor(0.5, 1, 0.5) 
    for _, b in ipairs(activeBullets) do
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
    end
end

-- Função auxiliar que usaremos no futuro para checar colisões com inimigos
function Bullet.getAll()
    return activeBullets
end

return Bullet