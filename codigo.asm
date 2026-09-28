ORG 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------Instruções----------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;---------------Base do Jogo---------------;;

MAIN:
    LDA #20             ;carrega a instrução de ativar display
    TRAP VIDEO_CONFIG   ;ativa o display
    OR #0               ;checa se houve erro
    JNZ ERRO            ;se houve erro termina o jogo
    JSR MENU            ;vai para o jogo
    HLT                 ;para o jogo

MENU:
    JSR INTRODUCAO      ;texto introdutorio
    JMP ESPERAR_TECLA_MENU

GAME:
    LDA #0                          ;Limpa o terminal
    TRAP CURSOR
    JSR LIMPAR_DISPLAY              ;Limpa o display para desenhar os novos objetos
    JSR DESENHAR_TABULEIRO          ;desenha os circulos do usuário
    JSR DISPLAY_CURSOR              ;desenhar o cursor como um circulo, se o quadrado já foi preenchido, pinta o simbolo do quadrado de vermelho
    JSR CHECAR_FIM                  ;checa se o adversario venceu
    JSR ESCOLHA_INTERMEDIARIA       ;rotina das escolhas do usuario dentro do jogo
    JSR CHECAR_FIM                  ;checa se jogador venceu
    JSR ADVERSARIO                  ;rotina do adversario
    JMP GAME                        ;faz um loop
    RET


;;---------------Gráficos---------------;;

LIMPAR_DISPLAY:                     ;limpa o display para atualizar as imagens
    LDA #21
    TRAP LIMPAR
    RET

DESENHAR_LINHAS:                    ;faz as linhas da tabela
    LDA #23
    TRAP RETA_1
    LDA #23
    TRAP RETA_2
    LDA #23
    TRAP RETA_3
    LDA #23
    TRAP RETA_4

    RET

DESENHAR_TABULEIRO:
    JSR DESENHAR_LINHAS                 ;desenha as linhas do tabuleiro
    JSR DESENHAR_PLAYER_OU_ADVERSARIO   ;desenha o X ou O

    JSR CONTADOR                        ;soma 1 ao contador

    LDA PTR_CELULA                      ;vai para ao próximo quadrado
    ADD #1
    STA PTR_CELULA
    LDA PTR_CELULA+1
    ADC #0
    STA PTR_CELULA+1

    LDA #42                             ;desloca o x do circulo player
    ADD CIRCULO
    STA CIRCULO

    LDA #42                             ;desloca o O do inimigo
    ADD X_ADVERSARIO
    STA X_ADVERSARIO

    LDA CONT                            ;checa se está na ultima coluna
    SUB #3
    JSR VOLTA_PRIMEIRA_COLUNA_INTERMEDIARIO           ;volta para primeira coluna
    LDA CONT
    SUB #6
    JSR VOLTA_PRIMEIRA_COLUNA_INTERMEDIARIO

    LDA CONT
    SUB #9
    JNZ DESENHAR_TABULEIRO
    JSR REINICIA_CONTADOR

    LDA #22                             ;volta ao primeiro quadrado
    STA CIRCULO
    LDA #11
    STA CIRCULO+1

    LDA #22                             ;volta ao primeiro quadrado
    STA X_ADVERSARIO
    LDA #11
    STA X_ADVERSARIO+1

    LDA PTR_CELULA
    SUB #9
    STA PTR_CELULA
    LDA PTR_CELULA+1
    SBC #0
    STA PTR_CELULA+1
    RET

DESENHAR_ADVERSARIO:
    ;diagonal 1
    LDA X_ADVERSARIO      
    SUB X_ADVERSARIO+2    
    STA RETA_X                  

    LDA X_ADVERSARIO+1    
    SUB X_ADVERSARIO+2    
    STA RETA_X+1                

    LDA X_ADVERSARIO      
    ADD X_ADVERSARIO+2    
    STA RETA_X+2                 

    LDA X_ADVERSARIO+1    
    ADD X_ADVERSARIO+2    
    STA RETA_X+3           

    LDA X_ADVERSARIO+3    
    STA RETA_X+4

    LDA #23
    TRAP RETA_X            

    ;diagonal 2
    LDA X_ADVERSARIO      
    SUB X_ADVERSARIO+2    
    STA RETA_X             

    LDA X_ADVERSARIO+1    
    ADD X_ADVERSARIO+2    
    STA RETA_X+1           

    LDA X_ADVERSARIO      
    ADD X_ADVERSARIO+2    
    STA RETA_X+2           

    LDA X_ADVERSARIO+1    
    SUB X_ADVERSARIO+2    
    STA RETA_X+3           

    LDA X_ADVERSARIO+3  
    STA RETA_X+4

    LDA #23
    TRAP RETA_X            
    RET

DESENHAR_PLAYER_OU_ADVERSARIO:
    LDA @PTR_CELULA
    SUB #1
    JZ DESENHAR_PLAYER
    LDA @PTR_CELULA
    SUB #2
    JZ DESENHAR_ADVERSARIO
    RET

DESENHAR_PLAYER:
    LDA #25
    TRAP CIRCULO
    RET


VOLTA_PRIMEIRA_COLUNA_INTERMEDIARIO:
    JZ VOLTA_PRIMEIRA_COLUNA
    RET

VOLTA_PRIMEIRA_COLUNA:
    LDA #22             ;volta o player
    STA CIRCULO
    LDA CIRCULO+1
    ADD #21
    STA CIRCULO+1

    LDA #22             ;volta o adversario
    STA X_ADVERSARIO
    LDA X_ADVERSARIO+1
    ADD #21
    STA X_ADVERSARIO+1

    RET


CONTADOR:
    LDA CONT
    ADD #1
    STA CONT
    RET

REINICIA_CONTADOR:
    LDA #0
    STA CONT
    RET
CONT: DB 0


DISPLAY_CURSOR:
    JSR IR_CELULA
    OR #0
    JNZ CURSOR_VERMELHO
    LDA #252
    STA CURSOR+3
    LDA #25
    TRAP CURSOR
    jSR VOLTAR_CELULA
    RET

CURSOR_VERMELHO:
    LDA #224
    STA CURSOR+3
    LDA #25
    TRAP CURSOR
    JSR VOLTAR_CELULA
    RET


;;---------------Entrada do Usuario---------------;;

ESPERAR_TECLA_MENU:     ;espera o usuario digitar z para começar o jogo
    LDA #1
    TRAP ENTRADA
    LDA ENTRADA
    SUB #122            ; z
    JZ GAME
    JMP ESPERAR_TECLA_MENU

ESCOLHA_INTERMEDIARIA:
    LDA TURNO_DO_JOGADOR
    SUB #1
    JZ ESCOLHA
    RET

ESCOLHA:
    LDA #1
    TRAP ENTRADA

    ;As entradas devem ser minusculas
    LDA ENTRADA
    SUB #97       ;a
    JZ ESQUERDA

    LDA ENTRADA
    SUB #100    ;d
    JZ DIREITA

    LDA ENTRADA
    SUB #119    ;w
    JZ CIMA

    LDA ENTRADA
    SUB #115    ;s
    JZ BAIXO

                    ;Confirmar a seleção do quadrado
    LDA ENTRADA
    SUB #122    ;z
    JZ CONFIRMAR

    LDA ENTRADA     ;termina o jogo
    SUB #120    ;x
    JZ ERRO

    LDA ENTRADA     ;reinicia o jogo
    SUB #114    ;r
    JZ REINICIAR_JOGO

    ;Se não decidir nada volta para decidir
    JMP ESCOLHA


ESQUERDA:
    LDA CURSOR
    SUB #22
    JZ EXTREMA_ESQUERDA
    LDA CURSOR
    SUB #42
    STA CURSOR
    LDA POSICAO
    SUB #1
    STA POSICAO
    RET

EXTREMA_ESQUERDA:
    LDA CURSOR
    ADD #84
    STA CURSOR
    LDA POSICAO
    ADD #2
    STA POSICAO
    RET

DIREITA:
    LDA CURSOR
    SUB #106
    JZ EXTREMA_DIREITA
    LDA CURSOR
    ADD #42
    STA CURSOR
    LDA POSICAO
    ADD #1
    STA POSICAO
    RET

EXTREMA_DIREITA:
    LDA CURSOR
    SUB #84
    STA CURSOR
    LDA POSICAO
    SUB #2
    STA POSICAO
    RET
    
CIMA:
    LDA CURSOR+1
    SUB #11
    JZ EXTREMO_CIMA
    LDA CURSOR+1
    SUB #21
    STA CURSOR+1
    LDA POSICAO
    SUB #3
    STA POSICAO
    RET

EXTREMO_CIMA:
    LDA CURSOR+1
    ADD #42
    STA CURSOR+1
    LDA POSICAO
    ADD #6
    STA POSICAO
    RET

BAIXO:
    LDA CURSOR+1
    SUB #53
    JZ EXTREMO_BAIXO
    LDA CURSOR+1
    ADD #21
    STA CURSOR+1
    LDA POSICAO
    ADD #3
    STA POSICAO
    RET

EXTREMO_BAIXO:
    LDA CURSOR+1
    SUB #42
    STA CURSOR+1
    LDA POSICAO
    SUB #6
    STA POSICAO
    RET

CONFIRMAR:
    JSR IR_CELULA
    OR #0
    JZ PREENCHER
    JSR VOLTAR_CELULA
    RET


IR_CELULA:
    LDA PTR_CELULA
    ADD POSICAO
    STA PTR_CELULA

    LDA PTR_CELULA+1
    ADC #0
    STA PTR_CELULA+1
    
    LDA @PTR_CELULA
    RET

VOLTAR_CELULA:
    LDA PTR_CELULA
    SUB POSICAO
    STA PTR_CELULA

    LDA PTR_CELULA+1
    SBC #0
    STA PTR_CELULA+1

    RET

PREENCHER:
    LDA #1
    STA @PTR_CELULA
    JSR VOLTAR_CELULA
    JSR TURNO_DO_JOGADOR_FALSO
    JSR INCREMENTA_CONT_DOS_QUADRADOS
    RET
    

;;---------------Adversário---------------;;

ADVERSARIO:
    LDA TURNO_DO_JOGADOR    ;checa se não é o turno do jogador
    OR #0
    JNZ PULAR_ADVERSARIO

    LDA #7                  ;intrução para criar número pseudo aleatório
    TRAP CURSOR             ;variavel qualquer para ele não reclamar

    AND #0b00001111         ;remove os algarismos invalidos

    STA NUMERO_ALEATORIO
    LDA NUMERO_ALEATORIO
    SUB #9
    JN  NUMERO_VALIDO
    JMP ADVERSARIO

NUMERO_VALIDO:
    LDA NUMERO_ALEATORIO

    ADD PTR_CELULA
    STA PTR_CELULA
    LDA PTR_CELULA+1
    ADC #0
    STA PTR_CELULA+1

    LDA @PTR_CELULA
    SUB #1
    JZ  TENTAR_NOVAMENTE
    SUB #1
    JZ  TENTAR_NOVAMENTE
    LDA #2
    STA @PTR_CELULA

    LDA PTR_CELULA
    SUB NUMERO_ALEATORIO
    STA PTR_CELULA
    LDA PTR_CELULA+1
    SBC #0
    STA PTR_CELULA+1

    JSR INCREMENTA_CONT_DOS_QUADRADOS

    JSR TURNO_DO_JOGADOR_POSITIVO
    RET

PULAR_ADVERSARIO:
    RET

TENTAR_NOVAMENTE:       ;limpa o ponteiro
    LDA PTR_CELULA
    SUB NUMERO_ALEATORIO
    STA PTR_CELULA
    LDA PTR_CELULA+1
    SBC #0
    STA PTR_CELULA+1
    JMP ADVERSARIO


;;---------------Controle de Turnos---------------;;

TURNO_DO_JOGADOR_FALSO:
    LDA #0
    STA TURNO_DO_JOGADOR
    RET
TURNO_DO_JOGADOR_POSITIVO:
    LDA #1
    STA TURNO_DO_JOGADOR
    RET

INCREMENTA_CONT_DOS_QUADRADOS:
    LDA QUADRADOS_MARCADOS
    ADD #1
    STA QUADRADOS_MARCADOS
    RET


;;---------------Texto---------------;;

ESCREVE_TEXTO:
    LDA  @PTR_TEXTO
    OR   #0
    JZ   RETORNAR
    LDA  #2
    TRAP @PTR_TEXTO
    LDA  PTR_TEXTO
    ADD  #1
    STA  PTR_TEXTO
    LDA  PTR_TEXTO+1
    ADC  #0
    STA  PTR_TEXTO+1
    JMP  ESCREVE_TEXTO

INTRODUCAO:             ;rotulo retirado do tutorial do professor
    INTRODUCAO:
    LDA PTR_STR_INTRODUCAO
    STA PTR_TEXTO
    LDA PTR_STR_INTRODUCAO+1
    STA PTR_TEXTO+1
    JSR ESCREVE_TEXTO
    RET

VITORIA:
    LDA PTR_STR_VITORIA
    STA PTR_TEXTO
    LDA PTR_STR_VITORIA+1
    STA PTR_TEXTO+1
    JSR ESCREVE_TEXTO
    JMP FINALIZAR_JOGO_COM_VENCEDOR

DERROTA:
    LDA PTR_STR_DERROTA
    STA PTR_TEXTO
    LDA PTR_STR_DERROTA+1
    STA PTR_TEXTO+1
    JSR ESCREVE_TEXTO
    JMP FINALIZAR_JOGO_COM_VENCEDOR

EMPATE:
    LDA PTR_STR_EMPATE
    STA PTR_TEXTO
    LDA PTR_STR_EMPATE+1
    STA PTR_TEXTO+1
    JSR ESCREVE_TEXTO
    JMP FINALIZAR_JOGO



;;---------------Fim de Jogo---------------;;

CHECAR_FIM:
    LDA QUADRADOS_MARCADOS
    SUB #5
    JN RETORNAR

                        ;verifica cada possibilidade de fim de jogo
                        ;compara cada quadrado da coluna, se todos forem iguais resultara no valor de vencedor
                        ;1 - Player | 2 - Adversario 


    LDA BKP_PTR_RETA_VITORIA      
    STA PTR_RETA_VITORIA
    LDA BKP_PTR_RETA_VITORIA+1
    STA PTR_RETA_VITORIA+1

    ;linha 1
    LDA CELULA
    AND CELULA+1
    AND CELULA+2
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    ;linha 2
    LDA CELULA+3
    AND CELULA+4
    AND CELULA+5
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    ;linha 3
    LDA CELULA+6
    AND CELULA+7
    AND CELULA+8
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    LDA CELULA
    AND CELULA+3
    AND CELULA+6
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    LDA CELULA+1
    AND CELULA+4
    AND CELULA+7
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA    

    LDA CELULA+2
    AND CELULA+5
    AND CELULA+8
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    LDA CELULA
    AND CELULA+4
    AND CELULA+8
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    LDA CELULA+2
    AND CELULA+4
    AND CELULA+6
    JSR CHECAR_RESULTADO
    JSR AVANCAR_RETA_VITORIA

    LDA QUADRADOS_MARCADOS
    SUB #9
    JN RETORNAR

    JSR EMPATE

CHECAR_RESULTADO:
    SUB #1      ;player venceu
    JZ VITORIA
    SUB #1      ;player perdeu
    JZ DERROTA
    RET

AVANCAR_RETA_VITORIA:
    LDA PTR_RETA_VITORIA
    ADD #5
    STA PTR_RETA_VITORIA
    LDA PTR_RETA_VITORIA+1
    ADC #0 
    STA PTR_RETA_VITORIA+1
    RET


FINALIZAR_JOGO_COM_VENCEDOR:
    LDA #23
    TRAP @PTR_RETA_VITORIA
    JMP FINALIZAR_JOGO

FINALIZAR_JOGO:
    POP 
    POP
    POP
    POP
    JSR REINICIAR_ESTADO
    JMP MENU

REINICIAR_JOGO:
    POP
    POP
    JSR REINICIAR_ESTADO
    JMP GAME

REINICIAR_ESTADO:               ;reinicia todas as variaveis do jogo
    LDA #1
    STA TURNO_DO_JOGADOR
    LDA #0
    STA NUMERO_ALEATORIO
    STA QUADRADOS_MARCADOS
    LDA #64
    STA CURSOR
    LDA #32
    STA CURSOR+1

    JSR REINICIAR_CELULA

    LDA #4
    STA POSICAO

    RET

REINICIAR_CELULA:               ;reinicia o vetor celula
    LDA #0
    STA @PTR_CELULA

    JSR CONTADOR

    LDA PTR_CELULA
    ADD #1
    STA PTR_CELULA
    LDA PTR_CELULA+1
    ADC #0
    STA PTR_CELULA+1

    LDA CONT
    SUB #9
    JNZ REINICIAR_CELULA

    JSR REINICIA_CONTADOR

    LDA PTR_CELULA
    SUB #9
    STA PTR_CELULA
    LDA PTR_CELULA+1
    SBC #0
    STA PTR_CELULA+1

    RET


;;---------------Utils---------------;;

RETORNAR:
    RET

ERRO:
    HLT
    
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;------------------Dados------------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;----Jogadador---;;

TURNO_DO_JOGADOR: DB 1                  ;indica se é o turno do jogador ou não
POSICAO: DB 4                           ;posicão que o jogador se encontra
CURSOR:  DB 64, 32, 6, 252, 0           ;"estrutura" do circulo do cursor
ENTRADA: DB 0


;;----Adversário---;;

NUMERO_ALEATORIO: DB 0                  ;variavel para guardar numeros aleatorios


;;----Tabuleiro----;;

CELULA:             DS 9                ;estado de cada quadrado; 0:vazio; 1:cheio
PTR_CELULA:         DW CELULA           ;ponteiro do estado
QUADRADOS_MARCADOS: DB 0                ;quantidade de quadrados preenchidos


;;---Texto----;;

PTR_STR_INTRODUCAO: DW STR_INTRODUCAO
PTR_STR_VITORIA:    DW STR_VITORIA
PTR_STR_DERROTA:    DW STR_DERROTA
PTR_STR_EMPATE:     DW STR_EMPATE
PTR_TEXTO:          DS 2

STR_INTRODUCAO: STR "Bem vindo ao jogo da velha! As teclas disponiveis são:\na - esquerda\ns - baixo\nd - direita\nw - cima\nz - confirmar\nx - terminar o jogo\nr - reiniciar partida\n\nPressione z para iniciar"
                DB 0
STR_VITORIA:    STR "Parabéns por vencer!\n"
                DB 0
STR_DERROTA:    STR "Você perdeu!\n"
                DB 0
STR_EMPATE:     STR "Tente outra vez.\n"
                DB 0


;;----Gráficos----;;

CIRCULO:        DB 22, 11, 6, 255, 0;circulo que o jogador usa para preencher os quadrados
X_ADVERSARIO:   DB 22, 11, 6, 3, 0  ;circulo inimigo 
RETA_X:         DS 5

VIDEO_BASE EQU 16384 ; 0x4000

VIDEO_CONFIG:
    DW VIDEO_BASE
LIMPAR:
    DB 0              ; PRETO

RETA_1: DB 43, 0, 43, 64, 255
RETA_2: DB 85, 0, 85, 64, 255
RETA_3: DB 0, 22, 128, 22, 255
RETA_4: DB 0, 43, 128, 43, 255

RETA_LINHA_1:   DB 0,   11, 128, 11, 0AAh
RETA_LINHA_2:   DB 0,   32, 128, 32, 0AAh
RETA_LINHA_3:   DB 0,   53, 128, 53, 0AAh
RETA_COLUNA_1:  DB 22,  0,  22,  64, 0AAh
RETA_COLUNA_2:  DB 64,  0,  64,  64, 0AAh
RETA_COLUNA_3:  DB 106, 0,  106, 64, 0AAh

RETA_DIAG_1:    DB 0,   0,  128, 64, 0AAh
RETA_DIAG_2:    DB 0,   64, 128, 0,  0AAh

PTR_RETA_VITORIA:       DW RETA_LINHA_1
BKP_PTR_RETA_VITORIA:   DW RETA_LINHA_1

END MAIN     
