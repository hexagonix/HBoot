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
;;                     Sistema Operacional Hexagonix - Hexagonix Operating System
;;
;;                         Copyright (c) 2015-2023 Felipe Miguel Nery Lunkes
;;                        Todos os direitos reservados - All rights reserved.
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

;; Aqui vamos carregar módulos do HBoot, caso o usuário necessite dos mesmos. Estes
;; módulos podem futuramente extender as funções do HBoot, podendo ser desenvolvidos
;; para funções específicas, como teste de memória, testes de outros componentes e 
;; etc

CABECALHO_MODULO = 10h      ;; Versão 1.0 da definição de cabeçalhos de módulo
SEG_MODULOS      equ 0x2000 ;; Segmento para carregamento de imagens de diagnóstico

;;************************************************************************************

HBoot.modHBoot.Mensagens:

.retornoMod: db 13, 10, "HBoot: Voce retornou de um modulo HBoot finalizado.", 13, 10
             db "HBoot: E recomendado reiniciar o computador antes de iniciar o Hexagon.", 13, 10
             db "HBoot: Pressione [ENTER] para continuar...", 13, 10, 0

;;************************************************************************************

carregarModulo:

    mov byte[HBoot.Modulos.Controle.moduloAtivado], 01h

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.iniciarModulo

    call imprimir

    mov di, HBoot.Arquivos.imagemModulo

    call lerTeclado

    mov si, HBoot.Arquivos.imagemModulo
    mov di, HBoot.Arquivos.nomeImagem

    mov cx, 11
    
;; Copiar o nome do arquivo

    rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], SEG_MODULOS

    call procurarArquivo

    jc .gerenciarErroArquivo

    mov dl, byte[idDrive]            ;; Drive utilizado para a inicialização
    mov ebp, dword[enderecoBPB + (SEG_HBOOT * 16)] ;; Ponteiro para o BPB
    mov esi, dword[enderecoLBAParticao + (SEG_HBOOT * 16)] ;; Ponteiro para a partição

    push ss
    push sp

    jmp SEG_MODULOS:CABECALHO_MODULO ;; Configurar CS:IP e executar o módulo

.gerenciarErroArquivo:

    exibir HBoot.Mensagens.moduloAusente

    call aguardarTeclado
    
    jmp verificarInteracaoUsuario.testarComponentes

;;************************************************************************************

retornarModulo:

    mov ax, SEG_HBOOT
    mov ds, ax
    mov es, ax
    mov gs, ax

    pop ss
    pop sp 

    push ds
    pop es 
    
    exibir HBoot.modHBoot.Mensagens.retornoMod

    call aguardarTeclado

    jmp analisarPC