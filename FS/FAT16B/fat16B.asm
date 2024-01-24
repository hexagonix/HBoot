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

;;************************************************************************************
;;
;;                                  Hexagon Boot
;;
;;                          Hexagon kernel boot loader
;;
;;             Logic for finding and loading file on a FAT16 volume
;;
;;************************************************************************************

;; Now we will look for the file present in the HBoot.Files.imageName buffer that was
;; filled previously

searchFileFAT16B:

;; Calculate root directory size
;;
;; Formula:
;;
;; Size = (rootEntries * 32) / bytesPerSector

    mov ax, word[rootEntries]
    shl ax, 5 ;; Multiply by 32
    mov bx, word[bytesPerSector]
    xor dx, dx ;; DX = 0
    
    div bx ;; AX = AX / BX
    
    mov word[rootSize], ax ;; Save root directory size

;; Calculate the size of FAT tables
;;
;; Formula:
;;
;; Size = totalFATs * sectorsPerFAT

    mov ax, word[sectoresPerFAT]
    movzx bx, byte[totalFATs]
    xor dx, dx ;; DX = 0
    
    mul bx ;; AX = AX * BX
    
    mov word[sizeFATs], ax ;; Save FAT size

;; Calculate all reserved sectors
;;
;; Formula:
;;
;; reservedSectors + partition LBA

    add word[reservedSectors], bp ;; BP is the LBA of the partition
    
;; Calculate data area address
;;
;; Formula:
;;
;; reservedSectors + sizeFATs + rootSize

    movzx eax, word[reservedSectors]  
    
    add ax, word[sizeFATs]
    add ax, word[rootSize]
    
    mov dword[dataArea], eax
    
;; Calculate the LBA address of the root directory and load it
;;
;; Formula:
;;
;; LBA = reservedSectors + sizeFATs

    movzx esi, word[reservedSectors]
    
    add si, word[sizeFATs]

    mov ax, word[rootSize]
    mov di, diskBuffer
        
    call loadSector

;; Search the root directory for the file entry to load it

    mov cx, word[rootEntries]
    mov bx, diskBuffer

    cld ;; Clear direction
    
searchFileFAT16BLoop:

;; Finding the 11-character file name in an entry

    xchg cx, dx ;; Save loop counter
    mov cx, 11
    mov si, HBoot.Files.imageName
    mov di, bx
    
    rep cmpsb ;; Compare (ECX) characters between DI and SI
    
    je .fileFound

    add bx, 32 ;; Go to the next root directory entry (+32 bytes)
    
    xchg cx, dx ;; Reset counter
    
    loop searchFileFAT16BLoop

;; The requested file was not found. Display error message and finish

    pop esi

    mov si, HBoot.Messages.notFound
    
    call printScreen
    
    jmp $

.fileFound:

    mov si, word[bx+26]     
    mov word[cluster], si ;; Save first cluster

;; Load FAT into memory to find all clusters of the file

    mov ax, word[sectoresPerFAT]  ;; Total sectors to load
    mov si, word[reservedSectors] ;; LBA
    mov di, diskBuffer            ;; Buffer where data will be loaded

    call loadSector

;; Calculate cluster size in bytes
;;
;; Formula:
;;
;; sectorsPerCluster * bytesPerSector

    movzx eax, byte[sectoresPerCluster]
    movzx ebx, word[bytesPerSector]
    xor edx, edx
        
    mul ebx ;; AX = AX * BX 
    
    mov ebp, eax ;; Save cluster size
    
    mov ax, word[HBoot.Files.finalSegment] ;; File upload segment
    mov es, ax
    mov edi, 0 ;; Buffer to load the file

;; Find cluster and load cluster chain

loadClustersFAT16BLoop:

;; Convert a cluster's logical address to LBA address (physical address)
;;
;; Formula:
;;
;; ((cluster - 2) * sectorsPerCluster) + dataArea
 
    movzx esi, word[cluster]    
        
    sub esi, 2

    movzx ax, byte[sectoresPerCluster]       
    xor edx, edx ;; DX = 0
    
    mul esi ;; (cluster - 2) * sectoresPerCluster
    
    mov esi, eax    

    add esi, dword[dataArea]

    movzx ax, byte[sectoresPerCluster] ;; Total sectors to load
    
    call loadSector
    
;; Find next sector in FAT table

    mov bx, word[cluster]
    shl bx, 1 ;; BX * 2 (2 bytes on input)
    
    add bx, diskBuffer ;; FAT location

    mov si, word[bx] ;; SI contain the next cluster

    mov word[cluster], si ;; Save this

    cmp si, 0xFFF8 ;; 0xFFF8 is end of file (EOF)
    jae .finished

;; Add space for the next cluster
    
    add edi, ebp ;; EBP has the size of the cluster
    
    jmp loadClustersFAT16BLoop

.finished:

    ret