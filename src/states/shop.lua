local Shop = {}
local Player = require "src.entities.player"

-- Variáveis de controle da interface
local items = {}
local selectedIndex = 1
local inputCooldown = 0 -- Temporizador para evitar "metralhadora" de inputs

function Shop.load()
    selectedIndex = 1
    
    -- Estrutura de dados dos Upgrades baseada no GDD
    items = {
        {
            name = "Blindagem (Max HP)",
            desc = "Aumenta a integridade estrutural da maquina em 20 pontos e a repara.",
            cost = 50,
            action = function()
                Player.maxHp = Player.maxHp + 20
                Player.hp = Player.maxHp -- Cura total como bonus
            end
        },
        {
            name = "Reator de Foco",
            desc = "Expande a capacidade maxima de energia para o Poder Especial.",
            cost = 75,
            action = function()
                Player.maxEnergy = Player.maxEnergy + 50
            end
        },
        {
            name = "Propulsores Leves",
            desc = "Aumenta a velocidade de esquiva e movimentacao.",
            cost = 100,
            action = function()
                Player.speed = Player.speed + 30
            end
        }
    }
end

function Shop.update(dt)
    -- Lógica de Debounce: Ignora inputs se o timer for maior que zero
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
        return
    end

    -- Navegação no menu (W / S, conforme GDD)
    if love.keyboard.isDown("w") then
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then selectedIndex = #items end
        inputCooldown = 0.15 -- Trava o input por 150ms
    elseif love.keyboard.isDown("s") then
        selectedIndex = selectedIndex + 1
        if selectedIndex > #items then selectedIndex = 1 end
        inputCooldown = 0.15
    end

    -- Confirmação de Compra (Barra de Espaço)
    if love.keyboard.isDown("space") then
        local item = items[selectedIndex]
        
        if Player.coins >= item.cost then
            Player.coins = Player.coins - item.cost
            item.action() -- Executa a função anônima do item
            print("Sucesso: Adquiriu " .. item.name)
        else
            print("Aviso: Fundos insuficientes para " .. item.name)
        end
        inputCooldown = 0.3 -- Trava maior para não comprar duas vezes sem querer
    end

    -- Prosseguir para a próxima etapa da história (Enter)
    if love.keyboard.isDown("return") then
        -- Quando a Fase 2 existir, usaremos MudarEstado("play") novamente, 
        -- mas com um roteamento para trocar a forma do player para "Nave"
        print("Preparando transicao para a Orbita Cega...")
        inputCooldown = 0.5
    end
end

function Shop.draw()
    -- Fundo que remete ao hangar / bunker
    love.graphics.clear(0.1, 0.1, 0.15) 

    -- Cabeçalho
    love.graphics.setColor(1, 0.8, 0) -- Amarelo
    love.graphics.printf("TERMINAL DE UPGRADES AEGIS", 0, 15, 320, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Creditos: $" .. Player.coins, 10, 40)

    -- Lista de Itens
    local startY = 70
    for i, item in ipairs(items) do
        if i == selectedIndex then
            love.graphics.setColor(0.2, 1, 0.2) -- Verde destaque
            love.graphics.print("> " .. item.name .. " ($" .. item.cost .. ")", 20, startY + (i * 15))
        else
            love.graphics.setColor(0.6, 0.6, 0.6) -- Cinza para inativos
            love.graphics.print("  " .. item.name .. " ($" .. item.cost .. ")", 20, startY + (i * 15))
        end
    end

    -- Painel de Descrição (Rodapé)
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.printf(items[selectedIndex].desc, 10, 135, 300, "center")

    -- Instrução de avanço
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("[ENTER] Iniciar Fase 2", 0, 165, 320, "center")
end

return Shop