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

HBoot.Memx86.Control:

.availableMemory:   dw 0 ;; Available memory
.availableMemoryMB: dw 0 ;; Available memory in megabytes

;; Return total memory installed
;;
;; Input:
;;
;; Nothing
;;
;;
;; Output:
;;
;; AX - Total memory in megabytes (string)
;; BX - Total memoty (16-bit int)

HBoot.Memory.getTotalMemory:

    mov ax, word[HBoot.Memx86.Control.availableMemoryMB]

    call HBoot.Lib.LibString.toString

    mov bx, word[HBoot.Memx86.Control.availableMemoryMB]

    ret

;;*************************************************************************************************

HBoot.Memory.checkMemory:

    push edx
    push ecx
    push ebx

    xor eax, eax
    xor ebx, ebx
    
    mov ax, 0xE801
    
    xor dx, dx
    xor cx, cx
    
    int 15h
    
    jnc .process
    
    xor eax, eax
    
    jmp .end ;; Error

.quantify:

    mov si, ax
    
    or si, bx
    jne .quantify
    
    mov ax, cx
    mov bx, dx

.process:

    cmp ax, 0x3C00
    jb .below16MB
    
    movzx eax, bx
    
    add eax, 100h
    
    shl eax, 16 ;; EAX = EAX * 65536
    
    jmp .end

.below16MB:

    shl eax, 10 ;; EAX = EAX * 1024

.end:

    pop ebx
    pop ecx
    pop edx
    
;; Let's save the total recovered memory here. If it is sufficient for the process to continue,
;; the amount of installed RAM will be provided to Hexagon, in Kbytes

;; Let's compare whether the amount of RAM is enough for a successful boot

    shr eax, 10 ;; EAX = EAX / 1024

;; We now need to add memory below 1 MB that is available but does not enter into
;; the quantification made.

    add eax, 1024 ;; Ready. Let's add 1024 kbytes to the account

    mov word[HBoot.Memx86.Control.availableMemory], ax 

    cmp dword eax, MINIMUM_MEMORY
    jbe .memoryError ;; If less than that, we don't have enough

    shr eax, 10

    mov word[HBoot.Memx86.Control.availableMemoryMB], ax 

    ret

.memoryError:

    fputs HBoot.Messages.memoryError

    jmp $ ;; It can't go on. So stay here