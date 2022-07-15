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

    jmp inicioHBoot

;;************************************************************************************

;; Vamos incluir todas as constantes utilizadas

include "hboot.s"

;; Macros utilizados pelo HBoot

include "macros.s"

;; Camada de abstração de Sistemas de Arquivos (que inclui os arquivos de cada
;; Sistema de Arquivos)

include "FS/univerFS.asm"

;; Agora incluir todo o código que lida diretamente com dispositivos 

include "Dev/dev.asm"

;; Agora, bibliotecas úteis

include "Lib/string.asm"
include "Lib/num.asm"
include "Lib/DOS.asm"

;;************************************************************************************

inicioHBoot:

;; Configurar pilha e ponteiro

    cli				   ;; Desativar interrupções
    
    mov ax, SEG_HBOOT
    mov ss, ax
    mov sp, 0
    
    sti				   ;; Habilitar interrupções

;; Salvar entedereço LBA da partição, fornecido pelo Saturno®

    push esi ;; Aqui temos o endereço do BPB
    
    mov dword[enderecoLBAParticao], ebp ;; Salvar aqui o LBA da partição
    mov dword[enderecoBPB], esi         ;; Salvar o BPB
    
;; Carregar registradores de segmento para a nova posição
     
    clc 

    mov ax, SEG_HBOOT
    mov ds, ax
    mov es, ax
    
    sti

    mov byte[idDrive], dl ;; Salvar número do drive

;;************************************************************************************

boasVindasHBoot:

    pushad

    call limparTela       ;; Limpar a tela

    call tomInicializacao ;; Tocar tom de inicialização
 
    mov si, HBoot.Mensagens.iniciando
    
    call imprimir

analisarPC:

    call initDev

    call definirSistemaArquivos
    
;; Agora iremos verificar se o usuário deseja alterar o comportamento do processo
;; de inicialização, inclusive passando parâmetros para o núcleo, por exemplo

    call verificarInteracaoUsuario 

    popad 

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
    mov dl, byte[idDrive]           ;; Drive utilizado para a inicialização
    mov cx, word[memoriaDisponivel] ;; Memória RAM instalada

;; O Hexagon® apresenta o cabeçalho HAPP, que será padrão em todos os executáveis no
;; formato Hexagon®. Este cabeçalho apresenta 38 bytes (0x26), então devemos pulá-lo. Os 
;; dados contidos no cabeçalho serão futuramente validados, se necessário

    jmp SEG_KERNEL:CABECALHO_HAPP   ;; Configurar CS:IP e executar o Kernel

;;************************************************************************************

;; Tocar tom de inicialização do Sistema, tal como em Macs/Apple

tomInicializacao:
  
;; Roteiro de execução com nota e tempo. Macro em "HBOOT.S"

    tocarNota HBoot.Sons.nDO, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nLA, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nDO, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nLA, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nFA, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nSI, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nDO2, HBoot.Sons.tNormal

    call desligarsom

    ret

;;************************************************************************************

verificarInteracaoUsuario:

    mov si, HBoot.Mensagens.aguardarUsuario

    call imprimir

    mov bx, 0

.loopSegundos:

    mov dx, FATOR_TEMPO

    call executarAtraso

    add bx, 1

    cmp bx, CICLOS_PARAMETROS_INICIACAO
    je .continuarBoot

    mov ah, 1

    int 16h
 
    jz .loopSegundos

    mov ah, 0

    int 16h

    cmp ah, F8 ;; F8
    je .pressionouF8

    jmp .continuarBoot

;;*******************************

.pressionouF8:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

.pontoPressionouF8:

    novaLinha
    
    mov si, HBoot.Mensagens.pressionouF8

    call imprimir

    mov si, HBoot.Mensagens.listaModif

    call imprimir

    mov si, HBoot.Mensagens.selecioneModif

    call imprimir

.pontoControlePressionouF8:

;; Agora vamos verificar qual a opção selecionada pelo usuário para modificar o comportamento
;; da inicialização. Vamos primeiro ler o número

    mov ah, 0

    int 16h 

;; Agora vamos comparar com as opções disponíveis

    cmp al, '1'
    je .linhaComando

    cmp al, '2'
    je .exibirInformacoesDetalhadas

    cmp al, '3'
    je .continuarBoot

    cmp al, '4'
    je .infoHBoot

    ;; cmp al, '5'
    ;; je .alterarVerbose

    cmp al, 't'
    je .testarComponentes

    cmp al, 'T'
    je .testarComponentes


;; Se nenhuma tecla válida foi pressionada, retornar à escolha de
;; teclas

    jmp .pontoControlePressionouF8

;;*******************************

;; Aqui vamos fornecer mais informações sobre o HBoot

.infoHBoot:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.sobreHBoot

    call imprimir

    mov si, HBoot.Mensagens.enterContinuar

    call imprimir 

    call aguardarTeclado

    jmp .retornar

;;*******************************

.alterarVerbose:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.alterarVerbose

    call imprimir

    mov ah, 00h

    int 16h

    cmp al, '0'
    je .desativarVerbose

    cmp al, '1'
    je .ativarVerbose

    mov si, HBoot.Mensagens.falhaOpcao

    call imprimir

    mov si, HBoot.Mensagens.opcaoInvalida

    call imprimir

    mov ah, 00h

    int 16h

    mov si, HBoot.Mensagens.prosseguirBoot

    call imprimir

.desativarVerbose:

    mov byte[HBoot.Parametros.verbose], 00h

    mov si, HBoot.Mensagens.prosseguirBoot

    call imprimir

    jmp .retornar

.ativarVerbose:

    mov byte[HBoot.Parametros.verbose], 01h

    mov si, HBoot.Mensagens.prosseguirBoot

    call imprimir

    jmp .retornar

;;*******************************

.linhaComando:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.linhaComando

    call imprimir

    mov di, HBoot.Parametros.bufLeitura

    call lerTeclado

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.prosseguirBoot

    call imprimir

    jmp .retornar

;;*******************************

.exibirInformacoesDetalhadas:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.informacoesDetalhadas
    
    call imprimir

    mov si, HBoot.Mensagens.vendedorProcessador

    call imprimir

    mov si, HBoot.Procx86.Dados.vendedorProcx86

    call imprimir

    mov si, HBoot.Mensagens.nomeProcessador

    call imprimir

    mov si, HBoot.Procx86.Dados.nomeProcx86

    call imprimir

    mov si, HBoot.Mensagens.unidadesOnline

    call imprimir

.verificarUnidadesOnline:

.verificardsq0:

    cmp byte[HBoot.Disco.dsq0Online], 01h
    je .dsq0Online

    jmp .verificardsq1

.dsq0Online:

    mov si, HBoot.Mensagens.dsq0

    call imprimir

    mov si, HBoot.Mensagens.espacoSimples

    call imprimir

.verificardsq1:

    cmp byte[HBoot.Disco.dsq1Online], 01h
    je .dsq1Online

    jmp .verificarhd0

.dsq1Online:

    mov si, HBoot.Mensagens.dsq1

    call imprimir

    mov si, HBoot.Mensagens.espacoSimples

    call imprimir

.verificarhd0:

    cmp byte[HBoot.Disco.hd0Online], 01h
    je .hd0Online

    jmp .verificarhd1

.hd0Online:

    mov si, HBoot.Mensagens.hd0

    call imprimir

    mov si, HBoot.Mensagens.espacoSimples

    call imprimir

.verificarhd1:

    cmp byte[HBoot.Disco.hd1Online], 01h
    je .hd1Online

    jmp .verificarConcluido

.hd1Online:

    mov si, HBoot.Mensagens.hd1

    call imprimir

    mov si, HBoot.Mensagens.espacoSimples

    call imprimir

.verificarConcluido:

    mov si, HBoot.Mensagens.discoBoot

    call imprimir

    mov dl, byte[idDrive]

    cmp dl, 00h
    je .dsq0

    cmp dl, 01h
    je .dsq1
    
    cmp dl, 80h
    je .hd0
    
    cmp dl, 81h
    je .hd1
    
    cmp dl, 82h
    je .hd2
    
    cmp dl, 83h
    je .hd3

.dsq0:

    mov si, HBoot.Mensagens.dsq0

    call imprimir

    jmp .continuarInformacoes

.dsq1:

    mov si, HBoot.Mensagens.dsq1

    call imprimir

    jmp .continuarInformacoes

.hd0:

    mov si, HBoot.Mensagens.hd0

    call imprimir

    jmp .continuarInformacoes

.hd1:

    mov si, HBoot.Mensagens.hd1

    call imprimir

    jmp .continuarInformacoes

.hd2:

    mov si, HBoot.Mensagens.hd2

    call imprimir

    jmp .continuarInformacoes

.hd3:

    mov si, HBoot.Mensagens.hd3

    call imprimir

    jmp .continuarInformacoes

.continuarInformacoes:

    mov si, HBoot.Mensagens.sistemaArquivos

    call imprimir

    cmp byte[HBoot.SistemaArquivos.codigo], HBoot.SistemaArquivos.FAT12
    je .FAT12

    cmp byte[HBoot.SistemaArquivos.codigo], HBoot.SistemaArquivos.FAT16
    je .FAT16

    cmp byte[HBoot.SistemaArquivos.codigo], HBoot.SistemaArquivos.FAT16B
    je .FAT16B

    cmp byte[HBoot.SistemaArquivos.codigo], HBoot.SistemaArquivos.FAT16LBA
    je .FAT16LBA

    mov si, HBoot.Mensagens.saDesconhecido

.FAT12:

    mov si, HBoot.Mensagens.FAT12

    call imprimir

    jmp .continuarSistemaArquivos

.FAT16:

    mov si, HBoot.Mensagens.FAT16

    call imprimir

    jmp .continuarSistemaArquivos

.FAT16B:

    mov si, HBoot.Mensagens.FAT16B

    call imprimir

    jmp .continuarSistemaArquivos

.FAT16LBA:

    mov si, HBoot.Mensagens.FAT16LBA

    call imprimir

    jmp .continuarSistemaArquivos


.continuarSistemaArquivos:

    mov si, HBoot.Mensagens.arquivoHexagon

    call imprimir

    mov si, HBoot.Arquivos.imagemHexagon

    call imprimir

    mov si, HBoot.Mensagens.infoLinhaComando

    call imprimir

    mov si, HBoot.Parametros.bufLeitura

    cmp byte[si], 0
    je .semLinhaDefinida

    call imprimir

    jmp .continuarLinha

.semLinhaDefinida:

    mov si, HBoot.Mensagens.linhaVazia
    
    call imprimir 

.continuarLinha:

    mov si, HBoot.Mensagens.versaoHBoot

    call imprimir

    mov si, HBoot.Mensagens.versaoProtocolo

    call imprimir

    mov si, HBoot.Mensagens.enterContinuar

    call imprimir 

    call aguardarTeclado

    jmp .retornar

;;*******************************

.testarComponentes:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

.semAviso:

    mov si, HBoot.Mensagens.testarComponentes

    call imprimir

    mov si, HBoot.Mensagens.listaComponentes

    call imprimir

    mov si, HBoot.Mensagens.selecioneComponente

    call imprimir

.pontoControleTeste:

;; Agora vamos verificar qual a opção selecionada pelo usuário para modificar o comportamento
;; da inicialização. Vamos primeiro ler o número

    mov ah, 0

    int 16h 

;; Agora vamos comparar com as opções disponíveis

    cmp al, '1'
    je .testarTom

    cmp al, '2'
    je .exibirRegs

    cmp al, '3'
    je .testarVideo

    cmp al, '4'
    je .reiniciar

    cmp al, '5'
    je .pontoPressionouF8

    cmp al, 'd'
    je .iniciarDOS

    cmp al, 'D'
    je .iniciarDOS

    jmp .pontoControleTeste

;;*******************************

.iniciarDOS:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.modoDOS

    call imprimir

    mov si, HBoot.Mensagens.selecioneModif

    call imprimir

.selecionarDOS:

    mov ah, 0

    int 16h 

;; Agora vamos comparar com as opções disponíveis

    cmp al, '1'
    je .iniciarFreeDOS

    cmp al, 'v'
    je .testarComponentes

    cmp al, 'V'
    je .testarComponentes

    jmp .selecionarDOS

.iniciarFreeDOS:

 ;; Vamos marcar como modo de compatibilidade DOS para o boot

    mov byte[HBoot.Controle.modoBoot], 01h

    jmp HBoot.DOS.iniciarFreeDOS

;;*******************************

.testarTom:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    tocarNota HBoot.Sons.CANON1, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.CANON2, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.CANON3, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.CANON4, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.CANON5, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.CANON6, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.CANON7, HBoot.Sons.tNormal  
    tocarNota HBoot.Sons.CANON8, HBoot.Sons.tExtendido   

    call desligarsom

    jmp .testarComponentes

;;*******************************

.exibirRegs:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.exibirRegs

    call imprimir

    push HBoot.Mensagens.axx
    push ax
    
    call parahexa

    push HBoot.Mensagens.bxx
    push bx

    call parahexa

    push HBoot.Mensagens.cxx
    push cx

    call parahexa

    push HBoot.Mensagens.dxx
    push dx
    
    call parahexa

    push HBoot.Mensagens.css
    push cs
    
    call parahexa

    push HBoot.Mensagens.dss
    push ds
    
    call parahexa

    push HBoot.Mensagens.sss
    push ss
    
    call parahexa

    push HBoot.Mensagens.ess
    push es
    
    call parahexa

    push HBoot.Mensagens.spp
    push sp
    
    call parahexa

    push HBoot.Mensagens.sii
    push si
    
    call parahexa

    push HBoot.Mensagens.dii
    push di
    
    call parahexa

    push HBoot.Mensagens.gss
    push gs
    
    call parahexa

    push HBoot.Mensagens.fss
    push fs
    
    call parahexa

    mov si, HBoot.Mensagens.reinicioContinuar

    call imprimir

    call aguardarTeclado

    int 19h

;; Se falhar, vamos ficar aqui até o reinício vir automaticamente

    jmp $

;;*******************************

.testarVideo:

    pushad
    pushf

    call testarVideo

    popf 
    popad 

    jmp .semAviso

;;*******************************

.reiniciar:

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.reinicioContinuarED

    call imprimir

    call aguardarTeclado

    int 19h

.retornar:

    jmp .pontoPressionouF8

;;*******************************

.continuarBoot:
   
    ret

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

;;************************************************************************************
;;
;; Variáveis e constantes utilizadas 
;;
;;************************************************************************************

HBoot.Mensagens:

.iniciando:             db "HBoot: Hexagon(R) Boot (HBoot) versao ", versaoHBoot, " iniciado.", 13, 10
                        db "HBoot: Gerenciador de Inicializacao para Hexagon(R).", 13, 10
                        db "HBoot: Copyright (C) 2020-2021 Felipe Miguel Nery Lunkes.", 13, 10
                        db "HBoot: Todos os direitos reservados.", 13, 10, 0
.naoEncontrado:         db 13,10, "HBoot: A imagem do Hexagon(R) nao foi encontrada no disco atual.", 13, 10
                        db "HBoot: Impossivel continuar com o protocolo de inicializacao. Tente realizar", 13, 10
                        db "HBoot: uma restauracao ou reinstalacao do Sistema e tente iniciar o Sistema", 13, 10
                        db "HBoot: novamente.", 13, 10, 0
.erroDisco:             db "HBoot: Erro de disco!", 0 ;; Mensagem de erro no disco
.erroA20:               db "HBoot: Erro ao habilitar a linha A20, necessaria para o", 13, 10
                        db "HBoot: o modo protegido.", 13, 10
                        db "HBoot: Impossivel continuar a inicializacao. Reinicie seu computador.", 0
.erroMemoria:           db "HBoot: Memoria RAM instalada insuficiente para executar o Hexagon(R).", 13, 10
                        db "HBoot: Impossivel continuar. Ao menos 32 Mb sao necessarios.", 13, 10
                        db "HBoot: Instale mais memoria e tente novamente.", 0
.imagemInvalida:        db 13, 10, "HBoot: A imagem em disco do Hexagon(R) parece estar corrompida e nao pode", 13, 10
                        db "HBoot: ser utilizada para a inicializacao. Tente reinstalar ou recuperar o", 13, 10
                        db "HBoot: Sistema para continuar.", 0
.modoDOS:               db 13, 10, "HBoot: O HBoot entrou em modo de compatibilidade de iniciacao DOS.", 13, 10
                        db "HBoot: Isso significa que voce pode iniciar algum sistema DOS instalado na", 13, 10
                        db "HBoot: mesma particao/volume do Hexagon(R)/Andromeda(R), caso ele suporte o", 13, 10
                        db "HBoot: Sistema de Arquivos do volume Hexagon(R). Selecione abaixo a opcao mais", 13, 10
                        db "HBoot: pertinente para o seu caso. Lembrando que esta e uma funcao ainda em", 13, 10
                        db "HBoot: teste e problemas podem ocorrer. Caso nao tenha um sistema DOS instalado", 13, 10
                        db "HBoot: no volume de instalacao do Hexagon(R), o processo ira falhar.", 13, 10
                        db " > [1] Iniciar FreeDOS instalado no volume Hexagon(R).", 10, 13
                        db " > [v,V]: Retornar ao menu anterior.", 13, 10, 0
.aguardarUsuario:       db "HBoot: Pressione [F8] para alterar parametros de inicializacao...",  0
.pressionado:           db "[Ok]", 13, 10, 0
.falhaOpcao:            db "[Falha]", 13, 10, 0
.sobreHBoot:            db 13, 10, "Hboot: Informacoes do Hexagon(R) Boot - HBoot versao ", versaoHBoot, 13, 10, 13, 10
                        db "O Hexagon Boot (HBoot) e um gerenciador de inicializacao poderoso", 13, 10
                        db "desenvolvido para inicializar o kernel Hexagon(R) em um volume do", 13, 10
                        db "armazenamento do seu computador. O HBoot tem como funcao realizar", 13, 10
                        db "testes para verificar se o computador pode executar o Hexagon(R) e,", 13, 10
                        db "apos os testes, carregar o kernel, fornecer parametros (caso sejam", 13, 10
                        db "fornecidos pelo usuario) e iniciar a execucao do Hexagon(R).", 0
.pressionouF8:          db "HBoot: Aqui voce pode alterar parametros de boot do Hexagon(R).", 13, 10, 0
.listaModif:            db 13,10, "HBoot: Voce pode alterar os parametros abaixo (lista provisoria):", 13, 10
                        db " > [1]: Fornecer linha de comando personalizada.", 13, 10
                        db " > [2]: Obter informacoes do ambiente de inicializacao.", 13, 10
                        db " > [3]: Confirmar alteracoes/informacoes e continuar a inicializacao.", 13, 10
                        db " > [4]: Mais informacoes sobre o HBoot.", 13, 10, 0
.selecioneModif:        db 13, 10, "HBoot: Selecione opcao: ", 0
.modifIndisponivel:     db 13, 10, "HBoot: Opcao invalida. Pressione [ENTER] para continuar boot.", 0
.testarComponentes:     db 13, 10, "HBoot: Aqui voce pode testar componentes do HBoot, bem como utilizar", 13, 10
                        db "HBoot: funcoes e recursos em desenvolvimento ou que nao sao de uso amplo.", 13, 10, 0
.listaComponentes:      db 13, 10, "HBoot: Voce pode testar alguns componentes (lista provisoria):", 13, 10
                        db "HBoot: Aviso! Alguns testes requerem reinicio do computador!", 13, 10
                        db " > [1]: Testar tom de inicializacao (chora, Mac).", 13, 10
                        db " > [2]: Exibir conteudo dos registradores (necessario posterior reinicio).", 13, 10
                        db " > [3]: Realizar teste de video em modo grafico.", 13, 10
                        db " > [4]: Reiniciar o computador.", 13, 10
                        db " > [5]: Retornar ao menu anterior.", 13, 10
                        db " > [d,D]: Iniciar modo de compatibilidade de boot e iniciar sistema DOS.", 13, 10, 0
.exibirRegs:            db 13, 10, 13, 10, "HBoot: Lista e conteudo dos registradores do processador principal (proc0):", 13, 10, 13, 10, 0
.selecioneComponente:   db 13, 10, "HBoot: Selecione opcao: ", 0
.componenteInvalido:    db 13, 10, "HBoot: Opcao invalida. Pressione [ENTER] retornar.", 13, 10, 0
.alterarVerbose:        db 13, 10, "HBoot: Escolha (0) para desligar verbose ou (1) para ligar:", 0
.opcaoInvalida:         db 13, 10, "HBoot: Opcao de alteracao de comportamento invalida para a selecao.", 13, 10
                        db "HBoot: Pressione [ENTER] para continuar o boot sem alteracao de comportamento...", 13, 10, 0
.prosseguirBoot:        db "HBoot: Prosseguindo com o protocolo de boot...", 13, 10, 0       
.linhaComando:          db 13, 10, "HBoot: Insira a linha de comando para o Hexagon(R). Atente para os parametros", 13, 10
                        db "suportados, com maximo de 64 caracteres.", 13, 10
                        db "> ", 0        
.saInvalido:            db 13, 10, "HBoot: O Sistema de Arquivos do volume nao e suportado pelo HBoot no momento.", 13, 10, 0     
.erroMBR:               db 13, 10, "HBoot: Erro ao tentar recuperar informacoes da MBR. Impossivel continuar.", 13, 10, 0
.informacoesDetalhadas: db 13, 10, "HBoot: Informacoes detalhadas do ambiente de inicializacao:", 0
.informacaoMemoria:     db 13, 10, " > Memoria total instalada: ", 0
.vendedorProcessador:   db 13, 10, " > Informacao do processador (assinatura do fabricante): ", 0
.nomeProcessador:       db 13, 10, " > Nome do processador: ", 0
.discoBoot:             db 13, 10, " > Volume de inicializacao (nome Hexagon(R)): ", 0
.arquivoHexagon:        db 13, 10, " > Imagem do Hexagon(R) em disco a ser carregada: ", 0
.infoLinhaComando:      db 13, 10, " > Linha de comando para o Hexagon(R): ", 0
.linhaVazia:            db "<vazio>", 0
.hd0:                   db "hd0", 0
.hd1:                   db "hd1", 0
.hd2:                   db "hd2", 0
.hd3:                   db "hd3", 0
.dsq0:                  db "dsq0", 0
.dsq1:                  db "dsq1", 0
.cdrom0:                db "cdrom0", 0
.sistemaArquivos:       db 13, 10, " > Sistema de Arquivos do volume: ", 0
.FAT16:                 db "FAT16", 0
.FAT16B:                db "FAT16B", 0
.FAT12:                 db "FAT12", 0
.FAT16LBA:              db "FAT16LBA", 0
.FAT32:                 db "FAT32", 0
.saDesconhecido:        db "<desconhecido>", 0
.enterContinuar:        db 13, 10
.enterContinuarEU:      db 13, 10, "HBoot: pressione [ENTER] para retornar ao menu anterior...", 13, 10, 0
.tamanhoParticao:       db 13, 10, " > Tamanho da particao do volume: ", 0
.versaoHBoot:           db 13, 10, " > Versao do HBoot: ", versaoHBoot, 0
.versaoProtocolo:       db 13, 10, " > Versao do protocolo de boot do Hexagon(R): ", verProtocolo, 0
.novaLinha:             db 13, 10, 0
.unidadesOnline:        db 13, 10, " > Unidades online (nomes Hexagon(R)): ", 0
.espacoSimples:         db " ", 0
.hex:                   db "0x0000", 13, 10, 0
.hexc:                  db "0123456789ABCDEF"
.css:                   db " > Registrador CS: ",0
.dss:                   db " > Registrador DS: ",0
.sss:                   db " > Registrador SS: ",0
.ess:                   db " > Registrador ES: ",0
.gss:                   db " > Registrador GS: ",0
.fss:                   db " > Registrador FS: ",0
.axx:                   db " > Registrador AX: ",0
.bxx:                   db " > Registrador BX: ",0
.cxx:                   db " > Registrador CX: ",0
.dxx:                   db " > Registrador DX: ",0
.spp:                   db " > Registrador SP: ",0
.bpp:                   db " > Registrador BP: ",0
.sii:                   db " > Registrador SI: ",0
.dii:                   db " > Registrador DI: ",0
.reinicioContinuarED:   db 13, 10
.reinicioContinuar:     db 13, 10, "Pressione [ENTER] para reiniciar o computador (necessario)...", 13, 10, 0

;; Parâmetros que podem ser passados para o Hexagon®

HBoot.Parametros:

.verbose:           db 0
.forcarMemoria:     db 0
.forcarDisco:       db 0
.bufLeitura:        times 64 db 0 ;; Um buffer de parâmetro em texto para o Hexagon®  
.parada:            db 0          ;; Ponto de parada da exibição do conteúdo

;; Nome e informações de arquivo necessárias para o carregamento do Hexagon®

HBoot.Arquivos:

.nomeHBoot:         db "HBOOT      " ;; Nome de arquivo do HBoot em disco
.nomeImagem:        db "           " ;; Aqui será salvo o nome do arquivo que deverá ser carregado
.imagemHexagon:     db "HEXAGON SIS" ;; Nome do arquivo que contém o Kernel Hexagon®, a ser carregado
.parada:            db 0             ;; Ponto de parada da exibição do conteúdo
.imagemInvalida:    db 0             ;; A imagem é válida?
.segmentoFinal:     dw 0             ;; Aqui ficará a localização do segmento a ser carregado

HBoot.Sons: ;; Frequências de som para as notas musicais utilizadas para a música

;; Tema do Andromeda®

.nDO  = 2000
.nRE  = 2100
.nMI  = 2300
.nFA  = 2700
.nSOL = 3000
.nLA  = 3200
.nSI  = 3600
.nDO2 = 4060

;; CANON

.CANON1 = 3060
.CANON2 = 4020
.CANON3 = 3800
.CANON4 = 5400
.CANON5 = 5080
.CANON6 = 7120
.CANON7 = 5080
.CANON8 = 4420

;; Temporizador padrão em microssegundos

.tNormal    = 01h
.tExtendido = 02h

HBoot.Controle:

.modoBoot: db 0

;;************************************************************************************

;; O arquivo será carregado no espaço abaixo

bufferDeDisco: 
