org 0x7e00
jmp 0x0000:start

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
	mov bh, 0 	   ; [pagina] - 0
	mov cx, %1     ; [coluna] - MP -> posiçao x da linha
	mov dx, %2     ; [linha]  - MP -> posicao y da linha
	mov byte [size], %3 	 ; tamanho da linha
	mov byte [direction], %4 ; direcao da linha (VERTICAL ou HORIZONTAL)
	mov ah, 0ch
	int 10h
	call draw_linha
%endmacro

draw_linha:
	cmp byte [direction], VERTICAL
	je .vertical
	jmp .horizontal
	.vertical:
		inc dx
		jmp .draw
	.horizontal:
		inc cx
	
	.draw:
	int 10h

	dec byte [size]	
	cmp byte [size], 0
	jge draw_linha
	ret

size 	  db 0
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
	
	print_linha 30, 30, 50, HORIZONTAL, 0x0c
	print_linha 55, 5, 50, VERTICAL, 0x0d


	jmp halt

halt:
	jmp $

times 510 - ($ - $$) db 0
dw 0xaa55
