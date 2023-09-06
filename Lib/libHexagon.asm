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

;; Caso nenhuma interação tenha acontecido, devemos então procurar e iniciar o Hexagon
;; Caso alguma interação tenha ocorrido mas o usuário selecionou continuar a inicialização,
;; também devemos continuar com o protocolo de boot

carregarHexagon:

    exibir HBoot.Mensagens.carregarHexagon

    call configurarInicioHexagon ;; Configura nome de imagem e localização em memória

    call procurarArquivo ;; Procurar o arquivo que contêm o Kernel

    jmp executarKernel ;; Executar o Hexagon

;;************************************************************************************

;; Função que transfere a execução para o Hexagon, passando parâmetros pelos
;; registradores, como descrito a seguir:
;;
;; EBP - Ponteiro para o BIOS Parameter Block do volume de boot
;; DL  - Número lógico do volume usado para a inicialização
;; CX  - Quantidade, em Kbytes, de memória RAM instalada na máquina
;; Mais parâmetros poderão ser passados agora em razão da criação do segundo
;; estágio (HBoot)

executarKernel:

    pop ebp ;; Ponteiro para o BPB
    mov esi, HBoot.Parametros.bufLeitura + (SEG_HBOOT * 16) ;; Apontar ESI para parâmetros
    mov bl, byte[idDrive] ;; Drive utilizado para a inicialização
    mov cx, word[memoriaDisponivel] ;; Memória RAM instalada

;; O Hexagon apresenta o cabeçalho HAPP, que será padrão em todos os executáveis no
;; formato Hexagon. Este cabeçalho apresenta 38 bytes (0x26), então devemos pulá-lo. Os
;; dados contidos no cabeçalho serão futuramente validados, se necessário

    jmp SEG_KERNEL:CABECALHO_HAPP ;; Configurar CS:IP e executar o Kernel

;;************************************************************************************

configurarInicioHexagon:

    mov si, HBoot.Arquivos.imagemHexagon
    mov di, HBoot.Arquivos.nomeImagem

    mov cx, 11

;; Copiar o nome do arquivo

    rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], SEG_KERNEL

;; Vamos marcar para modo de boot do Hexagon

    mov byte[HBoot.Controle.modoBoot], 00h

    ret