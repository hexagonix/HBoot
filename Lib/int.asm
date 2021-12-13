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

HBoot.Int:

.cs: dw 0
.es: dw 0
.ss: dw 0
.sp: dw 0
.ds: dw 0

;;************************************************************************************

;; Agora, uma rotina para instalar interrupções de software. Útil para servir módulos com
;; funções do carregador, além de permitir que o módulo retorne o controle ao HBoot quando
;; terminar sua(s) tarefa(s).

;; Entrada:
;;
;; BL - Número da interrupção de software a instalar
;; CX - Segmento para instalar (geralmente, CS)
;; DI - Ponteiro para o manipulador
;;
;; Aviso! AX, BX, CX e DX perdidos no processo

instalarInterrupcao:	

        push es

		xor	bh, bh
		shl	bx, 2	;; Localização dentro do segmento com o vetor de interrupção

		xor	ax, ax
		mov	es, ax

		cli			;; Desativar as interrupções

		mov	[es:0000h + bx], di
		mov	[es:0002h + bx], cx

		sti			;; Habilitar interrupções

		pop	es
        
		ret

;;************************************************************************************

instalar80h:

	mov bl, 80h
	mov cx, cs 
	mov di, retornarHBoot

	call instalarInterrupcao

	ret 
	
;;************************************************************************************

retornarHBoot:

		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push di

		jmp SEG_HBOOT:retornarInterrupcao

		pop	di
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		iret

;;************************************************************************************

retornarInterrupcao:

    jmp analisarPC.novaEntrada
	