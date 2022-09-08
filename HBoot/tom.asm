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
;; Copyright (C) 2016-2022 Felipe Miguel Nery Lunkes
;; Todos os direitos reservados.

;; Tocar tom de inicialização do sistema, tal como em Macs/Apple

tomInicializacao:
  
;; Roteiro de execução com nota e tempo. Macro em "HBOOT.S"

    tocarNota HBoot.Sons.nDO, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nLA, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nDO, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nLA, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nFA, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nSI, HBoot.Sons.tNormal
    tocarNota HBoot.Sons.nDO2, HBoot.Sons.tNormal

    call desligarsom

    ret