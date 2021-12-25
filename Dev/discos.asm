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
;;                 Copyright © 2020-2022 Felipe Miguel Nery Lunkes
;;                         Todos os direitos reservados
;;                                  
;;************************************************************************************

HBoot.Disco:

.tamanho:		db 16
.reservado:	    db 0
.totalSetores:	dw 0
.deslocamento:	dw 0x0000
.segmento:	    dw 0
.LBA:		    dd 0
                dd 0
.dsq0Online:    db 0
.dsq1Online:    db 0
.hd0Online:     db 0
.hd1Online:     db 0

HBoot.Disco.Mensagens:

.erroReiniciarDisco: db 13, 10, "HBoot: Falha ao reiniciar disco.", 13, 10
                     db "HBoot: Pressione [ENTER] para continuar...", 13, 10, 13, 10, 0

;;************************************************************************************
;;	
;; Dados do disco
;;
;;************************************************************************************
                                                        
bytesPorSetor:	 	 dw 512	;; Número de bytes em cada setor
setoresPorCluster:	 db 8	;; Setores por cluster
setoresReservados:	 dw 16	;; Setores reservados após o setor de inicialização
totalFATs:		     db 2	;; Número de tabelas FAT
entradasRaiz:		 dw 512	;; Número total de pastas e arquivos no diretório raiz
setoresPorFAT:		 dw 16	;; Setores usados na FAT
idDrive:		     db 0	;; Número de identificação do drive.
tamanhoRaiz:         dw 0   ;; Tamanho do diretório raiz (em setores)
tamanhoFATs:         dw 0   ;; Tamanho das tabelas FAT (em setores)
areaDeDados:         dd 0   ;; Endereço físico da área de dados (LBA)
enderecoLBAParticao: dd 0   ;; Endereço LBA da partição
enderecoBPB:         dd 0   ;; Endereço do BIOS Parameter Block (BPB)
cluster:	         dw 0   ;; Cluster atual
memoriaDisponivel:   dw 0   ;; Memória disponível

;;************************************************************************************

verificarDiscos:

    pushad
    pushf

.verificardsq0:

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 00h 
 
    int 13h

    jc .errodsq0
 
    mov byte[HBoot.Disco.dsq0Online], 01h
 
    jmp .verificardsq1
 
.errodsq0:
 
    mov byte[HBoot.Disco.dsq0Online], 00h
  
    jmp .verificardsq1
  
.verificardsq1:
  
    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 01h 
 
    int 13h
 
    jc .errodsq1
 
    mov byte[HBoot.Disco.dsq1Online], 01h
 
    jmp verificarhd0
 
.errodsq1:
 
    mov byte[HBoot.Disco.dsq1Online], 00h

    jmp verificarhd0
 
;;************************************************************************************

verificarhd0:

    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 80h 
 
    int 13h

    jc .errohd0
 
    mov byte[HBoot.Disco.hd0Online], 01h
 
    jmp .verificarhd1
 
 .errohd0:
 
    mov byte[HBoot.Disco.hd0Online], 00h
  
    jmp .verificarhd1
  
.verificarhd1:
  
    mov ah, 02h
    mov al, 01h
    mov ch, 01h
    mov cl, 01h
    xor bx, bufferDeDisco
    mov dh, 00h
    mov dl, 81h 
 
    int 13h
 
    jc .errohd1
 
    mov byte[HBoot.Disco.hd1Online], 01h
 
    jmp .continuar
 
 .errohd1:
 
    mov byte[HBoot.Disco.hd1Online], 00h

.continuar:

    clc 
    cld

    popf
    popad

    ret

;;************************************************************************************

;; Carregar setor do disco especificado
;;
;; Entrada:
;;
;; AX  - Total de setores para carregar
;; ESI - Endereço LBA	
;; ES:DI - Localização do destino

carregarSetor:

    push si

    mov word[HBoot.Disco.totalSetores], ax
    mov dword[HBoot.Disco.LBA], esi
    mov word[HBoot.Disco.segmento], es
    mov word[HBoot.Disco.deslocamento], di

    mov dl, byte[idDrive]
    mov si, HBoot.Disco
    mov ah, 0x42		;; Função de leitura
    
    int 13h             ;; Serviços de disco do BIOS
    
    jnc .concluido			

;; Se ocorrerem erros no disco, exibir mensagem de erro na tela

    exibir HBoot.Mensagens.erroDisco	
    
    jmp $

.concluido:
    
    pop si
    
    ret

;;************************************************************************************

reiniciarDiscos:

.reiniciardsq0:

    mov ah, 00h
    mov dl, 00h 

    int 13h

    jc .erro 

.reiniciardsq1:

    mov ah, 00h 
    mov dl, 01h 

    int 13h

    jc .erro 

.reiniciarhd0:

    mov ah, 00h
    mov dl, 80h 

    int 13h

    jc .erro

.reiniciarhd1:

    mov ah, 00h
    mov dl, 81h 

    int 13h

    jc .erro

    jmp .fim

.erro:

    exibir HBoot.Disco.Mensagens.erroReiniciarDisco

    call aguardarTeclado

.fim:

    ret
