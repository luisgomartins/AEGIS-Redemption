-- src/entities/enemy_bullet.lua

local EnemyBullet = {}
local activeBullets = {}
local VIRTUAL_HEIGHT = 180
local VIRTUAL_WIDTH = 320 -- Adicionado para checagem lateral

-- Agora recebemos dx e dy como parâmetros opcionais
function EnemyBullet.spawn(x, y, dx, dy, customDamage, customSpeed)
    local newBullet = {
        x = x, 
        y = y,
        radius = 3,
        speed = customSpeed or 150, -- Usa a velocidade customizada ou o padrão 150
        damage = customDamage or 20, -- Usa o dano customizado ou o padrão 20
        dx = dx or 0,
        dy = dy or 1
    }
    table.insert(activeBullets, newBullet)
end

function EnemyBullet.update(dt)
    for i = #activeBullets, 1, -1 do
        local b = activeBullets[i]
        
        -- Atualizamos a posição baseada nos vetores de direção
        b.x = b.x + (b.dx * b.speed) * dt
        b.y = b.y + (b.dy * b.speed) * dt
        
        -- Limpeza (Teardown): Remove se sair por baixo OU pelas laterais
        if b.y > VIRTUAL_HEIGHT or b.x < 0 or b.x > VIRTUAL_WIDTH then
            table.remove(activeBullets, i)
        end
    end
end

function EnemyBullet.draw()
    love.graphics.setColor(1, 0.6, 0.1)
    for _, b in ipairs(activeBullets) do
        love.graphics.circle("fill", b.x, b.y, b.radius)
    end
end

function EnemyBullet.getAll()
    return activeBullets
end

function EnemyBullet.clear()
    activeBullets = {}
end

return EnemyBullet