# Projeto Bootloader
Um jogo só que em Assembly.

# Como jogar

## Básico
- Existem cinco simbolos: `trac`, `grib`, `lott`, `fohg` e `bicc`
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
- `trac` ganha de `bicc` e `grib`, mas perde para `lott` e `fohg`
- `grib` ganha de `lott` e `bicc`, mas perde para `trac` e `fohg`
- `lott` ganha de `trac` e `fohg`, mas perde para `bicc` e `grib`
- `bicc` ganha de `fohg` e `lott`, mas perde para `grib` e `trac`
- `fohg` ganha de `grib` e `trac`, mas perde para `lott` e `bicc`

Além disso, a cor da carta influencia na pontuação:
- Cartas que atacarem uma carta de mesma cor perdem `1 ponto`
- Cartas que atacarem um rival ganham `1 ponto`. Rivais:
	- `azul` é rival de `vermelho`
	- `vermelho` é rival de `verde`
	- `verde` é rival de `azul`
- Cartas que atacarem outras cores se não as suas ou as rivais não perdem ou ganham pontos.

# Sobre
- `boot1.asm` inicia em `0x7c00` e carrega o setor de memória de boot2
- `boot2.asm` inicia em `0x500` e carrega o setor de memória do kernel mas antes disso apresenta algumas mensagens para alertar o usuario do que está acontecendo
- `kernel.asm` inicia em `0x7e00` e é onde o programa principal está armazenado
- Para compilar, veja o makefile

# Style
- Identação: `4 espaços`
- Espaço depois de toda virgula e ponto-e-virgula
- Uma linha em branco depois de cada função
- Funções e macros usam snake_case (não usar camelCase)
- Numeros hexadecimais são representados com `0x`, a não ser em caso de interrupção, onde devem ser representados por `h`
    - Ex: `org 0x7c00`
    - Ex: `int 10h`
- Comentários próximos devem estar alinhados
    - Ex:
```
xor si, si ; clear «s1»
xor bx, bx ; clear «bx»
cx, 1      ; set initial decimal place
```
- Comentar o que cada registrador configura antes de uma interrupção. O `ah` deve sempre ser o ultimo `mov` listado antes de uma interrupção
    - Ex: 
```	
; [int 10h 03h] read cursor and store in «dh», «dl»
xor bh, bh    ; [video page] - 0 
mov ah, 03h
int 10h
```
- Comentários sobre registradores dados como parâmetros por um macro devem estar anotados com MP
    - Ex:
```
%macro print_bloco 3
	; [int 10h 0ch] - printar pixel
	mov al, 0xa ; [cor]    - verde
	mov bh, 0   ; [pagina] - 0
	mov cx, %1  ; [coluna] - MP -> coluna inicial
	mov dx, %2  ; [linha]  - MP -> linha inicial
	mov ah, 0ch
	int 10h 
%endmacro
```