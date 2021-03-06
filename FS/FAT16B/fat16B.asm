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
;;                  Copyright © 2020-2022 Felipe Miguel Nery Lunkes
;;                          Todos os direitos reservados
;;                                  
;;************************************************************************************
;;
;;                                   Hexagon® Boot
;;
;;                   Carregador de Inicialização do Kernel Hexagon®
;;
;;            Lógica para encontrar e carregar arquivo em um volume FAT16
;;
;;************************************************************************************

;; Agora iremos procurar o arquivo que contêm o Kernel

procurarArquivoFAT16B:

;; Calcular o tamanho do diretório raiz
;; 
;; Fórmula:
;;
;; Tamanho  = (entradasRaiz * 32) / bytesPorSetor

    mov ax, word[entradasRaiz]
    shl ax, 5			;; Multiplicar por 32
    mov bx, word[bytesPorSetor]
    xor dx, dx			;; DX = 0
    
    div bx				;; AX = AX / BX
    
    mov word[tamanhoRaiz], ax ;; Salvar tamanho do diretório raiz

;; Calcular o tamanho das tabelas FAT	
;;
;; Fórmula:
;; Tamanho  = totalFATs * setoresPorFAT

    mov ax, word[setoresPorFAT]
    movzx bx, byte[totalFATs]
    xor dx, dx			      ;; DX = 0
    
    mul bx				      ;; AX = AX * BX
    
    mov word[tamanhoFATs], ax ;; Salvar tamanho das FATs

;; Calcular todos os setores reservados
;;
;; Fórmula:
;;
;; setoresReservados + LBA da partição

    add word[setoresReservados], bp	;; BP é o LBA da partição
    
;; Calcular o endereço da área de dados
;;
;; Fórmula:
;;
;; setoresReservados + tamanhoFATs + tamanhoRaiz

    movzx eax, word[setoresReservados]	
    
    add ax, word[tamanhoFATs]
    add ax, word[tamanhoRaiz]
    
    mov dword[areaDeDados], eax
    
;; Calcular o endereço LBA do diretório raiz e o carregar
;;
;; Fórmula:
;; 
;; LBA  = setoresReservados + tamanhoFATs

    movzx esi, word[setoresReservados]
    
    add si, word[tamanhoFATs]

    mov ax, word[tamanhoRaiz]
    mov di, bufferDeDisco
        
    call carregarSetor

;; Procurar no diretório raiz a entrada do arquivo para o carregar

    mov cx, word[entradasRaiz]
    mov bx, bufferDeDisco

    cld				    ;; Limpar direção
    
loopEncontrarArquivoFAT16B:

;; Encontrar o nome de 11 caracteres do arquivo em uma entrada

    xchg cx, dx			;; Salvar contador de loop
    mov cx, 11
    mov si, HBoot.Arquivos.nomeImagem
    mov di, bx
    
    rep cmpsb			;; Comparar (ECX) caracteres entre DI e SI
    
    je .arquivoEncontrado

    add bx, 32			;; Ir para a próxima entrada do diretório raiz (+ 32 bytes)
    
    xchg cx, dx			;; Restaurar contador
    
    loop loopEncontrarArquivoFAT16B

;; O arquivo executável do Kernel não foi encontrado. Exibir mensagem de erro e finalizar.

    pop esi

    mov si, HBoot.Mensagens.naoEncontrado
    
    call imprimir
    
    jmp $

.arquivoEncontrado:

    mov si, word[bx+26]		
    mov word[cluster], si ;; Salvar primeiro cluster

;; Carregar FAT na memória para encontrar todos os clusters do arquivo

    mov ax, word[setoresPorFAT]	    ;; Total de setores para carregar
    mov si, word[setoresReservados]	;; LBA
    mov di, bufferDeDisco		    ;; Buffer para onde os dados serão carregados

    call carregarSetor

;; Calcular o tamanho do cluster em bytes
;;
;; Fórmula:
;;
;; setoresPorCluster * bytesPorSetor

    movzx eax, byte[setoresPorCluster]
    movzx ebx, word[bytesPorSetor]
    xor edx, edx
        
    mul ebx				    ;; AX = AX * BX	
    
    mov ebp, eax			;; Salvar tamanho do cluster
    
    mov ax, word[HBoot.Arquivos.segmentoFinal]	;; Segmento de carregamento do arquivo
    mov es, ax
    mov edi, 0			    ;; Buffer para carregar o Kernel

;; Encontrar cluster e carregar cadeia de clusters

loopCarregarClustersFAT16B:

;; Converter endereço lógico de um cluster para endereço LBA (endereço físico)
;;
;; Fórmula:
;; 
;; ((cluster - 2) * setoresPorCluster) + areaDeDados
 
    movzx esi, word[cluster]	
        
    sub esi, 2

    movzx ax, byte[setoresPorCluster]		
    xor edx, edx         ;; DX = 0
    
    mul esi              ;; (cluster - 2) * setoresPorCluster
    
    mov esi, eax	

    add esi, dword[areaDeDados]

    movzx ax, byte[setoresPorCluster] ;; Total de setores para carregar
    
    call carregarSetor
    
;; Encontrar próximo setor na tabela FAT

    mov bx, word[cluster]
    shl bx, 1                   ;; BX * 2 (2 bytes na entrada)
    
    add bx, bufferDeDisco       ;; Localização da FAT

    mov si, word[bx]		    ;; SI contêm o próximo cluster

    mov word[cluster], si       ;; Salvar isso

    cmp si, 0xFFF8              ;; 0xFFF8 é fim de arquivo (EOF)
    jae .finalizado

;; Adicionar espaço para o próximo cluster
    
    add edi, ebp                ;; EBP tem o tamanho do cluster
    
    jmp loopCarregarClustersFAT16B

.finalizado:

    ret