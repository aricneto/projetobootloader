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

gridx dw 0
gridy dw 0

; (x, y)
%macro get_grid 2
    mov word [gridx], %1
    mov word [gridy], %2
    call calc_grid
%endmacro

calc_grid:
    cmp word [gridy], 0
    je .top
    cmp word [gridy], 1
    je .mid
    jmp .bot

    .top:
        mov word [gridy], 20
        imul 92, word [gridx]
        add word [gridx], 20
        jmp .end
    .mid:
        mov word [gridy], 190
        imul word [gridx], -92
        add word [gridx], 190
        jmp .end
    .bot:
        mov word [gridy], 300
        imul word [gridx], -92
        add word [gridx], 365
        jmp .end
    
    .end:
        ret
        

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
%macro rect 5
    mov cx, %1
    mov dx, %2
    mov ax, %3
    mov si, %4
    mov byte [color], %5
    call draw_barras
%endmacro

select_start dw 0
select_end dw 0

%macro draw_selection 3
    mov word [select_start], %1
    mov word [select_end], %2
    sub word [select_end], 3
    sub word [select_start], 3
    rect_oco word [select_start], word [select_end], sum(CARD_SIZE_X, 6), sum(CARD_SIZE_Y, 6), %3, 3
%endmacro

; (x, y, width, length, color, thickness)
; desenha um retângulo oco em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; e grossura «thickness»
%macro rect_oco 6
    ;horizontais
    rect %1, %2, %3, %6, %5 ; cima -> x, y, width, thickness, color
    add word [y_init], %4
    sub word [y_init], %6
    rect %1, word [y_init], %3, %6, %5 ; baixo -> x, length, width, thickness, color
    ;verticais
    rect %1, %2, %6, %4, %5 ; x, y, thickness, length, color
    add word [x_init], %3
    sub word [x_init], %6
    rect word [x_init], %2, %6, %4, %5 ; width, y, thickness, length, color
%endmacro

; (x, y, border_color)
%macro draw_card 3
    rect %1, %2, CARD_SIZE_X, CARD_SIZE_Y, 0x0f
    ;rect_oco diff(%1, 2), diff(%2, 2), sum(CARD_SIZE_X, 4), sum(CARD_SIZE_Y, 4), %3, 2
    ;rect_oco diff(%1, 3), diff(%2, 3), sum(CARD_SIZE_X, 6), sum(CARD_SIZE_Y, 6), 0x0c, 1
%endmacro

%macro add_x 1
    add word [x_init], %1
%endmacro

%macro sub_x 1
    sub word [x_init], %1
%endmacro

%macro add_y 1
    add word [y_init], %1
%endmacro

%macro sub_y 1
    sub word [y_init], %1
%endmacro

; (x, y, color)
; card start x, y
%macro draw_glib 3
    draw_card %1, %2, %3

    add_x 16
    add_y 28
    rect word [x_init], word [y_init], 9, 50, %3
    add_y 41    
    rect word [x_init], word [y_init], 40, 9, %3
    sub_y 20
    add_x 15
    rect word [x_init], word [y_init], 9, 25, %3
    
%endmacro

; (x, y, color)
; card start x, y
%macro draw_fohg 3
    draw_card %1, %2, %3

    add_x 11 ; x = 11
    add_y 51 ; y = 51
    rect word [x_init], word [y_init], 50, 9, %3
    add_x 5  ; x = 16
    add_y 16 ; y = 67
    rect word [x_init], word [y_init], 40, 9, %3
    sub_y 32 ; y = 35
    rect word [x_init], word [y_init], 9, 35, %3
    sub_y 5 ; y = 30
    add_x 15 ; x = 15
    rect word [x_init], word [y_init], 9, 50, %3
%endmacro

; (x, y, color)
; card start x, y
%macro draw_trac 3
    draw_card %1, %2, %3

    add_x 16 ; x = 16
    add_y 28 ; y = 28
    rect word [x_init], word [y_init], 9, 20, %3
    add_y 20 ; y = 48
    rect word [x_init], word [y_init], 40, 9, %3
    add_y 21 ; y = 69
    rect word [x_init], word [y_init], 22, 9, %3
    add_x 14 ; x = 30
    sub_y 21 ; y = 48
    rect word [x_init], word [y_init], 9, 30, %3
%endmacro

; (x, y, color)
; card start x, y
%macro draw_lott 3
    draw_card %1, %2, %3

    add_x 16 ; x = 16
    add_y 48 ; y = 48
    rect word [x_init], word [y_init], 40, 9, %3
    sub_y 20 ; y = 28
    rect word [x_init], word [y_init], 9, 50, %3
    add_x 16 ; x = 32
    add_y 20 ; y = 48
    rect word [x_init], word [y_init], 9, 30, %3
    add_x 4 ; x = 36
    add_y 21 ; y = 69
    rect word [x_init], word [y_init], 20, 9, %3
%endmacro

; (x, y, color)
; card start x, y
%macro draw_bicc 3
    draw_card %1, %2, %3

    add_x 16 ; x = 16
    add_y 62 ; y = 62
    rect word [x_init], word [y_init], 40, 9, %3
    add_x 5 ; x = 21
    sub_y 28 ; y = 34
    rect word [x_init], word [y_init], 30, 9, %3
    add_x 10 ; x = 31
    sub_y 14 ; y = 20
    rect word [x_init], word [y_init], 9, 60, %3
    add_x 16 ; x = 47
    add_y 30 ; y = 50
    rect word [x_init], word [y_init], 9, 15, %3
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
    mov word [x_coord], cx
    mov word [y_coord], dx
    mov word [width], ax
    mov word [length], si
    mov word [x_init], cx
    mov word [y_init], dx
    .draw:
        print_linha word [x_coord], word [y_coord], si, VERTICAL, byte [color]
        inc word [x_coord]
        dec word [width]
        cmp word [width], 0
        jg .draw
    ret

x_coord dw 0
y_coord dw 0
width dw 0
length dw 0

x_init dw 0
y_init dw 0

color db 0
size 	  dw 0
direction db 0

refresh_video:
    ; [int 10h 00h] - modo de video
    mov al, 13h ; [modo de video VGA]
    mov ah, 00h
    int 10h
    ret

kaka dw 10

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

    ;rect word [kaka], word [kaka], word [kaka], word [kaka], 0x0c
    ;draw_bicc word [kaka], gridy(0), 0x0c

    get_grid 2, 0
    draw_trac gridx, gridy, 0x0c

    ;draw_glib gridx_center(0), 190, 0x02    
    ;draw_fohg gridx_center(1), 190, 0x0c
    ;draw_bicc gridx_center(2), 190, 0x0c
;
    ;draw_lott gridx_bot(0), gridy_bot(3), 0x02
    ;draw_glib gridx_bot(1), gridy_bot(3), 0x09
    ;draw_fohg gridx_bot(2), gridy_bot(3), 0x0c

    jmp halt

num_barras db 2
barra_start dw 0
tab_start dw 111

halt:
    jmp $
