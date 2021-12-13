;;************************************************************************************
;;
;;    
;;                        Carregador de Inicialização HBoot
;;        
;;                             Hexagon® Boot - HBoot
;;           
;;                Copyright © 2020-2021 Felipe Miguel Nery Lunkes
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

;; Agora, o HBoot pode realizar a inicialização de sistemas DOS-like, como MS-DOS,
;; FreeDOS, DR-DOS, dentre outros. Para isso, o nome de arquivo do DOS específico deve
;; ser definido, bem como o segmento de carregamento do mesmo

;; Aqui temos os nomes de arquivos que possam conter um kernel DOS

HBoot.Modulos.DOS.Arquivos:

.imagemFreeDOS: db "KERNEL  SYS"

;; Aqui temos os segmentos para carregamento de um kernel DOS (variável)

HBoot.Modulos.DOS.Segmentos.segmentoFreeDOS equ 0x60

;;************************************************************************************

HBoot.Modulos.DOS.iniciarFreeDOS:

    mov byte[HBoot.Modulos.Controle.moduloAtivado], 01h

    mov si, HBoot.Modulos.DOS.Arquivos.imagemFreeDOS
	mov di, HBoot.Arquivos.nomeImagem

	mov cx, 11
	
;; Copiar o nome do arquivo

	rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], HBoot.Modulos.DOS.Segmentos.segmentoFreeDOS

    call procurarArquivo

    jc .gerenciarErroArquivo

;; O FreeDOS recebe o parâmetro de drive de boot em BL

    mov bl, byte[idDrive]           ;; Drive utilizado para a inicialização

    jmp HBoot.Modulos.DOS.Segmentos.segmentoFreeDOS:00h ;; Configurar CS:IP e executar o Kernel

    jmp $

.gerenciarErroArquivo:

    exibir HBoot.Mensagens.DOSAusente

    call aguardarTeclado

    jmp verificarInteracaoUsuario.testarComponentes
