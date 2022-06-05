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

verificarMemoria:

    push edx
	push ecx
	push ebx

	xor eax, eax
	xor ebx, ebx
	
	mov ax, 0xE801
	
	xor dx, dx
	xor cx, cx
	
	int 15h
	
	jnc .processar
	
	xor eax, eax
	
	jmp .fim         ;; Erro                                  

.quantificar:

	mov si, ax
	
	or si, bx
	jne .quantificar
	
	mov ax, cx
	mov bx, dx

.processar:

	cmp ax, 0x3C00
	jb .abaixoDe16MB
	
	movzx eax, bx
	
	add eax, 100h
	
	shl eax, 16      ;; EAX = EAX * 65536
	
	jmp .fim

.abaixoDe16MB:

	shl eax, 10      ;; EAX = EAX * 1024

.fim:

	pop ebx
	pop ecx
	pop edx
	
;; Vamos salvar aqui o total de memória recuperado. Caso seja suficiente para o processo continuar,
;; a quantidade de RAM instalada será fornecida ao Hexagon®, em Kbytes

;; Vamos comparar se a quantidade de RAM é suficiente para uma inicialização bem sucedida

    shr eax, 10 ;; EAX = EAX / 1024

;; Precisamos agora adicionar a memória abaixo de 1 MB que está disponível mas que 
;; não entra na quantificação feita.

	add eax, 1024 ;; Pronto. Vamos adicionar 1024 kbytes a conta

    mov word[memoriaDisponivel], ax 

    cmp dword eax, MEMORIA_MINIMA
    jbe .erroMemoria ;; Se menos que isso, não temos o suficiente

    ret

.erroMemoria:

    exibir HBoot.Mensagens.erroMemoria

    jmp $ ;; Não dá para continuar. Então, permanecer aqui
