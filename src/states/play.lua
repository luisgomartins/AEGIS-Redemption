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

-- Função matemática pura para detecção AABB
local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function Play.load()
    if Play.faseAtual == 1 then
        Player.load() 
    elseif Play.faseAtual == 2 then
        Player.form = "nave"
        Player.width = 16
        Player.height = 16
        Player.x = (320 / 2) - (Player.width / 2)
        Player.y = 180 - Player.height - 10
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

    -- ==========================================================
    -- SISTEMA DE SPAWN ALEATÓRIO POR TEMPO (APENAS FASE 2)
    -- ==========================================================
    if Play.faseAtual == 2 and Enemy.hp > 0 then
        ambientDropTimer = ambientDropTimer + dt
        if ambientDropTimer >= ambientDropCooldown then
            ambientDropTimer = 0 -- Reseta o cronômetro
            
            -- Escolhe uma posição X aleatória válida dentro das bordas da tela (320px)
            local randomX = math.random(10, 300)
            local randomY = -10 -- Começa um pouco acima da tela para suavizar a entrada
            
            -- Sorteia o tipo: 70% de chance de ser Moeda, 30% de ser Cura
            local chance = math.random()
            if chance <= 0.70 then
                Coin.spawn(randomX, randomY, "coin")
            else
                Coin.spawn(randomX, randomY, "heal")
            end
        end
    end

    if Enemy.hp > 0 then
        Enemy.update(dt)
        
        -- Lógica de Colisão: Tiros do Kael vs Boss
        local bullets = Bullet.getAll()
        for i = #bullets, 1, -1 do
            local b = bullets[i]
            
            if CheckCollision(b.x, b.y, b.width, b.height, Enemy.x, Enemy.y, Enemy.width, Enemy.height) then
                Enemy.hp = Enemy.hp - b.damage
                
                if not b.isSpecial then 
                    Player.energy = math.min(Player.energy + 10, Player.maxEnergy) 
                end

                -- Mantém o drop por dano tradicional (apenas moedas normais de impacto)
                if math.random() <= 0.25 then
                    local dropX = Enemy.x + (Enemy.width / 2) - 3
                    local dropY = Enemy.y + (Enemy.height / 2)
                    Coin.spawn(dropX, dropY, "coin")
                end

                table.remove(bullets, i)
            end
        end
    end
    
    if Enemy.hp <= 0 then
        print("VITORIA! Entrando no Hangar...")
        MudarEstado("shop")
    end

    -- Colisão: Tiros do Inimigo vs Jogador
    local eBullets = EnemyBullet.getAll()
    for i = #eBullets, 1, -1 do
        local eb = eBullets[i]
        
        if CheckCollision(eb.x, eb.y, eb.width, eb.height, Player.x, Player.y, Player.width, Player.height) then
            Player.hp = Player.hp - eb.damage
            table.remove(eBullets, i)
            
            if Player.hp <= 0 then
                print("GAME OVER - Destruído")
                MudarEstado("menu")
            end
        end
    end

    -- ==========================================================
    -- LOGICA DE COLETA ATUALIZADA (MOEDAS E CURA)
    -- ==========================================================
    local activeCoins = Coin.getAll()
    for i = #activeCoins, 1, -1 do
        local c = activeCoins[i]
        if CheckCollision(c.x, c.y, c.width, c.height, Player.x, Player.y, Player.width, Player.height) then
            
            -- Tratamento polimórfico baseado no tipo do drop coletado
            if c.type == "coin" then
                Player.coins = Player.coins + c.value
            elseif c.type == "heal" then
                -- Cura o jogador sem passar do HP Máximo configurado no GDD (e preserva upgrades)
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
        love.graphics.printf("ECO DESTRUIDO!", 0, 80, 320, "center")
    end
    
    Hud.draw(Player, Enemy)
    love.graphics.setColor(1, 1, 1)
end

return Play