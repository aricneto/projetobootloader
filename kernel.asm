org 0x7e00
jmp 0x0000:start
bloco: ;que tem a cor verde limão
	;mov dx,0
	while2:
		mov dx,0
		while:
			inc dx
			add cx,100
			call pixel
			sub cx,100
			cmp dx,40
		jne while
		inc cx
		cmp cx,40
	jne while2
	mov cx,0
ret
pixel:    ;printa o pixel na posição x = dx!Y= cx
	mov ah, 0ch
	mov bh, 0
	mov al,0ah ;mudar a cor
	int 10h
	ret
move:
	add cx,10
	mov dx,cx
	add dx,10
	call bloco
	call atualizaVideo
	ret
atualizaVideo:
	mov ah, 00h
	mov al, 13h
	int 10h
	ret
start:
    xor ax, ax    ;zera ax, xor é mais rápido que mov
    mov ds, ax    ;zera ds (não pode ser zerado diretamente)
    mov es, ax    ;zera es
		mov ah, 00h
		mov al, 13h
		int 10h
		;call move
		call bloco
	  jmp $         ;$ = linha atual
done:
	jmp $
times 510 - ($ - $$) db 0
dw 0xaa55
