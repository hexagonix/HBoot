;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2015-2023 Felipe Miguel Nery Lunkes
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
;; Copyright (c) 2015-2023, Felipe Miguel Nery Lunkes
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

verificarMemoria:

    push edx
    push ecx
    push ebx

    xor eax, eax
    xor ebx, ebx
    
    mov ax, 0xE801
    
    xor dx, dx
    xor cx, cx
    
    int 15h
    
    jnc .processar
    
    xor eax, eax
    
    jmp .fim         ;; Erro                                  

.quantificar:

    mov si, ax
    
    or si, bx
    jne .quantificar
    
    mov ax, cx
    mov bx, dx

.processar:

    cmp ax, 0x3C00
    jb .abaixoDe16MB
    
    movzx eax, bx
    
    add eax, 100h
    
    shl eax, 16      ;; EAX = EAX * 65536
    
    jmp .fim

.abaixoDe16MB:

    shl eax, 10      ;; EAX = EAX * 1024

.fim:

    pop ebx
    pop ecx
    pop edx
    
;; Vamos salvar aqui o total de memória recuperado. Caso seja suficiente para o processo continuar,
;; a quantidade de RAM instalada será fornecida ao Hexagon®, em Kbytes

;; Vamos comparar se a quantidade de RAM é suficiente para uma inicialização bem sucedida

    shr eax, 10 ;; EAX = EAX / 1024

;; Precisamos agora adicionar a memória abaixo de 1 MB que está disponível mas que 
;; não entra na quantificação feita.

    add eax, 1024 ;; Pronto. Vamos adicionar 1024 kbytes a conta

    mov word[memoriaDisponivel], ax 

    cmp dword eax, MEMORIA_MINIMA
    jbe .erroMemoria ;; Se menos que isso, não temos o suficiente

    ret

.erroMemoria:

    exibir HBoot.Mensagens.erroMemoria

    jmp $ ;; Não dá para continuar. Então, permanecer aqui