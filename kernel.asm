org 0x7e00
jmp 0x0000:start

; constantes
VERTICAL equ 0
HORIZONTAL equ 1
CARD_SIZE_X equ 72
CARD_SIZE_Y equ 102

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
        imul ax, -92
        add ax, 375
        jmp .end
    .bot:
        mov bx, 355
        imul ax, -92
        add ax, 545
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

%macro draw_selection 3
    get_grid %1, %2
    sub ax, 3
    sub bx, 3
    mov word [select_start], ax
    mov word [select_end], bx
    rect_oco word [select_start], word [select_end], CARD_SIZE_X + 6, CARD_SIZE_Y + 6, %3, 3
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

; (x, y)
%macro draw_card 2
    get_grid %1, %2
    rect ax, bx, CARD_SIZE_X, CARD_SIZE_Y, 0x0f
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

    add_x 11 ; x = 11
    add_y 51 ; y = 51
    rect_color_var word [x_init], word [y_init], 50, 9
    add_x 5  ; x = 16
    add_y 16 ; y = 67
    rect_color_var word [x_init], word [y_init], 40, 9
    sub_y 32 ; y = 35
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
    add_y 21 ; y = 69
    rect_color_var word [x_init], word [y_init], 22, 9
    add_x 14 ; x = 30
    sub_y 21 ; y = 48
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
    add_x 16 ; x = 32
    add_y 20 ; y = 48
    rect_color_var word [x_init], word [y_init], 9, 30
    add_x 4 ; x = 36
    add_y 21 ; y = 69
    rect_color_var word [x_init], word [y_init], 20, 9
%endmacro

; (x, y, color)
; card start x, y
%macro draw_bicc 3
    draw_card %1, %2

    add_x 16 ; x = 16
    add_y 62 ; y = 62
    rect_color_var word [x_init], word [y_init], 40, 9
    add_x 5 ; x = 21
    sub_y 28 ; y = 34
    rect_color_var word [x_init], word [y_init], 30, 9
    add_x 10 ; x = 31
    sub_y 14 ; y = 20
    rect_color_var word [x_init], word [y_init], 9, 60
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
    draw_selection word [p_selection], word [p_number], 0x00
    ret

game_loop:

    .read:
        ; [int 16h 00h] - ler teclado
        mov ah, 00h
        int 16h ; salva tecla em «ah»
        cmp ah, 4bh ; seta esquerda
        je .left
        cmp ah, 4dh ; seta direita
        je .right
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
        
        .draw:
            draw_selection word [p_selection], word [p_number], 0x09

        jmp game_loop

; carta selecionada pelo player
p_selection dw 0
; numero do jogador atual (0 ou 2)
p_number dw 0

current_x dw 0
current_y dw 0

play_cards:
    mov byte [current_x], 0
    .play:
        call random_color
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
            draw_trac word [current_x], word [current_y], 0 
            jmp .next
        .glib:
            draw_glib word [current_x], word [current_y], 0 
            jmp .next
        .lott:
            draw_lott word [current_x], word [current_y], 0 
            jmp .next
        .fohg:
            draw_fohg word [current_x], word [current_y], 0 
            jmp .next
        .bicc:
            draw_bicc word [current_x], word [current_y], 0 
            jmp .next

        .next:
            inc byte [current_x]
            cmp byte [current_x], 4 ; 3 cartas para cada jogador
            jl .play
            jmp .finish

        .finish:
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

    call play_cards
    mov byte [current_y], 2
    call play_cards
    ;draw_trac 0, 0, 0x0c
    ;draw_glib 1, 0, 0x0c
    ;draw_fohg 2, 0, 0x0c
    ;
    ;draw_trac 0, 1, 0x0c
    ;draw_lott 1, 1, 0x0c
    ;draw_trac 2, 1, 0x0c
;
    ;draw_glib 0, 2, 0x0c
    ;draw_fohg 1, 2, 0x0c
    ;draw_fohg 2, 2, 0x0c

    call game_loop

    jmp halt

cards_player_1 db 0b00110011, 0b00110011, 0b00110011

halt:
    jmp $
