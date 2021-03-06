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

use16

;; Aqui será criada uma tabela em memória com informações sobre os dispositivos em uma
;; árvore binária linear, mais como uma matriz. O povoamento com as informações sobre 
;; os dispositivos, obtidas pelo HBoot por análise direta de I/O ou pelo BIOS, devem
;; respeitar a ordem de campos, para que essas informações possam ser decodificadas 
;; pelo Hexagon mais tarde. Isso vai substituir os endereços e valores "hard-coded" 
;; do Hexagon. A árvore terá 128 campos de uma word cada, e cada dispositivo terá duas
;; words para armazenamento de informações. Futuramente, cada um poderá ter duas words 
;; e um campo para arnamzenamento de nome obtido.

HBoot.Dev:

.arvoreDispositivos16: times 128 dw 0

;; Agora a tabela deve ser preenchida durante a operação do HBoot em uma ordem definida, como a 
;; seguir. O endereço dessa tabela será fornecida ao Hexagon, para que ele a decodifique. Isso
;; consegue garantir que mais informações possam ser passadas, uma vez que temos um número 
;; limitado de registradores. Seguir de acordo com o offset. O primeiro fica vazio e o segundo
;; com o valor referente

;; Campo | Dados/valores/endereços/offsets
;;
;; 0       Vazio/uso futuro
;; 3       Memória total detectada
;; 5       Endereço da primeira porta paralela - 0 se ausente
;; 7       ID da unidade de boot
;; 9       Número de discos rígidos disponíveis
;; 11      bool - presença ou ausência de unidades de disquete
;; 13      ID do sistema de arquivos da unidade de boot
;; 15      Versão principal do HBoot
;; 17      Subversão do HBoot  
;; 19      bool - presença ou ausência de linha de comando para o Hexagon
;; 21     
;; 23
;; 25
;; 27
;; 29
;; 31
;; 33
;; 35 
;; 37
;; 39
;; 41
;; 43
;; 45
;; 47
;; 49
;; 51
;; 53
;; 55
;; 57
;; 61
;; 63

.arvoreDispositivos32: times 64 dd 0

;; Agora a tabela deve ser preenchida durante a operação do HBoot em uma ordem definida, como a 
;; seguir. O endereço dessa tabela será fornecida ao Hexagon, para que ele a decodifique. Isso
;; consegue garantir que mais informações possam ser passadas, uma vez que temos um número 
;; limitado de registradores. Seguir de acordo com o offset

;; Campo | Dados/valores/endereços/offsets
;;
;; 0       Vazio/uso futuro
;; 3       
;; 5       
;; 7       
;; 9       
;; 11      
;; 13      
;; 15      
;; 17        
;; 19      
;; 21     
;; 23
;; 25
;; 27
;; 29
;; 31

;;************************************************************************************

povoarArvoreDispositivos:

    push ax 
    push bx 
    push cx

.povoarArvore16:

;; Campo 0 e 1 permanecem vazios 

;; Campos 2 e 3: memória total disponível

    mov ax, word[memoriaDisponivel]
    mov word[HBoot.Dev.arvoreDispositivos16+3], ax
    mov word[HBoot.Dev.arvoreDispositivos16+2], 00h ;; Campo 2

;; Campos 4 e 5: endereço da primeira porta paralela

    mov ax, word[HBoot.Paralela.Controle.enderecoLPT1]
    mov word[HBoot.Dev.arvoreDispositivos16+5], ax
    mov word[HBoot.Dev.arvoreDispositivos16+4], 00h 

;; Campos 6 e 7: ID da unidade de boot

    movzx ax, byte[idDrive]
    mov word[HBoot.Dev.arvoreDispositivos16+7], ax
    mov word[HBoot.Dev.arvoreDispositivos16+6], 00h 

.povoarArvore32:

    pop cx 
    pop bx 
    pop ax

    ret

;;************************************************************************************

;; Esta é a cola de código de dispositivos suportados.
;; Aqui são incluídos os arquivos que interagem com dispositivos da máquina

include "init.asm"
include "discos.asm"
include "teclado.asm"
include "console.asm"
include "som.asm"
include "memx86.asm"
include "procx86.asm"
include "BIOSx86.asm"
include "serial.asm"
include "paralela.asm"