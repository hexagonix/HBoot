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

HBoot.Procx86.Data:

.processorVendor:
times 13 db 0
.processorName:
db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd", 0

;;************************************************************************************

HBoot.Procx86.initProc:

    call HBoot.Procx86.identifyProcessorVendor

    call HBoot.Procx86.identifyProcessorName

    call HBoot.Procx86.enableA20 ;; Trying to enable line A20

    ret

;;************************************************************************************

HBoot.Procx86.identifyProcessorVendor:

    mov eax, 0
    
    cpuid
    
    mov [HBoot.Procx86.Data.processorVendor], ebx
    mov [HBoot.Procx86.Data.processorVendor + 4], edx
    mov [HBoot.Procx86.Data.processorVendor + 8], ecx

    ret

;;************************************************************************************

HBoot.Procx86.identifyProcessorName:

    mov eax, 80000002h  
    
    cpuid
    
    mov di, HBoot.Procx86.Data.processorName     

    stosd

    mov eax, ebx

    stosd

    mov eax, ecx

    stosd

    mov eax, edx

    stosd
    
    mov eax, 80000003h

    cpuid
    
    stosd

    mov eax, ebx
    
    stosd
    
    mov eax, ecx
    
    stosd
    
    mov eax, edx
    
    stosd
    
    mov eax, 80000004h  
    
    cpuid
    
    stosd
    
    mov eax, ebx
    
    stosd
    
    mov eax, ecx
    
    stosd 
    
    mov eax, edx
    
    stosd
    
    mov si, HBoot.Procx86.Data.processorName
    
    mov cx, 48
    
.loopCPU:   

    lodsb

    cmp al, ' '
    jae .formatCPUName
    
    mov al, 0
    
.formatCPUName:   

    mov [si-1], al
    
    loop .loopCPU

    ret

;;************************************************************************************

;; Let's try to activate the A20 to see if the processor supports protected mode

HBoot.Procx86.enableA20:

    clc 

    mov ax, 0x2401 ;; Request A20 activation
        
    int 15h ;; BIOS Interrupt

    jc .errorA20

    ret 
    
.errorA20:

    fputs HBoot.Messages.errorA20

    jmp $