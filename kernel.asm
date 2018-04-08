org 0x7e00
jmp 0x0000:start

; constantes usadas por print_linha
VERTICAL equ 0
HORIZONTAL equ 1

%define sum(x,y) x + y
%define diff(x,y) x - y
%define mult(x,y) x * y

; (x, y, tamanho, direcao, cor)
; printa uma linha a partir da posicao («x», «y»)
; de tamanho «tamanho»
; na direcao «direcao»
; de cor «cor»
%macro print_linha 5
    ; [int 10h 0ch] - printar pixel
    mov al, %5     ; [cor]    - verde
    mov bh, 0      ; [pagina] - 0
    mov cx, %1     ; [coluna] - MP -> posiçao x da linha
    mov dx, %2     ; [linha]  - MP -> posicao y da linha
    mov word [size], %3 	 ; tamanho da linha
    mov byte [direction], %4 ; direcao da linha (VERTICAL ou HORIZONTAL)
    mov ah, 0ch
    int 10h
    call draw_linha
%endmacro

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
%macro print_retangulo 5
    mov word [x_coord], %1
    mov word [y_coord], %2
    mov word [width], %3
    mov si, %4
    mov byte [color], %5
    call draw_barras
%endmacro

; (x, y, width, length, color, thickness)
; desenha um retângulo oco em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; e grossura «thickness»
%macro print_retangulo_oco 6
    print_retangulo %1, %2, %3, %6, %5 ; x, y, width, thickness, color
    print_retangulo %1, sum(%2, %4), %3, %6, %5 ; x, length, width, thickness, color
    print_retangulo %1, %2, %6, %4, %5 ; x, y, thickness, length, color
    print_retangulo sum(%1, %3), %2, %6, sum(%4, 1), %5 ; width, y, thickness, length, color
%endmacro

draw_linha:    
    ; desenhar
    int 10h

    ; checar direçao a ser desenhada
    cmp byte [direction], VERTICAL
    je .vertical
    jmp .horizontal
    .vertical:
        inc dx
        jmp .continue
    .horizontal:
        inc cx

    .continue:
    ; size representa o numero total
    ; de pixels a ser printado
    dec word [size]	
    cmp word [size], 0
    jg draw_linha
    ret

draw_barras:
    print_linha word [x_coord], word [y_coord], si, VERTICAL, byte [color]
    inc word [x_coord]
    dec word [width]
    cmp word [width], 0
    jg draw_barras
    ret

x_coord dw 0
y_coord dw 0
width dw 0
color db 0
size 	  dw 0
direction db 0

refresh_video:
    ; [int 10h 00h] - modo de video
    mov al, 13h ; [modo de video VGA]
    mov ah, 00h
    int 10h
    ret

draw_arena:
    print_retangulo_oco 91, 170, 125, 10, 0x0b, 1

    print_retangulo 89, 0, 3, 200, 0x0e
    print_retangulo 214, 0, 3, 200, 0x0e

    mov byte [num_barras], 5
    .print_tabs:
        print_linha word [tab_start], 0, 200, VERTICAL, 0x0c
        add byte [tab_start], 21
        dec byte [num_barras]
        cmp byte [num_barras], 0
        jg .print_tabs
    ret

start:
    ; setup
    xor ax, ax    ; ax <- 0
    mov ds, ax    ; ds <- 0
    mov es, ax    ; es <- 0

    ; [int 10h 00h] - modo de video
    mov al, 12h ; [modo de video VGA 640x480 16 color graphics]
    mov ah, 00h 
    int 10h

    mov ah, 0xb
	mov bh, 0
	mov bl, 08h
	int 10h

    print_retangulo 30, 30, 80, 110, 0x0f
    print_retangulo 40, 35, 4, 12, 0x00
    print_retangulo 35, 50, 15, 15, 0x0c

    ;call draw_arena

    jmp halt

num_barras db 2
barra_start dw 0
tab_start dw 111

halt:
    jmp $
