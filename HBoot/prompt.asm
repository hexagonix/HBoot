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

verificarInteracaoUsuario:

    exibir HBoot.Mensagens.aguardarUsuario

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

    exibir HBoot.Mensagens.pressionado

.pontoPressionouF8:

    novaLinha
    
    exibir HBoot.Mensagens.pressionouF8

    exibir HBoot.Mensagens.listaModif

    exibir HBoot.Mensagens.selecioneModif

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

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.sobreHBoot

    exibir HBoot.Mensagens.enterContinuar

    call aguardarTeclado

    jmp .retornar

;;*******************************

.alterarVerbose:

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.alterarVerbose

    mov ah, 00h

    int 16h

    cmp al, '0'
    je .desativarVerbose

    cmp al, '1'
    je .ativarVerbose

    exibir HBoot.Mensagens.falhaOpcao

    exibir HBoot.Mensagens.opcaoInvalida

    call aguardarTeclado

    exibir HBoot.Mensagens.prosseguirBoot

.desativarVerbose:

    mov byte[HBoot.Parametros.verbose], 00h

    exibir HBoot.Mensagens.prosseguirBoot

    jmp .retornar

.ativarVerbose:

    mov byte[HBoot.Parametros.verbose], 01h

    exibir HBoot.Mensagens.prosseguirBoot

    jmp .retornar

;;*******************************

.linhaComando:

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.linhaComando

    mov di, HBoot.Parametros.bufLeitura

    call lerTeclado

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.prosseguirBoot

    jmp .retornar

;;*******************************

.exibirInformacoesDetalhadas:

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.informacoesDetalhadas

    exibir HBoot.Mensagens.vendedorProcessador

;; Agora vamos verificar se existe algo dentro da variável

    exibir HBoot.Procx86.Dados.vendedorProcx86

    exibir HBoot.Mensagens.nomeProcessador

    mov si, HBoot.Procx86.Dados.nomeProcx86

    cmp byte[si], 0
    jne .comProcessadorVariavel

    mov si, HBoot.Mensagens.semCPUIDNome

.comProcessadorVariavel:

    call imprimir

    exibir HBoot.Mensagens.unidadesOnline

.verificarUnidadesOnline:

.verificardsq0:

    cmp byte[HBoot.Disco.dsq0Online], 01h
    je .dsq0Online

    jmp .verificardsq1

.dsq0Online:

    exibir HBoot.Mensagens.dsq0

    exibir HBoot.Mensagens.espacoSimples

.verificardsq1:

    cmp byte[HBoot.Disco.dsq1Online], 01h
    je .dsq1Online

    jmp .verificarhd0

.dsq1Online:

    exibir HBoot.Mensagens.dsq1

    exibir HBoot.Mensagens.espacoSimples

.verificarhd0:

    cmp byte[HBoot.Disco.hd0Online], 01h
    je .hd0Online

    jmp .verificarhd1

.hd0Online:

    exibir HBoot.Mensagens.hd0

    exibir HBoot.Mensagens.espacoSimples

.verificarhd1:

    cmp byte[HBoot.Disco.hd1Online], 01h
    je .hd1Online

    jmp .verificarConcluido

.hd1Online:

    exibir HBoot.Mensagens.hd1

    exibir HBoot.Mensagens.espacoSimples

.verificarConcluido:

   exibir HBoot.Mensagens.discoBoot

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

    exibir HBoot.Mensagens.dsq0

    jmp .continuarInformacoes

.dsq1:

    exibir HBoot.Mensagens.dsq1

    jmp .continuarInformacoes

.hd0:

    exibir HBoot.Mensagens.hd0

    jmp .continuarInformacoes

.hd1:

    exibir HBoot.Mensagens.hd1

    jmp .continuarInformacoes

.hd2:

    exibir HBoot.Mensagens.hd2

    jmp .continuarInformacoes

.hd3:

    exibir HBoot.Mensagens.hd3

    jmp .continuarInformacoes

.continuarInformacoes:

    exibir HBoot.Mensagens.sistemaArquivos

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

    exibir HBoot.Mensagens.FAT12

    jmp .continuarSistemaArquivos

.FAT16:

    exibir HBoot.Mensagens.FAT16

    jmp .continuarSistemaArquivos

.FAT16B:

    exibir HBoot.Mensagens.FAT16B

    jmp .continuarSistemaArquivos

.FAT16LBA:

    exibir HBoot.Mensagens.FAT16LBA

    jmp .continuarSistemaArquivos


.continuarSistemaArquivos:

    exibir HBoot.Mensagens.arquivoHexagon

    exibir HBoot.Arquivos.imagemHexagon

    exibir HBoot.Mensagens.infoLinhaComando

    mov si, HBoot.Parametros.bufLeitura

    cmp byte[si], 0
    je .semLinhaDefinida

    call imprimir

    jmp .continuarLinha

.semLinhaDefinida:

    exibir HBoot.Mensagens.linhaVazia
  
.continuarLinha:

    exibir HBoot.Mensagens.versaoHBoot

    exibir HBoot.Mensagens.versaoProtocolo

    exibir HBoot.Mensagens.enterContinuar

    call aguardarTeclado

    jmp .retornar

;;*******************************

.testarComponentes:

    exibir HBoot.Mensagens.pressionado

.semAviso:

    exibir HBoot.Mensagens.testarComponentes

    exibir HBoot.Mensagens.listaComponentes

    exibir HBoot.Mensagens.selecioneComponente

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

    cmp al, 'm'
    je .carregarModuloHBoot

    cmp al, 'M'
    je .carregarModuloHBoot

    jmp .pontoControleTeste

;;*******************************

.carregarModuloHBoot:

   jmp carregarModulo
  
;;*******************************

.iniciarDOS:

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.modoDOS

    exibir HBoot.Mensagens.selecioneModif

.selecionarDOS:

    mov ah, 0

    int 16h 

;; Agora vamos comparar com as opções disponíveis

    cmp al, '1'
    je .iniciarFreeDOS

    cmp al, '2'
    je .testarComponentes

    jmp .selecionarDOS

.iniciarFreeDOS:

;; Vamos marcar como modo de compatibilidade DOS para o boot

    mov byte[HBoot.Controle.modoBoot], 01h

    jmp HBoot.Modulos.DOS.iniciarFreeDOS

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

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.exibirRegs

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

    exibir HBoot.Mensagens.reinicioContinuar

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

    exibir HBoot.Mensagens.pressionado

    exibir HBoot.Mensagens.reinicioContinuarED

    call aguardarTeclado

    int 19h

.retornar:

    jmp .pontoPressionouF8

;;*******************************

.continuarBoot:
   
    ret

;;************************************************************************************
