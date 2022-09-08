;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2016-2022 Felipe Miguel Nery Lunkes
;; │┌─┐││─┼┼┼┤┌┐│┌┐│┌┐│┌┐┼┼┼┼┘          Todos os direitos reservados
;; ││ │││─┼┼┼┤┌┐│└┘│└┘││││├┼┼┐
;; └┘ └┴──┴┘└┴┘└┴─┐├──┴┘└┴┴┘└┘
;;              ┌─┘│                 Licenciado sob licença BSD-3-Clause
;;              └──┘          
;;
;;
;;************************************************************************************
;;
;; Este arquivo é licenciado sob licença BSD-3-Clause. Observe o arquivo de licença 
;; disponível no repositório para mais informações sobre seus direitos e deveres ao 
;; utilizar qualquer trecho deste arquivo.
;;
;; Copyright (C) 2016-2022 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.

;; Caso nenhuma interação tenha acontecido, devemos então procurar e iniciar o Hexagon®
;; Caso alguma interação tenha ocorrido mas o usuário selecionou continuar a inicialização,
;; também devemos continuar com o protocolo de boot 

carregarHexagon:

    call configurarInicioHexagon ;; Configura nome de imagem e localização em memória

    call procurarArquivo  ;; Procurar o arquivo que contêm o Kernel

    jmp executarKernel    ;; Executar o Hexagon®

;;************************************************************************************

;; Função que transfere a execução para o Hexagon®, passando parâmetros pelos 
;; registradores, como descrito a seguir:
;;
;; EBP - Ponteiro para o BIOS Parameter Block do disco de boot
;; DL  - Número lógico do disco usado para a inicialização
;; CX  - Quantidade, em Kbytes, de memória RAM instalada na máquina
;; Mais parâmetros poderão ser passados agora em razão da criação do segundo
;; estágio (HBoot)

executarKernel:
    
    pop ebp                         ;; Ponteiro para o BPB
    mov esi, HBoot.Parametros.bufLeitura + (SEG_HBOOT * 16) ;; Apontar ESI para parâmetros
    mov bl, byte[idDrive]           ;; Drive utilizado para a inicialização
    mov cx, word[memoriaDisponivel] ;; Memória RAM instalada

;; O Hexagon® apresenta o cabeçalho HAPP, que será padrão em todos os executáveis no
;; formato Hexagon®. Este cabeçalho apresenta 38 bytes (0x26), então devemos pulá-lo. Os 
;; dados contidos no cabeçalho serão futuramente validados, se necessário

    jmp SEG_KERNEL:CABECALHO_HAPP   ;; Configurar CS:IP e executar o Kernel

;;************************************************************************************

configurarInicioHexagon:

    mov si, HBoot.Arquivos.imagemHexagon
    mov di, HBoot.Arquivos.nomeImagem

    mov cx, 11
    
;; Copiar o nome do arquivo

    rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], SEG_KERNEL

;; Vamos marcar para modo de boot do Hexagon(R)

    mov byte[HBoot.Controle.modoBoot], 00h 

    ret