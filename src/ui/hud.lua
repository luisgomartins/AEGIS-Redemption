-- src/ui/hud.lua

local Hud = {} -- Módulo para a interface de usuário (HUD)

local BAR_WIDTH = 90 -- Largura total da barra de vida/energia
local BAR_HEIGHT = 8 -- Altura da barra
local PADDING = 8

function Hud.draw(player, enemy)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Kael", PADDING, 4)

    local playerHpRatio = math.max(0, player.hp) / player.maxHp
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", PADDING, 18, BAR_WIDTH, BAR_HEIGHT)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", PADDING, 18, BAR_WIDTH * playerHpRatio, BAR_HEIGHT)

    local playerEnergyRatio = math.max(0, player.energy) / player.maxEnergy
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", PADDING, 28 + BAR_HEIGHT, BAR_WIDTH, BAR_HEIGHT)
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.rectangle("fill", PADDING, 28 + BAR_HEIGHT, BAR_WIDTH * playerEnergyRatio, BAR_HEIGHT)

    love.graphics.setColor(1, 0.8, 0)
    love.graphics.print("Moedas: " .. player.coins, 500, 6)

    -- 4. Barra de Vida do Chefe (Topo central)
    -- Só renderiza se o inimigo estiver vivo e referenciado
    if enemy and enemy.hp > 0 then
        local enemyHpRatio = math.max(0, enemy.hp) / enemy.maxHp
        local bossBarWidth = 130 * 2
        local startX = (640 / 2) - (bossBarWidth / 2)
        local bossBarY = 6

        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", startX, bossBarY, bossBarWidth, BAR_HEIGHT)
        love.graphics.setColor(0.8, 0.1, 0.1) -- Vermelho
        love.graphics.rectangle("fill", startX, bossBarY, bossBarWidth * enemyHpRatio, BAR_HEIGHT)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ECO", 0, bossBarY - 8, 640, "center")
    end

    -- Resetar a cor para não afetar as próximas renderizações no main loop
    love.graphics.setColor(1, 1, 1)
end

return Hud