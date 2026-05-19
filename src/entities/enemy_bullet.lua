-- src/entities/enemy_bullet.lua

local EnemyBullet = {}
local activeBullets = {}
local VIRTUAL_HEIGHT = 180
local VIRTUAL_WIDTH = 320 -- Adicionado para checagem lateral

-- Agora recebemos dx e dy como parâmetros opcionais
function EnemyBullet.spawn(x, y, dx, dy)
    local newBullet = {
        x = x, 
        y = y,
        width = 6, 
        height = 6,
        speed = 150, 
        damage = 20,
        -- Se dx/dy não forem informados, o tiro desce reto (0 no X, 1 no Y)
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
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
    end
end

function EnemyBullet.getAll()
    return activeBullets
end

function EnemyBullet.clear()
    activeBullets = {}
end

return EnemyBullet