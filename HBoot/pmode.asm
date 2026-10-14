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

;; A transitional GDT, only long enough to survive the jump into Hexagon's
;; own protectedEntryPoint, since Hexagon installs its own GDT immediately
;; and nothing here needs to outlive that jump
;;
;; 08h bases itself at SEG_HBOOT, so every HBoot label already used as a
;; plain real-mode offset keeps working unchanged once in protected mode.
;; 10h and 18h are both flat (base 0), one executable and one not, since
;; the far jump into Hexagon's entry point needs a code descriptor of its
;; own to land through

HBoot.PM.GDT:

dd 0, 0 ;; Null descriptor

.hbootCode: ;; Selector 08h

dw 0FFFFh
dw 0000h
db 01h
db 10011010b
db 11001111b
db 00h

;; Selector 10h: flat, used only as the far jump's own target selector, since a
;; far jump needs an executable descriptor

.linearCode: 

dw 0FFFFh
dw 0000h
db 00h
db 10011010b
db 11001111b
db 00h

.linear: ;; Selector 18h

dw 0FFFFh
dw 0000h
db 00h
db 10010010b
db 11001111b
db 00h

HBoot.PM.GDTEnd:

HBoot.PM.GDTReg:

dw HBoot.PM.GDTEnd - HBoot.PM.GDT - 1
dd HBoot.PM.GDT + (SEG_HBOOT * 16)

;; Hexagon's entry point is the first byte after its own HAPP header, so
;; the jump below needs nothing out of the image itself to find it

HBoot.PM.hexagonEntry = (HBoot.Modules.Hexagon.Segments.segmentHexagon * 16) + HAPP_HEADER_SIZE

;;************************************************************************************

;; Switches to 32-bit protected mode and jumps straight into Hexagon's own
;; entry point, EBX carrying the flat address of the HXBI block
;; HBoot.HXBI.buildBlock already filled in. Never returns

HBoot.PM.switchAndJump:

    cli

    lgdt[HBoot.PM.GDTReg]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 08h:HBoot.PM.protectedEntry

use32

HBoot.PM.protectedEntry:

;; 18h is flat (base 0) on every one of DS/SS/ES/FS/GS here, since the
;; kernel's own header lives outside HBoot's own segment entirely

    mov ax, 18h
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebx, HBoot.HXBI.block + (SEG_HBOOT * 16)

    jmp 10h:HBoot.PM.hexagonEntry

use16
