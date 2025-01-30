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
;;                         Copyright (c) 2015-2025 Felipe Miguel Nery Lunkes
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
;; Copyright (c) 2015-2025, Felipe Miguel Nery Lunkes
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

;; Function to clear the screen in real mode

HBoot.Console.clearScreen:

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

;; Function for print string in real mode
;;
;; Input:
;;
;; SI - String

HBoot.Console.printString:

    lodsb ;; mov AL, [SI] & inc SI
    
    or al, al ;; cmp AL, 0
    jz .done
    
    mov ah, 0Eh
    
    int 10h ;; Send [SI] to screen
    
    jmp HBoot.Console.printString
    
.done: 

    ret

;;************************************************************************************

HBoot.Console.printHexadecimal:

    pusha

    mov bp, sp
    mov si, [bp+18] 
    
.cont:
    
    lodsb
        
    or al, al
    jz .done
        
    mov ah, 0x0e
    mov bx, 0
    mov bl, 7 
    
    int 10h
        
    jmp .cont
        
.done:
    
    mov sp, bp
    
    popa
    
    ret

;;************************************************************************************

HBoot.Console.testVideo:

    mov ax, 19

    int 10h ;; 320x200 with 256 colors

    mov ax, 0A000h
    mov es, ax ;; Set DI for video memory segment
    xor bl, bl ;; BL will be used to store the figure number

.new:

    inc bl

    hlt ;; Processor will wait

    xor cx, cx
    xor dx, dx ;; CX and DX represent the coordinates
    xor di, di ;; Set di to start of screen

.a:

    mov al, cl
    xor al, dl
    
    add al, dl
    add al, bl ;; Create a color
    
    stosb ;; Write a pixel
    
    inc cx

    cmp cx, 320 ;; Update coordinates
    jne .a

    xor cx, cx
    
    inc dx

    cmp dx, 200
    jne .a

    mov ah, 1 ;; Check if any key has been pressed
    
    int 16h

    jz .new ;; If no key pressed, display another figure

    mov ax, 3 ;; Return to text mode
    
    int 10h

;; It is important to restore the segment before finishing!

    mov ax, SEG_HBOOT
    mov es, ax

    ret
