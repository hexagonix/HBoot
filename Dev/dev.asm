;;************************************************************************************
;;
;;    
;;                        Carregador de Inicialização HBoot
;;        
;;                             Hexagon® Boot - HBoot
;;           
;;                 Copyright © 2020-2021 Felipe Miguel Nery Lunkes
;;                         Todos os direitos reservados
;;                                  
;;************************************************************************************
;;
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;
;;
;;************************************************************************************

;; Esta é a cola de código de dispositivos suportados.
;; Aqui são incluídos os arquivos que interagem com dispositivos da máquina

include "init.asm"
include "discos.asm"
include "teclado.asm"
include "video.asm"
include "som.asm"
include "memx86.asm"
include "procx86.asm"
include "BIOSx86.asm"
include "serial.asm"