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

HBoot.SistemaArquivos:

.codigo:          db 0
.tamanhoParticao: dd 0
.FAT12            = 01h ;; FAT12 (Futuro)
.FAT16            = 04h ;; FAT16 (< 32 MB)
.FAT16B           = 06h ;; FAT16B (FAT16B) - Suportado
.FAT16LBA         = 0Eh ;; FAT16 (LBA)

;;************************************************************************************

definirSistemaArquivos:
    
    call lerMBR

    mov byte[HBoot.SistemaArquivos.codigo], ah
    
    ret

;;************************************************************************************

lerMBR:

;; Primeiro devemos carregar a MBR na memória
    
    mov ax, 01h                    ;; Número de setores para ler
    mov esi, 00h                   ;; LBA do setor inicial
    mov di, bufferDeDisco          ;; Deslocamento
    mov dl, byte[idDrive] 

    call carregarSetor

    jc .erro

    mov ebx, bufferDeDisco

    add ebx, 0x1BE ;; Deslocamento da primeira partição

    mov ah, byte[es:ebx+04h]        ;; Contém o sistema de arquivos

    mov ebx, dword[es:ebx+0xF]      ;; Tamanho da partição

    mov dword[HBoot.SistemaArquivos.tamanhoParticao], ebx

    jmp .fim

.erro:

    mov si, HBoot.Mensagens.erroMBR

    call imprimir

    jmp $

.fim:

    ret

;;************************************************************************************

;; Aqui temos as funções genéricas chamadas, que redirecionarão para a lógica correta

procurarArquivo:

    mov ah, byte[HBoot.SistemaArquivos.codigo]

    cmp ah, HBoot.SistemaArquivos.FAT16B
    je .FAT16B 

    mov si, HBoot.Mensagens.saInvalido

    call imprimir

    jmp $

.FAT16B:

    call procurarArquivoFAT16B

    ret

;;************************************************************************************

;; Lista de Sistemas de Arquivos suportado pelo HBoot

include "FAT16B/fat16B.asm"
