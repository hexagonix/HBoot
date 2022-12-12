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

;;************************************************************************************
;;
;; Mensagens e debug
;;
;;************************************************************************************

HBoot.Mensagens:

.iniciando:             db "Hexagon(R) Boot (HBoot) version ", versaoHBoot, " (", __stringdia, "/", __stringmes, "/", __stringano, ").", 13, 10
                        db "Boot loader for Hexagon(R).", 13, 10
                        db "Copyright (C) 2020-", __stringano, " Felipe Miguel Nery Lunkes.", 13, 10
                        db "All rights reserved.", 13, 10, 0
.aguardarUsuario:       db "Press [F8] to access HBoot settings... ",  0
.naoEncontrado:         db 13,10, "HBoot: Hexagon(R) image not found on current volume.", 13, 10
                        db "Impossible to continue the initialization protocol. Please try to perform", 13, 10
                        db "a system restore or reinstallation and try to start the system again.", 13, 10, 0
.erroDisco:             db 13, 10, "HBoot: Disk Error! Restart your computer and try again.", 0 ;; Mensagem de erro no disco
.erroA20:               db "HBoot: Error enabling line A20, required for protected mode.", 13, 10
                        db "Unable to continue booting. Please restart your computer.", 0
.erroMemoria:           db "HBoot: Insufficient RAM installed to run Hexagon(R).", 13, 10
                        db "Cannot continue. At least 32 Mb are required.", 13, 10
                        db "Install more memory and try again.", 0
.imagemInvalida:        db 13, 10, "HBoot: The Hexagon(R) disk image appears to be corrupt and cannot", 13, 10
                        db "be used for initialization. Try reinstalling or recovering system to", 13, 10
                        db "continue.", 0
.modoDOS:              db 13, 10, "HBoot: Load DOS system from a Hexagon(R) volume", 13, 10
                        db "HBoot: HBoot has entered DOS boot compatibility mode.", 13, 10
                        db "This means you can boot some DOS system installed on same partition/volume as", 13, 10
                        db "Hexagon(R), if it supports Hexagon(R) Volume File System. Please select more ", 13, 10
                        db "option below pertinent to your case. The list below does not contain DOS", 13, 10
                        db "installations about Hexagon(R) automatically detected on the original volume", 13, 10
                        db "installation of Hexagon(R), but currently supported DOS versions by HBoot ", 13, 10
                        db "protocols. Remembering that this is a function still in testing and problems ", 13, 10
                        db "may occur. If you don't have a DOS system installed on the Hexagon(R) ", 13, 10
                        db "installation volume, the process will fail.", 13, 10
                        db "It is worth remembering that HBoot or this function does not contain code", 13, 10
                        db "derived from no other projects, open source or otherwise, so compatibility" , 13, 10
                        db "is not guaranteed and may not work. The initialization parameters of DOS system", 13, 10
                        db "may vary and some of these were taken from the documentation of the appropriate", 13, 10
                        db "projects, if any.", 13, 10
                        db "[!] Warning! File and executable formats are incompatible between DOS and", 13, 10
                        db "Hexagon(R) systems. To return to Hexagon(R), restart your computer and wait.", 13, 10
                        db " > [1]: Start FreeDOS installed on the Hexagon(R) volume.", 10, 13
                        db " > [2]: Return to previous menu.", 13, 10, 0
.iniciarModulo:         db 13, 10, "HBoot: Start HBoot module.", 13, 10
                        db "HBoot: Here you can start a compatible module for HBoot.", 13, 10
                        db "Enter a file name in FAT format, as in the example:", 13, 10
                        db "For oi.txt file, supply 'OI TXT', without quotes and in capital letters.", 13, 10
                        db "The name must have a maximum of 11 uppercase characters.", 13, 10, 13, 10
                        db " > ", 0
.pressionado:           db "[Ok]", 13, 10, 0
.falhaOpcao:            db "[Fail]", 13, 10, 0
.sobreHBoot:            db 13, 10, "HBoot: Hexagon(R) Boot Information - HBoot version ", versaoHBoot, " (", __stringdia, "/", __stringmes, "/", __stringano, ")", 13, 10, 13, 10
                        db "Hexagon Boot (HBoot) is a powerful boot loader designed to boot the Hexagon(R) ", 13, 10
                        db "kernel on a volume storage of your computer. HBoot has the function to perform", 13, 10
                        db "tests to verify that the computer can run Hexagon(R) and, after the tests, load", 13, 10
                        db "the kernel, provide parameters (if any user-supplied) and start running", 13, 10
                        db "Hexagon(R).", 0
.pressionouF8:          db "HBoot: Here you can change Hexagon(R) boot parameters.", 13, 10, 0
.listaModif:            db 13, 10, "You can change the parameters below:", 13, 10
                        db " > [1]: Provide custom command line/parameters to Hexagon(R).", 13, 10
                        db " > [2]: Get configured boot environment information.", 13, 10
                        db " > [3]: Commit changes/information and start Hexagon(R).", 13, 10
                        db " > [4]: More information about HBoot.", 13, 10
                        db " > [t,T]: Experimental and diagnostic options (modules, starting FreeDOS, etc).", 10, 13
                        db " Use experimental and diagnostic functions with care!", 10, 13, 0
.selecioneModif:        db 13, 10, "HBoot: Select option: ", 0
.modifIndisponivel:     db 13, 10, "HBoot: Invalid option. Press [ENTER] to continue boot.", 0
.testarComponentes:     db 13, 10, "HBoot: Here you can test HBoot components as well as use", 13, 10
                        db "functions and features under development or not in wide use.", 13, 10, 0
.listaComponentes:      db 13, 10, "You can test some components (tentative list):", 13, 10
                        db "[!] Warning! Some tests require computer restart!", 13, 10
                        db " > [1]: Test startup tone (cries, Mac).", 13, 10
                        db " > [2]: Display contents of registers (required later restart).", 13, 10
                        db " > [3]: Perform video test in graphics mode.", 13, 10
                        db " > [4]: Restart the computer.", 13, 10
                        db " > [5]: Return to previous menu.", 13, 10
                        db " > [d,D]: Start boot compatibility mode and start DOS system.", 13, 10
                        db " > [m,M]: Load module in HBoot format.", 13, 10, 0
.exibirRegs:            db 13, 10, 13, 10, "HBoot: List and contents of main processor registers (proc0):", 13, 10, 13, 10, 0
.selecioneComponente:   db 13, 10, "HBoot: Select option: ", 0
.componenteInvalido:    db 13, 10, "HBoot: Invalid option. Press [ENTER] to return.", 13, 10, 0
.alterarVerbose:        db 13, 10, "HBoot: Choose (0) to turn off verbose or (1) to turn on:", 0
.opcaoInvalida:         db 13, 10, "HBoot: Invalid behavior change option for selection.", 13, 10
                        db "HBoot: Press [ENTER] to continue boot without changing behavior...", 13, 10, 0
.prosseguirBoot:        db "HBoot: Continuing with the boot protocol...", 13, 10, 0       
.linhaComando:          db 13, 10, "HBoot: Enter the command line for Hexagon(R). Pay attention to the parameters", 13, 10
                        db "supported, with a maximum of 64 characters.", 13, 10
                        db "> ", 0   
.semCPUIDNome:          db "<Pentium III or generic/unknown processor>", 0    
.saInvalido:            db 13, 10, "HBoot: Volume Filesystem is not supported by HBoot at this time.", 13, 10, 0     
.erroMBR:               db 13, 10, "HBoot: Error when trying to retrieve information from the MBR. Impossible to continue.", 13, 10, 0
.informacoesDetalhadas: db 13, 10, "HBoot: Detailed boot environment information:", 0
.informacaoMemoria:     db 13, 10, " > Total memory installed: ", 0
.vendedorProcessador:   db 13, 10, " > Processor information (manufacturer's signature): ", 0
.nomeProcessador:       db 13, 10, " > Processor name: ", 0
.discoBoot:             db 13, 10, " > Boot volume (Hexagon name): ", 0
.arquivoHexagon:        db 13, 10, " > Hexagon image on disk to be loaded: ", 0
.infoLinhaComando:      db 13, 10, " > Command line for Hexagon: ", 0
.moduloAusente:         db 13, 10, 13, 10, "HBoot: The file containing an HBoot module was not found on disk.", 13, 10
                        db "HBoot: Press [ENTER] to return to the previous menu...", 13, 10, 0
.DOSAusente:            db 13, 10, 13, 10, "HBoot: DOS system files not found on disk.", 13, 10
                        db "HBoot: Press [ENTER] to return to the previous menu...", 13, 10, 0
.HexagonAusente:        db 13, 10, 13, 10, "HBoot: The file containing the Hexagon(R) was not found.", 13, 10
                        db "HBoot: Press [ENTER] to restart your computer...", 13, 10, 0
.linhaVazia:            db "<null>", 0
.hd0:                   db "hd0", 0
.hd1:                   db "hd1", 0
.hd2:                   db "hd2", 0
.hd3:                   db "hd3", 0
.dsq0:                  db "dsq0", 0
.dsq1:                  db "dsq1", 0
.cdrom0:                db "cdrom0", 0
.sistemaArquivos:       db 13, 10, " > Volume file system: ", 0
.FAT16:                 db "FAT16", 0
.FAT16B:                db "FAT16B", 0
.FAT12:                 db "FAT12", 0
.FAT16LBA:              db "FAT16LBA", 0
.FAT32:                 db "FAT32", 0
.saDesconhecido:        db "<unknown>", 0
.enterContinuar:        db 13, 10
.enterContinuarEU:      db 13, 10, "HBoot: press [ENTER] to return to the previous menu...", 13, 10, 0
.tamanhoParticao:       db 13, 10, " > volume partition size: ", 0
.versaoHBoot:           db 13, 10, " > HBoot version: ", versaoHBoot, " (build ", __stringdia, "/", __stringmes, "/", __stringano, ")", 0
.versaoProtocolo:       db 13, 10, " > HBoot boot protocol (loader) version: ", verProtocolo, 0
.novaLinha:             db 13, 10, 0
.unidadesOnline:        db 13, 10, " > Online volumes (Hexagon names): ", 0
.espacoSimples:         db " ", 0
.hex:                   db "0x0000", 13, 10, 0
.hexc:                  db "0123456789ABCDEF"
.css:                   db " > Register CS: ",0
.dss:                   db " > Register DS: ",0
.sss:                   db " > Register SS: ",0
.ess:                   db " > Register ES: ",0
.gss:                   db " > Register GS: ",0
.fss:                   db " > Register FS: ",0
.axx:                   db " > Register AX: ",0
.bxx:                   db " > Register BX: ",0
.cxx:                   db " > Register CX: ",0
.dxx:                   db " > Register DX: ",0
.spp:                   db " > Register SP: ",0
.bpp:                   db " > Register BP: ",0
.sii:                   db " > Register SI: ",0
.dii:                   db " > Register DI: ",0
.reinicioContinuarED:   db 13, 10
.reinicioContinuar:     db 13, 10, "Press [ENTER] to restart the computer (required)...", 13, 10, 0
;