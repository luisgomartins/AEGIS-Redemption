-- main.lua

-- 1. Configurações Globais de Debug e RNG
io.stdout:setvbuf("no") -- Força o console a exibir prints em tempo real
math.randomseed(os.time()) -- Inicializa a semente de números aleatórios

-- 2. Importação de Bibliotecas
local push = require "libs.push"

-- 3. Constantes de Resolução
local VIRTUAL_WIDTH = 640
local VIRTUAL_HEIGHT = 360
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

-- 4. Gerenciador de Estados
EstadoAtual = "menu"
local estados = {}

function love.load()
    -- Garante a nitidez do redimensionamento do pixel art
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("AEGIS: Redemption")
    -- Inicializa o canvas virtual
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- Carrega os módulos de estado
    estados.menu = require "src.states.menu"
    estados.play = require "src.states.play" 
    estados.shop = require "src.states.shop"
    estados.gameover = require "src.states.gameover"
    estados.victory = require "src.states.victory"

    if estados[EstadoAtual].load then
        estados[EstadoAtual].load()
    end
end

function love.update(dt)
    if estados[EstadoAtual].update then
        estados[EstadoAtual].update(dt)
    end
end

function love.draw()
    push:apply("start") -- Inicia a renderização na resolução 640x360
    
    if estados[EstadoAtual].draw then
        estados[EstadoAtual].draw()
    end
    
    push:apply("end") -- Finaliza e estica para 1280x720
end

-- Função auxiliar global para transição de telas
function MudarEstado(novoEstado)
    EstadoAtual = novoEstado
    if estados[EstadoAtual].load then
        estados[EstadoAtual].load()
    end
end

-- Atalho global para fechar o jogo rapidamente durante os testes
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.keypressed(key)
    if estados[EstadoAtual] and estados[EstadoAtual].keypressed then
        estados[EstadoAtual].keypressed(key)
    end
end