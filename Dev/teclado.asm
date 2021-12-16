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

lerTeclado:

.ler:  

    xor cl, cl

.loop:

    mov ah, 0
    
    int 16h

    cmp al, 8h
    je .apagar

    cmp al, 0Dh
    je .pronto

    cmp cl, 3Fh
    je .loop

    mov ah, 0Eh
    int 10h

    stosb

    inc cl

    jmp .loop

.apagar:          ;; Usa o Driver de Teclado Principal para apagar um caracter

    cmp cl, 0
    je .loop

    dec di
    
    mov byte [di], 0
    
    dec cl

    mov ah, 0Eh
    mov al, 08h

    int 10h

    mov al, ' '
    
    int 10h

    mov al, 08h

    int 10h

    jmp .loop

.pronto:          ;; Tarefa ou rotina concluida

    mov al, 0

    stosb

    ret

;;************************************************************************************

aguardarTeclado:

    mov ah, 00h

    int 16h

    ret
