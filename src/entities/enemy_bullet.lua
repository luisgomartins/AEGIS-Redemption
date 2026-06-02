-- src/entities/enemy_bullet.lua

local EnemyBullet = {}
local activeBullets = {}
local VIRTUAL_HEIGHT = 360
local VIRTUAL_WIDTH = 640 -- Adicionado para checagem lateral
local bulletSprite = nil

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
    if not bulletSprite then
        bulletSprite = love.graphics.newImage("assets/sprites/TiroRosa.png")
    end

    love.graphics.setColor(1, 1, 1)

    -- Pega as dimensões originais da imagem para a nossa matemática
    local imgW = bulletSprite:getWidth()
    local imgH = bulletSprite:getHeight()

    for _, b in ipairs(activeBullets) do
        local scaleX = b.width / imgW
        local scaleY = b.height / imgH

        local originX = imgW / 2
        local originY = imgH / 2

        local drawX = b.x + (b.width / 2)
        local drawY = b.y + (b.height / 2)

        local angle = math.atan2(b.dy, b.dx)

        love.graphics.draw(
            bulletSprite, 
            drawX,        -- Posição X (centralizada)
            drawY,        -- Posição Y (centralizada)
            angle,        -- Rotação de acordo com o trajeto
            scaleX,       -- Escala X
            scaleY,       -- Escala Y
            originX,      -- Centro da imagem X
            originY       -- Centro da imagem Y
        )
    end
end

function EnemyBullet.getAll()
    return activeBullets
end

function EnemyBullet.clear()
    activeBullets = {}
end

return EnemyBullet