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
;;
;;************************************************************************************

;; Agora, o HBoot pode realizar a inicialização de sistemas DOS-like, como MS-DOS,
;; FreeDOS, DR-DOS, dentre outros. Para isso, o nome de arquivo do DOS específico deve
;; ser definido, bem como o segmento de carregamento do mesmo

;; Aqui temos os nomes de arquivos que possam conter um kernel DOS

HBoot.DOS.Arquivos:

.imagemFreeDOS: db "KERNEL  SYS"

;; Aqui temos os segmentos para carregamento de um kernel DOS (variável)

HBoot.DOS.Segmentos.segmentoFreeDOS equ 0x60

;;************************************************************************************

HBoot.DOS.iniciarFreeDOS:

    mov si, HBoot.DOS.Arquivos.imagemFreeDOS
	mov di, HBoot.Arquivos.nomeImagem

	mov cx, 11
	
;; Copiar o nome do arquivo

	rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], HBoot.DOS.Segmentos.segmentoFreeDOS

    call procurarArquivo

    pop ebp                         ;; Ponteiro para o BPB

;; O FreeDOS recebe o parâmetro de drive de boot em BL

    mov bl, byte[idDrive]           ;; Drive utilizado para a inicialização

    jmp HBoot.DOS.Segmentos.segmentoFreeDOS:0000 ;; Configurar CS:IP e executar o Kernel

    jmp $
