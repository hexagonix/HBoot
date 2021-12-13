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

iniciarCOM1:  ;; Esse método é usado para inicializar uma Porta Serial


    mov ah, 0     ;; Move o valor 0 para o registrador ah 
	              ;; A função 0 é usada para inicializar a Porta Serial COM1
    mov al, 0xE3  ;; Parâmetros da porta serial
    mov dx, 0     ;; Número da porta (COM 1) - Porta Serial 1
    
    int 14h       ;; Inicializar porta - Ativa a porta para receber e enviar dados
	
	ret

;;************************************************************************************

transferirCOM1: ;; Esse método é usado para transferir dados pela Porta Serial aberta

    lodsb         ;; Carrega o próximo caractere à ser enviado

    or al, al     ;; Compara o caractere com o fim da mensagem
    jz .pronto    ;; Se igual ao fim, pula para .pronto

    mov ah, 01h   ;; Função de envio de caractere do BIOS por Porta Serial
    int 14h       ;; Chama o BIOS e executa a ação 

    jc near .erro

    jmp transferirCOM1 ;; Se não tiver acabado, volta à função e carrega o próximo caractere

.pronto: ;; Se tiver acabado...

    ret      ;; Retorna a função que o chamou

.erro:

    stc

    ret
