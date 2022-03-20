;; Módulo de diagnóstico e inicialização de hardware para HBoot
;;
;; x86-Detect
;;
;; Copyright (C) 2022 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.

use16	


cabecalhoHBoot:

.assinatura:  db "HBOOT"       ;; Assinatura, 5 bytes
.arquitetura: db 01h           ;; Arquitetura (i386), 1 byte
.versaoMod:   db 01h           ;; Versão
.subverMod:   db 00h           ;; Subversão
.nomeMod:     db "x86Detec"    ;; Nome do módulo

;;************************************************************************************

inicioModulo:  

    push dx 

;; Primeiro devemos configurar e definir os registradores de segmento. O segmento é fornecido 
;; juntamente com CS, então devemos passar o valor do segmento para AX e então para DS e ES, que
;; não podem ser acessados diretamente em uma cópia a partir de CS.

    mov ax, cs           
    mov ds, ax           
    mov es, ax                                        

    mov si, x86.iniciando

    call imprimir ;; E solicitar a função de exibição para que a exiba na tela

    call verificarDiscos

    mov si, x86.terminar

    call imprimir ;; E solicitar a função de exibição para que a exiba na tela

    mov ax, 0

    int 16h 

;;************************************************************************************
;;
;; Funções de análise de dispositivo
;;
;;************************************************************************************

;;************************************************************************************

verificarDiscos:

    mov si, x86.identificandoDiscos

    call imprimir

    clc 

.dsq0:

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 00h 
 
    int 13h

    jc .errodsq0
 
    mov si, x86.dsq0
    
    call imprimir 

    jmp .dsq1
 
.errodsq0:

  jmp .dsq1
  
.dsq1:
  
    clc 

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 01h 
 
    int 13h
 
    jc .errodsq1
 
    mov si, x86.dsq1
    
    call imprimir 
 
    jmp .hd0
 
 .errodsq1:

    jmp .hd0
 
;;**************************************************************************

.hd0:

    clc 

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 80h 
 
    int 13h

    jc .errohd0
 
    mov si, x86.hd0
    
    call imprimir 
 
    jmp .hd1
 
 .errohd0:
  
    jmp .hd1
  
.hd1:

    clc
  
    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 81h 
 
    int 13h
 
    jc .errohd1
 
    mov si, x86.hd1
    
    call imprimir 
 
    jmp .fim
 
 .errohd1:

.fim:

    ret

;;************************************************************************************

;;************************************************************************************
;;
;; Funções úteis para a execução do módulo
;;
;;************************************************************************************

;; Função construída para exibir na saída de vídeo do usuário uma mensagem presente em SI e
;; retornar a função que a chamou

imprimir:

    lodsb		;; mov AL, [SI] & inc SI
    
    or al, al	;; cmp AL, 0
    jz .pronto
    
    mov ah, 0Eh
    
    int 10h     ;; Enviar [SI] para a tela
    
    jmp imprimir
    
.pronto: 

    ret

;;************************************************************************************

limparTela:                  

    pusha 

    mov dx, 0
    mov bh, 0
    mov ah, 2
    
    int 10h

    mov ah, 6
    mov al, 0
    mov cx, 0
    mov dh, 24
    mov dl, 79
    
    int 10h

    popa 

    ret

;;************************************************************************************

lerTeclado:  

    xor cl, cl

.loop:

    mov ah, 0
    
    int 16h

    cmp al, 0x08
    je .apagar

    cmp al, 0x0D
    je .pronto

    cmp cl, 0x3F
    je .loop

    mov ah, 0x0E
    
    int 10h

    stosb

    inc cl

    jmp .loop

.apagar:          ;; Apagar um caracter

    cmp cl, 0
    je .loop

    dec di
    
    mov byte [di], 0
    
    dec cl

    mov ah, 0x0E
    mov al, 0x08

    int 10h

    mov al, ' '

    int 10h

    mov al, 0x08
    
    int 10h

    jmp .loop

.pronto:          ;; Tarefa ou rotina concluida

    mov al, 0

    stosb

    mov ah, 0x0E
    mov al, 0x0D
    
    int 10h

    mov al, 0x0A
    int 10h

    ret

;;************************************************************************************

aguardarPressionamento:

    mov ax, 0

    int 16h

    ret

;;************************************************************************************

identificarTecla:

    mov     ah, 1

    int     16h

    jz      identificarTecla

    mov     ah, 0

    int     16h

    ret

;;************************************************************************************

paraMaiusculo: ;; Esta função requer um ponteiro para a string, em DS:SI

	pusha
	
	mov bx, 0xFFFF						;; Início em -1, dentro da String
	
paraMaiusculoLoop:	

	inc bx
	
    mov al, byte [ds:si+bx]				;; Em al, o caracter atual
	
	cmp al, 0							;; Caso no fim da String
	je paraMaiusculoPronto			;; Está tudo pronto
	
	cmp al, 'a'
	jb paraMaiusculoLoop              ;; Código ASCII muito baixo para ser minúsculo
	
	cmp al, 'z'
	ja paraMaiusculoLoop              ;; Código ASCII muito alto para ser minúsculo
	
	sub al, 'a'-'A'
	mov byte [ds:si+bx], al				;; Subtraia e transformar em maiúsculo
	
	jmp paraMaiusculoLoop             ;; Próximo caractere
	
paraMaiusculoPronto:	

	popa
	
	ret

;;************************************************************************************

VERSAO equ "0.0.1"

x86:

.terminar:            db 10, 13, "O x86-Detect terminou de fazer o diagnostico.", 13, 10, 0
.identificandoDiscos: db 10, 13, "Indentificando unidades de disco online: ", 0
.iniciando:           db 10, 13, 10, 13, "x86-Detect para HBoot versao ", VERSAO, 10, 13, 0
.dsq0:                db "dsq0", 0
.dsq1:                db "dsq1", 0
.hd0:                 db "hd0", 0
.hd1:                 db "hd1", 0
.espaco:              db " ", 0