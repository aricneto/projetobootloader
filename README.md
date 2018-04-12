# Projeto Bootloader
Um jogo só que em Assembly.

# Como jogar

## Básico
- Existem cinco simbolos: `trac`, `glib`, `lott`, `fohg` e `bicc`
- E três cores: `azul`, `vermelho` e `verde`
- No começo do jogo, o sistema escolhe uma carta para aperecer no centro
	- O jogador 1 deve escolher uma carta para atacar a do centro
	- O jogador 2 então escolhe uma carta para atacar a do centro
	- As cartas de cada jogador são reveladas.
	- O jogador 1 deve agora escolher uma carta para atacar a do jogador 2
	- O jogador 2 então escolhe uma carta para atacar a do jogador 1
	- Assim, ganha quem tiver mais pontos

## Pontuação
A pontuação é dada como um jogo de pedra-papel-tesoura, com algumas peculiaridades. Uma vitória equivale a `+2 pontos`, uma derrota a `-1 ponto`:
- `trac` ganha de `bicc` e `glib`, mas perde para `lott` e `fohg`
- `glib` ganha de `lott` e `bicc`, mas perde para `trac` e `fohg`
- `lott` ganha de `trac` e `fohg`, mas perde para `bicc` e `glib`
- `bicc` ganha de `fohg` e `lott`, mas perde para `glib` e `trac`
- `fohg` ganha de `glib` e `trac`, mas perde para `lott` e `bicc`

# Sobre
- `boot1.asm` inicia em `0x7c00` e carrega o setor de memória de boot2
- `boot2.asm` inicia em `0x500` e carrega o setor de memória do kernel mas antes disso apresenta algumas mensagens para alertar o usuario do que está acontecendo
- `kernel.asm` inicia em `0x7e00` e é onde o programa principal está armazenado
- Para compilar, `make all`

# Style
- Identação: `4 espaços`
- Espaço depois de toda virgula e ponto-e-virgula
- Uma linha em branco depois de cada função
- Funções e macros usam snake_case (não usar camelCase)
- Numeros hexadecimais são representados com `0x`, a não ser em caso de interrupção, onde devem ser representados por `h`
    - Ex: `org 0x7c00`
    - Ex: `int 10h`