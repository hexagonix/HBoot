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

HBoot.VBE.Control:

.found:               db 0 ;; 1 once a matching mode was actually set
.modeListSegment:     dw 0
.modeListOffset:      dw 0
.framebufferAddress:  dd 0
.pitch:               dw 0
.bpp:                 db 0

HBoot.VBE.infoBlock:
times 512 db 0
HBoot.VBE.modeInfoBlock:
times 256 db 0

;;************************************************************************************

;; Sets the video mode named by HBoot.Video.Config (already read from
;; boot.cfg), leaving HBoot.VBE.Control filled in on success. Does nothing
;; if boot.cfg named no resolution, or if no mode matches it exactly

HBoot.VBE.setupVBE:

    cmp byte[HBoot.Video.Config.resolutionSet], 0
    je .noResolutionRequested

    mov dword[HBoot.VBE.infoBlock], "VBE2" ;; Requests the VBE 2.0 info layout

    mov ax, 4F00h
    mov di, HBoot.VBE.infoBlock

    int 10h

    cmp ax, 004Fh
    jne .noMatch

    mov ax, word[HBoot.VBE.infoBlock + 14] ;; VideoModePtr offset
    mov word[HBoot.VBE.Control.modeListOffset], ax

    mov ax, word[HBoot.VBE.infoBlock + 16] ;; VideoModePtr segment
    mov word[HBoot.VBE.Control.modeListSegment], ax

.modeLoop:

    mov ax, word[HBoot.VBE.Control.modeListSegment]
    mov es, ax

    mov si, word[HBoot.VBE.Control.modeListOffset]
    mov cx, word[es:si] ;; Current mode number

    cmp cx, 0FFFFh ;; End of the list
    je .noMatch

    add si, 2
    mov word[HBoot.VBE.Control.modeListOffset], si

    mov ax, SEG_HBOOT ;; ES is back to our own segment for every call below
    mov es, ax

    push cx

    mov ax, 4F01h
    mov di, HBoot.VBE.modeInfoBlock

    int 10h

    pop cx

    cmp ax, 004Fh
    jne .modeLoop ;; This one mode's own info query failed, try the next

;; ModeAttributes: bit 0 supported, bit 4 graphics, bit 7 linear framebuffer

    mov ax, word[HBoot.VBE.modeInfoBlock]

    test ax, 1
    jz .modeLoop

    test ax, 10h
    jz .modeLoop
    
    test ax, 80h
    jz .modeLoop

    mov ax, word[HBoot.VBE.modeInfoBlock + 18] ;; XResolution

    cmp ax, word[HBoot.Video.Config.width]
    jne .modeLoop

    mov ax, word[HBoot.VBE.modeInfoBlock + 20] ;; YResolution

    cmp ax, word[HBoot.Video.Config.height]
    jne .modeLoop

    mov al, byte[HBoot.VBE.modeInfoBlock + 25] ;; BitsPerPixel
    
    cmp al, byte[HBoot.Video.Config.bpp]
    jne .modeLoop

    mov bx, cx
    or bx, 4000h ;; Request the linear framebuffer for this mode

    mov ax, 4F02h

    int 10h

    cmp ax, 004Fh
    jne .noMatch

    mov ax, word[HBoot.VBE.modeInfoBlock + 16] ;; BytesPerScanLine
    mov word[HBoot.VBE.Control.pitch], ax

    mov eax, dword[HBoot.VBE.modeInfoBlock + 40] ;; PhysBasePtr
    mov dword[HBoot.VBE.Control.framebufferAddress], eax

    mov al, byte[HBoot.VBE.modeInfoBlock + 25]
    mov byte[HBoot.VBE.Control.bpp], al

    mov byte[HBoot.VBE.Control.found], 1

    fputs HBoot.Messages.vbeModeSet

    ret

.noMatch:

    fputs HBoot.Messages.vbeModeNotSet

.noResolutionRequested:

    ret
