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

HBoot.Init.Dev:

.IDUnidade: db 0
.FSUnidade: db 0

initDev:

    call initProc         ;; Verificar o desenvolvedor do processador

    call verificarMemoria ;; Identificar memória instalada  

    call verificarDiscos  ;; Vamos verificar as unidades presentes no computador

    call iniciarCOM1      ;; Vamos iniciar a porta serial COM1

    call iniciarParalela  ;; Iniciar a porta paralela

    ret
