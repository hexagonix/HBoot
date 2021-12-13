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

HBoot.Paralela.Controle:

.numPortas:    db 0
.enderecoLPT1: dw 0

use16 

;; Inicializar e obter o endereço da porta LPT1

iniciarParalela:

	pusha
	push ds
	
	mov ax, 40h
	mov ds, ax				    ;; Início da área de dados do BIOS começa em 0040:0000h
	
	mov ax, word [ds:10h]		;; AX := equipamento 
	test ax, 1100000000000000b	;; Bytes 14-15 armazenam o número de portas paralelas
	jz .semPortaParalela        ;; Sem porta paralela
	
	mov ax, word [ds:08h]		;; O endereço base de LPT1 começa no offset 08h
	mov word[cs:HBoot.Paralela.Controle.enderecoLPT1], ax	;; Armazenar o endereço
	
    jmp .sairPortaParalela

.semPortaParalela:

    mov byte[HBoot.Paralela.Controle.numPortas], 00h 
	mov word[HBoot.Paralela.Controle.enderecoLPT1], 00h	;; Armazenar o endereço

.sairPortaParalela:

	pop ds
	popa

	ret

;;************************************************************************************