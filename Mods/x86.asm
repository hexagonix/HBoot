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

;; Módulo de diagnóstico e inicialização de hardware para HBoot
;;
;; x86-Detect
;;
;; Copyright (C) 2022 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.
;;
;; Contêm código derivado das bibliotecas Assembly para PX-DOS
;; Copyright (C) 2012-2016 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.

;; Macros 

macro exibir mensagem
{

    mov si, mensagem

    call imprimir

}

;;************************************************************************************

;; Definições iniciais e constantes

MEMORIA_MINIMA = 32768    ;; Memória mínima necessária para boot seguro do Hexagonix

;;************************************************************************************

use16   

cabecalhoHBoot:

.assinatura:  db "HBOOT"       ;; Assinatura, 5 bytes
.arquitetura: db 01h           ;; Arquitetura (i386), 1 byte
.versaoMod:   db 00h           ;; Versão
.subverMod:   db 02h           ;; Subversão
.nomeMod:     db "x86Det  "    ;; Nome do módulo

;;************************************************************************************

inicioModulo:  

    push dx 

;; Primeiro devemos configurar e definir os registradores de segmento. O segmento é fornecido 
;; juntamente com CS, então devemos passar o valor do segmento para AX e então para DS e ES, que
;; não podem ser acessados diretamente em uma cópia a partir de CS.

    mov ax, cs           
    mov ds, ax           
    mov es, ax                                        

;; Vamos preparar a tela para o usuário

    call limparTela
    call definirCor

;; Exibir informações de inicialização

    exibir x86.iniciando
    exibir x86.direitos

;; Vamos iniciar agora a verificação do hardware disponível

    call verificarHardware

;; Vamos verificar se a execução do Hexagon foi aprovada

    exibir x86.terminar

    call verificarAprovacao

;; Vamos solicitar a interação do usuário para reiniciar e retornar ao HBoot

    exibir x86.reinicioNecessario

    call aguardarPressionamento

;; Reiniciar!

    int 19h

;;************************************************************************************
;;
;; Funções de análise de dispositivo
;;
;;************************************************************************************

verificarHardware:

    exibir x86.iniciandoIdentificacao

    call identificarVendedorProcx86
    call identificarNomeProcx86
    call verificarMemoria
    call verificarDiscos
;;  call verificarPortasSeriais
;;  call verificarPortasParalelas
;;  call verificarVideo
;;  call verificarPerifericos

    ret

;;************************************************************************************

verificarAprovacao:

    exibir x86.resultadoAvaliacao

    cmp byte[x86.aprovadoTestes], 01h
    je .aprovado 

    exibir x86.resultadoNegativo

    jmp .fim 

.aprovado:

    exibir x86.resultadoPositivo

.fim:

    ret

;;************************************************************************************

verificarDiscos:

    exibir x86.identificandoDiscos

    clc 

.dsq0:

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 00h 
 
    int 13h

    jc .errodsq0
 
    exibir x86.dsq0

    jmp .dsq1
 
.errodsq0:

  jmp .dsq1
  
.dsq1:
  
    clc 

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 01h 
 
    int 13h
 
    jc .errodsq1
 
    exibir x86.dsq1
    
    jmp .hd0
 
 .errodsq1:

    jmp .hd0
 
;;**************************************************************************

.hd0:

    clc 

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 80h 
 
    int 13h

    jc .errohd0
 
    exibir x86.hd0
 
 ;; Para realização a inicialização correta, o hd0 é requisito

    cmp byte [x86.aprovadoTestes], 01h
    jne .continuar 

    mov byte[x86.aprovadoTestes], 01h ;; Aprovado aqui mas recusado de todo jeito

.continuar:

    jmp .hd1
 
 .errohd0:
  
    jmp .hd1
  
.hd1:

    clc
  
    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h

    xor bx, bx

    mov bx, 0x50
    mov es, bx

    xor bx, bx

    mov dh, 00h
    mov dl, 81h 
 
    int 13h
 
    jc .errohd1
 
    exibir x86.hd1

    jmp .fim
 
 .errohd1:

.fim:

    ret

;;************************************************************************************

identificarVendedorProcx86:

    mov eax, 0
    
    cpuid
    
    mov [x86.vendedorx86], ebx
    mov [x86.vendedorx86 + 4], edx
    mov [x86.vendedorx86 + 8], ecx

.exibirUsuario:

    exibir x86.fornecedorProc

    exibir x86.vendedorx86

    ret

;;************************************************************************************

identificarNomeProcx86:

    mov eax, 80000002h  
    
    cpuid
    
    mov di, x86.nomex86     

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
    
    mov si, x86.nomex86     
    
    mov cx, 48
    
.loopCPU:   

    lodsb

    cmp al, ' '
    jae .formatarNomeCPU
    
    mov al, 0
    
.formatarNomeCPU:   

    mov [si-1], al
    
    loop .loopCPU

    exibir x86.nomeProcessador

    mov si, x86.nomex86

    cmp byte[si], 0
    jne .comCPUID

    exibir x86.semCPUID

    jmp .fim

.comCPUID:

    exibir x86.nomex86

.fim:

    ret

;;************************************************************************************

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
    
    add eax, 1024 ;; Vamos adicionar o abaixo da marca de 1 Mb

    push eax 

    exibir x86.memoriaDisponivel

    pop eax 
    push eax 

    shr ax, 10 ;; ECX = ECX / 1024

    call paraString 

    mov si, ax
    
    call imprimir

    exibir x86.megabytes 

    pop eax 

    cmp dword eax, MEMORIA_MINIMA
    jbe .erroMemoria ;; Se menos que isso, não temos o suficiente

    exibir x86.memoriaSuficiente

;; Para realização a inicialização correta, o mínimo de RAM é requisito

    mov byte[x86.aprovadoTestes], 01h

    jmp .terminar

.erroMemoria:

    exibir x86.memoriaInsuficiente

;; Para realização a inicialização correta, o mínimo de RAM é requisito

    mov byte[x86.aprovadoTestes], 00h

.terminar:

    ret

;;************************************************************************************
;;
;; Funções úteis para a execução do módulo
;;
;; Bibliotecas Assembly para PX-DOS adaptadas para o x86-Detect
;; Copyright (C) 2012-2016 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.
;;
;;************************************************************************************

;; Função construída para exibir na saída de vídeo do usuário uma mensagem presente em SI e
;; retornar a função que a chamou

imprimir:

    lodsb       ;; mov AL, [SI] & inc SI
    
    or al, al   ;; cmp AL, 0
    jz .pronto
    
    mov ah, 0Eh
    
    int 10h     ;; Enviar [SI] para a tela
    
    jmp imprimir
    
.pronto: 

    ret

;;************************************************************************************

limparTela:

    mov dx, 0
    mov bh, 0
    mov ah, 2
    
    int 10h  
    
    mov ah, 6           
    mov al, 0           
    mov bh, 7           
    mov cx, 0           
    mov dh, 24          
    mov dl, 79
    
    int 10h

    ret

;;************************************************************************************

lerTeclado:  

    xor cl, cl

.loop:

    mov ah, 0
    
    int 16h

    cmp al, 0x08
    je .apagar

    cmp al, 0x0D
    je .pronto

    cmp cl, 0x3F
    je .loop

    mov ah, 0x0E
    
    int 10h

    stosb

    inc cl

    jmp .loop

.apagar:          ;; Apagar um caracter

    cmp cl, 0
    je .loop

    dec di
    
    mov byte [di], 0
    
    dec cl

    mov ah, 0x0E
    mov al, 0x08

    int 10h

    mov al, ' '

    int 10h

    mov al, 0x08
    
    int 10h

    jmp .loop

.pronto:          ;; Tarefa ou rotina concluida

    mov al, 0

    stosb

    mov ah, 0x0E
    mov al, 0x0D
    
    int 10h

    mov al, 0x0A
    int 10h

    ret

;;************************************************************************************

aguardarPressionamento:

    mov ax, 0

    int 16h

    ret

;;************************************************************************************

identificarTecla:

    mov     ah, 1

    int     16h

    jz      identificarTecla

    mov     ah, 0

    int     16h

    ret

;;************************************************************************************

paraMaiusculo: ;; Esta função requer um ponteiro para a string, em DS:SI

    pusha
    
    mov bx, 0xFFFF                      ;; Início em -1, dentro da String
    
paraMaiusculoLoop:  

    inc bx
    
    mov al, byte [ds:si+bx]             ;; Em al, o caracter atual
    
    cmp al, 0                           ;; Caso no fim da String
    je paraMaiusculoPronto          ;; Está tudo pronto
    
    cmp al, 'a'
    jb paraMaiusculoLoop              ;; Código ASCII muito baixo para ser minúsculo
    
    cmp al, 'z'
    ja paraMaiusculoLoop              ;; Código ASCII muito alto para ser minúsculo
    
    sub al, 'a'-'A'
    mov byte [ds:si+bx], al             ;; Subtraia e transformar em maiúsculo
    
    jmp paraMaiusculoLoop             ;; Próximo caractere
    
paraMaiusculoPronto:    

    popa
    
    ret

;;************************************************************************************

gotoxy:

;; Em dh a linha
;; Em dl a coluna

    push ax
    push bx
    push dx

    mov ah, 02h
    mov bh, 0

    int 10h

    pop dx
    pop bx
    pop ax
        
    ret

;;************************************************************************************

definirCor:

    mov ah, 00h
    mov al, 03h

    int 10h

    mov ax, 1003h
    mov bx, 0    

    int 10h

    push ax      
    push ds      
    push bx      
    push cx      
    push di      

    mov ax, 40h
    mov ds, ax  
    mov ah, 06h
    mov al, 0   
    mov bh, 1001_1111b  
    mov ch, 0   
    mov cl, 0   
    mov di, 84h 
    mov dh, [di] 
    mov di, 4ah 
    mov dl, [di]

    dec dl  

    int 10h
 
    mov bh, 0  
    mov dl, 0   
    mov dh, 0   
    mov ah, 02

    int 10h

    pop di      
    pop cx      
    pop bx      
    pop ds      
    pop ax      

    ret 

;;************************************************************************************

paraString:

    pusha

    mov cx, 0
    mov bx, 10
    mov di, .tmp
        
.empurrar:

    mov dx, 0

    div bx
    inc cx

    push dx

    test ax,ax
    jnz .empurrar
        
.puxar:

    pop dx

    add dl, '0'
    mov [di], dl

    inc di
    dec cx

    jnz .puxar

    mov byte [di], 0

    popa

    mov ax, .tmp

    ret
        
    .tmp: times 7 db 0

;;************************************************************************************

;;************************************************************************************
;;
;; Constantes e mensagens do módulo 
;;
;;************************************************************************************

VERSAO equ "0.2 (05/06/2022)"

x86:

.iniciando:              db "x86-Detect para HBoot versao ", VERSAO, 10, 13, 0
.direitos:               db "Copyright (C) 2022 Felipe Miguel Nery Lunkes. Todos os direitos reservados.", 10, 13, 0
.iniciandoIdentificacao: db 10, 13, "[!] Iniciando a identificacao e inicializacao do hardware instalado...", 0
.identificandoDiscos:    db 10, 13, " [>] Unidades de disco online (nomes Hexagon): ", 0
.terminar:               db 10, 13, "[!] O x86-Detect terminou de fazer o diagnostico.", 10, 13, 0
.dsq0:                   db "dsq0", 0
.dsq1:                   db "dsq1", 0
.hd0:                    db "hd0", 0
.hd1:                    db "hd1", 0
.espaco:                 db " ", 0
.virgula:                db ", ", 0
.ponto:                  db ".", 0
.fornecedorProc:         db 10, 13, " [>] Fabricante do processador instalado: ", 0
.nomeProcessador:        db 10, 13, " [>] Nome do processador instalado: ", 0
.vendedorx86: times 13   db 0
.nomex86:                db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd", 0
.semCPUID:               db "processador sem suporte a CPUID.", 0
.memoriaInsuficiente:    db " [impossivel executar o Hexagon].", 0
.memoriaSuficiente:      db " [compativel com Hexagon].", 0
.resultadoAvaliacao:     db 10, 13, "Resultado da avaliacao de desempenho e compatibilidade:", 10, 13, 0
.resultadoNegativo:      db 10, 13, "[!] O sistema nao podera ser iniciado nesta configuracao.", 0
.resultadoPositivo:      db 10, 13, "[:D] O Hexagonix pode ser iniciado neste dispositivo/configuracao.", 0
.memoriaDisponivel:      db 10, 13, " [>] Memoria total instalada: ", 0
.megabytes:              db " megabytes", 0
.reinicioNecessario:     db 10, 13, 10, 13, "[!] Reinicio necessario. Pressione qualquer tecla para continuar...", 0
.aprovadoTestes:         db 0