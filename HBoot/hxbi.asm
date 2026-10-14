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

;; Hexagon Boot Information: the block Hexagon.init reads instead of the
;; BL/EBP/CX/ESI registers HBoot used to pass it. Header, then a stream of
;; tags each carrying its own type and size, ending in a type 0 tag

HBoot.HXBI.block:
times 4096 db 0

HBoot.HXBI.cursor: dw 0 ;; Offset of the next tag to write, within the block above

;;************************************************************************************

;; Writes a tag header at HBoot.HXBI.cursor, without advancing past it yet.
;; The caller fills in the payload through EDI, then calls
;; HBoot.HXBI.endTag with the same size to move the cursor past it
;;
;; Input:
;;
;; EAX - Tag type
;; ECX - Tag size, header included
;;
;; Output:
;;
;; EDI - Offset of this tag's payload, right after its 8-byte header

HBoot.HXBI.beginTag:

    movzx edi, word[HBoot.HXBI.cursor]

    add edi, HBoot.HXBI.block

    mov dword[edi], eax
    mov dword[edi+4], ecx

    add edi, 8

    ret

;;************************************************************************************

;; Input:
;;
;; ECX - The tag's total size, same value passed to HBoot.HXBI.beginTag

HBoot.HXBI.endTag:

    add word[HBoot.HXBI.cursor], cx

    ret

;;************************************************************************************

HBoot.HXBI.Const.loaderName:
db "HBoot", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;; 16 bytes, zero-padded

HBoot.HXBI.Local.tmpCount: dw 0
HBoot.HXBI.Local.tmpSize:  dw 0

;;************************************************************************************

;; Fills in HBoot.HXBI.block: the header, then every tag HBoot itself can
;; produce (loader info, memory map, boot device, command line,
;; framebuffer), ending in the type 0 tag

HBoot.HXBI.buildBlock:

;; Every payload below lands through ES:DI, and HBoot.FS.searchFile leaves
;; ES wherever the last BIOS call it made needed it

    push ds
    pop es

    mov dword[HBoot.HXBI.block], "HXBI"
    mov dword[HBoot.HXBI.block + 4], 1 ;; version
    mov dword[HBoot.HXBI.block + 12], 1 ;; flags, bit 0 = A20 confirmed enabled

    mov word[HBoot.HXBI.cursor], 16

;; Tag 1: loader info

    mov eax, 1
    mov ecx, 28

    call HBoot.HXBI.beginTag

    mov dword[edi], 00010000h ;; loaderVersion 1.0

    add edi, 4

    mov esi, HBoot.HXBI.Const.loaderName
    mov ecx, 16

    cld
    rep movsb

    mov ecx, 28

    call HBoot.HXBI.endTag

;; Tag 2: memory map, straight from HBoot.Memory.E820.entries, minus the
;; 4-byte ACPI extended attribute E820h reports on each entry

    movzx eax, word[HBoot.Memory.E820.entryCount]
    mov word[HBoot.HXBI.Local.tmpCount], ax

    mov ebx, eax

    imul ebx, ebx, 20
    
    add ebx, 16 ;; +8 tag header, +8 entrySize/entryCount fields
    
    mov word[HBoot.HXBI.Local.tmpSize], bx

    mov eax, 2
    movzx ecx, word[HBoot.HXBI.Local.tmpSize]

    call HBoot.HXBI.beginTag

    mov dword[edi], 20 ;; entrySize

    movzx eax, word[HBoot.HXBI.Local.tmpCount]
    mov dword[edi + 4], eax ;; entryCount

    add edi, 8

    mov esi, HBoot.Memory.E820.entries
    movzx ecx, word[HBoot.HXBI.Local.tmpCount]

.copyMemEntry:

    cmp ecx, 0
    je .memDone

    push ecx

    mov ecx, 20 ;; base + length + type, the E820 entry's own attribute dropped

    cld
    rep movsb

    add esi, 4

    pop ecx

    dec ecx

    jmp .copyMemEntry

.memDone:

    movzx ecx, word[HBoot.HXBI.Local.tmpSize]

    call HBoot.HXBI.endTag

;; Tag 3: boot device: the drive HBoot booted from, and the boot sector
;; Saturno left resident, embedded and not pointed to

    mov eax, 3
    mov ecx, 524

    call HBoot.HXBI.beginTag

    mov al, byte[idDrive]
    mov byte[edi], al

    mov byte[edi + 1], 0
    mov byte[edi + 2], 0
    mov byte[edi + 3], 0

    add edi, 4

    mov eax, dword[BPBAdress] ;; Flat address of Saturno's sector

    mov ecx, eax
    
    and ecx, 0Fh
    
    shr eax, 4
    
    mov bx, ax

    push ds

    mov ds, bx
    mov si, cx

    mov cx, 512

    cld
    rep movsb

    pop ds

    mov ecx, 524

    call HBoot.HXBI.endTag

;; Tag 4: command line, from HBoot.Parameters.readBuffer. Only 64 bytes
;; of it are real; the rest of the tag's own 256 bytes stay zeroed

    mov eax, 4
    mov ecx, 264

    call HBoot.HXBI.beginTag

    mov esi, HBoot.Parameters.readBuffer
    mov ecx, 64

    cld
    rep movsb

    mov ecx, 264

    call HBoot.HXBI.endTag

;; Tag 5: framebuffer, from HBoot.VBE.Control. Stays zeroed if
;; HBoot.VBE.setupVBE never found a matching mode

    mov eax, 5
    mov ecx, 32

    call HBoot.HXBI.beginTag

    mov eax, dword[HBoot.VBE.Control.framebufferAddress]
    mov dword[edi], eax
    mov dword[edi + 4], 0 ;; High dword of the 64-bit address, always 0 below 4 GB

    movzx eax, word[HBoot.VBE.Control.pitch]
    mov dword[edi + 8], eax

    movzx eax, word[HBoot.Video.Config.width]
    mov dword[edi + 12], eax

    movzx eax, word[HBoot.Video.Config.height]
    mov dword[edi + 16], eax

    mov al, byte[HBoot.VBE.Control.bpp]
    mov byte[edi + 20], al

    mov ecx, 32

    call HBoot.HXBI.endTag

;; Tag 0: end of the list

    mov eax, 0
    mov ecx, 8

    call HBoot.HXBI.beginTag
    call HBoot.HXBI.endTag

    movzx eax, word[HBoot.HXBI.cursor]
    mov dword[HBoot.HXBI.block + 8], eax ;; totalSize

    ret
