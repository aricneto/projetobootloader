org 0x7e00
jmp 0x0000:start

%define sum(x,y) x + y
%define diff(x,y) x - y
%define mult(x,y) x * y
%define divd(x,y) x / y

; constantes
VERTICAL equ 0
HORIZONTAL equ 1
CARD_SIZE_X equ 72
CARD_SIZE_Y equ 102
HALF_CARD_SIZE_X equ divd(CARD_SIZE_X, 2)
HALF_CARD_SIZE_Y equ divd(CARD_SIZE_Y, 2)

%define gridx(x) sum(20, sum(mult(20, x), mult(CARD_SIZE_X, x)))
%define gridy(y) sum(20, sum(mult(20, y), mult(CARD_SIZE_Y, y)))

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
%macro rect 5
    mov word [x_coord], %1
    mov word [y_coord], %2
    mov word [width], %3
    mov si, %4
    mov byte [color], %5
    call draw_barras
%endmacro

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; do centro pra fora (todas as direçoes)
%macro rect_center_all 5
    rect diff(%1, divd(%3, 2)), diff(%2, divd(%4, 2)), %3, %4, %5
%endmacro

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; do centro pra fora horizontal
%macro rect_center_hor 5
    rect diff(%1, divd(%3, 2)), %2, %3, %4, %5
%endmacro

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; do centro pra fora vertical
%macro rect_center_ver 5
    rect %1, diff(%2, divd(%4, 2)), %3, %4, %5
%endmacro

; (x, y, width, length, color, thickness)
; desenha um retângulo oco em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; e grossura «thickness»
%macro rect_oco 6
    ;horizontais
    rect %1, %2, %3, %6, %5 ; cima -> x, y, width, thickness, color
    rect %1, diff(sum(%2, %4), %6), %3, %6, %5 ; baixo -> x, length, width, thickness, color
    ;verticais
    rect %1, %2, %6, %4, %5 ; x, y, thickness, length, color
    rect diff(sum(%1, %3), %6), %2, %6, %4, %5 ; width, y, thickness, length, color
%endmacro

; (x, y, border_color)
%macro draw_card 3
    rect %1, %2, CARD_SIZE_X, CARD_SIZE_Y, 0x0f
    rect_oco diff(%1, 2), diff(%2, 2), sum(CARD_SIZE_X, 4), sum(CARD_SIZE_Y, 4), %3, 2
    rect_oco diff(%1, 3), diff(%2, 3), sum(CARD_SIZE_X, 6), sum(CARD_SIZE_Y, 6), 0x0c, 1
%endmacro

; (x, y, color)
; card start x, y
%macro draw_glib 3
    draw_card %1, %2, %3
    rect sum(%1, 16), sum(%2, 28), 9, 50, %3
    rect sum(%1, 16), sum(%2, 69), 40, 9, %3
    rect_oco sum(%1, 16), sum(%2, 53), 25, 25, %3, 9
%endmacro

; (x, y, color)
; card start x, y
%macro draw_fohg 3
    draw_card %1, %2, %3
    rect_center_all sum(%1, HALF_CARD_SIZE_X), sum(%2, HALF_CARD_SIZE_Y), 9, 50, %3
    rect_center_hor sum(%1, HALF_CARD_SIZE_X), sum(%2, HALF_CARD_SIZE_Y), 50, 9, %3
    rect_center_hor sum(%1, HALF_CARD_SIZE_X), sum(%2, 67), 40, 9, %3
    rect sum(%1, 16), sum(%2, 35), 9, 35, %3
%endmacro

; (x, y, color)
; card start x, y
%macro draw_trac 3
    draw_card %1, %2, %3
    rect_center_hor sum(%1, HALF_CARD_SIZE_X), sum(%2, 48), 9, 30, %3
    rect sum(%1, 16), sum(%2, 48), 40, 9, %3
    rect sum(%1, 16), sum(%2, 28), 9, 20, %3
    rect sum(%1, 16), sum(%2, 69), 22, 9, %3
%endmacro

; (x, y, color)
; card start x, y
%macro draw_lott 3
    draw_card %1, %2, %3
    rect_center_hor sum(%1, HALF_CARD_SIZE_X), sum(%2, 48), 9, 30, %3
    rect sum(%1, 16), sum(%2, 48), 40, 9, %3
    rect sum(%1, 16), sum(%2, 28), 9, 50, %3
    rect sum(%1, HALF_CARD_SIZE_X), sum(%2, 69), 20, 9, %3
%endmacro

; (x, y, color)
; card start x, y
%macro draw_bicc 3
    draw_card %1, %2, %3
    rect_center_all sum(%1, HALF_CARD_SIZE_X), sum(%2, HALF_CARD_SIZE_Y), 9, 60, %3
    rect_center_hor sum(%1, HALF_CARD_SIZE_X), sum(%2, 34), 30, 9, %3
    rect_center_hor sum(%1, HALF_CARD_SIZE_X), sum(%2, 62), 40, 9, %3
    rect sum(%1, 47), sum(%2, 50), 9, 15, %3
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

    ;draw_card 10, 10, 0x01
    ;draw_bicc gridx(0), gridy(0), 0x04
    draw_card gridx(0), gridy(0), 0x04    
    draw_card gridx(1), gridy(0), 0x04
    draw_card gridx(2), gridy(0), 0x04
    draw_card gridx(3), gridy(0), 0x04
    draw_card gridx(0), gridy(1), 0x04
    draw_card gridx(1), gridy(1), 0x04
    draw_card gridx(2), gridy(1), 0x04
    draw_card gridx(3), gridy(1), 0x04
    draw_card gridx(0), gridy(2), 0x04
    draw_card gridx(1), gridy(2), 0x04
    draw_card gridx(2), gridy(2), 0x04
    draw_card gridx(3), gridy(2), 0x04
    ;draw_lott gridx(3), gridy(1), 0x04
    ;draw_lott gridx(3), gridy(2), 0x04

    ;draw_lott gridx(4), gridy(3), 0x04    

    jmp halt

num_barras db 2
barra_start dw 0
tab_start dw 111

halt:
    jmp $
