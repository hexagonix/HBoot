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
;;                         Copyright (c) 2015-2026 Felipe Miguel Nery Lunkes
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
;; Copyright (c) 2015-2026, Felipe Miguel Nery Lunkes
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

;; Here we will load HBoot modules, if the user needs them.
;; These modules can in the future extend the functions of HBoot, and can be developed for specific
;; functions, such as memory testing, testing of other components, etc

MODULE_HEADER  = 10h      ;; Module headers definition version 1.0

;; Segment for loading module images. It has to stay clear of 0x2000, where
;; Saturno relocated itself, since the BIOS Parameter Block sitting there is
;; what HBoot hands the kernel

MODULE_SEGMENT equ 0x3000

;;************************************************************************************

HBoot.modHBoot.Messages:

.modReturn:
db 13, 10, "HBoot: You have returned from a finished HBoot module.", 13, 10
db "HBoot: Press [ENTER] to continue...", 13, 10, 0

;;************************************************************************************

HBoot.Lib.HMod.loadAndStartHBootModule:

    mov byte[HBoot.Modules.Control.moduleActivated], 01h

    mov si, HBoot.Messages.pressed

    call HBoot.Console.printString

    mov si, HBoot.Messages.startMod

    call HBoot.Console.printString

    mov di, HBoot.Files.moduleImage

    call HBoot.Keyboard.readKeyboard

;; The path is read the way it is written, so a module can sit in a directory
;; instead of having to be typed the way the entry itself is stored on disk

    mov si, HBoot.Files.moduleImage

    call HBoot.FS.parsePath

    jc .manageInvalidPath

    mov word[HBoot.Files.finalSegment], MODULE_SEGMENT

    call HBoot.FS.searchFile

    jc .manageFileError

    call HBoot.Services.install ;; From here on a module can call HBoot itself

    mov dl, byte[idDrive] ;; Drive used for boot
    mov ebp, dword[BPBAdress] ;; Pointer to BPB
    mov esi, dword[partitionLBAAdress] ;; Pointer to partition

;; Where to come back to is kept here and not on the stack the module
;; inherits, so it can ask to return from any depth

    mov word[HBoot.Modules.Control.moduleSS], ss
    mov word[HBoot.Modules.Control.moduleSP], sp

    jmp MODULE_SEGMENT:MODULE_HEADER ;; Configure CS:IP and run the module

.manageFileError:

    fputs HBoot.Messages.modNotFound

    call HBoot.Keyboard.waitKeyboard

    jmp HBoot.HBoot.verifyUserInteraction.testComponents

;;************************************************************************************

.manageInvalidPath:

    fputs HBoot.Messages.modInvalidPath

    call HBoot.Keyboard.waitKeyboard

    jmp HBoot.HBoot.verifyUserInteraction.testComponents

;;************************************************************************************

;; Where function 05h of the service interrupt lands, and the only way back
;; into HBoot. Reentering at its entry point instead would have HBoot read the
;; volume it booted from out of registers the module is free to have used

HBoot.Lib.HMod.moduleReturn:

    mov ax, SEG_HBOOT
    mov ds, ax
    mov gs, ax

;; An interrupt cannot land between these two, so the stack is never half
;; restored

    mov ss, word[HBoot.Modules.Control.moduleSS]
    mov sp, word[HBoot.Modules.Control.moduleSP]

    push ds
    pop es

    fputs HBoot.modHBoot.Messages.modReturn

    call HBoot.Keyboard.waitKeyboard

    jmp analyzeDevice