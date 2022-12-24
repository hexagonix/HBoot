;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2016-2023 Felipe Miguel Nery Lunkes
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

;;************************************************************************************
;;    
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;           
;;                  Copyright © 2020-2023 Felipe Miguel Nery Lunkes
;;                          Todos os direitos reservados
;;                                  
;;************************************************************************************

;; O HBoot funciona exclusivamente em modo real 16-bit. Sendo assim, implementa funções
;; de controle de dispositivos e de leitura de sistema de Arquivos com código incompatível
;; com o Hexagon®. Não existe código Hexagon® aqui, com implementação feita do zero

use16                   

;; O Hboot deve apresentar um cabeçalho especial de imagem HBoot, esperada pelo primeiro
;; estágio de inicialização. São 6 bytes, com assinatura (número mágico) e arquitetura 
;; alvo

;; Vamos incluir o arquivo de versão

include "HBoot/versao.asm"

cabecalhoHBoot:

.assinatura:  db "HBOOT"          ;; Assinatura, 5 bytes
.arquitetura: db arquiteturaHBoot ;; Arquitetura (i386), 1 byte
.versaoMod:   db verHBoot         ;; Versão
.subverMod:   db suvberHBoot      ;; Subversão
.nomeHBoot:   db "HBoot   "       ;; Nome do módulo

    jmp inicioHBoot

;;************************************************************************************

;; Vamos incluir todas as constantes utilizadas

include "HBoot/hboot.s"

;; Macros utilizados pelo HBoot

include "Lib/macros.s"

;; Camada de abstração de Sistemas de Arquivos (que inclui os arquivos de cada
;; sistema de Arquivos)

include "FS/univerFS.asm"

;; Agora incluir todo o código que lida diretamente com dispositivos 

include "Dev/dev.asm"

;; Agora, bibliotecas úteis

include "Lib/lib.asm"

;; Agora, funções do HBoot

include "HBoot/prompt.asm"
include "HBoot/tom.asm"

;; Mensagens e debug

include "HBoot/mensagens.s"

;;************************************************************************************

inicioHBoot:

;; Configurar pilha e ponteiro

    cli                ;; Desativar interrupções
    
    mov ax, SEG_HBOOT
    mov ss, ax
    mov sp, 0
    
    sti                ;; Habilitar interrupções

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

    jmp carregarHexagon

;;************************************************************************************

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
.imagemHexagon:     db "HEXAGON    " ;; Nome do arquivo que contém o Kernel Hexagon®, a ser carregado
.parada:            db 0             ;; Ponto de parada da exibição do conteúdo
.imagemModulo:      times 64 db ' '  ;; Por segurança, um buffer maior
.imagemInvalida:    db 0             ;; A imagem é válida?
.segmentoFinal:     dw 0             ;; Aqui ficará a localização do segmento a ser carregado

HBoot.Controle:

.modoBoot: db 0

;;************************************************************************************

;; O arquivo será carregado no espaço abaixo

bufferDeDisco: 
