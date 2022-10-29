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

;; Agora, o HBoot pode realizar a inicialização de sistemas DOS-like, como MS-DOS,
;; FreeDOS, DR-DOS, dentre outros. Para isso, o nome de arquivo do DOS específico deve
;; ser definido, bem como o segmento de carregamento do mesmo

;; Aqui temos os nomes de arquivos que possam conter um kernel DOS

HBoot.Modulos.DOS.Arquivos:

.imagemFreeDOS: db "KERNEL  SYS"

;; Aqui temos os segmentos para carregamento de um kernel DOS (variável)

HBoot.Modulos.DOS.Segmentos.segmentoFreeDOS equ 0x60

;;************************************************************************************

HBoot.Modulos.DOS.iniciarFreeDOS:

    push ds 
    pop es 
    
    mov byte[HBoot.Modulos.Controle.moduloAtivado], 01h

    mov si, HBoot.Modulos.DOS.Arquivos.imagemFreeDOS
    mov di, HBoot.Arquivos.nomeImagem

    mov cx, 11
    
;; Copiar o nome do arquivo

    rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], HBoot.Modulos.DOS.Segmentos.segmentoFreeDOS

    call procurarArquivo

    jc .gerenciarErroArquivo

;; O FreeDOS recebe o parâmetro de drive de boot em BL

    mov bl, byte[idDrive]           ;; Drive utilizado para a inicialização

    jmp HBoot.Modulos.DOS.Segmentos.segmentoFreeDOS:0000h ;; Configurar CS:IP e executar o Kernel

    jmp $

.gerenciarErroArquivo:

    exibir HBoot.Mensagens.DOSAusente

    call aguardarTeclado

    jmp verificarInteracaoUsuario.testarComponentes