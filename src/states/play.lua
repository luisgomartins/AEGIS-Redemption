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

-- Função para detecção de colisão circular baseada em raio
-- Calcula o raio a partir da width/height (usa a metade da width como raio)
local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    local r1 = w1 / 2
    local r2 = w2 / 2
    
    -- Centro das entidades
    local centerX1 = x1 + w1 / 2
    local centerY1 = y1 + h1 / 2
    local centerX2 = x2 + w2 / 2
    local centerY2 = y2 + h2 / 2
    
    -- Distância entre os centros
    local dx = centerX1 - centerX2
    local dy = centerY1 - centerY2
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Colisão ocorre se a distância for menor que a soma dos raios
    return distance < (r1 + r2)
end

function Play.load()
    -- Carrega as músicas das fases (streaming para mp3) e controla reprodução
    if love and love.audio then
        if not Play.music1 then
            Play.music1 = love.audio.newSource("assets/music/Guardian of The Former Seas_edited.mp3", "stream")
            Play.music1:setLooping(true)
            Play.music1:setVolume(0.05)
        end
        if not Play.music2 then
            Play.music2 = love.audio.newSource("assets/music/Pest of The Cosmos_edited.mp3", "stream")
            Play.music2:setLooping(true)
            Play.music2:setVolume(0.05)
        end
        if not Play.music3 then
            Play.music3 = love.audio.newSource("assets/music/Unholy Insurgency_edited.mp3", "stream")
            Play.music3:setLooping(true)
            Play.music3:setVolume(0.05)
        end
    end

    -- Define comportamento por fase e gerencia a música ativa em Play.music
    if Play.faseAtual == 1 then
        Player.load()
        -- Limpa projéteis existentes ao (re)iniciar a fase/respawn do jogador
        Bullet.clear()
        EnemyBullet.clear()
        -- toca música 1
        if Play.music2 and Play.music2:isPlaying() then Play.music2:stop() end
        if Play.music3 and Play.music3:isPlaying() then Play.music3:stop() end
        Play.music = Play.music1
        if Play.music and not Play.music:isPlaying() then Play.music:play() end
        -- Carrega o background da fase 1
        if not Play.background1 then
            Play.background1 = love.graphics.newImage("assets/backgrounds/BackGround1.png")
            -- calcula escala para ajustar à resolução 640x360
            local bw = Play.background1:getWidth()
            local bh = Play.background1:getHeight()
            Play.bg1ScaleX = 640 / bw
            Play.bg1ScaleY = 360 / bh
        end
    elseif Play.faseAtual == 2 then
        Player.load()
        -- Limpa projéteis existentes ao (re)iniciar a fase/respawn do jogador
        Bullet.clear()
        EnemyBullet.clear()
        -- fase 2: nave
        if Play.music1 and Play.music1:isPlaying() then Play.music1:stop() end
        if Play.music3 and Play.music3:isPlaying() then Play.music3:stop() end
        Play.music = Play.music2
        if Play.music and not Play.music:isPlaying() then Play.music:play() end

        Player.form = "nave"
        Player.width = 32
        Player.height = 32
        Player.x = (640 / 2) - (Player.width / 2)
        Player.y = 360 - Player.height - 10
        -- Carrega o background da fase 2
        if not Play.background2 then
            Play.background2 = love.graphics.newImage("assets/backgrounds/BackGround2.png")
            local bw = Play.background2:getWidth()
            local bh = Play.background2:getHeight()
            Play.bg2ScaleX = 640 / bw
            Play.bg2ScaleY = 360 / bh
        end
    elseif Play.faseAtual == 3 then
        Player.load()
        -- Limpa projéteis existentes ao (re)iniciar a fase/respawn do jogador
        Bullet.clear()
        EnemyBullet.clear()
        -- fase 3: toca música 3
        if Play.music1 and Play.music1:isPlaying() then Play.music1:stop() end
        if Play.music2 and Play.music2:isPlaying() then Play.music2:stop() end
        Play.music = Play.music3
        if Play.music and not Play.music:isPlaying() then Play.music:play() end

        -- Carrega o background da fase 3
        if not Play.background3 then
            Play.background3 = love.graphics.newImage("assets/backgrounds/BackGround3.png")
            local bw = Play.background3:getWidth()
            local bh = Play.background3:getHeight()
            Play.bg3ScaleX = 640 / bw
            Play.bg3ScaleY = 360 / bh
        end

        Player.form = "nave"
        Player.width = 32
        Player.height = 32
        Player.x = (640 / 2) - (Player.width / 2)
        Player.y = 360 - Player.height - 10
    else
        -- outras fases: garante que nenhuma música de fase esteja tocando
        if Play.music1 and Play.music1:isPlaying() then Play.music1:stop() end
        if Play.music2 and Play.music2:isPlaying() then Play.music2:stop() end
        if Play.music3 and Play.music3:isPlaying() then Play.music3:stop() end
        Play.music = nil

        if Play.faseAtual >= 2 then
            Player.load()
            -- Limpa projéteis ao recarregar a fase (caso seja respawn)
            Bullet.clear()
            EnemyBullet.clear()
            Player.form = "nave"
            Player.width = 32
            Player.height = 32
            Player.x = (640 / 2) - (Player.width / 2)
            Player.y = 360 - Player.height - 10
        end
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
            local randomX = math.random(10, 630)
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
        
        if CheckCollision(eb.x, eb.y, eb.width, eb.height, Player.x, Player.y, Player.width, Player.height) then
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
    
    if love.keyboard.isDown("1") then
            Play.faseAtual = 1
            Play.load() -- R
        elseif love.keyboard.isDown("2") then
            Play.faseAtual = 2
            Play.load() -- 
        elseif love.keyboard.isDown("3") then
            Play.faseAtual = 3
            Play.load()
    end

    if love.keyboard.isDown("backspace") then
        MudarEstado("menu")
    end
end
function Play.draw()
    love.graphics.clear(0.15, 0.15, 0.18)

    -- Desenha o background da fase 1 ou fase 2 antes de tudo
    if Play.faseAtual == 1 and Play.background1 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Play.background1, 0, 0, 0, Play.bg1ScaleX or 1, Play.bg1ScaleY or 1)
    elseif Play.faseAtual == 2 and Play.background2 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Play.background2, 0, 0, 0, Play.bg2ScaleX or 1, Play.bg2ScaleY or 1)
    elseif Play.faseAtual == 3 and Play.background3 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Play.background3, 0, 0, 0, Play.bg3ScaleX or 1, Play.bg3ScaleY or 1)
    end

    -- Borda do mapa para reforçar a área de jogo
    love.graphics.setColor(0.3, 0.3, 0.45)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 2, 2, 636, 356)
    love.graphics.setColor(1, 1, 1)

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