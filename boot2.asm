org 0x500
jmp 0x0000:start

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ah, 0xb
    mov bh, 0
    mov bl, 4
    int 10h
    jmp load_menu
load_menu:
;Setando a posição do disco onde kernel.asm foi armazenado(ES:BX = [0x7E00:0x0])
    mov ax, 0x7E0	;0x7E0<<1 + 0 = 0x7E00
    mov es,ax
    xor bx,bx		;Zerando o offset

;Setando a posição da RAM onde o menu será lido
    mov ah, 0x02	;comando de ler setor do disco
    mov al, 4		;quantidade de blocos ocupados pelo menu
    mov dl, 0		;drive floppy

;Usaremos as seguintes posições na memoria:
    mov ch, 0		;trilha 0
    mov cl, 3		;setor 3
    mov dh, 0		;cabeca 0
    int 13h
    jc load_menu	;em caso de erro, tenta de novo

break:
    jmp 0x7e00		;Pula para a posição carregada

times 510-($-$$) db 0
dw 0xaa55
