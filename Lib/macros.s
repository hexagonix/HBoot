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

macro tocarNota nota, tempo
{

    mov ax, nota
    mov bx, 8
    
    call emitirsom

    mov dx, tempo

    call executarAtraso

}

macro novaLinha
{

    mov si, HBoot.Mensagens.novaLinha

    call imprimir

}

;; Uma forma mais simples de exibir conteúdo 

macro exibir texto
{

    mov si, texto

    call imprimir

}

macro diag texto
{

    mov si, texto

    call transferirCOM1

}