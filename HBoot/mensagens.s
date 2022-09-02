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

;;************************************************************************************
;;
;; Mensagens e debug
;;
;;************************************************************************************

HBoot.Mensagens:

.iniciando:             db "Hexagon(R) Boot (HBoot) versao ", versaoHBoot, " (", __stringdia, "/", __stringmes, "/", __stringano, ").", 13, 10
                        db "Gerenciador de Inicializacao para Hexagon(R).", 13, 10
                        db "Copyright (C) 2020-", __stringano, " Felipe Miguel Nery Lunkes.", 13, 10
                        db "Todos os direitos reservados.", 13, 10, 0
.aguardarUsuario:       db "Pressione [F8] para acessar as configuracoes do HBoot... ",  0
.naoEncontrado:         db 13,10, "HBoot: A imagem do Hexagon(R) nao foi encontrada no disco atual.", 13, 10
                        db "Impossivel continuar com o protocolo de inicializacao. Tente realizar", 13, 10
                        db "uma restauracao ou reinstalacao do sistema e tente iniciar o sistema", 13, 10
                        db "novamente.", 13, 10, 0
.erroDisco:             db 13, 10, "HBoot: Erro de disco! Reinicie o computador e tente novamente.", 0 ;; Mensagem de erro no disco
.erroA20:               db "HBoot: Erro ao habilitar a linha A20, necessaria para o", 13, 10
                        db "modo protegido.", 13, 10
                        db "Impossivel continuar a inicializacao. Reinicie seu computador.", 0
.erroMemoria:           db "HBoot: Memoria RAM instalada insuficiente para executar o Hexagon(R).", 13, 10
                        db "Impossivel continuar. Ao menos 32 Mb sao necessarios.", 13, 10
                        db "Instale mais memoria e tente novamente.", 0
.imagemInvalida:        db 13, 10, "HBoot: A imagem em disco do Hexagon(R) parece estar corrompida e nao pode", 13, 10
                        db "ser utilizada para a inicializacao. Tente reinstalar ou recuperar o", 13, 10
                        db "sistema para continuar.", 0
.modoDOS:               db 13, 10, "HBoot: Carregar sistema DOS a partir de um volume Hexagon(R)", 13, 10
                        db "HBoot: O HBoot entrou em modo de compatibilidade de iniciacao DOS.", 13, 10
                        db "Isso significa que voce pode iniciar algum sistema DOS instalado na", 13, 10
                        db "mesma particao/volume do Hexagon(R)/Andromeda(R), caso ele suporte o", 13, 10
                        db "sistema de Arquivos do volume Hexagon(R). Selecione abaixo a opcao mais", 13, 10
                        db "pertinente para o seu caso. A lista abaixo nao contem instalacoes DOS", 13, 10
                        db "sobre o Hexagon(R) detectadas automaticamente no volume original da", 13, 10
                        db "instalacao do Hexagon(R), mas sim as versoes DOS atualmente suportadas", 13, 10
                        db "pelos protocolos do HBoot. Lembrando que esta e uma funcao ainda em", 13, 10
                        db "teste e problemas podem ocorrer. Caso nao tenha um sistema DOS instalado", 13, 10
                        db "no volume de instalacao do Hexagon(R), o processo ira falhar.", 13, 10
                        db "Vale lembrar que o HBoot ou esta funcao nao contem codigo derivado de", 13, 10
                        db "nenhum outro projeto, de codigo livre ou nao, entao a compatibilidade" , 13, 10
                        db "nao e garantida e pode nao funcionar. Os parametros de inicializacao de", 13, 10
                        db "sistema DOS podem variar e alguns destes foram obtidos da documentacao", 13, 10
                        db "dos devidos projetos, caso exista.", 13, 10
                        db "[!] Aviso! Os formatos de arquivos e executaveis sao incompativeis entre", 13, 10
                        db "os sistemas DOS e Hexagon(R). Para retornar ao Hexagon(R), reinicie", 13, 10
                        db "seu computador e aguarde.", 13, 10
                        db " > [1] Iniciar FreeDOS instalado no volume Hexagon(R).", 10, 13
                        db " > [2]: Retornar ao menu anterior.", 13, 10, 0
.iniciarModulo:         db 13, 10, "HBoot: Iniciar modulo do HBoot.", 13, 10
                        db "HBoot: Aqui voce pode iniciar um modulo compativel para o HBoot.", 13, 10
                        db "Informe um nome de arquivo no formato FAT, como no exemplo:", 13, 10
                        db "Para arquivo oi.txt, forneca 'OI      TXT', sem aspas e em maiusculo.", 13, 10
                        db "O nome deve ter, no maximo, 11 caracteres maiusculos.", 13, 10, 13, 10
                        db " > ", 0
.pressionado:           db "[Ok]", 13, 10, 0
.falhaOpcao:            db "[Falha]", 13, 10, 0
.sobreHBoot:            db 13, 10, "Hboot: Informacoes do Hexagon(R) Boot - HBoot versao ", versaoHBoot, " (", __stringdia, "/", __stringmes, "/", __stringano, ")", 13, 10, 13, 10
                        db "O Hexagon Boot (HBoot) e um gerenciador de inicializacao poderoso", 13, 10
                        db "desenvolvido para inicializar o kernel Hexagon(R) em um volume do", 13, 10
                        db "armazenamento do seu computador. O HBoot tem como funcao realizar", 13, 10
                        db "testes para verificar se o computador pode executar o Hexagon(R) e,", 13, 10
                        db "apos os testes, carregar o kernel, fornecer parametros (caso sejam", 13, 10
                        db "fornecidos pelo usuario) e iniciar a execucao do Hexagon(R).", 0
.pressionouF8:          db "HBoot: Aqui voce pode alterar parametros de boot do Hexagon(R).", 13, 10, 0
.listaModif:            db 13, 10, "Voce pode alterar os parametros abaixo:", 13, 10
                        db " > [1]: Fornecer linha de comando/parametros personalizada ao Hexagon(R).", 13, 10
                        db " > [2]: Obter informacoes do ambiente de inicializacao configurado.", 13, 10
                        db " > [3]: Confirmar alteracoes/informacoes e iniciar o Hexagon(R).", 13, 10
                        db " > [4]: Mais informacoes sobre o HBoot.", 13, 10
                        db " > [t,T]: Opcoes experimentais e de diagnostico (modulos, iniciar FreeDOS, etc).", 10, 13
                        db "          Use as funcoes experimentais e de diagnostico com cuidado!", 10, 13, 0
.selecioneModif:        db 13, 10, "HBoot: Selecione opcao: ", 0
.modifIndisponivel:     db 13, 10, "HBoot: Opcao invalida. Pressione [ENTER] para continuar boot.", 0
.testarComponentes:     db 13, 10, "HBoot: Aqui voce pode testar componentes do HBoot, bem como utilizar", 13, 10
                        db "funcoes e recursos em desenvolvimento ou que nao sao de uso amplo.", 13, 10, 0
.listaComponentes:      db 13, 10, "Voce pode testar alguns componentes (lista provisoria):", 13, 10
                        db "[!] Aviso! Alguns testes requerem reinicio do computador!", 13, 10
                        db " > [1]: Testar tom de inicializacao (chora, Mac).", 13, 10
                        db " > [2]: Exibir conteudo dos registradores (necessario posterior reinicio).", 13, 10
                        db " > [3]: Realizar teste de video em modo grafico.", 13, 10
                        db " > [4]: Reiniciar o computador.", 13, 10
                        db " > [5]: Retornar ao menu anterior.", 13, 10
                        db " > [d,D]: Iniciar modo de compatibilidade de boot e iniciar sistema DOS.", 13, 10
                        db " > [m,M]: Carregar modulo no formato HBoot.", 13, 10, 0
.exibirRegs:            db 13, 10, 13, 10, "HBoot: Lista e conteudo dos registradores do processador principal (proc0):", 13, 10, 13, 10, 0
.selecioneComponente:   db 13, 10, "HBoot: Selecione opcao: ", 0
.componenteInvalido:    db 13, 10, "HBoot: Opcao invalida. Pressione [ENTER] retornar.", 13, 10, 0
.alterarVerbose:        db 13, 10, "HBoot: Escolha (0) para desligar verbose ou (1) para ligar:", 0
.opcaoInvalida:         db 13, 10, "HBoot: Opcao de alteracao de comportamento invalida para a selecao.", 13, 10
                        db "HBoot: Pressione [ENTER] para continuar o boot sem alteracao de comportamento...", 13, 10, 0
.prosseguirBoot:        db "HBoot: Prosseguindo com o protocolo de boot...", 13, 10, 0       
.linhaComando:          db 13, 10, "HBoot: Insira a linha de comando para o Hexagon(R). Atente para os parametros", 13, 10
                        db "suportados, com maximo de 64 caracteres.", 13, 10
                        db "> ", 0   
.semCPUIDNome:          db "<Pentium III ou processador generico/desconhecido>", 0    
.saInvalido:            db 13, 10, "HBoot: O sistema de Arquivos do volume nao e suportado pelo HBoot no momento.", 13, 10, 0     
.erroMBR:               db 13, 10, "HBoot: Erro ao tentar recuperar informacoes da MBR. Impossivel continuar.", 13, 10, 0
.informacoesDetalhadas: db 13, 10, "HBoot: Informacoes detalhadas do ambiente de inicializacao:", 0
.informacaoMemoria:     db 13, 10, " > Memoria total instalada: ", 0
.vendedorProcessador:   db 13, 10, " > Informacao do processador (assinatura do fabricante): ", 0
.nomeProcessador:       db 13, 10, " > Nome do processador: ", 0
.discoBoot:             db 13, 10, " > Volume de inicializacao (nome Hexagon(R)): ", 0
.arquivoHexagon:        db 13, 10, " > Imagem do Hexagon(R) em disco a ser carregada: ", 0
.infoLinhaComando:      db 13, 10, " > Linha de comando para o Hexagon(R): ", 0
.moduloAusente:         db 13, 10, 13, 10, "HBoot: O arquivo que contem um modulo HBoot nao foi encontrado no disco.", 13, 10
                        db "HBoot: Pressione [ENTER] para retornar ao menu anterior...", 13, 10, 0
.DOSAusente:            db 13, 10, 13, 10, "HBoot: Os arquivos de sistema DOS nao foram encontrados no disco.", 13, 10
                        db "HBoot: Pressione [ENTER] para retornar ao menu anterior...", 13, 10, 0
.HexagonAusente:        db 13, 10, 13, 10, "HBoot: O arquivo que contem o Hexagon(R) nao foi encontrado.", 13, 10
                        db "HBoot: Pressione [ENTER] para reiniciar seu computador...", 13, 10, 0
.linhaVazia:            db "<vazio>", 0
.hd0:                   db "hd0", 0
.hd1:                   db "hd1", 0
.hd2:                   db "hd2", 0
.hd3:                   db "hd3", 0
.dsq0:                  db "dsq0", 0
.dsq1:                  db "dsq1", 0
.cdrom0:                db "cdrom0", 0
.sistemaArquivos:       db 13, 10, " > Sistema de Arquivos do volume: ", 0
.FAT16:                 db "FAT16", 0
.FAT16B:                db "FAT16B", 0
.FAT12:                 db "FAT12", 0
.FAT16LBA:              db "FAT16LBA", 0
.FAT32:                 db "FAT32", 0
.saDesconhecido:        db "<desconhecido>", 0
.enterContinuar:        db 13, 10
.enterContinuarEU:      db 13, 10, "HBoot: pressione [ENTER] para retornar ao menu anterior...", 13, 10, 0
.tamanhoParticao:       db 13, 10, " > Tamanho da particao do volume: ", 0
.versaoHBoot:           db 13, 10, " > Versao do HBoot: ", versaoHBoot, " (build ", __stringdia, "/", __stringmes, "/", __stringano, ")", 0
.versaoProtocolo:       db 13, 10, " > Versao do protocolo de boot (carregador) do HBoot: ", verProtocolo, 0
.novaLinha:             db 13, 10, 0
.unidadesOnline:        db 13, 10, " > Unidades online (nomes Hexagon(R)): ", 0
.espacoSimples:         db " ", 0
.hex:                   db "0x0000", 13, 10, 0
.hexc:                  db "0123456789ABCDEF"
.css:                   db " > Registrador CS: ",0
.dss:                   db " > Registrador DS: ",0
.sss:                   db " > Registrador SS: ",0
.ess:                   db " > Registrador ES: ",0
.gss:                   db " > Registrador GS: ",0
.fss:                   db " > Registrador FS: ",0
.axx:                   db " > Registrador AX: ",0
.bxx:                   db " > Registrador BX: ",0
.cxx:                   db " > Registrador CX: ",0
.dxx:                   db " > Registrador DX: ",0
.spp:                   db " > Registrador SP: ",0
.bpp:                   db " > Registrador BP: ",0
.sii:                   db " > Registrador SI: ",0
.dii:                   db " > Registrador DI: ",0
.reinicioContinuarED:   db 13, 10
.reinicioContinuar:     db 13, 10, "Pressione [ENTER] para reiniciar o computador (necessario)...", 13, 10, 0
;