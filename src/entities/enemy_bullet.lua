-- src/entities/enemy_bullet.lua
local EnemyBullet = {} -- Tabela para armazenar os tiros inimigos, cada tiro é uma tabela com suas próprias propriedades (posição, velocidade, etc)

local activeBullets = {} -- Tiros ativos na tela
local VIRTUAL_HEIGHT = 180 -- Precisamos da altura para saber quando o tiro saiu da tela

function EnemyBullet.spawn(x, y) -- Cria um novo tiro inimigo na posição (x, y) e o adiciona à lista de tiros ativos
    local newBullet = { 
        x = x, -- A posição inicial do tiro, geralmente a posição do inimigo que atira
        y = y, -- O tiro começa na mesma altura do inimigo, mas pode ser ajustado para sair de uma "boca de canhão" específica
        width = 6, -- Largura do tiro, ajustada para ser mais visível e diferente do tiro do jogador
        height = 6,  -- Um tiro mais quadrado/redondo para diferenciar do tiro do jogador
        speed = 150, -- Mais lento que o do Kael, para dar tempo de desviar (GDD: Mecânica de Esquiva)
        damage = 10 -- Dano que o tiro causa ao jogador, pode ser ajustado para balancear a dificuldade
    }
    table.insert(activeBullets, newBullet) -- Adiciona o novo tiro à lista de tiros ativos
end

function EnemyBullet.update(dt) -- Atualiza a posição dos tiros e remove os que saíram da tela
    for i = #activeBullets, 1, -1 do -- Iteramos de trás para frente para poder remover tiros sem pular índices
        local b = activeBullets[i] -- Referência ao tiro atual
        
        -- Movimenta o tiro para BAIXO (eixo Y positivo)
        b.y = b.y + b.speed * dt
        
        -- Se o tiro sair completamente pela base da tela, nós o removemos
        if b.y > VIRTUAL_HEIGHT then
            table.remove(activeBullets, i)
        end
    end
end

function EnemyBullet.draw()
    -- Laranja/Amarelo para contrastar com o vermelho do Boss e o verde do Kael
    love.graphics.setColor(1, 0.6, 0.1) 
    for _, b in ipairs(activeBullets) do
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
    end
end

function EnemyBullet.getAll()
    return activeBullets
end

return EnemyBullet