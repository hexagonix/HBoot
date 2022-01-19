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

;; O HBoot funciona exclusivamente em modo real 16-bit. Sendo assim, implementa funções
;; de controle de dispositivos e de leitura de Sistema de Arquivos com código incompatível
;; com o Hexagon®. Não existe código Hexagon® aqui, com implementação feita do zero

use16					

;; O Hboot deve apresentar um cabeçalho especial de imagem HBoot, esperada pelo primeiro
;; estágio de inicialização. São 6 bytes, com assinatura (número mágico) e arquitetura 
;; alvo

cabecalhoHBoot:

.assinatura:  db "HBOOT"     ;; Assinatura, 5 bytes
.arquitetura: db ARQUITETURA ;; Arquitetura (i386), 1 byte

    cmp byte[HBoot.Parametros.execucaoModulo], 00h
    jne retornarModulo

    mov byte[HBoot.Parametros.execucaoModulo], 01h

    jmp inicioHBoot

;;************************************************************************************

;; Vamos incluir todas as constantes utilizadas

include "Lib/hboot.s"

;; Macros utilizados pelo HBoot

include "Lib/macros.s"

;; Camada de abstração de Sistemas de Arquivos (que inclui os arquivos de cada
;; Sistema de Arquivos)

include "FS/univerFS.asm"

;; Agora incluir todo o código que lida diretamente com dispositivos 

include "Dev/dev.asm"

;; Agora, bibliotecas úteis

include "Lib/string.asm"
include "Lib/num.asm"
include "Lib/HAPP.asm"
include "Lib/int.asm"
include "Lib/libMod.asm"
include "Lib/libUtil.asm"
include "Lib/libHexagon.asm"
include "Lib/prompt.asm"

;; Agora vamos incluir os módulos internos e o carregador de módulos

include "Lib/modulos.asm"

;;************************************************************************************

inicioHBoot:

;; Configurar pilha e ponteiro

    cli				   ;; Desativar interrupções
    
    mov ax, SEG_HBOOT
    mov ss, ax
    mov sp, 0
    
    sti				   ;; Habilitar interrupções

;; Salvar entedereço LBA da partição, fornecido pelo Saturno®
    
    mov dword[enderecoLBAParticao], ebp ;; Salvar aqui o LBA da partição
    mov dword[enderecoBPB], esi         ;; Salvar o BPB
    
;; Carregar registradores de segmento para a nova posição
     
    cli 

    mov ax, SEG_HBOOT
    mov ds, ax
    mov es, ax
    
    sti

    mov byte[idDrive], dl ;; Salvar número do drive

;;************************************************************************************

boasVindasHBoot:

    call limparTela       ;; Limpar a tela

    call tomInicializacao ;; Tocar tom de inicialização
 
    exibir  HBoot.HBoot.iniciando

analisarPC:

    call initDev

    call definirSistemaArquivos

    call instalar80h

    jmp .naoHouveMod

.novaEntrada:

;; Agora iremos verificar se o usuário deseja alterar o comportamento do processo
;; de inicialização, inclusive passando parâmetros para o núcleo, por exemplo

.naoHouveMod:

;; Vamos checar a interação do usuário. ALém de fornecer uma linha de comando ao
;; Hexagon®, o usuário pode iniciar um módulo HBoot, obter informações sobre o
;; hardware e software e também iniciar outro sistema operacional cujos arquivos
;; estejam na mesma unidade, como um sistema do tipo DOS.

    call verificarInteracaoUsuario  

;; Caso nenhuma interação tenha acontecido, devemos então procurar e iniciar o Hexagon®.
;; Caso alguma interação tenha ocorrido mas o usuário selecionou continuar a inicialização,
;; também devemos continuar com o protocolo de boot 

    jmp carregarHexagon

;;************************************************************************************

;;************************************************************************************
;;
;; Variáveis e constantes utilizadas 
;;
;;************************************************************************************

HBoot.HBoot:

.iniciando:             db "Hexagon(R) Boot (HBoot) versao ", versaoHBoot, ".", 13, 10
                        db "Gerenciador de Inicializacao para Hexagon(R).", 13, 10
                        db "Copyright (C) 2020-2022 Felipe Miguel Nery Lunkes.", 13, 10
                        db "Todos os direitos reservados.", 13, 10, 0

;; Parâmetros que podem ser passados para o Hexagon®

HBoot.Parametros:

.verbose:           db 0
.forcarMemoria:     db 0
.forcarDisco:       db 0
.bufLeitura:        times 64 db 0 ;; Um buffer de parâmetro em texto para o Hexagon®  
.parada:            db 0          ;; Ponto de parada da exibição do conteúdo
.execucaoModulo:    db 0

;; Nome e informações de arquivo necessárias para o carregamento do Hexagon®

HBoot.Arquivos:

.nomeHBoot:         db "HBOOT      " ;; Nome de arquivo do HBoot em disco
.nomeImagem:        db "           " ;; Aqui será salvo o nome do arquivo que deverá ser carregado
.imagemHexagon:     db "HEXAGON SIS" ;; Nome do arquivo que contém o Kernel Hexagon®, a ser carregado
.parada:            db 0             ;; Ponto de parada da exibição do conteúdo
.imagemModulo:      times 64 db ' '  ;; Por segurança, um buffer maior
.imagemInvalida:    db 0             ;; A imagem é válida?
.segmentoFinal:     dw 0             ;; Aqui ficará a localização do segmento a ser carregado

HBoot.Controle:

.modoBoot: db 0

;;************************************************************************************

;; O arquivo será carregado no espaço abaixo

bufferDeDisco: 
