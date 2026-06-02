-- src/entities/enemy_bullet.lua

local EnemyBullet = {}
local activeBullets = {}
local VIRTUAL_HEIGHT = 360
local VIRTUAL_WIDTH = 640 -- Adicionado para checagem lateral

-- Agora recebemos dx e dy como parâmetros opcionais
function EnemyBullet.spawn(x, y, dx, dy, customDamage, customSpeed, splitTimer, splitCount)
    local newBullet = {
        x = x,
        y = y,
        width = 6 * 2,
        height = 6 * 2,
        speed = customSpeed or (150 * 2), -- Usa a velocidade customizada ou o padrão 150
        damage = customDamage or 0,
        dx = dx or 0,
        dy = dy or 1,
        splitTimer = splitTimer or 0,
        splitTimerMax = splitTimer or 0,
        splitCount = splitCount or 0
    }
    table.insert(activeBullets, newBullet)
end

function EnemyBullet.update(dt)
    for i = #activeBullets, 1, -1 do
        local b = activeBullets[i]

        if b.splitTimer > 0 then
            b.splitTimer = b.splitTimer - dt
            if b.splitTimer <= 0 and b.splitCount < 3 then
                local angle = math.atan2(b.dy, b.dx)
                local spread = 0.4
                local nextSplitCount = b.splitCount + 1
                local nextSplitTimer = b.splitTimerMax > 0 and b.splitTimerMax or 0.4

                EnemyBullet.spawn(b.x, b.y, math.cos(angle + spread), math.sin(angle + spread), b.damage, b.speed, nextSplitTimer, nextSplitCount)
                EnemyBullet.spawn(b.x, b.y, math.cos(angle - spread), math.sin(angle - spread), b.damage, b.speed, nextSplitTimer, nextSplitCount)
                table.remove(activeBullets, i)
                goto continue
            end
        end

        -- Atualizamos a posição baseada nos vetores de direção
        b.x = b.x + (b.dx * b.speed) * dt
        b.y = b.y + (b.dy * b.speed) * dt

        -- Limpeza (Teardown): Remove se sair por baixo OU pelas laterais
        if b.y > VIRTUAL_HEIGHT or b.x < 0 or b.x > VIRTUAL_WIDTH then
            table.remove(activeBullets, i)
        end

        ::continue::
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