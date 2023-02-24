;;*************************************************************************************************
;;
;; 88                                                                                88              
;; 88                                                                                ""              
;; 88                                                                                                
;; 88,dPPPba,   ,adPPPba, 8b,     ,d8 ,adPPPPba,  ,adPPPb,d8  ,adPPPba,  8b,dPPPba,  88 8b,     ,d8  
;; 88P'    "88 a8P     88  `P8, ,8P'  ""     `P8 a8"    `P88 a8"     "8a 88P'   `"88 88  `P8, ,8P'   
;; 88       88 8PP"""""""    )888(    ,adPPPPP88 8b       88 8b       d8 88       88 88    )888(     
;; 88       88 "8b,   ,aa  ,d8" "8b,  88,    ,88 "8a,   ,d88 "8a,   ,a8" 88       88 88  ,d8" "8b,   
;; 88       88  `"Pbbd8"' 8P'     `P8 `"8bbdP"P8  `"PbbdP"P8  `"PbbdP"'  88       88 88 8P'     `P8  
;;                                               aa,    ,88                                         
;;                                                "P8bbdP"       
;;
;;            Sistema Operacional Hexagonix® - Hexagonix® Operating System            
;;
;;                  Copyright © 2015-2023 Felipe Miguel Nery Lunkes
;;                Todos os direitos reservados - All rights reserved.
;;
;;*************************************************************************************************
;;
;; Português:
;; 
;; O Hexagonix e seus componentes são licenciados sob licença BSD-3-Clause. Leia abaixo
;; a licença que governa este arquivo e verifique a licença de cada repositório para
;; obter mais informações sobre seus direitos e obrigações ao utilizar e reutilizar
;; o código deste ou de outros arquivos.
;;
;; English:
;;
;; Hexagonix and its components are licensed under a BSD-3-Clause license. Read below
;; the license that governs this file and check each repository's license for
;; obtain more information about your rights and obligations when using and reusing
;; the code of this or other files.
;;
;;*************************************************************************************************
;;
;; BSD 3-Clause License
;;
;; Copyright (c) 2015-2023, Felipe Miguel Nery Lunkes
;; All rights reserved.
;; 
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;; 
;; 1. Redistributions of source code must retain the above copyright notice, this
;;    list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;    this list of conditions and the following disclaimer in the documentation
;;    and/or other materials provided with the distribution.
;;
;; 3. Neither the name of the copyright holder nor the names of its
;;    contributors may be used to endorse or promote products derived from
;;    this software without specific prior written permission.
;; 
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;
;; $HexagonixOS$

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

    cmp al, '5'
    je .reiniciarDispositivo

    ;; cmp al, '9'
    ;; je .alterarVerbose

    cmp al, 't'
    je .testarComponentes

    cmp al, 'T'
    je .testarComponentes


;; Se nenhuma tecla válida foi pressionada, retornar à escolha de
;; teclas

    jmp .pontoControlePressionouF8

;;*******************************

.reiniciarDispositivo:

    call pararDiscos

    hlt 

    int 19h 

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

    call pararDiscos
    
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

    call pararDiscos

    int 19h

.retornar:

    jmp .pontoPressionouF8

;;*******************************

.continuarBoot:
   
    ret

;;************************************************************************************
