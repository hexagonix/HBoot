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
;;                  Copyright © 2020-2022 Felipe Miguel Nery Lunkes
;;                          Todos os direitos reservados
;;                                  
;;************************************************************************************

verificarImagemHAPP:

    mov di, SEG_KERNEL
    sub di, 0x50

    cmp byte[di+0], "H" ;; H de HAPP
	jne .imagemInvalida

	cmp byte[di+1], "A" ;; A de HAPP
	jne .imagemInvalida

	cmp byte[di+2], "P" ;; P de HAPP
	jne .imagemInvalida

	cmp byte[di+3], "P" ;; P de HAPP
	jne .imagemInvalida

;; Se chegamos até aqui, temos o cabeçalho no arquivo, devemos checar o restante dos campos,
;; como a arquitetura

;; Vamos checar se a arquitetura da imagem é a mesma do Sistema

	cmp byte[di+4], ARQUITETURA ;; Arquitetura suportada
	jne .imagemInvalida

;; Os tipos de imagem podem ser (01h) imagens executáveis e (02h e 03h) bibliotecas
;; estáticas ou dinâminas (implementações futuras)

	cmp byte[di+11], 03h
	jg .imagemInvalida

	jmp .fim ;; Vamos continuar sem marcar erro na imagem

.imagemInvalida:

    mov si, HBoot.Mensagens.imagemInvalida

    call imprimir

    jmp $
    
.fim:

    ret