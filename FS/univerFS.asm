;;************************************************************************************
;;
;;    
;; ┌┐ ┌┐                                 Sistema Operacional Hexagonix®
;; ││ ││
;; │└─┘├──┬┐┌┬──┬──┬──┬─┐┌┬┐┌┐    Copyright © 2016-2022 Felipe Miguel Nery Lunkes
;; │┌─┐││─┼┼┼┤┌┐│┌┐│┌┐│┌┐┼┼┼┼┘          Todos os direitos reservados
;; ││ │││─┼┼┼┤┌┐│└┘│└┘││││├┼┼┐
;; └┘ └┴──┴┘└┴┘└┴─┐├──┴┘└┴┴┘└┘
;;              ┌─┘│          
;;              └──┘          
;;
;;
;;************************************************************************************
;;
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;
;;
;;************************************************************************************

HBoot.SistemaArquivos:

.codigo:          db 0
.tamanhoParticao: dd 0
.FAT12            = 01h ;; FAT12 (Futuro)
.FAT16            = 04h ;; FAT16 (< 32 MB)
.FAT16B           = 06h ;; FAT16B (FAT16B) - Suportado
.FAT16LBA         = 0Eh ;; FAT16 (LBA)

;;************************************************************************************

definirSistemaArquivos:
	
	call lerMBR

	mov byte[HBoot.SistemaArquivos.codigo], ah
	
	ret

;;************************************************************************************

lerMBR:

;; Primeiro devemos carregar a MBR na memória
    
	mov ax, 01h                    ;; Número de setores para ler
	mov esi, 00h                   ;; LBA do setor inicial
	mov di, bufferDeDisco	       ;; Deslocamento
	mov dl, byte[idDrive] 

	call carregarSetor

	jc .erro

	mov ebx, bufferDeDisco

	add ebx, 0x1BE ;; Deslocamento da primeira partição

	mov ah, byte[es:ebx+04h]        ;; Contém o sistema de arquivos

    mov ebx, dword[es:ebx+0xF]      ;; Tamanho da partição

    mov dword[HBoot.SistemaArquivos.tamanhoParticao], ebx

	jmp .fim

.erro:

    mov si, HBoot.Mensagens.erroMBR

    call imprimir

    jmp $

.fim:

    ret

;;************************************************************************************

;; Aqui temos as funções genéricas chamadas, que redirecionarão para a lógica correta

procurarArquivo:

    mov ah, byte[HBoot.SistemaArquivos.codigo]

    cmp ah, HBoot.SistemaArquivos.FAT16B
    je .FAT16B 

    mov si, HBoot.Mensagens.saInvalido

    call imprimir

    jmp $

.FAT16B:

    call procurarArquivoFAT16B

    ret

;;************************************************************************************

;; Lista de Sistemas de Arquivos suportado pelo HBoot

include "FAT16B/fat16B.asm"
