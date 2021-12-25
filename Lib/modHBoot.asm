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

;; Aqui vamos carregar módulos do HBoot, caso o usuário necessite dos mesmos. Estes
;; módulos podem futuramente extender as funções do HBoot, podendo ser desenvolvidos
;; para funções específicas, como teste de memória, testes de outros componentes e 
;; etc

HBoot.modHBoot.Mensagens:

.retornoMod: db 13, 10, "HBoot: Voce retornou de um modulo HBoot finalizado.", 13, 10
             db "HBoot: E recomendado reiniciar o computador antes de iniciar o Hexagon(R).", 13, 10
             db "HBoot: Pressione [ENTER] para continuar...", 13, 10, 0

;;************************************************************************************

carregarModulo:

    mov byte[HBoot.Modulos.Controle.moduloAtivado], 01h

    mov si, HBoot.Mensagens.pressionado

    call imprimir

    mov si, HBoot.Mensagens.iniciarModulo

    call imprimir

    mov di, HBoot.Arquivos.imagemModulo

    call lerTeclado

    mov si, HBoot.Arquivos.imagemModulo
	mov di, HBoot.Arquivos.nomeImagem

	mov cx, 11
	
;; Copiar o nome do arquivo

	rep movsb ;; Copiar (ECX) caracteres de ESI para EDI

    mov word[HBoot.Arquivos.segmentoFinal], SEG_MODULOS

    call procurarArquivo

    jc .gerenciarErroArquivo

    mov dl, byte[idDrive]            ;; Drive utilizado para a inicialização
    mov ebp, dword[enderecoBPB + (SEG_HBOOT * 16)] ;; Ponteiro para o BPB
    mov esi, dword[enderecoLBAParticao + (SEG_HBOOT * 16)] ;; Ponteiro para a partição

    push ss
    push sp

    jmp SEG_MODULOS:CABECALHO_MODULO ;; Configurar CS:IP e executar o módulo

.gerenciarErroArquivo:

    exibir HBoot.Mensagens.moduloAusente

    call aguardarTeclado
    
    jmp verificarInteracaoUsuario.testarComponentes

;;************************************************************************************

retornarModulo:

    mov ax, SEG_HBOOT
    mov ds, ax
    mov es, ax
    mov gs, ax

    pop ss
    pop sp 

    push ds
    pop es 
    
    exibir HBoot.modHBoot.Mensagens.retornoMod

    call aguardarTeclado

    jmp analisarPC.novaEntrada