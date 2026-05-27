-- src/states/play.lua

local Play = {}

local Player = require "src.entities.player"
local Bullet = require "src.entities.bullet"
local Enemy = require "src.entities.enemy"
local EnemyBullet = require "src.entities.enemy_bullet"
local Hud = require "src.ui.hud"
local Coin = require "src.entities.coin"

Play.faseAtual = 1

-- Variáveis de controle para os drops aleatórios por tempo da Fase 2
local ambientDropTimer = 0
local ambientDropCooldown = 3.5 -- A cada 3.5 segundos surge um item do céu

-- Função matemática para detecção circular
local function CheckCircleCollision(x1, y1, r1, x2, y2, r2)
    local dx = x1 - x2
    local dy = y1 - y2
    local distanceSquared = (dx * dx) + (dy * dy)
    local radiusSum = r1 + r2
    return distanceSquared < (radiusSum * radiusSum)
end

-- Função para detecção de colisão retângulo vs círculo
local function CheckRectCircleCollision(rectX, rectY, rectWidth, rectHeight, circleX, circleY, circleRadius)
    local closestX = math.max(rectX, math.min(circleX, rectX + rectWidth))
    local closestY = math.max(rectY, math.min(circleY, rectY + rectHeight))
    local dx = circleX - closestX
    local dy = circleY - closestY
    return (dx * dx + dy * dy) < (circleRadius * circleRadius)
end

-- Função para detecção de colisão retângulo vs retângulo (AABB)
local function CheckRectRectCollision(rect1X, rect1Y, rect1Width, rect1Height, rect2X, rect2Y, rect2Width, rect2Height)
    return rect1X < rect2X + rect2Width and
           rect1X + rect1Width > rect2X and
           rect1Y < rect2Y + rect2Height and
           rect1Y + rect1Height > rect2Y
end

function Play.load()
    if Play.faseAtual == 1 then
        Player.load() 
    elseif Play.faseAtual >= 2 then -- Alterado para abranger a Fase 2 e 3
        Player.form = "nave"
        Player.width = 16
        Player.height = 16
        Player.x = (640 / 2) - (Player.width / 2)
        Player.y = 360 - Player.height - 10
    end
    Enemy.load(Play.faseAtual)
    Coin.clear() 
    ambientDropTimer = 0 -- Inicializa o timer de drops
end

function Play.update(dt)
    Player.update(dt)
    Bullet.update(dt)
    EnemyBullet.update(dt)
    Coin.update(dt) 
    -- =====================================
    -- SISTEMA DE SPAWN ALEATÓRIO POR TEMPO 
    -- =====================================
    if Play.faseAtual >= 1 then
        ambientDropTimer = ambientDropTimer + dt
        if ambientDropTimer >= ambientDropCooldown then
            ambientDropTimer = 0 -- Reseta o cronômetro
            
            -- Escolhe uma posição X aleatória válida dentro das bordas da tela (640px)
            local randomX = math.random(10, 300)
            local randomY = -10 -- Começa um pouco acima da tela para suavizar a entrada
            
            -- Fase 3: Apenas Cura. Fases 1-2: 70% Moeda, 30% Cura
            if Play.faseAtual == 3 then
                Coin.spawn(randomX, randomY, "heal")
            else
                local chance = math.random()
                if chance <= 0.70 then
                    Coin.spawn(randomX, randomY, "coin")
                else
                    Coin.spawn(randomX, randomY, "heal")
                end
            end
        end
    end

    if Enemy.hp > 0 then
        Enemy.update(dt)
        local bullets = Bullet.getAll()
        for i = #bullets, 1, -1 do
            local b = bullets[i]
            if CheckRectRectCollision(b.x, b.y, b.width, b.height, Enemy.x, Enemy.y, Enemy.width, Enemy.height) then
                Enemy.hp = Enemy.hp - b.damage
                if not b.isSpecial then
                    Player.energy = math.min(Player.energy + 10, Player.maxEnergy)
                end
                if math.random() <= 0.25 then
                    local dropX = Enemy.x + (Enemy.width / 2) - 3
                    local dropY = Enemy.y + (Enemy.height / 2)
                    -- Fase 3: Apenas Cura. Fases 1-2: Moeda
                    if Play.faseAtual == 3 then
                        Coin.spawn(dropX, dropY, "heal")
                    else
                        Coin.spawn(dropX, dropY, "coin")
                    end
                end
                table.remove(bullets, i)
            end
        end
    end
    
    if Enemy.hp <= 0 then
        EnemyBullet.clear()
        Bullet.clear()
        if Play.faseAtual == 3 then
            print("VITÓRIA FINAL! O Silêncio foi quebrado.")
            -- Reinicia para o menu após zerar (você pode criar uma tela de créditos no futuro)
            MudarEstado("victory")
        else
            print("VITORIA! Entrando no Hangar...")
            MudarEstado("shop")
        end
    end

    -- Colisão: Tiros do Inimigo vs Jogador
    local eBullets = EnemyBullet.getAll()
    for i = #eBullets, 1, -1 do
        local eb = eBullets[i]
        local playerCenterX = Player.x + (Player.width / 2)
        local playerCenterY = Player.y + (Player.height / 2)

        if CheckCircleCollision(eb.x, eb.y, eb.radius, playerCenterX, playerCenterY, Player.radius) then
            Player.hp = Player.hp - eb.damage
            table.remove(eBullets, i)
            if Player.hp <= 0 then
                print("GAME OVER - Destruído")
                MudarEstado("gameover")
            end
        end
    end

    -- ==========================================================
    -- LOGICA DE COLETA ATUALIZADA (MOEDAS E CURA)
    -- ==========================================================
    local activeCoins = Coin.getAll()
    for i = #activeCoins, 1, -1 do
        local c = activeCoins[i]
        local playerCenterX = Player.x + (Player.width / 2)
        local playerCenterY = Player.y + (Player.height / 2)

        if CheckRectCircleCollision(c.x, c.y, c.width, c.height, playerCenterX, playerCenterY, Player.radius) then

            if c.type == "coin" then
                Player.coins = Player.coins + c.value
            elseif c.type == "heal" then
                Player.hp = math.min(Player.hp + c.healAmount, Player.maxHp)
                print("KIT DE REPARO COLETADO! HP Atual: " .. Player.hp)
            end

            table.remove(activeCoins, i)
        end
    end

    -- ==========================================================
    -- ATALHOS DE DEBUG (REMOVER ANTES DO BUILD FINAL)
    -- ==========================================================
    --[[]
    if love.keyboard.isDown("1") then
        Play.faseAtual = 1
        Play.load() -- Recarrega as configurações da Fase 1 instantaneamente
    elseif love.keyboard.isDown("2") then
        Play.faseAtual = 2
        Play.load() -- Transiciona e recarrega os dados para a Fase 2
    end
    --]]
    if love.keyboard.isDown("backspace") then
        MudarEstado("menu")
    end
end
function Play.draw()
    love.graphics.clear(0.15, 0.15, 0.18) 

    Coin.draw() 
    Bullet.draw()
    EnemyBullet.draw()
    Player.draw()
    
    if Enemy.hp > 0 then
        Enemy.draw()
    else
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("ECO DESTRUIDO!", 0, 80, 640, "center")
    end
    
    Hud.draw(Player, Enemy)
    love.graphics.setColor(1, 1, 1)
end

return Play