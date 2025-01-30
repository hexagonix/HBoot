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

;;************************************************************************************
;;
;;                               Hexagon Boot
;;
;;                         Hexagon kernel boot loader
;;
;;               Copyright © 2020-2025 Felipe Miguel Nery Lunkes
;;                          All rights reserved
;;
;;************************************************************************************

;; HBoot works exclusively in 16-bit real mode.
;; Therefore, it implements device control and file system reading functions with code incompatible
;; with Hexagon. There is no Hexagon code here, with implementation made from scratch

use16

;; Hboot must feature a special HBoot image header expected by the first stage of booting.
;; There are 6 bytes, with signature (magic number) and target architecture

;; Let's include the version file

include "version.s"

HBootHeader:

.signature:     db "HBOOT"           ;; Signature, 5 bytes
.architecture:  db architectureHBoot ;; Architecture (i386), 1 byte
.modVersion:    db verHBoot          ;; Version
.modSubversion: db subverHBoot       ;; Subversion
.HBootName:     db "HBoot   "        ;; Module name

    jmp startHBoot

;;************************************************************************************

;; Let's include all the constants used

include "HBoot/hboot.s"

;; Macros used by HBoot

include "Lib/macros.s"

;; Filesystems abstraction layer (which includes the files from each filesystem)

include "FS/FS.asm"

;; Now include all code that directly deals with devices

include "Dev/dev.asm"

;; Now useful libraries

include "Lib/lib.asm"

;; Now, HBoot functions

include "HBoot/prompt.asm"
include "HBoot/sound.asm"

;; Messages and debugging

include "HBoot/messages.s"

;;************************************************************************************

startHBoot:

;; Configure stack and pointer

    cli ;; Disable interrupts

    mov ax, SEG_HBOOT
    mov ss, ax
    mov sp, 0

    sti ;; Enable interrupts

;; Save partition LBA address, provided by Saturno

    push esi ;; Here we have the BPB address

    mov dword[partitionLBAAdress], ebp ;; Save partition LBA here
    mov dword[BPBAdress], esi ;; Save BPB

;; Load segment registers to new position

    clc

    mov ax, SEG_HBOOT
    mov ds, ax
    mov es, ax

    sti

    mov byte[idDrive], dl ;; Save drive number

;;************************************************************************************

welcomeHBoot:

    call HBoot.Console.clearScreen ;; Clear the screen

    call HBoot.Sound.hexagonixBootSound ;; Play startup tone

    mov si, HBoot.Messages.starting

    call HBoot.Console.printString

analyzeDevice:

    call HBoot.Init.initDev

    call HBoot.FS.setFilesystem

;; Now we will check if the user wants to change the behavior of the boot process, including
;; passing parameters to the kernel, e.g.

    call HBoot.HBoot.verifyUserInteraction

    jmp HBoot.Lib.Hexagon.loadAndStartHexagon

;;************************************************************************************

;; Parameters that can be passed to Hexagon

HBoot.Parameters:

.verbose:
db 0
.forceMemory:
db 0
.forceDisk:
db 0
.readBuffer: ;; A text parameter buffer for Hexagon
times 64 db 0
.stopCharacter: ;; Content display stop point
db 0

;; Name and file information required for Hexagon loading

HBoot.Files:

.HBootFilename: ;; HBoot filename on volume
db "HBOOT      "
.imageName: ;; Here the name of the file to be loaded will be saved
db "           "
.moduleImage: ;; For safety, a larger buffer
times 64 db ' '
.stopCharacter: db 0 ;; Content display stop point
.invalidImage:  db 0 ;; Is the image valid?
.finalSegment:  dw 0 ;; Here will be the location of the segment to be loaded

HBoot.Control:

.bootMode: db 0

;;************************************************************************************

;; The file will be uploaded to the space below

diskBuffer:
