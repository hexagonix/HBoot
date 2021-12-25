;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2016-2022 Felipe Miguel Nery Lunkes
;; │┌─┐││─┼┼┼┤┌┐│┌┐│┌┐│┌┐┼┼┼┼┘          Todos os direitos reservados
;; ││ │││─┼┼┼┤┌┐│└┘│└┘││││├┼┼┐
;; └┘ └┴──┴┘└┴┘└┴─┐├──┴┘└┴┴┘└┘
;;              ┌─┘│          
;;              └──┘          
;;
;;
;;************************************************************************************
;;    
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;           
;;                 Copyright © 2020-2022 Felipe Miguel Nery Lunkes
;;                         Todos os direitos reservados
;;                                  
;;************************************************************************************

;; Função para limpar a tela em modo real

limparTela:

    mov dx, 0
	mov bh, 0
	mov ah, 2
	
    int 10h  
	
	mov ah, 6			
	mov al, 0			
	mov bh, 7			
	mov cx, 0			
	mov dh, 24			
	mov dl, 79
	
    int 10h

    ret

;;************************************************************************************

;; Função para imprimir string em modo real
;;
;; Entrada:
;;
;; SI - String

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

imprimirHexa:

	pusha

	mov bp, sp
	mov si, [bp+18] 
	
.cont:
	
	lodsb
		
	or al, al
	jz .pronto
		
	mov ah, 0x0e
	mov bx, 0
	mov bl, 7 
	
    int 10h
		
	jmp .cont
		
.pronto:
	
	mov sp, bp
	
    popa
	
    ret

;;************************************************************************************

testarVideo:

	mov ax, 19
	int 10h ;; 320x200 com 256 cores

	mov ax, 0a000h
	mov es, ax ;; Definir DI para o segmento de memória de vídeo
	xor bl, bl ;; BL será usado para armazenar o número da figura

.novo:

	inc bl

	hlt ;; Processador irá aguardar

	xor cx, cx
	xor dx, dx ;; CX e DX representam as coordenadas
	xor di, di ;; Defina di para o início da tela

.a:

	mov al, cl
	xor al, dl
	add al, dl
	add al, bl ;; Cria uma cor
	
	stosb      ;; Escreve um pixel
	
	inc cx

	cmp cx, 320 ;; Atualizar coordenadas
	jne .a

	xor cx, cx
	
	inc dx

	cmp dx, 200
	jne .a

	mov ah, 1  ;; Checa se alguma tecla foi pressionada
	
	int 16h

	jz .novo ;; Se nenhuma tecla pressionada, exiba outra figura

	mov ax, 3 ;; Retornar ao modo texto
	
	int 10h

;; Importante restaurar o segmento antes de finalizar!

	mov ax, SEG_HBOOT
	mov es, ax

	ret
