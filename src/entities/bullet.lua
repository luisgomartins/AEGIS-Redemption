-- src/entities/bullet.lua
local Bullet = {}

-- Esta tabela privada guardará todos os projéteis ativos no momento
local activeBullets = {}

-- Função de "Fábrica" (Factory): cria um novo tiro na posição informada
function Bullet.spawn(x, y)
    local newBullet = {
        x = x,
        y = y,
        width = 4 * 2,
        height = 10 * 2,
        speed = 500, -- Mais rápido que o jogador, pois é um projétil
        damage = 100,  -- Dano base definido no GDD
        isSpecial = false -- Flag para diferenciar
    }
    table.insert(activeBullets, newBullet)
end

-- NOVA FUNÇÃO: Fábrica do Tiro Especial
function Bullet.spawnSpecial(x, y) -- Esta função pode ser chamada para criar um tiro mais poderoso, por exemplo, quando o jogador ativa um poder especial
    local specialBullet = { -- Propriedades do tiro especial, ajustadas para ser mais impactante visualmente e em termos de gameplay
        x = x, -- A posição inicial do tiro, geralmente a posição do jogador que atira
        y = y, -- O tiro começa na mesma altura do jogador, mas pode ser ajustado para sair de uma "boca de canhão" específica
        width = 16 * 2,  -- Tiro muito mais largo
        height = 32 * 2, -- Tiro mais comprido
        speed = 80, -- Muito mais lento que o tiro normal, para dar um efeito de "poder carregado" e permitir que o jogador posicione melhor
        damage = 100, -- 10x o dano de um tiro normal (Poder Destrutivo!)
        isSpecial = true -- Flag ativada
    }
    table.insert(activeBullets, specialBullet)
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
    
    for _, b in ipairs(activeBullets) do
        -- Diferencia a cor baseada na flag do projétil
        if b.isSpecial then
            -- Azul/Ciano brilhante para o Especial
            love.graphics.setColor(0, 1, 1) 
        else
            -- Verde para o tiro comum
            love.graphics.setColor(0.5, 1, 0.5) 
        end
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
    end
end

-- Função auxiliar que usaremos no futuro para checar colisões com inimigos
function Bullet.getAll()
    return activeBullets
end

function Bullet.clear()
    activeBullets = {}
end

return Bullet