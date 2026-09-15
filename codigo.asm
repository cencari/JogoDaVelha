ORG 0
;Um dia eu matarei o GPS
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

ESPERAR_TECLA_MENU:     ;espera o usuario digitar z para começar o jogo
    LDA #1
    TRAP ENTRADA
    LDA ENTRADA
    SUB #122            ; z
    JZ GAME
    JMP ESPERAR_TECLA_MENU

GAME:
    LDA #0                          ;Limpa o terminal
    TRAP CURSOR
    JSR LIMPAR_DISPLAY              ;Limpa o display para desenhar os novos objetos
    JSR DESENHAR_TABULEIRO          ;desenha os circulos do usuário
    JSR DISPLAY_CURSOR              ;desenhar o cursor como um circulo, se o quadrado já foi preenchido, pinta o simbolo do quadrado de vermelho
    JSR ESCOLHA_INTERMEDIARIA       ;rotina das escolhas do usuario dentro do jogo
    JSR CHECAR_FIM                  ;checa se o alguem preencheu alguma fileira
    JSR ADVERSARIO                  ;rotina do adversario
    JMP GAME                        ;faz um loop
    RET

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
    ADD CIRCULO_ADVERSARIO
    STA CIRCULO_ADVERSARIO

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
    STA CIRCULO_ADVERSARIO
    LDA #11
    STA CIRCULO_ADVERSARIO+1

    LDA PTR_CELULA
    SUB #9
    STA PTR_CELULA
    LDA PTR_CELULA+1
    SBC #0
    STA PTR_CELULA+1
    RET

DESENHAR_ADVERSARIO:
    LDA #25
    TRAP CIRCULO_ADVERSARIO             
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
    STA CIRCULO_ADVERSARIO
    LDA CIRCULO_ADVERSARIO+1
    ADD #21
    STA CIRCULO_ADVERSARIO+1

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

ESCOLHA_INTERMEDIARIA:
    LDA TURNO_DO_JOGADOR
    SUB #1
    JZ ESCOLHA
    RET

ESCOLHA:
    LDA #1
    TRAP ENTRADA

    ;As entradas devem ser minusculas por enquanto
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

;-------ESCOLHA DA DIRECAO---------
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

EXTREMA_ESQUERDA: ;lol
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

EXTREMA_DIREITA: ;lol
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
    
INTRODUCAO:             ;rotulo roubado do tutorial do professor XD
    LDA  @PTR_STR_INTRODUCAO
    OR   #0
    JZ   RETORNAR
    LDA  #2
    TRAP @PTR_STR_INTRODUCAO
    LDA  PTR_STR_INTRODUCAO
    ADD  #1
    STA  PTR_STR_INTRODUCAO
    LDA  PTR_STR_INTRODUCAO+1
    ADC  #0
    STA  PTR_STR_INTRODUCAO+1
    JMP  INTRODUCAO

ADVERSARIO:

    LDA TURNO_DO_JOGADOR    ;checa se não é o turno do jogador
    OR #0
    JNZ PULAR_ADVERSARIO

    LDA #7                  ;intrução para criar número pseudo aleatório
    TRAP CURSOR             ;variavel qualquer para ele não reclamar

    AND #0b00001111          ;remove os algarismos invalidos

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

------JOGO TERMINOU------
CHECAR_FIM:
    LDA QUADRADOS_MARCADOS
    SUB #5
    JN RETORNAR

                        ;verifica cada possibilidade de fim de jogo
                        ;compara cada quadrado da coluna, se todos forem iguais resultara no valor de vencedor
                        ;1 - Player | 2 - Adversario
    LDA CELULA
    AND CELULA+1
    AND CELULA+2
    JSR CHECAR_RESULTADO

    LDA CELULA+3
    AND CELULA+4
    AND CELULA+5
    JSR CHECAR_RESULTADO

    LDA CELULA+6
    AND CELULA+7
    AND CELULA+8
    JSR CHECAR_RESULTADO

    LDA CELULA
    AND CELULA+3
    AND CELULA+6
    JSR CHECAR_RESULTADO

    LDA CELULA+1
    AND CELULA+4
    AND CELULA+7
    JSR CHECAR_RESULTADO    

    LDA CELULA+2
    AND CELULA+5
    AND CELULA+8
    JSR CHECAR_RESULTADO

    LDA CELULA
    AND CELULA+4
    AND CELULA+8
    JSR CHECAR_RESULTADO

    LDA CELULA+2
    AND CELULA+4
    AND CELULA+6
    JSR CHECAR_RESULTADO

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

VITORIA:
    LDA  @PTR_STR_VITORIA
    OR   #0
    JZ   TRANSICAO
    LDA  #2
    TRAP @PTR_STR_VITORIA
    LDA  PTR_STR_VITORIA
    ADD  #1
    STA  PTR_STR_VITORIA
    LDA  PTR_STR_VITORIA+1
    ADC  #0
    STA  PTR_STR_VITORIA+1
    JMP  VITORIA

STR_VITORIA: STR "Parabéns por vencer!"
    DB 0
PTR_STR_VITORIA: DW STR_VITORIA

DERROTA:
    LDA  @PTR_STR_DERROTA
    OR   #0
    JZ   TRANSICAO
    LDA  #2
    TRAP @PTR_STR_DERROTA
    LDA  PTR_STR_DERROTA
    ADD  #1
    STA  PTR_STR_DERROTA
    LDA  PTR_STR_DERROTA+1
    ADC  #0
    STA  PTR_STR_DERROTA+1
    JMP  DERROTA

STR_DERROTA: STR "Como que tu perdeu mano? Tu é burro?"
    DB 0
PTR_STR_DERROTA: DW STR_DERROTA

EMPATE:
    LDA  @PTR_STR_EMPATE
    OR   #0
    JZ   TRANSICAO
    LDA  #2
    TRAP @PTR_STR_EMPATE
    LDA  PTR_STR_EMPATE
    ADD  #1
    STA  PTR_STR_EMPATE
    LDA  PTR_STR_EMPATE+1
    ADC  #0
    STA  PTR_STR_EMPATE+1
    JMP  EMPATE

STR_EMPATE: STR "Tente outra vez."
    DB 0
PTR_STR_EMPATE: DW STR_EMPATE

TRANSICAO:
    POP 
    POP
    POP
    POP
    JSR REINICIAR_ESTADO
    JMP MENU

RETORNAR:
    RET

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

    LDA BKP_PTR_VITORIA         ;reseta o texto de vitória
    STA PTR_STR_VITORIA
    LDA BKP_PTR_VITORIA+1
    STA PTR_STR_VITORIA+1

    LDA BKP_PTR_DERROTA         ;reseta o texto de derrota
    STA PTR_STR_DERROTA
    LDA BKP_PTR_DERROTA+1
    STA PTR_STR_DERROTA+1

    LDA BKP_PTR_EMPATE          ;reseta o texto de empate
    STA PTR_STR_EMPATE
    LDA BKP_PTR_EMPATE+1
    STA PTR_STR_EMPATE+1

    LDA BKP_PTR_INTRODUCAO      ;reseta o texto de introducao
    STA PTR_STR_INTRODUCAO
    LDA BKP_PTR_INTRODUCAO+1
    STA PTR_STR_INTRODUCAO+1
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

    

BKP_PTR_VITORIA: DW STR_VITORIA             ;guarda inicio do vetor
BKP_PTR_DERROTA: DW STR_DERROTA             
BKP_PTR_EMPATE:  DW STR_EMPATE
BKP_PTR_INTRODUCAO:   DW STR_INTRODUCAO

TURNO_DO_JOGADOR: DB 1                  ;indica se é o turno do jogador ou não
NUMERO_ALEATORIO: DB 0                  ;variavel para guardar numeros aleatorios
POSICAO: DB 4                           ;posicão que o jogador se encontra
CELULA: DB 0, 0, 0, 0, 0, 0, 0, 0, 0    ;estado de cada quadrado; 0:vazio; 1:cheio
PTR_CELULA: DW CELULA                   ;ponteiro do estado
QUADRADOS_MARCADOS: DB 0                ;quantidade de quadrados preenchidos
CURSOR: DB 64, 32, 6, 252, 0            ;"estrutura" do circulo do cursor
CIRCULO: DB 22, 11, 6, 255, 0           ;circulo que o jogador usa para preencher os quadrados
CIRCULO_ADVERSARIO: DB 22, 11, 6, 3, 0  ;circulo inimigo /trocar por X
ENTRADA: DB 0

STR_INTRODUCAO: STR "Bem vindo ao jogo da velha! As teclas disponiveis são essas:\na - esquerda\ns - baixo\nd - direita\nw - cima\nz - confirmar\nx - terminar o jogo\nr - reiniciar partida\n"
    DB 0
PTR_STR_INTRODUCAO: DW STR_INTRODUCAO

ERRO:
    HLT

VIDEO_BASE EQU 16384 ; 0x4000

VIDEO_CONFIG:
    DW VIDEO_BASE
LIMPAR:
    DB 0              ; PRETO

RETA_1: 
    DB 43, 0, 43, 64, 255
RETA_2: 
    DB 85, 0, 85, 64, 255
RETA_3: 
    DB 0, 22, 128, 22, 255
RETA_4: 
    DB 0, 43, 128, 43, 255
END MAIN     