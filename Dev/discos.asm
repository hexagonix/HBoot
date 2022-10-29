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
;; BSD 3-Clause License
;;
;; Copyright (c) 2015-2022, Felipe Miguel Nery Lunkes
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

HBoot.Disco:

.tamanho:       db 16
.reservado:     db 0
.totalSetores:  dw 0
.deslocamento:  dw 0x0000
.segmento:      dw 0
.LBA:           dd 0
                dd 0
.dsq0Online:    db 0
.dsq1Online:    db 0
.hd0Online:     db 0
.hd1Online:     db 0

;;************************************************************************************
;;  
;; Dados do disco
;;
;;************************************************************************************
                                                        
bytesPorSetor:       dw 512 ;; Número de bytes em cada setor
setoresPorCluster:   db 8   ;; Setores por cluster
setoresReservados:   dw 16  ;; Setores reservados após o setor de inicialização
totalFATs:           db 2   ;; Número de tabelas FAT
entradasRaiz:        dw 512 ;; Número total de pastas e arquivos no diretório raiz
setoresPorFAT:       dw 16  ;; Setores usados na FAT
idDrive:             db 0   ;; Número de identificação do drive.
tamanhoRaiz:         dw 0   ;; Tamanho do diretório raiz (em setores)
tamanhoFATs:         dw 0   ;; Tamanho das tabelas FAT (em setores)
areaDeDados:         dd 0   ;; Endereço físico da área de dados (LBA)
enderecoLBAParticao: dd 0   ;; Endereço LBA da partição
enderecoBPB:         dd 0   ;; Endereço do BIOS Parameter Block (BPB)
cluster:             dw 0   ;; Cluster atual
memoriaDisponivel:   dw 0   ;; Memória disponível

;;************************************************************************************

;; Carregar setor do disco especificado
;;
;; Entrada:
;;
;; AX  - Total de setores para carregar
;; ESI - Endereço LBA  
;; ES:DI - Localização do destino

carregarSetor:

    push si

    mov word[HBoot.Disco.totalSetores], ax
    mov dword[HBoot.Disco.LBA], esi
    mov word[HBoot.Disco.segmento], es
    mov word[HBoot.Disco.deslocamento], di

    mov dl, byte[idDrive]
    mov si, HBoot.Disco
    mov ah, 0x42        ;; Função de leitura
    
    int 13h             ;; Serviços de disco do BIOS
    
    jnc .concluido          

;; Se ocorrerem erros no disco, exibir mensagem de erro na tela

    mov si, HBoot.Mensagens.erroDisco   
    
    call imprimir
    
    jmp $

.concluido:
    
    pop si
    
    ret

;;************************************************************************************

verificarDiscos:

    pushad
    pushf

.verificardsq0:

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 00h 
 
    int 13h

    jc .errodsq0
 
    mov byte[HBoot.Disco.dsq0Online], 01h
 
    jmp .verificardsq1
 
.errodsq0:
 
    mov byte[HBoot.Disco.dsq0Online], 00h
  
    jmp .verificardsq1
  
.verificardsq1:
  
    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 01h 
 
    int 13h
 
    jc .errodsq1
 
    mov byte[HBoot.Disco.dsq1Online], 01h
 
    jmp verificarhd0
 
.errodsq1:
 
    mov byte[HBoot.Disco.dsq1Online], 00h

    jmp verificarhd0
 
;;************************************************************************************

verificarhd0:

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 80h 
 
    int 13h

    jc .errohd0
 
    mov byte[HBoot.Disco.hd0Online], 01h
 
    jmp .verificarhd1
 
 .errohd0:
 
    mov byte[HBoot.Disco.hd0Online], 00h
  
    jmp .verificarhd1
  
.verificarhd1:
  
    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 81h 
 
    int 13h
 
    jc .errohd1
 
    mov byte[HBoot.Disco.hd1Online], 01h
 
    jmp .continuar
 
 .errohd1:
 
    mov byte[HBoot.Disco.hd1Online], 00h

.continuar:

    clc 
    cld

    popf
    popad

    ret

;;************************************************************************************
