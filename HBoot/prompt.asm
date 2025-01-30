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

HBoot.HBoot.verifyUserInteraction:

    fputs HBoot.Messages.waitUser

    mov bx, 0

.loopSeconds:

    mov dx, TIME_FACTOR

    call HBoot.BIOS.causeDelay

    add bx, 1

    cmp bx, INIT_CICLES_PARAMETER
    je .continueBoot

    mov ah, 1

    int 16h

    jz .loopSeconds

    mov ah, 0

    int 16h

    cmp ah, F8 ;; F8
    je .pressedF8

    jmp .continueBoot

;;*******************************

.pressedF8:

    fputs HBoot.Messages.pressed

.pointPressedF8:

    putNewLine

    fputs HBoot.Messages.pressedF8

    fputs HBoot.Messages.mainCategories

    fputs HBoot.Messages.selectCategory

.pointPressedF8Checkpoint:

;; Now let's check which option the user selected to modify the startup behavior.
;; Let's first read the category number

    mov ah, 0

    int 16h

;; Now let's compare with the available options

    cmp al, '1'
    je .commandLine

    cmp al, '2'
    je .showDetailedInfo

    cmp al, '3'
    je .continueBoot

    cmp al, '4'
    je .infoHBoot

    cmp al, '5'
    je .rebootDevice

    ;; cmp al, '9'
    ;; je .changeVerboseMode

    cmp al, 't'
    je .testComponents

    cmp al, 'T'
    je .testComponents

;; If no valid key was pressed, return to key selection

    jmp .pointPressedF8Checkpoint

;;*******************************

.rebootDevice:

    call HBoot.Disk.stopDisks

    hlt

    int 19h

;;*******************************

;; Here we will provide more information about HBoot

.infoHBoot:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.aboutHBoot

    fputs HBoot.Messages.continueEnter

    call HBoot.Keyboard.waitKeyboard

    jmp .return

;;*******************************

.changeVerboseMode:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.changeVerboseMode

    mov ah, 00h

    int 16h

    cmp al, '0'
    je .turnOffVerbose

    cmp al, '1'
    je .turnOnVerbose

    fputs HBoot.Messages.optionFailure

    fputs HBoot.Messages.invalidOption

    call HBoot.Keyboard.waitKeyboard

    fputs HBoot.Messages.resumeBoot

.turnOffVerbose:

    mov byte[HBoot.Parameters.verbose], 00h

    fputs HBoot.Messages.resumeBoot

    jmp .return

.turnOnVerbose:

    mov byte[HBoot.Parameters.verbose], 01h

    fputs HBoot.Messages.resumeBoot

    jmp .return

;;*******************************

.commandLine:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.commandLine

    mov di, HBoot.Parameters.readBuffer

    call HBoot.Keyboard.readKeyboard

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.resumeBoot

    jmp .return

;;*******************************

.showDetailedInfo:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.detailedInfo

    fputs HBoot.Messages.processorVendor

;; Now let's check if there is something inside the variable

    fputs HBoot.Procx86.Data.processorVendor

    fputs HBoot.Messages.processorName

    mov si, HBoot.Procx86.Data.processorName

    cmp byte[si], 0
    jne .withProcessorNameAvailable

    mov si, HBoot.Messages.withoutCPUID

.withProcessorNameAvailable:

    call HBoot.Console.printString

    fputs HBoot.Messages.totalMemory

    call HBoot.Memory.getTotalMemory

    mov si, ax

    call HBoot.Console.printString

    fputs HBoot.Messages.megabytes

.verifyOnlineVolumes:

    fputs HBoot.Messages.onlineVolumes

.verifydsq0:

    cmp byte[HBoot.Disk.dsq0Online], 01h
    je .dsq0Online

    jmp .verifydsq1

.dsq0Online:

    fputs HBoot.Messages.dsq0

    fputs HBoot.Messages.space

.verifydsq1:

    cmp byte[HBoot.Disk.dsq1Online], 01h
    je .dsq1Online

    jmp .verifyhd0

.dsq1Online:

    fputs HBoot.Messages.dsq1

    fputs HBoot.Messages.space

.verifyhd0:

    cmp byte[HBoot.Disk.hd0Online], 01h
    je .hd0Online

    jmp .verifyhd1

.hd0Online:

    fputs HBoot.Messages.hd0

    fputs HBoot.Messages.space

.verifyhd1:

    cmp byte[HBoot.Disk.hd1Online], 01h
    je .hd1Online

    jmp .verificationCompleted

.hd1Online:

    fputs HBoot.Messages.hd1

    fputs HBoot.Messages.space

.verificationCompleted:

   fputs HBoot.Messages.bootDisk

    mov dl, byte[idDrive]

    cmp dl, 00h
    je .dsq0

    cmp dl, 01h
    je .dsq1

    cmp dl, 80h
    je .hd0

    cmp dl, 81h
    je .hd1

    cmp dl, 82h
    je .hd2

    cmp dl, 83h
    je .hd3

.dsq0:

    fputs HBoot.Messages.dsq0

    jmp .continueInfo

.dsq1:

    fputs HBoot.Messages.dsq1

    jmp .continueInfo

.hd0:

    fputs HBoot.Messages.hd0

    jmp .continueInfo

.hd1:

    fputs HBoot.Messages.hd1

    jmp .continueInfo

.hd2:

    fputs HBoot.Messages.hd2

    jmp .continueInfo

.hd3:

    fputs HBoot.Messages.hd3

    jmp .continueInfo

.continueInfo:

    fputs HBoot.Messages.filesystems

    cmp byte[HBoot.Filesystem.code], HBoot.Filesystem.FAT12
    je .FAT12

    cmp byte[HBoot.Filesystem.code], HBoot.Filesystem.FAT16
    je .FAT16

    cmp byte[HBoot.Filesystem.code], HBoot.Filesystem.FAT16B
    je .FAT16B

    cmp byte[HBoot.Filesystem.code], HBoot.Filesystem.FAT16LBA
    je .FAT16LBA

    mov si, HBoot.Messages.unknownFilesystem

.FAT12:

    fputs HBoot.Messages.FAT12

    jmp .continueFilesystem

.FAT16:

    fputs HBoot.Messages.FAT16

    jmp .continueFilesystem

.FAT16B:

    fputs HBoot.Messages.FAT16B

    jmp .continueFilesystem

.FAT16LBA:

    fputs HBoot.Messages.FAT16LBA

    jmp .continueFilesystem

.continueFilesystem:

    fputs HBoot.Messages.hexagonFile

    fputs HBoot.Modules.Hexagon.Files.imageHexagon

    fputs HBoot.Messages.commandLineInfo

    mov si, HBoot.Parameters.readBuffer

    cmp byte[si], 0
    je .emptyCommandLine

    call HBoot.Console.printString

    jmp .continueCommandLine

.emptyCommandLine:

    fputs HBoot.Messages.emptyCommandLine

.continueCommandLine:

    fputs HBoot.Messages.versionHBoot

    fputs HBoot.Messages.versionProtocol

    fputs HBoot.Messages.continueEnter

    call HBoot.Keyboard.waitKeyboard

    jmp .return

;;*******************************

.testComponents:

    fputs HBoot.Messages.pressed

.withoutWarning:

    fputs HBoot.Messages.testComponents

    fputs HBoot.Messages.componentList

    fputs HBoot.Messages.selectComponent

.testControlCheckpoint:

;; Now let's check which option the user selected

    mov ah, 0

    int 16h

;; Now let's compare with the available options

    cmp al, '1'
    je .playSound

    cmp al, '2'
    je .displayRegisters

    cmp al, '3'
    je .testVideo

    cmp al, '4'
    je .reboot

    cmp al, '5'
    je .pointPressedF8

    cmp al, 'd'
    je .startDOSMode

    cmp al, 'D'
    je .startDOSMode

    cmp al, 'm'
    je .loadHBootModule

    cmp al, 'M'
    je .loadHBootModule

    jmp .testControlCheckpoint

;;*******************************

.loadHBootModule:

   jmp HBoot.Lib.HMod.loadAndStartHBootModule

;;*******************************

.startDOSMode:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.DOSMode

    fputs HBoot.Messages.selectCategory

.selectDOSFlavor:

    mov ah, 0

    int 16h

;; Now let's compare with the available options

    cmp al, '1'
    je .startFreeDOS

    cmp al, '2'
    je .testComponents

    jmp .selectDOSFlavor

.startFreeDOS:

;; Let's mark it as DOS compatibility mode for boot

    mov byte[HBoot.Control.bootMode], 01h

    jmp HBoot.Lib.LibDOS.startFreeDOS

;;*******************************

.playSound:

    mov si, HBoot.Messages.pressed

    call HBoot.Console.printString

    playNote HBoot.Sounds.CANON1, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON2, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON3, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON4, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON5, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON6, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON7, HBoot.Sounds.tNormal
    playNote HBoot.Sounds.CANON8, HBoot.Sounds.tExtended

    call turnOffSound

    jmp .testComponents

;;*******************************

.displayRegisters:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.displayRegisters

    push HBoot.Messages.axx
    push ax

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.bxx
    push bx

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.cxx
    push cx

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.dxx
    push dx

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.css
    push cs

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.dss
    push ds

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.sss
    push ss

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.ess
    push es

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.spp
    push sp

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.sii
    push si

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.dii
    push di

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.gss
    push gs

    call HBoot.Lib.LibNum.toHexadecimal

    push HBoot.Messages.fss
    push fs

    call HBoot.Lib.LibNum.toHexadecimal

    fputs HBoot.Messages.continueReboot

    call HBoot.Keyboard.waitKeyboard

    call HBoot.Disk.stopDisks

    int 19h

;; If it fails, we will stay here until the restart comes automatically

    jmp $

;;*******************************

.testVideo:

    pushad
    pushf

    call HBoot.Console.testVideo

    popf
    popad

    jmp .withoutWarning


;;*******************************

.reboot:

    fputs HBoot.Messages.pressed

    fputs HBoot.Messages.rebootRequired

    call HBoot.Keyboard.waitKeyboard

    call HBoot.Disk.stopDisks

    int 19h

.return:

    jmp .pointPressedF8

;;*******************************

.continueBoot:

    ret
