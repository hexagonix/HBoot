;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2016-2022 Felipe Miguel Nery Lunkes
;; │┌─┐││─┼┼┼┤┌┐│┌┐│┌┐│┌┐┼┼┼┼┘          Todos os direitos reservados
;; ││ │││─┼┼┼┤┌┐│└┘│└┘││││├┼┼┐
;; └┘ └┴──┴┘└┴┘└┴─┐├──┴┘└┴┴┘└┘
;;              ┌─┘│                 Licenciado sob licença BSD-3-Clause
;;              └──┘          
;;
;;
;;************************************************************************************
;;
;; Este arquivo é licenciado sob licença BSD-3-Clause. Observe o arquivo de licença 
;; disponível no repositório para mais informações sobre seus direitos e deveres ao 
;; utilizar qualquer trecho deste arquivo.
;;
;; Copyright (C) 2016-2022 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.

paraString:

    pusha
    
    mov cx, 0
    mov bx, 10
    mov di, .tmp
        
.empurrar:

    mov dx, 0
    
    div bx
    
    inc cx
    
    push dx
    
    test ax,ax
    jnz .empurrar
        
.puxar:
    
    pop dx
    
    add dl, '0'
    mov [di], dl
    
    inc di
    dec cx
    
    jnz .puxar

    mov byte [di], 0
    
    popa
    
    mov ax, .tmp
    
    ret
             
.tmp: times 7 db 0
