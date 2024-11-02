;;*************************************************************************************************
;;
;; 88                                                                                88
;; 88                                                                                ""
;; 88
;; 88,dPPPba,   ,adPPPba, 8b,     ,d8 ,adPPPPba,  ,adPPPb,d8  ,adPPPba,  8b,dPPPba,  88 8b,     ,d8
;; 88P'    "88 a8P     88  `P8, ,8P'  ""     `P8 a8"    `P88 a8"     "8a 88P'   `"88 88  `P8, ,8P'
;; 88       88 8PP"""""""    )888(    ,adPPPPP88 8b       88 8b       d8 88       88 88    )888(
;; 88       88 "8b,   ,aa  ,d8" "8b,  88,    ,88 "8a,   ,d88 "8a,   ,a8" 88       88 88  ,d8" "8b,
;; 88       88  `"Pbbd8"' 8P'     `P8 `"8bbdP"P8  `"PbbdP"P8  `"PbbdP"'  88       88 88 8P'     `P8
;;                                               aa,    ,88
;;                                                "P8bbdP"
;;
;;                     Sistema Operacional Hexagonix - Hexagonix Operating System
;;
;;                         Copyright (c) 2015-2024 Felipe Miguel Nery Lunkes
;;                        Todos os direitos reservados - All rights reserved.
;;
;;*************************************************************************************************
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
;;*************************************************************************************************
;;
;; BSD 3-Clause License
;;
;; Copyright (c) 2015-2024, Felipe Miguel Nery Lunkes
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
;; Messages and debugging
;;
;;************************************************************************************

HBoot.Messages:

.starting:
db "Hexagon Boot (HBoot) version ", versionHBoot, " (", __stringDay, "/", __stringMonth, "/", __stringYear, ").", 13, 10
db "Boot loader for Hexagonix.", 13, 10
db "Copyright (C) 2015-", __stringYear, " Felipe Miguel Nery Lunkes.", 13, 10
db "All rights reserved.", 13, 10, 0
.waitUser:
db 13, 10, "Press [F8] to access HBoot settings... ",  0
.notFound:
db 13, 10, "HBoot: Hexagon image not found on current volume.", 13, 10
db "Impossible to continue the initialization protocol. Please try to perform", 13, 10
db "a system restore or reinstallation and try to start the system again.", 13, 10, 0
.diskError:
db 13, 10, "HBoot: Disk error! Restart your computer and try again.", 0 ;; Mensagem de error no disco
.errorA20:
db "HBoot: Error enabling line A20, required for protected mode.", 13, 10
db "Unable to continue booting. Please restart your computer.", 0
.memoryError:
db "HBoot: Insufficient RAM installed to run Hexagon.", 13, 10
db "Cannot continue. At least 32 Mb are required.", 13, 10
db "Install more memory and try again.", 0
.loadHexagon:
db 13, 10, 13, 10, "Loading Hexagon...", 0
.invalidImage:
db 13, 10, "HBoot: The Hexagon image appears to be corrupt and cannot be used for", 13, 10
db "initialization. Try reinstalling or recovering system to continue.", 0
.DOSMode:
db 13, 10, "HBoot: Load DOS system from a Hexagon volume.", 13, 10
db "HBoot: HBoot has entered DOS boot compatibility mode.", 13, 10
db "This means you can boot some DOS system installed on same partition/volume as", 13, 10
db "Hexagon, if it supports Hexagon volume filesystem. Please select more", 13, 10
db "option below pertinent to your case. The list below does not contain DOS", 13, 10
db "installations about Hexagon automatically detected on the original volume", 13, 10
db "installation of Hexagon, but currently supported DOS versions by HBoot", 13, 10
db "protocols. Remembering that this is a function still in testing and problems", 13, 10
db "may occur. If you don't have a DOS system installed on the Hexagon", 13, 10
db "installation volume, the process will fail.", 13, 10
db "It is worth remembering that HBoot or this function does not contain code", 13, 10
db "derived from no other projects, open source or otherwise, so compatibility" , 13, 10
db "is not guaranteed and may not work. The initialization parameters of DOS system", 13, 10
db "may vary and some of these were taken from the documentation of the appropriate", 13, 10
db "projects, if any.", 13, 10
db "[!] Warning! File and executable formats are incompatible between DOS and", 13, 10
db "Hexagon systems. To return to Hexagon, restart your computer and wait.", 13, 10
db " > [1]: Start FreeDOS installed on the Hexagon volume.", 10, 13
db " > [2]: Return to previous menu.", 13, 10, 0
.startMod:
db 13, 10, "HBoot: Start HBoot module.", 13, 10
db "HBoot: Here you can start a compatible module for HBoot.", 13, 10
db "Enter a file name in FAT format, as in the example:", 13, 10
db "For hello.txt file, supply 'HELLO   TXT', without quotes and in capital letters.", 13, 10
db "The name must have a maximum of 11 uppercase characters.", 13, 10, 13, 10
db " > ", 0
.pressed:
db "[Ok]", 13, 10, 0
.optionFailure:
db "[Fail]", 13, 10, 0
.aboutHBoot:
db 13, 10, "HBoot: Hexagon Boot Information - HBoot version ", versionHBoot, " (", __stringDay, "/", __stringMonth, "/", __stringYear, ")", 13, 10, 13, 10
db "Copyright 2015-", __stringYear, " Felipe Miguel Nery Lunkes.", 13, 10
db "All rights reserved.",13, 10
db "HBoot is licensed under BSD-3-Clause.", 13, 10, 13, 10
db "Hexagon Boot (HBoot) is a powerful boot loader designed to boot the Hexagon", 13, 10
db "kernel on a volume of your computer. HBoot has the function to perform tests", 13, 10
db "to verify that the computer can run Hexagon and, after the tests, load the ", 13, 10
db "kernel, provide parameters (if any user-supplied) and start running Hexagon.", 0
.pressedF8:
db "HBoot: Here you can change Hexagon boot parameters.", 13, 10, 0
.mainCategories:
db 13, 10, "You can change the parameters below:", 13, 10
db " > [1]: Provide a command line to Hexagon.", 13, 10
db " > [2]: Get information about the configured boot environment.", 13, 10
db " > [3]: Commit changes and start Hexagon/Hexagonix.", 13, 10
db " > [4]: More information about HBoot.", 13, 10
db " > [5]: Restart the device.", 13, 10
db " > [t,T]: Experimental and diagnostic options (modules, starting FreeDOS, etc).", 10, 13, 10, 13
db "[!] Warning: Use experimental and diagnostic functions with care!", 10, 13, 0
.selectCategory:
db 13, 10, "Select option: ", 0
.invalidCategory:
db 13, 10, "HBoot: Invalid option. Press [ENTER] to continue boot.", 0
.testComponents:
db 13, 10, "HBoot: Here you can test HBoot components as well as use functions and features", 13, 10
db "under development or not in wide use.", 13, 10, 0
.componentList:
db 13, 10, "You can test some components and functions of HBoot:", 13, 10
db "[!] Warning! Some tests require restart!", 13, 10
db " > [1]: Test sound hardware and startup tone.", 13, 10
db " > [2]: Display contents of registers (required restart).", 13, 10
db " > [3]: Perform video test in graphics mode.", 13, 10
db " > [4]: Restart the device.", 13, 10
db " > [5]: Return to previous menu.", 13, 10
db " > [d,D]: Start boot compatibility mode and start DOS system.", 13, 10
db " > [m,M]: Load module in HBoot format.", 13, 10, 0
.displayRegisters:
db 13, 10, 13, 10, "HBoot: List and contents of main processor registers (proc0):", 13, 10, 13, 10, 0
.selectComponent:
db 13, 10, "Select option: ", 0
.invalidComponent:
db 13, 10, "HBoot: Invalid option. Press [ENTER] to return.", 13, 10, 0
.changeVerboseMode:
db 13, 10, "HBoot: Choose (0) to turn off verbose or (1) to turn on:", 0
.invalidOption:
db 13, 10, "HBoot: Invalid behavior change option for selection.", 13, 10
db "HBoot: Press [ENTER] to continue boot without changing behavior...", 13, 10, 0
.resumeBoot:
db "HBoot: Continuing with the boot protocol...", 13, 10, 0
.commandLine:
db 13, 10, "Enter the command line for Hexagon. Pay attention to the parameters supported,", 13, 10
db "with a maximum of 64 characters.", 13, 10, 13, 10
db "> ", 0
.withoutCPUID:
db "<Pentium III or older/unknown processor>", 0
.invalidFilesystem:
db 13, 10, "HBoot: Volume filesystem is not supported by HBoot at this time.", 13, 10, 0
.errorMBR:
db 13, 10, "HBoot: Error when trying to retrieve information from the MBR. Impossible to continue.", 13, 10, 0
.detailedInfo:
db 13, 10, "Detailed boot environment information:", 0
.memoryInfo:
db 13, 10, " > Total memory installed: ", 0
.processorVendor:
db 13, 10, " > Processor information (manufacturer's signature): ", 0
.processorName:
db 13, 10, " > Processor name: ", 0
.bootDisk:
db 13, 10, " > Boot volume (Hexagon device name): ", 0
.hexagonFile:
db 13, 10, " > Hexagon image on volume to be loaded: ", 0
.totalMemory:
db 13, 10, " > Total memory installed: ", 0
.megabytes:
db " megabytes", 0
.commandLineInfo:
db 13, 10, " > Command line for Hexagon: ", 0
.modNotFound:
db 13, 10, 13, 10, "HBoot: The file containing an HBoot module was not found on volume.", 13, 10
db "HBoot: Press [ENTER] to return to the previous menu...", 13, 10, 0
.DOSNotFound:
db 13, 10, 13, 10, "HBoot: DOS system files not found on volume.", 13, 10
db "HBoot: Press [ENTER] to return to the previous menu...", 13, 10, 0
.hexagonNotFound:
db 13, 10, 13, 10, "HBoot: The file containing the Hexagon was not found.", 13, 10
db "HBoot: Press [ENTER] to restart your computer...", 13, 10, 0
.emptyCommandLine:
db "<null>", 0
.hd0:
db "hd0", 0
.hd1:
db "hd1", 0
.hd2:
db "hd2", 0
.hd3:
db "hd3", 0
.dsq0:
db "dsq0", 0
.dsq1:
db "dsq1", 0
.cdrom0:
db "cdrom0", 0
.filesystems:
db 13, 10, " > Volume file system: ", 0
.FAT16:
db "FAT16", 0
.FAT16B:
db "FAT16B", 0
.FAT12:
db "FAT12", 0
.FAT16LBA:
db "FAT16LBA", 0
.FAT32:
db "FAT32", 0
.unknownFilesystem:
db "<unknown>", 0
.continueEnter:
db 13, 10
.continueEnterReturn:
db 13, 10, "HBoot: press [ENTER] to return to the previous menu...", 13, 10, 0
.partitionSize:
db 13, 10, " > Volume partition size: ", 0
.versionHBoot:
db 13, 10, " > HBoot version: ", versionHBoot, " (build ", __stringDay, "/", __stringMonth, "/", __stringYear, ")", 0
.versionProtocol:
db 13, 10, " > HBoot boot protocol (loader) version: ", bootProtocolVersion, 0
.newLine:
db 13, 10, 0
.onlineVolumes:
db 13, 10, " > Online volumes (Hexagon device names): ", 0
.space:
db " ", 0
.hex:
db "0x0000", 13, 10, 0
.hexc:
db "0123456789ABCDEF"
.css:
db " > CS: ",0
.dss:
db " > DS: ",0
.sss:
db " > SS: ",0
.ess:
db " > ES: ",0
.gss:
db " > GS: ",0
.fss:
db " > FS: ",0
.axx:
db " > AX: ",0
.bxx:
db " > BX: ",0
.cxx:
db " > CX: ",0
.dxx:
db " > DX: ",0
.spp:
db " > SP: ",0
.bpp:
db " > BP: ",0
.sii:
db " > SI: ",0
.dii:
db " > DI: ",0
.rebootRequired:
db 13, 10
.continueReboot:
db 13, 10, "Press [ENTER] to restart the computer (required)...", 13, 10, 0
