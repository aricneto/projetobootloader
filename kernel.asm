org 0x7e00
jmp 0x0000:start

; constantes usadas por print_linha
VERTICAL equ 0
HORIZONTAL equ 1

%define sum(x,y) x + y
%define subt(x,y) x - y
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

draw_linha:
    ; checar direçao a ser desenhada
    cmp byte [direction], VERTICAL
    je .vertical
    jmp .horizontal
    .vertical:
        inc dx
        jmp .draw
    .horizontal:
        inc cx
    
    ; desenhar
    .draw:
    int 10h

    ; size representa o numero total
    ; de pixels a ser printado
    dec word [size]	
    cmp word [size], 0
    jge draw_linha
    ret

size 	  dw 0
direction db 0

; (x, y, width, length, color)
; imprime uma barra vertical começando em «start»
; e indo até («start» + «width», start + «length») 
; com cor «color»
%macro print_retangulo 5
    mov word [x_coord], %1
    mov word [y_coord], %2
    mov word [width], %3
    mov si, %4
    mov byte [color], %5
    call draw_barras
%endmacro

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

%macro print_retangulo_oco 6
    print_retangulo %1, %2, %3, %4, %5
    print_retangulo sum(%1, %6), sum(%2, %6), subt(%3, mult(%6, 2)), subt(%4, mult(%6, 2)), 0x00
%endmacro

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
    mov al, 13h ; [modo de video VGA]
    mov ah, 00h 
    int 10h
    
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


    jmp halt

num_barras db 2
barra_start dw 0
tab_start dw 111

halt:
    jmp $
