-- src/states/shop.lua

local Shop = {}
local Player = require "src.entities.player"
local Play = require "src.states.play" 

-- Variáveis de controle da interface
local items = {}
local selectedIndex = 1
local inputCooldown = 0 

-- NOVO: Variáveis para o background da loja
local bgImage = nil
local bgScaleX = 1
local bgScaleY = 1

function Shop.load()
    selectedIndex = 1

    -- 1. Carrega o Background da Loja e calcula a escala (Resolução Virtual: 640x360)
    if not bgImage then
        -- Utilizamos barras normais "/" por questões de compatibilidade multiplataforma
        bgImage = love.graphics.newImage("assets/backgrounds/Shop.png")
        bgScaleX = 640 / bgImage:getWidth()
        bgScaleY = 360 / bgImage:getHeight()
    end

    -- Carrega a música da loja (streaming para mp3)
    if love and love.audio then
        if not Shop.music then
            Shop.music = love.audio.newSource("assets/music/Antarctic Reinforcement - Structured Mix.mp3", "stream")
            Shop.music:setLooping(true)
            Shop.music:setVolume(0.05)
        end
        if Shop.music and not Shop.music:isPlaying() then
            Shop.music:play()
        end
    end

    -- Carrega o som de confirmação de compra
    if love and love.audio then
        if not Shop.purchaseSound then
            Shop.purchaseSound = love.audio.newSource("assets/sfx/confirmation_004.ogg", "static")
            Shop.purchaseSound:setVolume(0.07)
        end
    end
    
    -- Estrutura de dados dos Upgrades baseada no GDD
    items = {
        {
            name = "Blindagem (Max HP)",
            desc = "Aumenta a integridade estrutural da maquina em 40 pontos e a repara.",
            cost = 45,
            action = function(self)
                Player.maxHp = Player.maxHp + 40
                Player.hp = Player.maxHp -- Cura total como bonus
                local Costpercent = self.cost * 0.10
                self.cost = math.ceil(self.cost + Costpercent) 
            end
        },
        {
            name = "Reator de Foco",
            desc = "Diminui a quantidade requerida de energia para o Poder Especial.",
            cost = 70,
            action = function(self)
                Player.maxEnergy = Player.maxEnergy - 6
                local Costpercent = self.cost * 0.10
                self.cost = math.ceil(self.cost + Costpercent) 
            end
        },
        {
            name = "Propulsores Leves",
            desc = "Aumenta a velocidade de esquiva e movimentacao.",
            cost = 100,
            action = function(self)
                local Costpercent = self.cost * 0.10
                self.cost = math.ceil(self.cost + Costpercent) 
                Player.speed = Player.speed + 30
            end
        }
    }
end

function Shop.update(dt)
    -- Lógica de Debounce
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
        return
    end

    -- Navegação no menu (W / S, conforme GDD)
    if love.keyboard.isDown("w") then
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then selectedIndex = #items end
        inputCooldown = 0.15 
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
            item.action(item)
            
            if Shop.purchaseSound then
                Shop.purchaseSound:stop()
                Shop.purchaseSound:play()
            end
            print("Sucesso: Adquiriu " .. item.name)
        else
            print("Aviso: Fundos insuficientes para " .. item.name)
        end
        inputCooldown = 0.3 
    end

    -- Prosseguir para a próxima etapa da história (Enter)
    if love.keyboard.isDown("return") then
        print("Sistemas aeroespaciais ativados. Ascendendo a Orbita Cega")
        Play.faseAtual = Play.faseAtual + 1
        inputCooldown = 0.5
        MudarEstado("play")
    end
end

function Shop.draw()
    -- Limpa a tela com uma cor de fallback (caso a imagem demore um frame para carregar)
    love.graphics.clear(0.1, 0.1, 0.15) 

    -- 1. NOVO: Desenha a imagem de fundo preenchendo toda a tela
    love.graphics.setColor(1, 1, 1) -- Garante que a imagem não seja pintada de outra cor
    if bgImage then
        love.graphics.draw(bgImage, 0, 0, 0, bgScaleX, bgScaleY)
    end

    -- 2. Cabeçalho
    love.graphics.setColor(1, 0.8, 0) -- Amarelo
    love.graphics.printf("TERMINAL DE UPGRADES AEGIS", 0, 15, 640, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Creditos: $" .. Player.coins, 10, 40)

    -- 3. Lista de Itens
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

    -- 4. Painel de Descrição (Rodapé)
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.printf(items[selectedIndex].desc, 10, 135, 300, "center")

    -- 5. Instrução de avanço
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("[SPACE] Comprar Item", 0, 165, 640, "center")
    love.graphics.printf("[ENTER] Iniciar Próxima Fase", 0, 185, 640, "center")
end

return Shop