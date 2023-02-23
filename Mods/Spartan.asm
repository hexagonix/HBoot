;;************************************************************************************
;;
;;                             ┌┐ ┌┐
;;                             ││ ││
;;                             │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐
;;                             │┌─┐││─┼┼┼┤┌┐│┌┐│┌┐│┌┐┼┼┼┼┘
;;                             ││ │││─┼┼┼┤┌┐│└┘│└┘││││├┼┼┐
;;                             └┘ └┴──┴┘└┴┘└┴─┐├──┴┘└┴┴┘└┘
;;                                          ┌─┘│                 
;;                                          └──┘          
;;
;;            Sistema Operacional Hexagonix® - Hexagonix® Operating System            
;;
;;                  Copyright © 2015-2023 Felipe Miguel Nery Lunkes
;;                Todos os direitos reservados - All rights reserved.
;;
;;************************************************************************************
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
;;************************************************************************************
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

;; Implementação de teste de um módulo HBoot
;;
;; Exibe uma mensagem e, após interação do usuário, reinicia o computador

use16   

;; O Hboot e módulos devem apresentar um cabeçalho especial de imagem HBoot
;; São 10 bytes, com assinatura (número mágico), arquitetura alvo, versão,
;; subversão e nome interno, sendo o último com até 8 bytes.

cabecalhoHBoot:

.assinatura:  db "HBOOT"       ;; Assinatura, 5 bytes
.arquitetura: db 01h           ;; Arquitetura (i386), 1 byte
.versaoMod:   db 01h           ;; Versão
.subverMod:   db 00h           ;; Subversão
.nomeMod:     db "SPARTAN "    ;; Nome do módulo

;;************************************************************************************

;; Início do módulo: ?x????:10h 

inicioModulo:  

    push dx 

;; Primeiro devemos configurar e definir os registradores de segmento. O segmento é fornecido 
;; juntamente com CS, então devemos passar o valor do segmento para AX e então para DS e ES, que
;; não podem ser acessados diretamente em uma cópia a partir de CS.

    mov ax, cs           
    mov ds, ax           
    mov es, ax                                         

;; A função deste módulo é exibir uma mensagem previamente definida e então reiniciar o computador.
;; Outros módulos podem implementar diversas outras funcionalidades, incluindo ser um terceiro estágio
;; de boot para encontrar partições com sistemas de arquivos não suportados pelo HBoot e carregar e 
;; executar um kernel obtido de lá, onde o HBoot atuaria apenas sendo utilizado no processo de boot 
;; inicial e configuração de periféricos.

    mov si, Spartan.mensagem ;; Vamos fornecer a mensagem

    call imprimir ;; E solicitar a função de exibição para que a exiba na tela

    mov ah, 0 ;; Agora, aguardar o pressionamento de qualquer tecla pelo usuário

    int 16h ;; Existe uma função na interrupção do BIOS responsável pela manipulação de teclado

    pop dx 

    jmp 0x1000:06h ;; Agora, vamos reiniciar o computador após o pressionamento de qualquer tecla

;; Também é possível pular para o ponto de entrada do HBoot, utilizando o código abaixo. Entretanto,
;; isso só deve ser feito em casos especiais e quando realmente for bastante necessário. 

    ;; jmp 0x1000:06 ;; Retornar o controle diretamente ao HBoot via segmento:deslocamento

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

;; Área de dados, como constantes e variáveis do módulo. Podem ser incluídas mensagens, valores
;; constantes e reservas de memória, além de variáveis.

Spartan:

.mensagem: db 13, 10, 13, 10, "Modelo de implementacao de modulo HBoot iniciado com sucesso.", 13, 10
           db "Pressione qualquer tecla para retornar ao HBoot...", 13, 10, 0
