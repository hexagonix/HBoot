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

;; Image HAPP header size

HAPP_HEADER_SIZE = 26h ;; Version 2.0 of the HAPP definition

;; If no interaction has occurred, we must then look for and start Hexagon
;; If some interaction occurred but the user selected to continue booting,
;; we must also continue with the boot protocol

HBoot.Modules.Hexagon.Segments.segmentHexagon equ 0x50 ;; Segment for loading the Hexagon
HBoot.Modules.Hexagon.Files.imageHexagon:
db "HEXAGON    ", 0 ;; Name of the file containing the Hexagon kernel

;;************************************************************************************

HBoot.Lib.Hexagon.loadAndStartHexagon:

    fputs HBoot.Messages.loadHexagon

    call HBoot.Lib.Hexagon.configureHexagon ;; Configure image name and memory location

    call HBoot.FS.searchFile ;; Search for the file containing the kernel

    jmp HBoot.Lib.Hexgon.startHexagonKernel ;; Run Hexagon

;;************************************************************************************

;; Function that transfers execution to Hexagon, passing parameters through
;;registers, as described below:
;;
;; EBP - Pointer to the BIOS Parameter Block of the boot volume
;; DL  - Logical volume number used for boot
;; CX  - Quantity, in Kbytes, of RAM memory installed on the machine
;; More parameters can now be passed due to the creation of the second stage (HBoot)

HBoot.Lib.Hexgon.startHexagonKernel:

    pop ebp ;; Pointer to BPB
    mov esi, HBoot.Parameters.readBuffer + (SEG_HBOOT * 16) ;; Point ESI to parameters
    mov bl, byte[idDrive] ;; Drive used for boot
    mov cx, word[HBoot.Memx86.Control.availableMemory] ;; Installed memory

;; Hexagon features the HAPP header, which is standard on all Hexagon format executables.
;; This header is 38 bytes long (0x26), so we should skip it.
;; The data contained in the header will be validated in the future, if necessary

;; Configure CS:IP and run the kernel

    jmp HBoot.Modules.Hexagon.Segments.segmentHexagon:HAPP_HEADER_SIZE

;;************************************************************************************

HBoot.Lib.Hexagon.configureHexagon:

    mov si, HBoot.Modules.Hexagon.Files.imageHexagon
    mov di, HBoot.Files.imageName

    mov cx, 11

;; Copy file name

    rep movsb ;; Copy (ECX) characters from ESI to EDI

    mov word[HBoot.Files.finalSegment], HBoot.Modules.Hexagon.Segments.segmentHexagon

;; Let's set the Hexagon to boot mode

    mov byte[HBoot.Control.bootMode], 00h

    ret