;;************************************************************************************
;;
;;    
;;                        Carregador de Inicialização HBoot
;;        
;;                             Hexagon® Boot - HBoot
;;           
;;                 Copyright © 2020-2022 Felipe Miguel Nery Lunkes
;;                         Todos os direitos reservados
;;        
;;        
;;                                  Versão 1.0
;;        
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