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

;; Segment boot.cfg is loaded into while it's being read. Must sit above
;; Hexagon.Heap.End (kern/kern.asm), a boundary well past SEG_HBOOT itself.
;; A lower segment here reliably broke the boot volume mount later on

HBoot.Modules.BootCfg.Segments.segmentBootCfg equ 0x7000

HBoot.Modules.BootCfg.Files.imageBootCfg:
db "/boot/boot.cfg", 0

HBoot.Modules.BootCfg.Const.resolutionKey:
db "resolution="

HBoot.Video.Config:

.resolutionSet: db 0 ;; 1 once a resolution= line was actually parsed
.width:  dw 0
.height: dw 0
.bpp:    db 0

;;************************************************************************************

;; Reads boot/boot.cfg, if present, for a "resolution=WIDTHxHEIGHTxBPP"
;; line, the same key=value convention /etc/rc already uses on the
;; installed system. A missing file just leaves HBoot.Video.Config.resolutionSet
;; at 0, since a video mode is set from a config line alone, never guessed

HBoot.Lib.BootCfg.loadBootCfg:

    mov byte[HBoot.Video.Config.resolutionSet], 0

    mov si, HBoot.Modules.BootCfg.Files.imageBootCfg

    call HBoot.FS.parsePath

    jc .noBootCfg

    mov word[HBoot.Files.finalSegment], HBoot.Modules.BootCfg.Segments.segmentBootCfg

    call HBoot.FS.searchFile

;; Loading boot.cfg's own bytes leaves ES on segmentBootCfg, same as a
;; kernel load leaves it on the kernel's segment. Restored here since,
;; unlike the kernel case, boot.cfg isn't the last file HBoot reads

    push ax

    mov ax, SEG_HBOOT
    mov es, ax

    pop ax

    jc .noBootCfg

    call HBoot.Lib.BootCfg.parseResolution

    cmp byte[HBoot.Video.Config.resolutionSet], 0
    je .noBootCfg

    fputs HBoot.Messages.bootCfgFound

    mov ax, word[HBoot.Video.Config.width]
    
    call HBoot.Lib.LibString.toString
    
    mov si, ax
    
    call HBoot.Console.printString

    fputs HBoot.Messages.bootCfgSeparator

    mov ax, word[HBoot.Video.Config.height]
    
    call HBoot.Lib.LibString.toString
    
    mov si, ax
    
    call HBoot.Console.printString

    ret

.noBootCfg:

    fputs HBoot.Messages.bootCfgNotFound

    ret

;;************************************************************************************

;; Scans the loaded boot.cfg text for a "resolution=" line, skipping blank
;; lines and '#' comments

HBoot.Lib.BootCfg.parseResolution:

    push es

    mov ax, HBoot.Modules.BootCfg.Segments.segmentBootCfg
    mov es, ax

    xor di, di ;; Current line start, ES-relative

.lineLoop:

    cmp di, word[HBoot.Files.lastFileSize]
    jae .done

    cmp byte[es:di], '#'
    je .nextLine

    cmp byte[es:di], 0Ah
    je .advanceOneAndContinue

    push di

    mov si, HBoot.Modules.BootCfg.Const.resolutionKey
    mov cx, 11

    rep cmpsb

    je .matchedKey

    pop di

    jmp .nextLine

.matchedKey:

    pop bx ;; Discard the saved line start; DI is already past "resolution="

    jmp .parseValue

.nextLine:

    cmp di, word[HBoot.Files.lastFileSize]
    jae .done

    cmp byte[es:di], 0Ah
    je .advanceOneAndContinue

    inc di

    jmp .nextLine

.advanceOneAndContinue:

    inc di

    jmp .lineLoop

.parseValue:

    call HBoot.Lib.BootCfg.readDecimal

    mov word[HBoot.Video.Config.width], ax

    inc di ;; Skip the 'x'

    call HBoot.Lib.BootCfg.readDecimal

    mov word[HBoot.Video.Config.height], ax

    inc di ;; Skip the 'x'

    call HBoot.Lib.BootCfg.readDecimal

    mov byte[HBoot.Video.Config.bpp], al

    mov byte[HBoot.Video.Config.resolutionSet], 1

.done:

    pop es

    ret

;;************************************************************************************

;; Reads decimal digits at ES:DI until a non-digit is reached
;;
;; Input:
;;
;; ES:DI - First digit
;;
;; Output:
;;
;; AX - Parsed value
;; DI - Advanced past the digits read

HBoot.Lib.BootCfg.readDecimal:

    push bx
    push cx

    xor ax, ax

.digitLoop:

    mov cl, byte[es:di]

    cmp cl, '0'
    jb .done

    cmp cl, '9'
    ja .done

    sub cl, '0'
    movzx bx, cl

    imul ax, ax, 10

    add ax, bx

    inc di

    jmp .digitLoop

.done:

    pop cx
    pop bx

    ret
