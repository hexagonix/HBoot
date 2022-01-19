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

;; Versão do HBoot

versaoHBoot                 equ "1.2.0"
verProtocolo                equ "1.15.5"

;; Segmentos de carregamento do HBoot e do Hexagon®

SEG_HBOOT                   equ 0x1000 ;; Segmento de carregamento de HBoot  
SEG_KERNEL 	                equ 0x50   ;; Segmento para carregar Kernel
SEG_MODULOS                 equ 0x2000 ;; Segmento para carregamento de imagens de diagnóstico

;; Dados de arquitetura a qual deve-se carregar o Hexagon®

ARQUITETURA                 = 01h      ;; Arquitetura do HBoot e a qual se destina o Kernel

;; Tamanho do cabeçalho HAPP da imagem

CABECALHO_HAPP              = 026h     ;; Versão 2.0 da definição HAPP
CABECALHO_MODULO            = 11h      ;; Versão 1.0 da definição de cabeçalhos de módulo

;; Memória mínima para o boot do Hexagon®. Vale lembrar que os requisitos são variáveis a depender
;; da versão do Hexagon®, sendo necessária a adaptação à necessidade mínima de memória.

MEMORIA_MINIMA              = 31744    ;; Memória mínima necessária para boot seguro

;; Constantes utilizadas para alterações de parâmetros de boot

FATOR_TEMPO                 = 10000    ;; Contagem de décimos de segundo
CICLOS_PARAMETROS_INICIACAO = 05       ;; Contagem de tempo = valor x 1 décimo de segundo

;; Scancode de teclas do teclado

F8                          = 42h
ESC                         = 1Bh
