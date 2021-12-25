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

verificarImagemHAPP:

	push es

	push ds
	pop es 

    mov si, SEG_KERNEL

    cmp byte[si+0], "H" ;; H de HAPP
	jne .imagemInvalida

	cmp byte[si+1], "A" ;; A de HAPP
	jne .imagemInvalida

	cmp byte[si+2], "P" ;; P de HAPP
	jne .imagemInvalida

	cmp byte[si+3], "P" ;; P de HAPP
	jne .imagemInvalida

;; Se chegamos até aqui, temos o cabeçalho no arquivo, devemos checar o restante dos campos,
;; como a arquitetura

;; Vamos checar se a arquitetura da imagem é a mesma do Sistema

	cmp byte[si+4], ARQUITETURA ;; Arquitetura suportada
	jne .imagemInvalida

;; Os tipos de imagem podem ser (01h) imagens executáveis e (02h e 03h) bibliotecas
;; estáticas ou sinâminas (implementações futuras)

	cmp byte[si+11], 03h
	jg .imagemInvalida

	jmp .fim ;; Vamos continuar sem marcar erro na imagem

.imagemInvalida:

    exibir HBoot.Mensagens.imagemInvalida

    jmp $
    
.fim:

	pop es 
	
    ret