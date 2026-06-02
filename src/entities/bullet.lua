-- src/entities/bullet.lua
-- src/entities/bullet.lua
local Bullet = {}
local activeBullets = {}

-- Variáveis para armazenar as sprites em cache (Lazy Loading)
local spriteTank = nil
local spriteNave = nil

-- NOVO: O parâmetro 'form' informará se o tiro veio do "tank" ou da "nave"
function Bullet.spawn(x, y, form)
    local newBullet = {
        x = x,
        y = y,
        width = 8 * 2,   -- Ajuste conforme sua hitbox
        height = 12 * 2, -- Ajuste conforme sua hitbox
        speed = 400,     -- Velocidade do projétil do jogador
        damage = 10,
        isSpecial = false,
        form = form or "tank" -- Salva a forma da máquina que atirou
    }
    table.insert(activeBullets, newBullet)
end

-- NOVA FUNÇÃO: Fábrica do Tiro Especial
function Bullet.spawnSpecial(x, y) -- Esta função pode ser chamada para criar um tiro mais poderoso, por exemplo, quando o jogador ativa um poder especial
    local specialBullet = { -- Propriedades do tiro especial, ajustadas para ser mais impactante visualmente e em termos de gameplay
        x = x, -- A posição inicial do tiro, geralmente a posição do jogador que atira
        y = y, -- O tiro começa na mesma altura do jogador, mas pode ser ajustado para sair de uma "boca de canhão" específica
        width = 16 * 2,  -- Tiro muito mais largo
        height = 32 * 2, -- Tiro mais comprido
        speed = 180, -- Muito mais lento que o tiro normal, para dar um efeito de "poder carregado" e permitir que o jogador posicione melhor
        damage = 100, -- 10x o dano de um tiro normal (Poder Destrutivo!)
        isSpecial = true -- Flag ativada
    }
    table.insert(activeBullets, specialBullet)
end

function Bullet.update(dt)
    -- ATENÇÃO AQUI: Quando removemos itens de uma tabela no Lua, 
    -- devemos iterar de trás para frente. Se iterarmos do início ao fim (1 ao #)
    -- e removermos o índice 2, o índice 3 vira 2, e o loop pula uma verificação.
    for i = #activeBullets, 1, -1 do
        local b = activeBullets[i]
        
        -- Movimenta o tiro para cima (eixo Y negativo)
        b.y = b.y - b.speed * dt
        
        -- Otimização: Se o tiro sair completamente pelo topo da tela (y < 0),
        -- nós o removemos da tabela para liberar memória.
        if b.y + b.height < 0 then
            table.remove(activeBullets, i)
        end
    end
end

function Bullet.draw()
    -- 1. Lazy Loading das Sprites
    if not spriteTank then
        spriteTank = love.graphics.newImage("assets/sprites/TiroTank.png")
    end
    if not spriteNave then
        spriteNave = love.graphics.newImage("assets/sprites/TiroNave.png")
    end

    for _, b in ipairs(activeBullets) do
        local img -- Variável para armazenar a imagem que será desenhada
        
        -- 2. Verifica qual tiro deve ser desenhado
        if b.isSpecial then
            -- Se for o Especial (tecla F), FORÇA o uso da sprite da Nave
            img = spriteNave
            
            -- Tinge a sprite de Ciano (RGB: 0, 1, 1) para dar um efeito de "Energia Carregada"
            love.graphics.setColor(0, 1, 1) 
        else
            -- Se for tiro normal, escolhe dinamicamente baseada na variável 'form'
            img = (b.form == "nave") and spriteNave or spriteTank
            
            -- Mantém a cor original da sprite (Branco puro)
            love.graphics.setColor(1, 1, 1)
        end
        
        -- 3. Coleta as dimensões originais e calcula a Escala Dinâmica
        local imgW = img:getWidth()
        local imgH = img:getHeight()
        
        -- Como o Tiro Especial (spawnSpecial) provavelmente tem uma hitbox (width/height) maior,
        -- essa matemática vai esticar a imagem do TiroNave automaticamente!
        local scaleX = b.width / imgW
        local scaleY = b.height / imgH

        -- 4. Desenha o projétil
        love.graphics.draw(img, b.x, b.y, 0, scaleX, scaleY)
    end
    
    -- 5. Reseta a cor global do LÖVE para evitar que o resto do jogo (inimigos, interface) fique manchado
    love.graphics.setColor(1, 1, 1)
end

-- Função auxiliar que usaremos no futuro para checar colisões com inimigos
function Bullet.getAll()
    return activeBullets
end

function Bullet.clear()
    activeBullets = {}
end

return Bullet