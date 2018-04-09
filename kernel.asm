org 0x7e00
jmp 0x0000:start

; constantes usadas por print_linha
VERTICAL equ 0
HORIZONTAL equ 1

%define sum(x,y) x + y
%define diff(x,y) x - y
%define mult(x,y) x * y
%define divd(x,y) x / y

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
    rect %1, %2, 72, 102, 0x0f
    rect_oco diff(%1, 2), diff(%2, 2), 76, 106, %3, 2
    rect_oco diff(%1, 3), diff(%2, 3), 78, 108, 0x0c, 1
%endmacro

; (x, y, color)
; card start x, y
%macro draw_glib 3
    rect sum(%1, 16), sum(%2, 28), 9, 50, %3
    rect sum(%1, 16), sum(%2, 69), 40, 9, %3
    rect_oco sum(%1, 16), sum(%2, 53), 25, 25, %3, 9
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

    ; carta
    ;rect 30, 30, 80, 110, 0x0f

    ; naipe cima
    ;rect 37, 35, 3, 12, 0x00 ; 30 + 10, 30 + 5
    ;rect_oco 37, 50, 12, 12, 0x0c, 2 ; 30 + 5, 30 + 20


    draw_card 70, 30, 0x01
    draw_glib 70, 30, 0x04
    ; naipe baixo
    ;rect 101, 123, 3, 12, 0x00  ; 90 + 10, 120-12-3
    ;rect_oco 92, 108, 12, 12, 0x0c, 2 ; (30 - 5) + 80 - 15, 

    ; (80/2 + 30) - 7, (110/2) + 30 - 7 | centro
    ;rect 63, 78, 14, 14, 0x0c

    ; outra

    ; carta
    ;rect_oco 28, 28, 76, 106, 0x09, 2
    ;rect 30, 30, 72, 102, 0x0f

    ;rect_center_all 66, 81, 9, 50, 0x0c
    ;rect_center_hor 66, 81, 50, 9, 0x0c
    ;rect_center_hor 66, 97, 40, 9, 0x0c
    ;rect 46, 65, 9, 35, 0x0c

    jmp halt

num_barras db 2
barra_start dw 0
tab_start dw 111

halt:
    jmp $
