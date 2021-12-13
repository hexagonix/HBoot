;;************************************************************************************
;;
;;    
;;                        Carregador de Inicialização HBoot
;;        
;;                             Hexagon® Boot - HBoot
;;           
;;                 Copyright © 2020-2021 Felipe Miguel Nery Lunkes
;;                         Todos os direitos reservados
;;                                  
;;************************************************************************************
;;
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;
;;
;;************************************************************************************

parahexa:

	pusha

	mov bp, sp
	mov dx, [bp+20]

	push dx	

	call imprimirHexa

	mov dx, [bp+18]

	mov cx, 4
	mov si, HBoot.Mensagens.hexc
	mov di, HBoot.Mensagens.hex+2
	
guardar:
	
	rol dx, 4

	mov bx, 15

	and bx, dx

	mov al, [si+bx]

	stosb

	loop guardar

	push HBoot.Mensagens.hex

	call imprimirHexa

	mov sp, bp

	popa

	mov ax, SEG_HBOOT
	mov es, ax

	ret
