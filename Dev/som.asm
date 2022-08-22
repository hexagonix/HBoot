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

emitirsom:

    pusha

    mov cx, ax          

    mov al, 182

    out 43h, al
    
    mov ax, cx          
    
    out 42h, al
    
    mov al, ah
    
    out 42h, al

    in al, 61h          
    
    or al, 03h
    
    out 61h, al

    popa
    
    ret

;;************************************************************************************

desligarsom:

    pusha

    in al, 61h

    and al, 0FCh
    
    out 61h, al

    popa
    
    ret
    