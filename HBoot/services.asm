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

;;************************************************************************************
;;
;;                                  Hexagon Boot
;;
;;                          Hexagon kernel boot loader
;;
;;                Services HBoot offers to a module it has started
;;
;;************************************************************************************

;; A module runs with the whole machine to itself and would otherwise have to
;; carry its own copy of everything HBoot already does. Instead HBoot installs
;; the interrupt below before handing control over, and answers on it.
;;
;; The contract is the same for every function:
;;
;; Entry:
;;
;; AH - Function number
;;
;; Exit:
;;
;; CF - Clear if the function succeeded, set if it failed
;; EAX - Result of the function, or the error code when CF is set
;;
;; Every other register, and every segment register, comes back exactly as it
;; went in. A module may call from any stack, at any depth. Each function is
;; documented at the label that answers it
;;
;; The error codes returned in EAX:

HBoot.Services.Errors.invalidFunction  = 01h ;; No such function number
HBoot.Services.Errors.invalidPath      = 02h ;; Path names nothing the volume can hold
HBoot.Services.Errors.fileNotFound     = 03h ;; No such file on the volume
HBoot.Services.Errors.invalidParameter = 04h ;; Function called with a value it cannot use

;; Offsets into the frame HBoot.Services.entry builds. BP reaches all of them
;; through SS, whichever segment the module left in DS

HBoot.Services.Frame.flags    = 6  ;; Flag image the IRET reloads, where CF is returned
HBoot.Services.Frame.callerDS = -2
HBoot.Services.Frame.callerES = -4
HBoot.Services.Frame.EAX      = -8 ;; Register image the POPAD reloads, where the result is returned

;;************************************************************************************

;; What function 00h reports, so a module can tell which interface it is
;; talking to before relying on it

HBoot.Services.Information:

.signature:   db "HBSV"
.version:     db 01h
.subversion:  db 00h
.functions:   db 05h ;; Highest function number this interface answers
.reserved:    db 00h

.size = $ - HBoot.Services.Information

;; What function 02h reports about the volume HBoot booted from

HBoot.Services.Volume:

.BPB:          dd 0 ;; Flat address of the BIOS Parameter Block
.partitionLBA: dd 0 ;; LBA the partition starts at
.drive:        db 0 ;; Drive HBoot was loaded from
.filesystem:   db 0 ;; Filesystem code, as in HBoot.Filesystem
.reserved:     dw 0

.size = $ - HBoot.Services.Volume

;; A path arrives in the module's own segment and every routine past the entry
;; runs with DS on HBoot's, so it is copied here first

HBoot.Services.pathBuffer:
times 64 db 0

;;************************************************************************************

;; Points the service interrupt at HBoot. Only a module ever calls it, so the
;; vector goes in just before one starts and a boot that runs no module leaves
;; the table exactly as the BIOS left it

HBoot.Services.install:

    push es

    mov dx, 0
    mov es, dx

    cli

    mov word[es:HBOOT_SERVICES * 4], HBoot.Services.entry
    mov word[es:HBOOT_SERVICES * 4 + 2], SEG_HBOOT

    sti

    pop es

    ret

;;************************************************************************************

;; Where a module lands when it raises the service interrupt

HBoot.Services.entry:

    push bp

    mov bp, sp

;; Saving every register whole is what lets the contract promise that only EAX
;; and the flags can come back changed. The module's own DS and ES stay on the
;; frame, since a function may need to reach into its memory or write to it

    push ds
    push es

    pushad

    mov dx, SEG_HBOOT
    mov ds, dx

    push ds
    pop es

;; A module is free to have left either of these however it liked, and the
;; string moves below and the BIOS calls past them are not. The IRET puts the
;; module's own flags back, so neither is visible to it

    cld

    sti

    cmp ah, 00h
    je .information

    cmp ah, 01h
    je .printString

    cmp ah, 02h
    je .volumeInformation

    cmp ah, 03h
    je .loadFile

    cmp ah, 04h
    je .readSectors

    cmp ah, 05h
    je .moduleReturn

    mov eax, HBoot.Services.Errors.invalidFunction

    jmp .failure

;;*******************************

;; 00h - Fills the buffer at the caller's ES:DI with HBoot.Services.Information

.information:

    mov si, HBoot.Services.Information
    mov cx, HBoot.Services.Information.size
    mov es, word[bp + HBoot.Services.Frame.callerES]

    rep movsb

    xor eax, eax

    jmp .success

;;*******************************

.printString:

;; 01h - Prints the string at the caller's DS:SI. It is read from the module's
;; own segment, so nothing here decides how long a message may be

    mov ds, word[bp + HBoot.Services.Frame.callerDS]

    call HBoot.Console.printString

    mov dx, SEG_HBOOT
    mov ds, dx

    xor eax, eax

    jmp .success

;;*******************************

;; 02h - Fills the buffer at the caller's ES:DI with HBoot.Services.Volume

.volumeInformation:

    mov eax, dword[BPBAdress]
    mov dword[HBoot.Services.Volume.BPB], eax

    mov eax, dword[partitionLBAAdress]
    mov dword[HBoot.Services.Volume.partitionLBA], eax

    mov dl, byte[idDrive]
    mov byte[HBoot.Services.Volume.drive], dl

    mov dl, byte[HBoot.Filesystem.code]
    mov byte[HBoot.Services.Volume.filesystem], dl

    mov si, HBoot.Services.Volume
    mov cx, HBoot.Services.Volume.size

    mov es, word[bp + HBoot.Services.Frame.callerES]

    rep movsb

    xor eax, eax

    jmp .success

;;*******************************

;; 03h - Loads the file named by the path at the caller's DS:SI into its own
;; ES, from offset 0, and returns the size of the file in EAX

.loadFile:

    call HBoot.Services.copyCallerPath

    mov si, HBoot.Services.pathBuffer

    call HBoot.FS.parsePath

    jc .invalidPath

    mov ax, word[bp + HBoot.Services.Frame.callerES]
    mov word[HBoot.Files.finalSegment], ax

    call HBoot.FS.searchFile

    jc .fileNotFound

    mov eax, dword[HBoot.Files.lastFileSize]

    jmp .success

.invalidPath:

    mov eax, HBoot.Services.Errors.invalidPath

    jmp .failure

.fileNotFound:

    mov eax, HBoot.Services.Errors.fileNotFound

    jmp .failure

;;*******************************

;; 04h - Reads CX sectors from LBA EBX into the caller's ES:DI. A sector that
;; cannot be read is fatal to HBoot itself, as it is anywhere else

.readSectors:

    cmp cx, 0
    je .invalidParameter

    mov es, word[bp + HBoot.Services.Frame.callerES]
    mov ax, cx
    mov esi, ebx

    call HBoot.Disk.loadSector

    xor eax, eax

    jmp .success

.invalidParameter:

    mov eax, HBoot.Services.Errors.invalidParameter

    jmp .failure

;;*******************************

;; 05h - Gives control back to HBoot, which picks the boot up from where it
;; left off. The frame built above stops mattering here, since the return puts
;; HBoot back on the stack it ran the module from

.moduleReturn:

    jmp HBoot.Lib.HMod.moduleReturn

;;*******************************

.success:

    mov dword[bp + HBoot.Services.Frame.EAX], eax

    and word[bp + HBoot.Services.Frame.flags], 0FFFEh

    jmp .exit

.failure:

    mov dword[bp + HBoot.Services.Frame.EAX], eax

    or word[bp + HBoot.Services.Frame.flags], 01h

.exit:

    popad

    pop es
    pop ds

    pop bp

    iret

;;************************************************************************************

;; Copies the path a module passed in DS:SI into HBoot's own segment, where
;; HBoot.FS.parsePath and everything past it can read it
;;
;; Input:
;;
;; BP - Frame HBoot.Services.entry built, carrying the module's DS
;; SI - Path, terminated by a 0, in the module's segment
;;
;; Output:
;;
;; HBoot.Services.pathBuffer - The path, cut at what the buffer holds

HBoot.Services.copyCallerPath:

    push ds
    push si
    push di
    push cx

    mov di, HBoot.Services.pathBuffer
    mov cx, 63 ;; What fits in the buffer, leaving room for the terminator
    mov ds, word[bp + HBoot.Services.Frame.callerDS]

.copy:

    cmp cx, 0
    je .terminate

    lodsb

    stosb

    cmp al, 0
    je .copied

    dec cx

    jmp .copy

.terminate:

    mov byte[es:di], 0

.copied:

    pop cx
    pop di
    pop si
    pop ds

    ret
