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
;;
;;************************************************************************************

verificarMemoria:

    mov al, 18h
    
    out 70h, al
    
    in al, 71h

    mov ah, al
    mov al, 17h
    
    out 70h, al
    
    in al, 71h
    
    add ax, 1024 ;; Em AX temos a quantidade de RAM recuperada
    
;; Vamos salvar aqui o total de memória recuperado. Caso seja suficiente para o processo continuar,
;; a quantidade de RAM instalada será fornecida ao Hexagon®, em Kbytes

    mov word[memoriaDisponivel], ax 

;; Vamos comparar se a quantidade de RAM é suficiente para uma inicialização bem sucedida

    cmp ax, MEMORIA_MINIMA
    jbe .erroMemoria ;; Se menos que isso, não temos o suficiente

    ret ;; Se sim, temos e o protocolo de inicialização pode continuar

.erroMemoria:

    mov si, HBoot.Mensagens.erroMemoria

    call imprimir

    jmp $ ;; Não dá para continuar. Então, permanecer aqui
