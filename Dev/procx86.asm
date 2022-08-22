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

HBoot.Procx86.Dados:

.vendedorProcx86: times 13 db 0
.nomeProcx86:              db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd", 0

;;************************************************************************************

initProc:

    call identificarVendedorProcx86

    call identificarNomeProcx86

    call habilitarA20                ;; Tentar habilitar prematuramente linha A20

    ret

;;************************************************************************************

identificarVendedorProcx86:

    mov eax, 0
    
    cpuid
    
    mov [HBoot.Procx86.Dados.vendedorProcx86], ebx
    mov [HBoot.Procx86.Dados.vendedorProcx86 + 4], edx
    mov [HBoot.Procx86.Dados.vendedorProcx86 + 8], ecx

    ret

;;************************************************************************************

identificarNomeProcx86:

    mov eax, 80000002h  
    
    cpuid
    
    mov di, HBoot.Procx86.Dados.nomeProcx86     

    stosd

    mov eax, ebx

    stosd

    mov eax, ecx

    stosd

    mov eax, edx

    stosd
    
    mov eax, 80000003h

    cpuid
    
    stosd

    mov eax, ebx
    
    stosd
    
    mov eax, ecx
    
    stosd
    
    mov eax, edx
    
    stosd
    
    mov eax, 80000004h  
    
    cpuid
    
    stosd
    
    mov eax, ebx
    
    stosd
    
    mov eax, ecx
    
    stosd 
    
    mov eax, edx
    
    stosd
    
    mov si, HBoot.Procx86.Dados.nomeProcx86     
    
    mov cx, 48
    
.loopCPU:   

    lodsb

    cmp al, ' '
    jae .formatarNomeCPU
    
    mov al, 0
    
.formatarNomeCPU:   

    mov [si-1], al
    
    loop .loopCPU

    ret

;;************************************************************************************

;; Vamos tentar ativar o A20 para verificar se o processador é compatível com o 
;; modo protegido

habilitarA20:

    clc 

    mov ax, 0x2401  ;; Solicitar a ativação do A20
        
    int 15h         ;; Interrupção do BIOS

    jc .erroA20

    ret 
    
.erroA20:

    exibir HBoot.Mensagens.erroA20

    jmp $