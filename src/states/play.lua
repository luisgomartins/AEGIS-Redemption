-- src/states/play.lua
local Play = {}

-- Importando a entidade do jogador
local Player = require "src.entities.player"
-- Importando a entidade de projétil para que o jogador possa atirar
local Bullet = require "src.entities.bullet"
-- Importando a entidade do inimigo
local Enemy = require "src.entities.enemy"

-- Função matemática pura para detecção AABB
-- Recebe Posição X, Y e Dimensões (Largura, Altura) de dois objetos
local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function Play.load()
    -- Inicializa as propriedades do jogador para esta partida
    Player.load()
    -- Inicializa as propriedades do inimigo para esta partida
    Enemy.load()
end

function Play.update(dt)
    -- O estado Play delega a atualização para a entidade Player
    Player.update(dt)
    -- Atualiza os projéteis ativos
    Bullet.update(dt)
    -- Só atualizamos o boss e checamos colisões se ele ainda estiver vivo
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
                
                -- 2. Destrói o tiro para ele não atravessar o Boss
                table.remove(bullets, i)
                
                -- 3. Log de debug no console para acompanharmos o dano
                print("IMPACTO! Boss HP: " .. Enemy.hp)
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
    Player.draw()
    -- Só renderizamos o inimigo e a barra de HP se ele estiver vivo
    -- Isso evita confusão visual e melhora a performance, já que não precisamos desenhar o boss ou a barra de vida após sua derrota.
    if Enemy.hp > 0 then
        Enemy.draw()
        
        -- Feedback visual do HP do Boss no topo direito da tela
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.print("Eco 1 HP: " .. Enemy.hp, 230, 5)
    else
        -- Condição de Vitória (Temporária)
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("ECO 1 DESTRUIDO!", 0, 80, 320, "center")
    end
    
    -- HUD Temporário
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Fase 1: Ruínas de Neo-Cidade", 5, 5)
end

return Play