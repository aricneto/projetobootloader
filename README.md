# Projeto Bootloader
Tipo um Guitar Hero só que em Assembly.

# Sobre
- `boot1.asm` inicia em `0x7c00` e carrega o setor de memória de boot2
- `boot2.asm` inicia em `0x500` e carrega o setor de memória do kernel mas antes disso apresenta algumas mensagens para alertar o usuario do que está acontecendo
- `kernel.asm` inicia em `0x7e00` e é onde o programa principal está armazenado
- Para compilar, veja o makefile
- Todos tem 512 bytes de memória disponível

# Style
- Identação: `4 espaços`
- Espaço depois de toda virgula e ponto-e-virgula
- Numeros hexadecimais são representados com `0x`, a não ser em caso de interrupção, onde devem ser representados por `h`
    - Ex: `org 0x7c00`
    - Ex: `int 10h`
- Comentários próximos devem estar alinhados
    - Ex:
```
xor si, si ; clear «s1»
xor bx, bx ; clear «bx»
cx, 1      ; set initial decimal place
```
- Comentar o que cada registrador configura antes de uma interrupção
    - Ex: 
```	
; [int 10h 0x03] - read cursor and store in «dh», «dl»
xor bh, bh    ; [video page] «bh» <- 0 
mov ah, 0x03
int 10h
```