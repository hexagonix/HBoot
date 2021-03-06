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

HBoot.Sons: ;; Frequências de som para as notas musicais utilizadas para a música

;; Tema do Andromeda®

.nDO  = 2000
.nRE  = 2100
.nMI  = 2300
.nFA  = 2700
.nSOL = 3000
.nLA  = 3200
.nSI  = 3600
.nDO2 = 4060

;; CANON

.CANON1 = 3060
.CANON2 = 4020
.CANON3 = 3800
.CANON4 = 5400
.CANON5 = 5080
.CANON6 = 7120
.CANON7 = 5080
.CANON8 = 4420

;; Temporizador padrão em microssegundos

.tNormal    = 01h
.tExtendido = 02h
