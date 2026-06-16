
<img width="1395" height="777" alt="image" src="https://github.com/user-attachments/assets/4d4c47af-deac-4ebe-aa89-8f9eeae57155" />


# AEGIS: Redemption 
## AEGIS: Redemption é um jogo de estilo Shoot 'em Up (Navinha) tático e arcade desenvolvido em Lua utilizando o framework LÖVE (Love2D). O projeto foi concebido como parte dos requisitos acadêmicos da disciplina de Multimídia.
## O jogo acompanha a jornada de Kael Nova pilotando uma máquina Dual-Form capaz de alternar sua atuação tática: um tanque pesado na superfície terrestre e uma nave de alta manobrabilidade na órbita espacial, enfrentando três poderosas inteligências conhecidas como os 'Ecos'.

<img width="609" height="465" alt="image" src="https://github.com/user-attachments/assets/01182cb2-b3b3-4ba7-96f6-b0116e6952f7" />


## 🚀 Funcionalidades e Destaques Técnicos
* Mecânica Central Dual-Form: Controles e restrições físicas distintas para cada forma do jogador. Tanque limitado ao eixo X (movimentação linear na superfície) e Nave com liberdade total em 360° (eixos X e Y).
* Arquitetura Modular (State Machine): Código estruturado de forma desacoplada através de uma máquina de estados robusta (states/), onde main.lua gerencia o ciclo de vida global e repassa os callbacks do LÖVE para o estado ativo (menu, play, shop).
* Resolução Virtual Estável: Implementação da biblioteca push.lua para gerenciar uma resolução interna base de 640x360 pixels escalonada com filtro Nearest Neighbor, garantindo uma estética Retro Pixel Art perfeita e sem distorções em telas modernas.
* Padrões de Projéteis Trigonométricos (Bullet Hell): Inteligência Artificial dos inimigos calcula dinamicamente trajetórias complexas radiais e espirais usando funções de math.sin e math.cos.
* Física de Colisão Circular: Detecção precisa e justa baseada na distância euclidiana entre entidades (Teorema de Pitágoras com math.sqrt), evitando as falhas clássicas de hitboxes quadradas (AABB) para o gênero.
* Sistema de Loja e Inflação Dinâmica: Loop de jogabilidade fechado através de uma tela de upgrades (shop.lua), onde o jogador gerencia moedas coletadas para melhorar Blindagem, Reator e Propulsores, enfrentando um balanceamento de custo progressivo.
* Gerenciamento Eficiente de Áudio: Músicas de fundo (BGM) carregadas via Streaming para preservação de memória RAM e efeitos sonoros (SFX) do tipo Static para latência zero de resposta aos comandos.

  <img width="1385" height="774" alt="image" src="https://github.com/user-attachments/assets/2937b150-7db0-465b-9202-bb838a3d45ce" />

## 📁 Estrutura de Diretórios
- AEGIS_Redemption/
- ├── assets/         # Sprites, Fontes e Efeitos Sonoros
- ├── lib/            # Bibliotecas externas (ex: push.lua)
- ├── states/         # Gerenciamento de Telas (menu.lua, play.lua, shop.lua)
- ├── entities/       # Entidades físicas (player.lua, boss.lua, bullet.lua)
- ├── conf.lua        # Configurações de janela do LÖVE
- └── main.lua        # Ponto de entrada e Loop Principal

## 🎮 Como Jogar
Pré-requisitos: Certifique-se de ter o framework LÖVE (versão 11.x ou superior) instalado em seu sistema operacional. Download disponível em love2d.org.

Execução:

•	1. Faça o clone deste repositório:
git clone https://github.com/seu-usuario/aegis-redemption.git

•	2. Navegue até a pasta ou execute o LÖVE apontando para o diretório raiz do projeto:
love .

(Alternativamente, você pode arrastar e soltar a pasta do projeto diretamente sobre o executável do LÖVE).

<img width="1382" height="768" alt="image" src="https://github.com/user-attachments/assets/92943161-a50b-4520-907b-27fa6bed7a10" />

Controles:

-	Setas Direcionais / WASD: Movimentação do Tanque/Nave.
-	Espaço: Disparar tiros padrão.
-	Tecla F: Ativar o Disparo Especial de Alto Impacto (requer energia).
-	Tecla Esc / P: Pausar o jogo / Retornar ao Menu.
## 🛠️ Tecnologias Utilizadas
-	Linguagem: Lua
-	Framework: LÖVE 2D
-	Resolução: Biblioteca Push
-	Áudio e Gráficos: Carregamento dinâmico via API nativa love.audio e love.graphics
## 👥 Autores e Créditos
Projeto desenvolvido para fins acadêmicos.
- Luis Gustavo Martins - Programação, Arquitetura e Engenharia de Jogo - https://github.com/luisgomartins
- Luis Gustavo Martins - Design Gráfico e Padrões de Tiro
- Filipe Felix - Sonorização, GDD e solução de bugs de programação

Agradecimentos especiais ao professor José Tarcísio Franco, da disciplina de Multimídia.
 
