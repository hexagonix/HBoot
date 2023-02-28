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
;;                    Sistema Operacional Hexagonix® - Hexagonix® Operating System
;;
;;                          Copyright © 2015-2023 Felipe Miguel Nery Lunkes
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

;; Função para limpar a tela em modo real

limparTela:

    mov dx, 0
    mov bh, 0
    mov ah, 2
    
    int 10h  
    
    mov ah, 6           
    mov al, 0           
    mov bh, 7           
    mov cx, 0           
    mov dh, 24          
    mov dl, 79
    
    int 10h

    ret

;;************************************************************************************

;; Função para imprimir string em modo real
;;
;; Entrada:
;;
;; SI - String

imprimir:

    lodsb       ;; mov AL, [SI] & inc SI
    
    or al, al   ;; cmp AL, 0
    jz .pronto
    
    mov ah, 0Eh
    
    int 10h     ;; Enviar [SI] para a tela
    
    jmp imprimir
    
.pronto: 

    ret

;;************************************************************************************

imprimirHexa:

    pusha

    mov bp, sp
    mov si, [bp+18] 
    
.cont:
    
    lodsb
        
    or al, al
    jz .pronto
        
    mov ah, 0x0e
    mov bx, 0
    mov bl, 7 
    
    int 10h
        
    jmp .cont
        
.pronto:
    
    mov sp, bp
    
    popa
    
    ret

;;************************************************************************************

testarVideo:

    mov ax, 19

    int 10h ;; 320x200 com 256 cores

    mov ax, 0A000h
    mov es, ax ;; Definir DI para o segmento de memória de vídeo
    xor bl, bl ;; BL será usado para armazenar o número da figura

.novo:

    inc bl

    hlt ;; Processador irá aguardar

    xor cx, cx
    xor dx, dx ;; CX e DX representam as coordenadas
    xor di, di ;; Defina di para o início da tela

.a:

    mov al, cl
    xor al, dl
    
    add al, dl
    add al, bl ;; Cria uma cor
    
    stosb      ;; Escreve um pixel
    
    inc cx

    cmp cx, 320 ;; Atualizar coordenadas
    jne .a

    xor cx, cx
    
    inc dx

    cmp dx, 200
    jne .a

    mov ah, 1  ;; Checa se alguma tecla foi pressionada
    
    int 16h

    jz .novo ;; Se nenhuma tecla pressionada, exiba outra figura

    mov ax, 3 ;; Retornar ao modo texto
    
    int 10h

;; Importante restaurar o segmento antes de finalizar!

    mov ax, SEG_HBOOT
    mov es, ax

    ret
