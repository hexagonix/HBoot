;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2016-2022 Felipe Miguel Nery Lunkes
;; │┌─┐││─┼┼┼┤┌┐│┌┐│┌┐│┌┐┼┼┼┼┘          Todos os direitos reservados
;; ││ │││─┼┼┼┤┌┐│└┘│└┘││││├┼┼┐
;; └┘ └┴──┴┘└┴┘└┴─┐├──┴┘└┴┴┘└┘
;;              ┌─┘│                 Licenciado sob licença BSD-3-Clause
;;              └──┘          
;;
;;
;;************************************************************************************
;;
;; Este arquivo é licenciado sob licença BSD-3-Clause. Observe o arquivo de licença 
;; disponível no repositório para mais informações sobre seus direitos e deveres ao 
;; utilizar qualquer trecho deste arquivo.
;;
;; BSD 3-Clause License
;;
;; Copyright (c) 2015-2022, Felipe Miguel Nery Lunkes
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

HBoot.Procx86.Dados:

.vendedorProcx86: times 13 db 0
.nomeProcx86:              db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd", 0

;;************************************************************************************

initProc:

    call identificarVendedorProcx86

    call identificarNomeProcx86

    call habilitarA20                ;; Tentar habilitar prematuramente linha A20

    ret

;;************************************************************************************

identificarVendedorProcx86:

    mov eax, 0
    
    cpuid
    
    mov [HBoot.Procx86.Dados.vendedorProcx86], ebx
    mov [HBoot.Procx86.Dados.vendedorProcx86 + 4], edx
    mov [HBoot.Procx86.Dados.vendedorProcx86 + 8], ecx

    ret

;;************************************************************************************

identificarNomeProcx86:

    mov eax, 80000002h  
    
    cpuid
    
    mov di, HBoot.Procx86.Dados.nomeProcx86     

    stosd

    mov eax, ebx

    stosd

    mov eax, ecx

    stosd

    mov eax, edx

    stosd
    
    mov eax, 80000003h

    cpuid
    
    stosd

    mov eax, ebx
    
    stosd
    
    mov eax, ecx
    
    stosd
    
    mov eax, edx
    
    stosd
    
    mov eax, 80000004h  
    
    cpuid
    
    stosd
    
    mov eax, ebx
    
    stosd
    
    mov eax, ecx
    
    stosd 
    
    mov eax, edx
    
    stosd
    
    mov si, HBoot.Procx86.Dados.nomeProcx86     
    
    mov cx, 48
    
.loopCPU:   

    lodsb

    cmp al, ' '
    jae .formatarNomeCPU
    
    mov al, 0
    
.formatarNomeCPU:   

    mov [si-1], al
    
    loop .loopCPU

    ret

;;************************************************************************************

;; Vamos tentar ativar o A20 para verificar se o processador é compatível com o 
;; modo protegido

habilitarA20:

    clc 

    mov ax, 0x2401  ;; Solicitar a ativação do A20
        
    int 15h         ;; Interrupção do BIOS

    jc .erroA20

    ret 
    
.erroA20:

    exibir HBoot.Mensagens.erroA20

    jmp $