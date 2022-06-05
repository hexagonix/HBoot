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

;; Segmentos de carregamento do HBoot e do Hexagon®

SEG_HBOOT                   equ 0x1000 ;; Segmento de carregamento de HBoot  

;; Dados de arquitetura a qual deve-se carregar o Hexagon®

ARQUITETURA                 = 01h      ;; Arquitetura do HBoot e a qual se destina o Kernel

;; Memória mínima para o boot do Hexagon®. Vale lembrar que os requisitos são variáveis a depender
;; da versão do Hexagon®, sendo necessária a adaptação à necessidade mínima de memória.

MEMORIA_MINIMA              = 32768    ;; Memória mínima necessária para boot seguro

;; Constantes utilizadas para alterações de parâmetros de boot

FATOR_TEMPO                 = 10000    ;; Contagem de décimos de segundo
CICLOS_PARAMETROS_INICIACAO = 05       ;; Contagem de tempo = valor x 1 décimo de segundo

;; Scancode de teclas do teclado

F8                          = 42h
ESC                         = 1Bh
