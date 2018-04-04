org 0x7e00
jmp 0x0000:start

green:
	mov bl,0010b
	ret
red:
	mov bl,0100b
	ret
amarelo:
	mov bl,1110b
	ret
azul:
	mov bl,0001b
	ret
magenta:
	mov bl,0101b
	ret
ciano:
	mov bl,0111b
	ret
escolheCor:
	cmp al,103
	je green
	cmp al,'r'
	je red
	cmp al,'y'
	je amarelo
	cmp al,'b'
	je azul
	cmp al,'m'
	ret
print:
  mov ah,0xe
  mov bh,0
  mov bl,0xf
  int 10h
  ret
;trapezio:
	;call quadrado
	;call triangulo
	;ret
video:
	;set video mode

	mov ah, 00h
	mov al, 13h
	int 10h
	call ler
	call escolheCor
	call ler
	cmp al,'q'
	je quadrado
	cmp al,'t'
	je triangulo
	cmp al,'e'
	je trapezio
	ret
quaPixels:
	add cx,110
	add dx,50
	mov ah, 0ch
	mov bh, 0
	mov al,bl

	int 10h
	sub cx,110
	sub dx,50
	ret
quadrado:
	mov cx,100
	mov dx,1
	while2:
		mov cx,100
		while:
			call quaPixels
		loop while
		inc dx
		cmp dx,100
		jne while2
	ret
ler:
  mov ah,0x0
  int 16h
  ret
	trapezio:
		mov cx,300
		mov dx,100
		while4:
			mov cx,dx
			add cx,100
			while3:
				call quaPixels
			loop while3
			sub cx,100
			dec dx
			cmp dx,1
		jne while4
		ret
		ret
		triangulo:
			mov cx,300
			mov dx,100
			while6:
				mov cx,dx
				while5:
					call quaPixels
				loop while5
				dec dx
				cmp dx,1
			jne while6
			ret
			ret
start:
    xor ax, ax    ;zera ax, xor é mais rápido que mov
    mov ds, ax    ;zera ds (não pode ser zerado diretamente)
    mov es, ax    ;zera es

		call video

    jmp $         ;$ = linha atual
done:
	jmp $
times 510 - ($ - $$) db 0
dw 0xaa55
