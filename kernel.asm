org 0x7e00
jmp 0x0000:start

; constantes usadas por print_linha
VERTICAL equ 0
HORIZONTAL equ 1

%define addy(x,y) x + y

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

; (x, y, length, width)
; imprime uma barra vertical começando em «start»
; e indo até («start» + «width», start + «length») 
%macro print_barras 4
    mov word [x_coord], %1
    mov word [y_coord], %2
    mov word [xs], %3
    mov word [width], %4
    call draw_barras
%endmacro

draw_barras:
    print_linha word [x_coord], word [y_coord], xs, VERTICAL, 0x0e
    inc word [x_coord]
    dec word [width]
    cmp word [width], 0
    jg draw_barras
    ret

x_coord dw 0
y_coord dw 0
width dw 0
xs dw 0

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
    

    print_barras 89, 100, 50, 100
    ;print_linha 89, 10, 20, VERTICAL, 0x0e
    ;print_barras 210, 2

    ;mov byte [num_barras], 5
    ;.print_tabs:
    ;    print_linha word [tab_start], 0, 200, VERTICAL, 0x05
    ;    add byte [tab_start], 21
    ;    dec byte [num_barras]
    ;    cmp byte [num_barras], 0
    ;    jg .print_tabs
;
    ;print_linha 91, 170, 123, HORIZONTAL, 0x02
    ;print_linha 91, 180, 123, HORIZONTAL, 0x02
    ; TODO: TRANSFORMAR /\ EM UM LOOP!!!!!!!


    jmp halt

num_barras db 2
barra_start dw 0
tab_start dw 111

halt:
    jmp $
