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
;;             Logic for finding and loading file on a FAT16 volume
;;
;;************************************************************************************

;; Now we will look for the file present in the HBoot.Files.imageName buffer that was
;; filled previously

HBoot.FS.FAT16B.searchFileFAT16B:

;; reservedSectors is the BPB's own raw field. The block below folds the
;; partition's LBA into it for this call's own use, and every later call
;; needs that same fold done fresh, not stacked on top of last time's result

    push word[reservedSectors]

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
;;
;; The LBA comes from where HBoot saved it at startup, not from a register a
;; caller has to keep untouched for it

    mov bx, word[partitionLBAAdress]

    add word[reservedSectors], bx
    
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

    call HBoot.Disk.loadSector

    cld ;; Clear direction

;; HBoot.Files.imageDirectory blank means a flat root lookup. Anything else
;; names a root entry to resolve into a subdirectory, and the file is then
;; searched for inside it

    cmp byte[HBoot.Files.imageDirectory], ' '
    je .searchRoot

    mov si, HBoot.Files.imageDirectory
    mov di, diskBuffer
    mov cx, word[rootEntries]

    call HBoot.FS.FAT16B.findEntry

    jc .notFound

    test byte[di+11], 10h ;; Directory attribute bit
    jz .notFound

    mov si, word[di+26]
    mov word[cluster], si

;; The subdirectory walk below needs the FAT already in diskBuffer. It
;; stays there afterward, so the file search past it reuses that same
;; copy instead of loading it again

    call HBoot.FS.FAT16B.loadFAT

    call HBoot.FS.FAT16B.loadDirectoryChain

    mov di, subdirBuffer
    mov cx, 4000h / 32 ;; Entries subdirBuffer can hold

    jmp .searchForFile

.searchRoot:

    mov di, diskBuffer
    mov cx, word[rootEntries]

.searchForFile:

    mov si, HBoot.Files.imageName

    call HBoot.FS.FAT16B.findEntry

    jc .notFound

    mov bx, di

    jmp .fileFound

.notFound:

;; CF is all a caller gets, so each one reports a missing file its own way

    pop word[reservedSectors]

    stc

    ret

.fileFound:

    mov si, word[bx+26]
    mov word[cluster], si ;; Save first cluster

    mov eax, dword[bx+28]
    mov dword[HBoot.Files.lastFileSize], eax ;; Byte size, straight from the entry

;; A 0-byte file has no cluster allocated, and its entry's cluster field
;; reads 0 and not a real one. Treating that as a cluster number below
;; would wrap the LBA math into a bogus sector far off the volume

    cmp eax, 0
    je loadClustersFAT16BLoop.finished

;; A directory was resolved above, so the FAT it needed is already sitting
;; in diskBuffer. Only a flat root lookup still needs to load it here

    cmp byte[HBoot.Files.imageDirectory], ' '
    jne .haveFAT

;; Load FAT into memory to find all clusters of the file

    mov ax, word[sectoresPerFAT]  ;; Total sectors to load
    mov si, word[reservedSectors] ;; LBA
    mov di, diskBuffer            ;; Buffer where data will be loaded

    call HBoot.Disk.loadSector

.haveFAT:

;; Calculate cluster size in bytes
;;
;; Formula:
;;
;; sectorsPerCluster * bytesPerSector

    movzx eax, byte[sectoresPerCluster]
    movzx ebx, word[bytesPerSector]
    xor edx, edx
        
    mul ebx ;; AX = AX * BX

    mov dword[clusterSizeBytes], eax ;; Save cluster size

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
    
    call HBoot.Disk.loadSector
    
;; Find next sector in FAT table

    mov bx, word[cluster]
    shl bx, 1 ;; BX * 2 (2 bytes on input)
    
    add bx, diskBuffer ;; FAT location

    mov si, word[bx] ;; SI contain the next cluster

    mov word[cluster], si ;; Save this

    cmp si, 0xFFF8 ;; 0xFFF8 is end of file (EOF)
    jae .finished

;; Add space for the next cluster

    add edi, dword[clusterSizeBytes]
    
    jmp loadClustersFAT16BLoop

.finished:

    pop word[reservedSectors]

    ret

;;************************************************************************************

;; Searches a table of 32-byte directory entries for one whose first 11
;; bytes match, used by HBoot.FS.FAT16B.searchFileFAT16B against both the
;; root directory and a resolved subdirectory
;;
;; Input:
;;
;; SI - 11-byte name to match
;; DI - First entry in the table
;; CX - Number of entries to scan
;;
;; Output:
;;
;; DI - Matched entry, if found
;; CF - Set if none of the CX entries matched

HBoot.FS.FAT16B.findEntry:

    push dx
    push si

.loop:

    xchg cx, dx

    push si
    push di

    mov cx, 11

    rep cmpsb

    pop di
    pop si

    je .matched

    add di, 32

    xchg cx, dx

    loop .loop

    pop si
    pop dx

    stc

    ret

.matched:

    pop si
    pop dx

    clc

    ret

;;************************************************************************************

;; Loads the FAT table into diskBuffer, replacing whatever it held before

HBoot.FS.FAT16B.loadFAT:

    mov ax, word[sectoresPerFAT]
    mov si, word[reservedSectors]
    mov di, diskBuffer

    call HBoot.Disk.loadSector

    ret

;;************************************************************************************

;; Follows the FAT chain in diskBuffer, copying each cluster's raw bytes
;; into subdirBuffer in order. Stops at end-of-chain, or once subdirBuffer's
;; own 4000h bytes are full, whichever comes first
;;
;; Input:
;;
;; word[cluster] - First cluster of the directory to read

HBoot.FS.FAT16B.loadDirectoryChain:

    mov di, subdirBuffer

.loadNext:

;; Convert a cluster's logical address to LBA address (physical address)
;;
;; Formula:
;;
;; ((cluster - 2) * sectorsPerCluster) + dataArea

    movzx esi, word[cluster]

    sub esi, 2

    movzx ax, byte[sectoresPerCluster]
    
    xor edx, edx

    mul esi

    mov esi, eax

    add esi, dword[dataArea]

    movzx ax, byte[sectoresPerCluster]

    call HBoot.Disk.loadSector

;; Find next cluster in the FAT already sitting in diskBuffer

    mov bx, word[cluster]
    
    shl bx, 1

    add bx, diskBuffer

    mov si, word[bx]

    mov word[cluster], si

;; Advance the destination by one cluster's worth of bytes

    movzx eax, byte[sectoresPerCluster]
    movzx ebx, word[bytesPerSector]
    
    xor edx, edx

    mul ebx

    add di, ax

    cmp di, subdirBuffer + 4000h
    jae .done

    cmp si, 0xFFF8
    jb .loadNext

.done:

    ret

;;************************************************************************************

;; Turns a path written the way the user writes it into the pair of 11-byte
;; FAT names HBoot.FS.FAT16B.searchFileFAT16B searches with. A path may name
;; at most one directory, which is as deep as HBoot.Files.imageDirectory reaches
;;
;; Input:
;;
;; SI - Path, NUL terminated, as in "/boot/spartan.mod"
;;
;; Output:
;;
;; HBoot.Files.imageDirectory - Directory to search, blank for the root itself
;; HBoot.Files.imageName - Entry to look for inside it
;; CF - Set if the path names nothing a pair of 8.3 names can hold

HBoot.FS.FAT16B.parsePath:

    push ax
    push cx
    push si
    push di

    cld ;; Clear direction

;; A path with no directory in it searches the root, which is what a blank
;; directory field asks for, and stays that way unless a component names one

    mov di, HBoot.Files.imageDirectory
    mov al, ' '
    mov cx, 11

    rep stosb

;; A leading slash only says the path starts at the root, which is where
;; every search starts anyway

    cmp byte[si], '/'
    jne .readComponent

    inc si

.readComponent:

    mov di, HBoot.Files.imageName

    call HBoot.FS.FAT16B.convertComponent

    jc .invalidPath

;; A slash right after the component means it named a directory and not the
;; file, so it moves aside and the next component is read as the name

    cmp byte[si], '/'
    jne .parsed

    inc si

    push si

    mov si, HBoot.Files.imageName
    mov di, HBoot.Files.imageDirectory
    mov cx, 11

    rep movsb

    pop si

    mov di, HBoot.Files.imageName

    call HBoot.FS.FAT16B.convertComponent

    jc .invalidPath

;; One directory is all the fields can express, so anything still left after
;; the file name is a path this loader has nowhere to put

    cmp byte[si], 0
    jne .invalidPath

.parsed:

    pop di
    pop si
    pop cx
    pop ax

    clc

    ret

.invalidPath:

    pop di
    pop si
    pop cx
    pop ax

    stc

    ret

;;************************************************************************************

;; Writes one path component as the 11 bytes a directory entry begins with,
;; uppercase and blank padded, which is the form HBoot.FS.FAT16B.findEntry
;; compares against
;;
;; Input:
;;
;; SI - First character of the component
;; DI - 11-byte field to write
;;
;; Output:
;;
;; SI - Left on the separator or terminator that ended the component
;; DI - Advanced past the 11 bytes written
;; CF - Set if the component is empty or longer than 8.3 holds

HBoot.FS.FAT16B.convertComponent:

    push ax
    push cx

;; An empty component is what a doubled or a trailing slash leaves behind,
;; and no entry can ever match it

    cmp byte[si], 0
    je .invalidComponent

    cmp byte[si], '/'
    je .invalidComponent

    mov cx, 8 ;; Room left in the name field

.nameLoop:

    mov al, byte[si]

    cmp al, 0
    je .withoutExtension

    cmp al, '/'
    je .withoutExtension

    cmp al, '.'
    je .extension

    cmp cx, 0
    je .invalidComponent

    call HBoot.FS.FAT16B.toUppercase

    stosb

    inc si

    dec cx

    jmp .nameLoop

.withoutExtension:

    mov al, ' '

    rep stosb ;; Blank what is left of the name field

    mov cx, 3

    rep stosb ;; Nothing was written after a dot, so the extension is blank too

    jmp .converted

.extension:

    inc si ;; Step over the dot itself, it is not part of either field

    mov al, ' '

    rep stosb ;; Blank what is left of the name field

    mov cx, 3 ;; Room left in the extension field

.extensionLoop:

    mov al, byte[si]

    cmp al, 0
    je .padExtension

    cmp al, '/'
    je .padExtension

    cmp cx, 0
    je .invalidComponent

    call HBoot.FS.FAT16B.toUppercase

    stosb

    inc si

    dec cx

    jmp .extensionLoop

.padExtension:

    mov al, ' '

    rep stosb

.converted:

    pop cx
    pop ax

    clc

    ret

.invalidComponent:

    pop cx
    pop ax

    stc

    ret

;;************************************************************************************

;; Directory entries hold names in uppercase, which is not necessarily how a
;; path is written. Takes the character in AL and returns it there

HBoot.FS.FAT16B.toUppercase:

    cmp al, 'a'
    jb .unchanged

    cmp al, 'z'
    ja .unchanged

    sub al, 20h

.unchanged:

    ret
