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

;; Aqui temos os manipuladores de interrupção instaláveis e funções úteis para eles

;; O primeiro deles é o manipulador 21h, responsável por retornar o controle da máquina ao
;; HBoot após o módulo terminar seu trabalho

manipulador21h: