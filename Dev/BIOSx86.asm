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
;;************************************************************************************
;;
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;
;;
;;************************************************************************************

;; Aqui iremos utilizar os serviços do BIOS para provocar um atraso

executarAtraso:

    mov al, 0
    mov ah, 86h  ;; Função de causar atraso
    mov cx, 1    ;; CX:DX - tempo, em microssegundos

    int 15h      ;; Chamar BIOS

    ret

	