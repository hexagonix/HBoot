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

;; Função que transfere a execução para o Hexagon®, passando parâmetros pelos 
;; registradores, como descrito a seguir:
;;
;; EBP - Ponteiro para o BIOS Parameter Block do disco de boot (endereço)
;; ESI - Uma string com parâmetros
;; DL  - Número lógico do disco usado para a inicialização
;; CX  - Quantidade, em Kbytes, de memória RAM instalada na máquina
;; Mais parâmetros poderão ser passados agora em razão da criação do segundo
;; estágio (HBoot)
;;
;; Além disso, o HBoot vai começar a fornecer uma "árvore de dispositivos" contendo
;; todas as informações de hardware e software, incluindo informações do próprio 
;; HBoot. Essas informações estão em uma ordem pré-definida, que pode ser encontrada
;; no arquivo "Dev/dev.asm". Essas informações serão processadas pelo Hexagon®. Sendo
;; assim:
;;
;; AX - Endereço da árvore de dispositivos com dados de 16 bits (words)
;; EDI - Endereço da árvore de dispositivos com dados de 32 bits (dwords)

executarKernel:

;; Primeiramente, o HBoot deve povoar as árvores de 16 e 32 bits com as informações de
;; hardware já obtidas pelo HBoot durante o processo de inicialização e checagem do 
;; hardware.

    call povoarArvoreDispositivos ;; Povoar as árvores

    mov ebp, dword[enderecoBPB + (SEG_HBOOT * 16)] ;; Ponteiro para o BPB
    mov esi, HBoot.Parametros.bufLeitura + (SEG_HBOOT * 16) ;; Apontar ESI para parâmetros
    mov ax, HBoot.Dev.arvoreDispositivos16  ;; Fornecer a árvore de dispositivos 16 bits ao Hexagon
    mov edi, HBoot.Dev.arvoreDispositivos32 + (SEG_HBOOT * 16)  ;; Fornecer a árvore de dispositivos 32 bits ao Hexagon
    mov bl, byte[idDrive]           ;; Drive utilizado para a inicialização
    mov cx, word[memoriaDisponivel] ;; Memória RAM instalada

;; O Hexagon® apresenta o cabeçalho HAPP, que é o padrão em todos os executáveis no
;; formato Hexagon®. Este cabeçalho apresenta 38 bytes (0x26) na versão 1.0 da especificação,
;; utilizada pelo Hexagon®, então devemos pulá-lo. Entretanto, as especificações do formato HAPP
;; podem ser alteradas com o tempo, mas o Hexagon® poderá permanecer utilizando a especificação
;; 1.0 sem problemas, uma vez que as informações necessárias à execução já se encontram nessa
;; versão da especificação. Os dados contidos no cabeçalho serão futuramente validados, se necessário

    jmp SEG_KERNEL:CABECALHO_HAPP   ;; Configurar CS:IP e executar o Kernel

;;************************************************************************************

configurarInicioHexagon:

    cld 

	mov si, HBoot.Arquivos.imagemHexagon
	mov di, HBoot.Arquivos.nomeImagem

	mov cx, 11
	
;; Copiar o nome do arquivo

	rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], SEG_KERNEL

;; Vamos marcar para modo de boot do Hexagon(R)

    mov byte[HBoot.Controle.modoBoot], 00h 

    ret
