org 0x7e00
jmp 0x0000:start

; constantes usadas por print_linha
VERTICAL equ 0
HORIZONTAL equ 1

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
    
    ; TODO: TRANSFORMAR TUDO ISSO AQUI EM UM LOOP!!!!
    print_linha 89,  0, 200, VERTICAL, 0x0e
    print_linha 90,  0, 200, VERTICAL, 0x0e
    print_linha 216, 0, 200, VERTICAL, 0x0e
    print_linha 217, 0, 200, VERTICAL, 0x0e
    print_linha 218, 0, 200, VERTICAL, 0x0e

    print_linha 111, 0, 200, VERTICAL, 0x05
    print_linha 133, 0, 200, VERTICAL, 0x05
    print_linha 154, 0, 200, VERTICAL, 0x05
    print_linha 175, 0, 200, VERTICAL, 0x05
    print_linha 196, 0, 200, VERTICAL, 0x05

    print_linha 91, 170, 123, HORIZONTAL, 0x02
    print_linha 91, 180, 123, HORIZONTAL, 0x02
    ; TODO: TRANSFORMAR /\ EM UM LOOP!!!!!!!


    jmp halt

halt:
    jmp $
