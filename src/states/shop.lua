-- src/states/shop.lua

local Shop = {}
local Player = require "src.entities.player"
local Play = require "src.states.play" -- Importa o estado de jogo para acessar a fase atual e as propriedades do jogador

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
            cost = 45,
            action = function()
                Player.maxHp = Player.maxHp + 20
                Player.hp = Player.maxHp -- Cura total como bonus

                local Costpercent = self.cost * 0.10
                self.cost = math.ceil(self.cost + Costpercent) -- Aumenta o custo do próximo upgrade em 10%
            end
        },
        {
            name = "Reator de Foco",
            desc = "Diminui a quantidade requerida de energia para o Poder Especial.",
            cost = 75,
            action = function()
                Player.maxEnergy = Player.maxEnergy - 8

                local Costpercent = self.cost * 0.10
                self.cost = math.ceil(self.cost + Costpercent) -- Aumenta o custo do próximo upgrade em 10%
            end
        },
        {
            name = "Propulsores Leves",
            desc = "Aumenta a velocidade de esquiva e movimentacao.",
            cost = 100,
            action = function()
                local Costpercent = self.cost * 0.10
                self.cost = math.ceil(self.cost + Costpercent) -- Aumenta o custo do próximo upgrade em 10%
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
    if love.keyboard.isDown("b") then
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
        print("Sistemas aeroespaciais ativados. Ascendendo a Orbita Cega")
        -- Incrementa a fase antes de rotear
        Play.faseAtual = Play.faseAtual + 1
        
        -- Atraso de input e roteamento
        inputCooldown = 0.5
        MudarEstado("play")
    end
end

function Shop.draw()
    -- Fundo que remete ao hangar / bunker
    love.graphics.clear(0.1, 0.1, 0.15) 

    -- Cabeçalho
    love.graphics.setColor(1, 0.8, 0) -- Amarelo
    love.graphics.printf("TERMINAL DE UPGRADES AEGIS", 0, 15, 640, "center")
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
    love.graphics.printf("[ENTER] Iniciar Fase 2", 0, 165, 640, "center")
end

return Shop