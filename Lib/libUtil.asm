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

HBoot.Sons: ;; Frequências de som para as notas musicais utilizadas para a música

;; Tema do Hexagonix®

.nDO  = 2000
.nRE  = 2100
.nMI  = 2300
.nFA  = 2700
.nSOL = 3000
.nLA  = 3200
.nSI  = 3600
.nDO2 = 4060

;; CANON

.CANON1 = 3060
.CANON2 = 4020
.CANON3 = 3800
.CANON4 = 5400
.CANON5 = 5080
.CANON6 = 7120
.CANON7 = 5080
.CANON8 = 4420

;; Temporizador padrão em microssegundos

.tNormal    = 01h
.tExtendido = 02h
