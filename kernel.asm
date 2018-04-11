org 0x7e00
jmp 0x0000:start

; constantes
VERTICAL equ 0
HORIZONTAL equ 1
CARD_SIZE_X equ 72
CARD_SIZE_Y equ 102

; cada carta ocupa 5 bits
; cartas
TRAC equ 0 ; 000|00-000
GLIB equ 1 ; 000|00-001
LOTT equ 2 ; 000|00-010
FOHG equ 3 ; 000|00-011
BICC equ 4 ; 000|00-100
; cores
RED  equ 0x0c ; 000|00-000
GRN  equ 0x02 ; 000|01-000
BLU  equ 0x09 ; 000|10-000

MASK_GLYPH equ 0b00000111 ; AND mask para encontrar o tipo da carta

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
; calcula a grade para posicionamento
; das cartas, guarda em «ax», «bx»
%macro get_grid 2
    push ax
    push bx
    mov ax, %1
    mov bx, %2
    call calc_grid
%endmacro

calc_grid:
    cmp bx, 0
    je .top
    cmp bx, 1
    je .mid
    jmp .bot

    .top:
        mov bx, 20
        imul ax, 92
        add ax, 20
        jmp .end
    .mid:
        mov bx, 190
        imul ax, 92
        add ax, 190
        jmp .end
    .bot:
        mov bx, 356
        imul ax, 92
        add ax, 360
        jmp .end
    
    .end:
        mov word [gridx], ax
        mov word [gridy], bx
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

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor pré-definida pela variavel «byte color_var»
%macro rect_color_var 4
    mov cl, byte [color_var]
    mov byte [color], cl
    mov cx, %1
    mov dx, %2
    mov ax, %3
    mov si, %4
    call draw_barras
%endmacro

select_start dw 0
select_end dw 0

; (gridx, griy, color)
; de cor pré-definida pela variavel «byte color_var»
%macro draw_selection 2
    get_grid %1, %2
    sub ax, 6
    sub bx, 6
    mov word [select_start], ax
    mov word [select_end], bx
    rect_oco word [select_start], word [select_end], CARD_SIZE_X + 12, CARD_SIZE_Y + 12, %3, 3
    pop bx
    pop ax
%endmacro

; (x, y, width, length, color, thickness)
; desenha um retângulo oco em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
; e grossura «thickness»
%macro rect_oco 6
    ;horizontais
    rect_color_var %1, %2, %3, %6 ; cima -> x, y, width, thickness, color
    add word [y_init], %4
    sub word [y_init], %6
    rect_color_var %1, word [y_init], %3, %6 ; baixo -> x, length, width, thickness, color
    ;verticais
    rect_color_var %1, %2, %6, %4 ; x, y, thickness, length, color
    add word [x_init], %3
    sub word [x_init], %6
    rect_color_var word [x_init], %2, %6, %4 ; width, y, thickness, length, color
%endmacro

x_init_sp dw 0
y_init_sp dw 0

; (x, y)
%macro draw_card 2
    get_grid %1, %2
    rect ax, bx, CARD_SIZE_X, CARD_SIZE_Y, 0x0f
    pop bx
    pop ax
%endmacro

; (x, y)
%macro erase_card 2
    get_grid %1, %2
    rect ax, bx, CARD_SIZE_X, CARD_SIZE_Y, 0x00
    pop bx
    pop ax
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
    draw_card %1, %2

    add_x 16
    add_y 28
    rect_color_var word [x_init], word [y_init], 9, 50
    add_y 41    
    rect_color_var word [x_init], word [y_init], 40, 9
    sub_y 20
    add_x 15
    rect_color_var word [x_init], word [y_init], 9, 25
%endmacro

; (x, y, color)
; card start x, y
%macro draw_fohg 3
    draw_card %1, %2

    add_x 29 ; x = 11
    add_y 51 ; y = 51
    rect_color_var word [x_init], word [y_init], 30, 9
    sub_x 15  ; x = 16
    sub_y 16 ; y = 35
    rect_color_var word [x_init], word [y_init], 9, 35
    sub_y 5 ; y = 30
    add_x 15 ; x = 15
    rect_color_var word [x_init], word [y_init], 9, 50
%endmacro

; (x, y, color)
; card start x, y
%macro draw_trac 3
    draw_card %1, %2

    add_x 16 ; x = 16
    add_y 28 ; y = 28
    rect_color_var word [x_init], word [y_init], 9, 20
    add_y 20 ; y = 48
    rect_color_var word [x_init], word [y_init], 40, 9
    add_x 14 ; x = 30
    rect_color_var word [x_init], word [y_init], 9, 30
%endmacro

; (x, y, color)
; card start x, y
%macro draw_lott 3
    draw_card %1, %2

    add_x 16 ; x = 16
    add_y 48 ; y = 48
    rect_color_var word [x_init], word [y_init], 40, 9
    sub_y 20 ; y = 28
    rect_color_var word [x_init], word [y_init], 9, 50
    add_x 20 ; x = 32
    add_y 41 ; y = 48
    rect_color_var word [x_init], word [y_init], 20, 9
%endmacro

; (x, y, color)
; card start x, y
%macro draw_bicc 3
    draw_card %1, %2

    add_x 16 ; x = 16
    add_y 72 ; y = 62
    rect_color_var word [x_init], word [y_init], 40, 9
    add_x 15 ; x = 31
    sub_y 42 ; y = 20
    rect_color_var word [x_init], word [y_init], 9, 45
    add_x 16 ; x = 47
    add_y 30 ; y = 50
    rect_color_var word [x_init], word [y_init], 9, 15
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
color_var db 0

color_value db 0 ; usado para salvar a carta escolhida

size 	  dw 0
direction db 0

%macro random 1
    mov word [modulo], %1
    call rand
%endmacro

; rand é salvo em «dl»
rand:
    mov ah, 00h  ; interrupts to get system time
    int 1ah      ; CX:DX now hold number of clock ticks since midnight
    mov ax, dx
    xor dx, dx
    mov cx, word [modulo]
    div cx
    mov cx, 1
    ret

modulo dw 0

; gera uma cor aleatoria e carrega em «color»
random_color:
    random 3

    cmp dl, 0
    je .red
    cmp dl, 1
    je .green
    jmp .blue
    
    .red:
        mov byte [color_var], 0x0c
        ret
    .green:
        mov byte [color_var], 0x02
        ret
    .blue:
        mov byte [color_var], 0x09
        ret

refresh_video:
    ; [int 10h 00h] - modo de video
    mov al, 13h ; [modo de video VGA]
    mov ah, 00h
    int 10h
    ret

clear_selection:
    push word [color_var]
    mov word [color_var], 0x00
    draw_selection word [p_selection], word [p_number]
    pop word [color_var]
    ret

game_loop:

    .read:
        ; [int 16h 00h] - ler teclado
        mov ah, 00h
        int 16h ; salva tecla em «ah, al»
        cmp ah, 4bh ; seta esquerda
        je .left
        cmp ah, 4dh ; seta direita
        je .right
        cmp al, 0dh ; enter
        je .select_card
        jmp game_loop

        .left:
            call clear_selection
            dec word [p_selection]
            cmp word [p_selection], 0
            jge .draw
            mov word [p_selection], 2
            jmp .draw          

        .right:
            call clear_selection
            inc word [p_selection]
            cmp word [p_selection], 2
            jle .draw
            mov word [p_selection], 0
            jmp .draw

        .select_card:
            call clear_selection
            draw_bicc word [p_number], 1, 0
            erase_card word [p_selection], word [p_number]
            cmp word [p_number], 2
            je .p_one
            jmp .p_two
            .p_one:
                mov word [p_number], 0
                mov word [color_var], RED
                jmp .draw
            .p_two:
                mov word [p_number], 2
                mov word [color_var], BLU
                jmp .draw
        
        .draw: ; posicao da carta coluna, na linha tal que é dada por p_number
            draw_selection word [p_selection], word [p_number]

        jmp game_loop

; carta selecionada pelo player
p_selection dw 0
; numero do jogador atual (0 ou 2)
p_number dw 0

cards_player dd 0
cards_dealt db 0

current_x dw 0
current_y dw 0
max_cards dw 0

; (current x, current y, num_cartas, cor)
; colocar cartas aleatorias na mesa
; começando da posicao «x», «y»
; até «num_cartas»
; de cor «cor»
%macro lay_cards 4
    mov word [current_x], %1
    mov word [current_y], %2
    mov word [max_cards], %3
    mov word [color_var], %4
    call play_cards
%endmacro

%macro save_card 1
    or dword [cards_player], %1
    call record_card
%endmacro

record_card:
    inc byte [cards_dealt]
    shl dword [cards_player], 3
    ret

play_cards:
    .play:
        random 5

        cmp dl, 0
        je .trac

        cmp dl, 1
        je .glib

        cmp dl, 2
        je .lott
        
        cmp dl, 3
        je .fohg

        cmp dl, 4
        je .bicc

        .trac:
            save_card TRAC
            draw_trac word [current_x], word [current_y], 0
            jmp .next
        .glib:
            save_card GLIB
            draw_glib word [current_x], word [current_y], 0 
            jmp .next
        .lott:
            save_card LOTT
            draw_lott word [current_x], word [current_y], 0 
            jmp .next
        .fohg:
            save_card FOHG
            draw_fohg word [current_x], word [current_y], 0 
            jmp .next
        .bicc:
            save_card BICC
            draw_bicc word [current_x], word [current_y], 0 
            jmp .next

        .next:
            mov dx, word [max_cards]
            inc word [current_x]
            cmp word [current_x], dx ; 3 cartas para cada jogador
            jl .play
            jmp .finish

        .finish:
            shr dword [cards_player], 3 ; ultimos 3 bits nao sao usados
            ret


current_card db 0

start:
    ; setup
    xor ax, ax    ; ax <- 0
    mov ds, ax    ; ds <- 0
    mov es, ax    ; es <- 0
    mov ds, ax    ; ds <- 0

    ; [int 10h 00h] - modo de video
    mov al, 12h ; [modo de video VGA 640x480 16 color graphics]
    mov ah, 00h 
    int 10h

    ; [int 10h 0bh] - atributos de video
	mov bh, 0
	mov bl, 08h ; cor da tela
    mov ah, 0bh
	int 10h

    lay_cards 0, 0, 3, RED
    lay_cards 0, 2, 3, BLU
    lay_cards 1, 1, 1, GRN

    ; printar o numero da ultima carta
    mov ah, 09h
    mov al, byte [cards_player]
    and al, MASK_GLYPH
    add al, '0'
    mov bh, 0
    mov bl, 0x0c
    mov cx, 1
    int 10h

    mov word [p_number], 2 ; o jogador a ir primeiro
    mov word [color_var], BLU ; a cor do seletor é dada pela variavel «color_var»
    draw_selection 0, 2 ; seletor na linha 2, posição 0
    call game_loop

    jmp halt

halt:
    jmp $
