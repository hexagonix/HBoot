<p align="center">
<img src="https://github.com/hexagonix/Doc/blob/main/Img/banner.png">
</p>

<div align="center">

![](https://img.shields.io/github/license/hexagonix/HBoot.svg)
![](https://img.shields.io/github/stars/hexagonix/HBoot.svg)
![](https://img.shields.io/github/issues/hexagonix/HBoot.svg)
![](https://img.shields.io/github/issues-closed/hexagonix/HBoot.svg)
![](https://img.shields.io/github/issues-pr/hexagonix/HBoot.svg)
![](https://img.shields.io/github/issues-pr-closed/hexagonix/HBoot.svg)
![](https://img.shields.io/github/downloads/hexagonix/HBoot/total.svg)
![](https://img.shields.io/github/release/hexagonix/HBoot.svg)
[![](https://img.shields.io/twitter/follow/hexagonixOS.svg?style=social&label=Follow%20%40HexagonixOS)](https://twitter.com/hexagonixOS)

</div>

<!-- Vai funcionar como <hr> -->

<img src="https://github.com/hexagonix/Doc/blob/main/Img/hr.png" width="100%" height="2px" />

# Hexagon Boot - HBoot

<details title="Português (Brasil)" align='left'>
<br>
<summary align='left'>🇧🇷 Português (Brasil)</summary>
    
# Inicialização do Hexagon

<div align="justify">
        
Este repositório contém o gerenciador de inicialização MBR do Hexagonix e o Hexagon Boot, responsável por carregar, configurar e executar o Hexagon, bem como oferecer outros recursos.

> **Este arquivo não fornece informações técnicas sobre o HBoot ou o processo de inicialização do Hexagon. Para acessar a documentação técnica completa, clique [aqui](https://github.com/hexagonix/Doc/blob/main/HBoot/README.pt.md).**

</div>
    
## Saturno

<div align="justify">
    
O primeiro componente do Hexagonix é o Saturno. Ele é responsável por receber o controle do processo de inicialização realizado pelo BIOS/UEFI e procurar no volume o segundo estágio de inicialização. Para isso, ele implementa um driver para leitura de um sistema de arquivos FAT16. O segundo estágio de inicialização (ver adiante) pode implementar drivers para outros sistemas de arquivos e é responsável por encontrar o Hexagon, carregar módulos HBoot ou carregar um sistema do tipo DOS compatível (versão BETA).

</div>
    
## Hexagon Boot (HBoot)

<div align="justify">
    
O Hexagon Boot (HBoot) é um componente desenvolvido permitir a inicialização do kernel Hexagon. Até então, a inicialização era realizada por apenas um estágio, que definia um ambiente bem básico, carregava o Hexagon na memória e imediatamente passava o controle para ele, fornecendo um conjunto bem pequeno e limitado de parâmetros, uma vez que o código desse estágio fica restrito a 512 bytes, o que limita a realização de diversos testes e processamento de dados. Como o HBoot, foi possível expandir o número de tarefas realizadas antes da execução do Hexagon, além da possibilidade de fornecer mais informações a respeito do ambiente da máquina e de inicialização. Isso é particularmente importante para permitir a criação de uma árvore de dispositivos que pode ser utilizada pelo Hexagon para decidir como manipular cada dispositivo identificado. O HBoot é capaz de verificar quais unidades de disco estão disponíveis na máquina, emitir um tom de inicialização, obter a quantidade de memória RAM disponível instalada e permitir ou não o seguimento do processo de boot de acordo com essa informação. Caso nenhuma interação do usuário seja detectada 3 segundos após todos os testes e atividades essenciais para criar um ambiente de inicialização para o Hexagon, o sistema irá carregar e executar o Hexagon (presente em um arquivo no volume nomeado de **HEXAGON.SIS** no Hexagonix H1 e **HEXAGON** no Hexagonix H2), sendo descarregado da memória. A interação com o HBoot se dá pelo pressionamento da tecla F8 após a respectiva mensagem surgir na tela. 

</div>
    
### Outras funções disponíveis

<div align="justify">

* O HBoot permite o carregamento de módulos no formato HBoot, que podem ser úteis, no futuro, para permitir testes de hardware, como testes de memória e disco, caso os módulos estejam disponíveis no disco. Os módulos podem ser utilizados também para extender as funções do HBoot. A especificação do formato já está disponível e um exemplo pode ser encontrado abaixo. Esses módulos podem ser utilizados para testar dispositivos específicos, obter informações do hardware ou carregar arquivos em sistemas de arquivos não suportados originalmente pelo HBoot.
* No contexto do desenvolvimento do Hexagonix, o HBoot também pode carregar diretamente, a partir de um módulo atualmente built-in (essa função será movida para um módulo standalone o quanto antes) o núcleo do sistema operacional de código livre FreeDOS[^1], para que ferramentas utilitárias já estabelecidas e robustas que sejam executadas em ambiente DOS possam ser executadas sobre o volume e arquivos Hexagonix/Andromeda. O FreeDOS foi escolhido devido a sua característica de kernel composto por um único arquivo, geralmente "KERNEL.SYS"[^2], além da sua distribuição livre e gratuita. Já outros DOS, como o MS-DOS, anterior a versão 7.0, utilizam dois arquivos que devem estar contíguos no disco, e isso não é possível aqui, visto que a instalação do FreeDOS ocorre já em um volume Hexagonix, com a cópia do kernel, interpretador de comando e outros utilitários DOS, sendo que o sistema operacional principal é o Hexagonix/Andromeda, com iniciação opcional do FreeDOS para alguma atividade em especial[^3]. Caso os componentes de sistema do FreeDOS não estejam presentes no disco (a cópia dos arquivos do FreeDOS não faz parte da imagem padrão), a inicialização em modo de compatibilidade DOS não irá ocorrer.

</div>
    
[^1]: Você pode encontrar a página do projeto [aqui](https://www.freedos.org/).
[^2]: A inicialização em modo DOS foi possível após pesquisa na documentação do FreeDOS, especialmente no arquivo "SYS.C" (que pode ser encontrado [aqui](http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/dos/sys/2043/)), que indica em qual segmento o kernel espera ser carregado e quais os parâmetros são necessários. Cada sistema DOS apresenta um segmento de carregamento preferencial e esse carregamento de outras edições do DOS pode ser implementada futuramente com o auxílio dos módulos HBoot. Todo o código para o carregamento do núcleo foi desenvolvido do zero e não se baseia em algum existente.
[^3]: A iniciação em modo de compatibilidade DOS do HBoot pode ser útil para rodar ferramentas de verificação de erros no volume, desfragmentação do volume, particionador e outras ferramentas de diagnóstico, bem como de desenvolvimento, como compiladores e montadores que não são suportados pelo Hexagonix/Andromeda (as ferramentas de 16 bits, por exemplo).

### Exemplo de módulo HBoot

<div align="justify">
    
Abaixo é possível encontrar um exemplo de implementação de módulo HBoot:

```assembly
;;************************************************************************************
;;
;;    
;;                                Módulo do HBoot
;;        
;;                             Hexagon® Boot - HBoot
;;           
;;                 Copyright © 2020-2021 Felipe Miguel Nery Lunkes
;;                         Todos os direitos reservados
;;                                  
;;************************************************************************************

use16					

;; O módulo deve apresentar um cabeçalho especial de imagem HBoot
;; São 6 bytes, com assinatura (número mágico) e arquitetura alvo

cabecalhoHBoot:

.assinatura:  db "HBOOT"     ;; Assinatura, 5 bytes
.arquitetura: db 01h         ;; Arquitetura (i386), 1 byte

;; Configurar pilha e ponteiro

    cli				   ;; Desativar interrupções
    
    mov ax, 0x2000                 ;; Definir aqui os registradores de pilha
    mov ss, ax
    mov sp, 0
    
    sti				   ;; Habilitar interrupções
     
    clc 

    mov ax, 0x2000                 ;; Definir aqui os registradores de segmento
    mov ds, ax
    mov es, ax
    
    sti                            ;; Habilitar as interrupções

;; Seu código aqui

```

### Sistemas de arquivos suportados

* FAT16B
* FAT12 (em desenvolvimento)

Novos sistemas de arquivos serão implementados no futuro.

</div>
    
### Reportar bugs

<div align="justify">
    
O HBoot ganhou muita complexidade desde o início de seu desenvolvimento, em 2020. Devido a esse aumento de código e a natureza de sua operação (16-bit), bugs podem ser encontrados. Os mesmos podem ser reportados no repositório ou por email, disponível no final deste arquivo.

</div>
    
</details>

<details title="English" align='left'>
<br>
<summary align='left'>🇬🇧 English</summary>
    
# Hexagon initialization

<div align="justify">
        
This repository contains the Hexagonix MBR boot manager and Hexagon Boot, which is responsible for loading, configuring, and running Hexagon, as well as offering other features.

> **This file does not provide technical information about the HBoot and Hexagon boot process. To access the complete technical documentation, click [here](https://github.com/hexagonix/Doc/tree/main/HBoot/README.en.md).**

</div>
    
## Saturno

<div align="justify">
    
The first component of Hexagonix is the Saturno. It is responsible for taking control of the boot process performed by the BIOS/UEFI and looking in the volume for the second boot stage. For that, it implements a driver for reading a FAT16 file system. The second boot stage (see below) can implement drivers for other filesystems and is responsible for finding Hexagon, loading HBoot modules or loading a compatible DOS-like system (BETA version).

</div>
    
## Hexagon Boot (HBoot)

<div align="justify">
    
Hexagon Boot (HBoot) is a component designed to allow booting the Hexagon kernel. Until then, initialization was performed by just one stage, which defined a very basic environment, loaded Hexagon into memory and immediately passed control to it, providing a very small and limited set of parameters, since the code at this stage is restricted to 512 bytes, which limits the performance of various tests and data processing. With HBoot, it was possible to expand the number of tasks performed before running Hexagon, as well as the possibility to provide more information about the machine and boot environment. This is particularly important to allow the creation of a device tree that Hexagon can use to decide how to handle each identified device. HBoot is able to check which disk drives are available on the machine, emit a boot tone, obtain the amount of available RAM memory installed and allow or not to proceed with the boot process according to this information. If no user interaction is detected 3 seconds after all tests and activities essential to create a boot environment for Hexagon, the system will load and run Hexagon (present in a file on the volume named **HEXAGON.SIS** on Hexagonix H1 and **HEXAGON** on Hexagonix H2), being unloaded from memory. The interaction with HBoot takes place by pressing the F8 key after the respective message appears on the screen.

</div>
    
### Other functions available

<div align="justify">

* HBoot allows loading modules in HBoot format, which may be useful in the future to allow hardware tests such as memory and disk tests if modules are available on disk. The modules can also be used to extend the functions of HBoot. The format specification is now available and an example can be found below. These modules can be used to test specific devices, obtain hardware information, or load files into filesystems not originally supported by HBoot.
* In the context of Hexagonix development, HBoot can also directly load, from a currently built-in module (this function will be moved to a standalone module as soon as possible) the core of the FreeDOS[^4] open source operating system , so that established and robust utility tools that run in a DOS environment can run on the Hexagonix/Andromeda volume and files. FreeDOS was chosen because of its kernel feature consisting of a single file, usually "KERNEL.SYS"[^5], in addition to its free distribution. Other DOS, such as MS-DOS, prior to version 7.0, use two files that must be contiguous on the disk, and this is not possible here, since the installation of FreeDOS takes place on a Hexagonix volume, with the kernel copy , command interpreter, and other DOS utilities, with the main operating system being Hexagonix/Andromeda, with optional launch of FreeDOS for some special activity[^6]. If the FreeDOS system components are not present on the disk (copying the FreeDOS files is not part of the default image), booting in DOS compatibility mode will not occur.

</div>

[^4]: You can find the project page [here](https://www.freedos.org/).
[^5]: Booting in DOS mode was possible after searching the FreeDOS documentation, especially the "SYS.C" file (which can be found [here](http://www.ibiblio.org/pub/micro/ pc-stuff/freedos/files/dos/sys/2043/)), which indicates which thread the kernel expects to load and which parameters are required. Each DOS system has a preferred loading segment and this loading of other DOS editions can be implemented in the future with the help of HBoot modules. All the code for loading the core was developed from scratch and not based on any existing ones.
[^6]: HBoot's DOS compatibility mode boot can be useful for running volume error checking, volume defrag, partitioning and other diagnostic as well as development tools such as compilers and assemblers that are not supported by Hexagonix/Andromeda (the 16-bit tools for example).

### HBoot module example

<div align="justify">
    
Below you can find an example of an HBoot module implementation:

```assembly
;;************************************************ ***************************************
;;
;;
;; HBoot module
;;
;; Hexagon® Boot - HBoot
;;
;; Copyright © 2020-2021 Felipe Miguel Nery Lunkes
;; All rights reserved
;;
;;************************************************ ***************************************

use16

;; The module must have a special HBoot image header
;; It's 6 bytes, with signature (magic number) and target architecture

headerHBoot:

.signature: db "HBOOT" ;; Signature, 5 bytes
.architecture: db 01h ;; Architecture (i386), 1 byte

;; Configure stack and pointer

cli ;; disable interrupts
    
    mov ax, 0x2000 ;; Define stack registers here
    mov ss, ax
    mov sp, 0
    
    sti;; Enable interrupts
     
    clc

    mov ax, 0x2000 ;; Define segment registers here
    mov ds, ax
    mov es, ax
    
    sti ;; Enable interrupts

;; your code here

```

### Supported filesystems

* FAT16B
* FAT12 (under development)

New filesystems will be implemented in the future.

</div>
    
### Report bugs

<div align="justify">
    
HBoot has gained a lot of complexity since the beginning of its development in 2020. Due to this increase in code and the nature of its operation (16-bit), bugs can be found. They can be reported in the repository or by email, available at the end of this file.

</div>
    
</details>

<!--

Versão deste arquivo: 2.0

-->
