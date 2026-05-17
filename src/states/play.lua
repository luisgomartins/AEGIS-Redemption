-- src/states/play.lua
local Play = {}

local Player = require "src.entities.player"
local Bullet = require "src.entities.bullet"
local Enemy = require "src.entities.enemy"
local EnemyBullet = require "src.entities.enemy_bullet"
local Hud = require "src.ui.hud"

Play.faseAtual = 1 -- Variável para controlar a fase atual (1: Tanque, 2: Nave)

-- Função matemática pura para detecção AABB
-- Recebe Posição X, Y e Dimensões (Largura, Altura) de dois objetos
local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function Play.load()
    -- ==========================================
    -- 1. CONFIGURAÇÃO DO JOGADOR (KAEL)
    -- ==========================================
    if Play.faseAtual == 1 then
        -- Fase 1 (Novo Jogo): Carrega o Kael do zero (Tanque, HP base, 0 moedas)
        Player.load() 
    elseif Play.faseAtual == 2 then
        -- Fase 2 (Órbita Cega): Kael vem da Loja. 
        -- NÃO chamamos Player.load() para preservar as compras e o HP atual!
        
        -- Apenas transformamos a máquina Dual-Form:
        Player.form = "nave"
        Player.width = 16
        Player.height = 16
        Player.x = (320 / 2) - (Player.width / 2)
        Player.y = 180 - Player.height - 10
    end

    -- ==========================================
    -- 2. CONFIGURAÇÃO DO INIMIGO (ECOS)
    -- ==========================================
    -- Como é um novo chefe, sempre recarregamos, injetando o número da fase
    -- para que o script saiba quais atributos (HP, Velocidade) aplicar.
    Enemy.load(Play.faseAtual)
end

function Play.update(dt)
    -- O estado Play delega a atualização para a entidade Player
    Player.update(dt)
    -- Atualiza os projéteis ativos
    Bullet.update(dt)
    -- Só atualizamos o boss e checamos colisões se ele ainda estiver vivo
    EnemyBullet.update(dt) -- Atualiza os tiros inimigos

    if Enemy.hp > 0 then
        -- Atualiza a posição do inimigo (Eco 1)
        Enemy.update(dt)
        
        -- Lógica de Colisão: Tiros do Kael vs Boss (Eco 1)
        -- IMPORTANTE: A função CheckCollision é uma função pura, ou seja, ela não depende de nenhum estado externo e sempre retornará o mesmo resultado para os mesmos parâmetros. Isso a torna fácil de testar e reutilizar em diferentes partes do código.
        -- Ela verifica se os retângulos dos tiros e do inimigo estão se sobrepondo, o que indica um impacto. Se houver impacto, o HP do inimigo é reduzido pelo dano do tiro, e o tiro é removido para evitar múltiplos impactos.  
        -- IMPORTANTE: A função Bullet.getAll() retorna a tabela de tiros ativos, permitindo que o estado Play acesse e verifique cada tiro contra o inimigo.
        -- A ordem de verificação é crucial: primeiro verificamos se o inimigo ainda tem HP, para evitar checar colisões desnecessárias após a morte do boss, o que otimiza o desempenho.
        local bullets = Bullet.getAll()
        -- Iteramos de trás para frente, pois vamos deletar itens da tabela!
        for i = #bullets, 1, -1 do
            local b = bullets[i]
            
            -- Se o AABB retornar 'true', houve impacto
            if CheckCollision(b.x, b.y, b.width, b.height, Enemy.x, Enemy.y, Enemy.width, Enemy.height) then
                
                -- 1. Reduz o HP do Boss usando o dano do tiro
                Enemy.hp = Enemy.hp - b.damage
                
                -- MATEMÁTICA DE ACÚMULO DE ENERGIA:
                -- "not" inverte o valor booleano, como os tiros normais têm isSpecial = false, o "not" transforma isso em true e a energia sobe. 
                -- Como o tiro especial tem isSpecial = true, o not vira false, e o bloco de recarga é ignorado, mantendo a energia zerada após o impacto.
                if not b.isSpecial then 
                    Player.energy = math.min(Player.energy + 10, Player.maxEnergy) -- A função math.min garante que o valor nunca ultrapasse Player.maxEnergy.
                -- Se ele tiver 95 e ganhar 10 (total 105), o math.min força a ficar em 100.
                end

                -- 2. Destrói o tiro para ele não atravessar o Boss
                table.remove(bullets, i)
                
                -- 3. Log de debug no console para acompanharmos o dano
                print("Boss HP: " .. Enemy.hp .. " | Kael Energy: " .. Player.energy) -- Isso nos ajuda a verificar se o sistema de energia está funcionando corretamente, e se o dano está sendo aplicado ao boss.
            end
        end
    end
    if Enemy.hp <= 0 then
        -- Opcional: Adiciona moedas como recompensa pela vitória
        Player.coins = Player.coins + 150 
        print("VITORIA! Entrando no Hangar...")
        MudarEstado("shop")
    end


    -- Nova Colisão: Tiros do Inimigo vs Jogador (Kael)
    local eBullets = EnemyBullet.getAll() -- Pegamos os tiros inimigos ativos para verificar colisões com o jogador
    for i = #eBullets, 1, -1 do -- Iteramos de trás para frente para poder remover tiros sem pular índices
        local eb = eBullets[i] -- Referência ao tiro inimigo atual
        
        if CheckCollision(eb.x, eb.y, eb.width, eb.height, Player.x, Player.y, Player.width, Player.height) then -- Se houve colisão entre o tiro inimigo e o jogador
            Player.hp = Player.hp - eb.damage -- Reduz o HP do jogador pelo dano do tiro inimigo
            table.remove(eBullets, i) -- Remove o tiro inimigo para evitar múltiplos impactos
            print("KAEL ATINGIDO! HP: " .. Player.hp) -- Log de debug para acompanhar o HP do jogador após ser atingido
            
            -- Condição de Derrota (Game Over temporário)
            if Player.hp <= 0 then -- O jogador morreu
                print("GAME OVER - Tanque Destruído") -- Log de debug para indicar que o jogo acabou
                MudarEstado("menu") -- Volta pro menu se morrer
            end
        end
    end


    
    -- Opção de Qualidade de Vida (QoL) para testes: Voltar ao menu
    if love.keyboard.isDown("backspace") then
        MudarEstado("menu")
    end
end

function Play.draw()
    -- Fundo temporário para contrastar com as ruínas (Cor de escombros/poeira)
    love.graphics.clear(0.15, 0.15, 0.18) 

    -- IMPORTANTE: A ordem de desenho (Z-Index). 
    -- Desenhamos os tiros primeiro, e o jogador depois. 
    -- Assim, visualmente, o tiro sai "de baixo" do tanque.
    -- O inimigo é desenhado por último para garantir que ele apareça "na frente" do jogador, aumentando a sensação de ameaça.
    Bullet.draw()
    EnemyBullet.draw() -- Desenha os tiros inimigos
    Player.draw()
    -- Só renderizamos o inimigo e a barra de HP se ele estiver vivo
    -- Isso evita confusão visual e melhora a performance, já que não precisamos desenhar o boss ou a barra de vida após sua derrota.
    if Enemy.hp > 0 then
        Enemy.draw()
    else
        -- Condição de Vitória (Temporária)
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("ECO 1 DESTRUIDO!", 0, 80, 320, "center")
    end
    Hud.draw(Player, Enemy) -- Chama a função de desenho do HUD, passando o jogador e o inimigo para acessar seus atributos e renderizar as barras de vida, energia e contador de moedas

    love.graphics.setColor(1, 1, 1)

end
return Play