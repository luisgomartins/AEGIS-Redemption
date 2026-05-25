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
        speed = 400,
        damage = 500,
        isSpecial = false
    }
    table.insert(activeBullets, newBullet)
end

-- NOVA FUNÇÃO: Fábrica do Tiro Especial
function Bullet.spawnSpecial(x, y)
    local specialBullet = {
        x = x,
        y = y,
        width = 16,
        height = 32,
        speed = 50,
        damage = 100,
        isSpecial = true
    }
    table.insert(activeBullets, specialBullet)
end

function Bullet.update(dt)
    for i = #activeBullets, 1, -1 do
        local b = activeBullets[i]

        b.y = b.y - b.speed * dt

        if b.y + b.height < 0 then
            table.remove(activeBullets, i)
        end
    end
end

function Bullet.draw()

    for _, b in ipairs(activeBullets) do
        if b.isSpecial then
            love.graphics.setColor(0, 1, 1)
        else
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