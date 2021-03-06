;; Implementação de teste de um módulo HBoot
;;
;; Exibe uma mensagem e, após interação do usuário, reinicia o computador

use16	

;; O Hboot e módulos devem apresentar um cabeçalho especial de imagem HBoot
;; São 10 bytes, com assinatura (número mágico), arquitetura alvo, versão,
;; subversão e nome interno, sendo o último com até 8 bytes.

cabecalhoHBoot:

.assinatura:  db "HBOOT"       ;; Assinatura, 5 bytes
.arquitetura: db 01h           ;; Arquitetura (i386), 1 byte
.versaoMod:   db 01h           ;; Versão
.subverMod:   db 00h           ;; Subversão
.nomeMod:     db "SPARTAN "    ;; Nome do módulo

;;************************************************************************************

;; Início do módulo: ?x????:10h 

inicioModulo:  

    push dx 

;; Primeiro devemos configurar e definir os registradores de segmento. O segmento é fornecido 
;; juntamente com CS, então devemos passar o valor do segmento para AX e então para DS e ES, que
;; não podem ser acessados diretamente em uma cópia a partir de CS.

    mov ax, cs           
    mov ds, ax           
    mov es, ax                                         

;; A função deste módulo é exibir uma mensagem previamente definida e então reiniciar o computador.
;; Outros módulos podem implementar diversas outras funcionalidades, incluindo ser um terceiro estágio
;; de boot para encontrar partições com sistemas de arquivos não suportados pelo HBoot e carregar e 
;; executar um kernel obtido de lá, onde o HBoot atuaria apenas sendo utilizado no processo de boot 
;; inicial e configuração de periféricos.

    mov si, Spartan.mensagem ;; Vamos fornecer a mensagem

    call imprimir ;; E solicitar a função de exibição para que a exiba na tela

    mov ah, 0 ;; Agora, aguardar o pressionamento de qualquer tecla pelo usuário

    int 16h ;; Existe uma função na interrupção do BIOS responsável pela manipulação de teclado

    pop dx 

    jmp 0x1000:06h ;; Agora, vamos reiniciar o computador após o pressionamento de qualquer tecla

;; Também é possível pular para o ponto de entrada do HBoot, utilizando o código abaixo. Entretanto,
;; isso só deve ser feito em casos especiais e quando realmente for bastante necessário. 

    ;; jmp 0x1000:06 ;; Retornar o controle diretamente ao HBoot via segmento:deslocamento

;;************************************************************************************

;; Função construída para exibir na saída de vídeo do usuário uma mensagem presente em SI e
;; retornar a função que a chamou

imprimir:

    lodsb		;; mov AL, [SI] & inc SI
    
    or al, al	;; cmp AL, 0
    jz .pronto
    
    mov ah, 0Eh
    
    int 10h     ;; Enviar [SI] para a tela
    
    jmp imprimir
    
.pronto: 

    ret

;;************************************************************************************

;; Área de dados, como constantes e variáveis do módulo. Podem ser incluídas mensagens, valores
;; constantes e reservas de memória, além de variáveis.

Spartan:

.mensagem: db 13, 10, 13, 10, "Modelo de implementacao de modulo HBoot iniciado com sucesso.", 13, 10
           db "Pressione qualquer tecla para retornar ao HBoot...", 13, 10, 0
