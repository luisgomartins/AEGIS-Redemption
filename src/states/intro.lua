-- src/states/intro.lua
local Intro = {}
local Play = require "src.states.play"

local inputCooldown = 0

-- O texto da Lore baseado no seu GDD!
-- A sintaxe [[ ]] permite quebrar linhas livremente em Lua.
local loreText = [[
Ano 2026. 

A civilização terrestre foi devastada pelos "Ecos",
máquinas de guerra autônomas criadas pelo próprio ser humanos, 
que agora buscam purificar o planeta.

A resposta final da humanidade foi a Unidade Aegis, uma força de elite de pilotos, 
da qual Kael Nova era o membro mais promissor

Os Ecos lançaram um ataque global, beirando a humanidade a extinção e colapsando a Unidade Aegis,

Kael recuou para um laboratório antigo, onde encontrou o protótipo "Dual-Form",
Seu objetivo agora é dominar essa tecnologia e usar suas habilidades para enfrentar os Ecos, salvar o que resta da humanidade e vingar a queda da Aegis.
]]

function Intro.load()
    -- Colocamos um cooldown de meio segundo. Isso evita que o jogador aperte 
    -- ENTER no Menu e, sem querer, pule a história acidentalmente.
    inputCooldown = 0.5 
end

function Intro.update(dt)
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
    end
end

function Intro.keypressed(key)
    -- Só permite avançar se o tempo de segurança já passou
    if inputCooldown <= 0 and (key == "return" or key == "space") then
        -- Garante que o jogo comece na Fase 1
        Play.faseAtual = 1
        MudarEstado("play")
    end
end

function Intro.draw()
    -- Fundo bem escuro, quase preto, para focar na leitura
    love.graphics.clear(0.05, 0.05, 0.08)

    -- Desenha a Lore centralizada
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(loreText, 40, 70, 560, "center")

    -- Desenha o aviso para continuar piscando na parte de baixo
    local pulse = (math.sin(love.timer.getTime() * 5) + 1) / 2
    love.graphics.setColor(1, 1, 1, pulse) -- O último valor é a transparência (Alpha)
    love.graphics.printf("Pressione [ENTER] para iniciar a missão", 0, 300, 640, "center")
    
    love.graphics.setColor(1, 1, 1) -- Reseta a cor
end

return Intro