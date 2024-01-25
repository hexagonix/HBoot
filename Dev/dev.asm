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
;;                         Copyright (c) 2015-2024 Felipe Miguel Nery Lunkes
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
;; Copyright (c) 2015-2024, Felipe Miguel Nery Lunkes
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

use16

;; Here a table will be created in memory with information about the devices in a linear binary
;; tree, more like a matrix. The population with information about the devices, obtained by HBoot
;; through direct I/O analysis or by the BIOS, must respect the field order, so that this 
;; information can be decoded by Hexagon later.
;; This will replace Hexagon's "hard-coded" addresses and values.
;; The tree will have 128 fields of one word each, and each device will have two words for storing
;; information.
;; In the future, each one may have two words and a field to store the obtained name.

HBoot.Dev:

.deviceTree16: times 128 dw 0

;; Now the table must be populated during HBoot operation in a defined order as follows.
;; The address of this table will be provided to Hexagon so that it can decode it.
;; This ensures that more information can be passed, since we have a limited number of registers.
;; Follow according to the offset. The first one is empty and the second one with the corresponding
;; value

;; Field | Data/values/addresses/offsets
;;
;; 0    Empty/future use
;; 3    Total memory detected
;; 5    Address of first parallel port - 0 if absent
;; 7    Boot drive ID
;; 9    Number of available hard drives
;; 11   bool - presence or absence of floppy disk drives
;; 13   Boot drive file system ID
;; 15   Major version of HBoot
;; 17   Subversion of HBoot
;; 19   bool - presence or absence of command line for Hexagon
;; 21     
;; 23
;; 25
;; 27
;; 29
;; 31
;; 33
;; 35 
;; 37
;; 39
;; 41
;; 43
;; 45
;; 47
;; 49
;; 51
;; 53
;; 55
;; 57
;; 61
;; 63

.deviceTree32: times 64 dd 0

;; Now the table must be populated during HBoot operation in a defined order as follows.
;; The address of this table will be provided to Hexagon so that it can decode it.
;; This ensures that more information can be passed, since we have a limited number of registers.
;; Follow according to the offset

;; Field | Data/values/addresses/offsets
;;
;; 0    Empty/future use
;; 3       
;; 5       
;; 7       
;; 9       
;; 11      
;; 13      
;; 15      
;; 17        
;; 19      
;; 21     
;; 23
;; 25
;; 27
;; 29
;; 31

;;************************************************************************************

populateDeviceTree:

    push ax 
    push bx 
    push cx

.populateDeviceTree16:

;; Field 0 and 1 remain empty

;; Fields 2 and 3: total available memory

    mov ax, word[HBoot.Memx86.Control.availableMemory]
    mov word[HBoot.Dev.deviceTree16+3], ax
    mov word[HBoot.Dev.deviceTree16+2], 00h ;; Field 2

;; Fields 4 and 5: address of the first parallel port

    mov ax, word[HBoot.Parallel.Control.adressLPT1]
    mov word[HBoot.Dev.deviceTree16+5], ax
    mov word[HBoot.Dev.deviceTree16+4], 00h 

;; Fields 6 and 7: Boot drive id

    movzx ax, byte[idDrive]
    mov word[HBoot.Dev.deviceTree16+7], ax
    mov word[HBoot.Dev.deviceTree16+6], 00h 

.populateDeviceTree32:

    pop cx 
    pop bx 
    pop ax

    ret

;;************************************************************************************

;; This is the code glue for supported devices.
;; Included here are files that interact with machine devices

include "init.asm"
include "disks.asm"
include "keyboard.asm"
include "console.asm"
include "sound.asm"
include "memx86.asm"
include "procx86.asm"
include "BIOSx86.asm"
include "serial.asm"
include "parallel.asm"