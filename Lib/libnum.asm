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
