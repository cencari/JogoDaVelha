ORG 0
;Um dia eu matarei o GPS
MAIN:
    LDA #20             ;carrega a instrução de ativar display
    TRAP VIDEO_CONFIG   ;ativa o display
    OR #0               ;checa se houve erro
    JNZ ERRO            ;se sim para a aplicação
    JSR OUTPUT_TEXTO
    JSR GAME            ;se não vai para o jogo
    HLT                 ;para o jogo

GAME:
    JSR LIMPAR_DISPLAY  ;Limpa o display para desenhar os novos objetos
    JSR DESENHAR_LINHAS ;desenha as linhas do tabuleiro
    JSR ROTINA_CIRCULO  ;desenha os circulos do usuário
    JSR DISPLAY_CURSOR  ;
    JMP ESCOLHA
    JMP GAME
    RET

LIMPAR_DISPLAY:
    ;limpa o display para atualizar as imagens
    LDA #21
    TRAP LIMPAR

DESENHAR_LINHAS:
    ;faz as linhas da tabela
    LDA #23
    TRAP RETA_1
    LDA #23
    TRAP RETA_2
    LDA #23
    TRAP RETA_3
    LDA #23
    TRAP RETA_4
    LDA #5
    RET



ROTINA_CIRCULO:
    LDA @PTR_ESTADO
    SUB #1
    JSR CIRCULO_INTERMEDIARIO
    JSR CONTADOR

    LDA PTR_ESTADO
    ADD #1
    STA PTR_ESTADO

    LDA #42
    ADD CIRCULO
    STA CIRCULO

    LDA CONT
    SUB #3
    JSR VOLTAR_CIRCULO_INTERMEDIARIO
    LDA CONT
    SUB #6
    JSR VOLTAR_CIRCULO_INTERMEDIARIO

    LDA CONT
    SUB #9
    JNZ ROTINA_CIRCULO
    JSR REINICIA_CONTADOR
    LDA #22
    STA CIRCULO
    LDA #11
    STA CIRCULO+1
    LDA PTR_ESTADO
    SUB #9
    STA PTR_ESTADO
    RET

VOLTAR_CIRCULO_INTERMEDIARIO:
    JZ VOLTAR_CIRCULO
    RET

VOLTAR_CIRCULO:
    LDA #22
    STA CIRCULO
    LDA CIRCULO+1
    ADD #21
    STA CIRCULO+1
    RET
    

CIRCULO_INTERMEDIARIO:
    JZ DESENHAR_CIRCULO
    RET

DESENHAR_CIRCULO:
    LDA #25
    TRAP CIRCULO
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
    JSR IR_ESTADO
    SUB #1
    JZ CURSOR_VERMELHO
    LDA #252
    STA CURSOR+3
    LDA #25
    TRAP CURSOR
    jSR VOLTAR_ESTADO
    RET

CURSOR_VERMELHO:
    LDA #224
    STA CURSOR+3
    LDA #25
    TRAP CURSOR
    JSR VOLTAR_ESTADO
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
    JMP GAME

EXTREMA_ESQUERDA: ;lol
    LDA CURSOR
    ADD #84
    STA CURSOR
    LDA POSICAO
    ADD #2
    STA POSICAO
    JMP GAME

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
    JMP GAME

EXTREMA_DIREITA: ;lol
    LDA CURSOR
    SUB #84
    STA CURSOR
    LDA POSICAO
    SUB #2
    STA POSICAO
    JMP GAME
    
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
    JMP GAME

EXTREMO_CIMA:
    LDA CURSOR+1
    ADD #42
    STA CURSOR+1
    LDA POSICAO
    ADD #6
    STA POSICAO
    JMP GAME

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
    JMP GAME

EXTREMO_BAIXO:
    LDA CURSOR+1
    SUB #42
    STA CURSOR+1
    LDA POSICAO
    SUB #6
    STA POSICAO
    JMP GAME

CONFIRMAR:
    JSR IR_ESTADO
    SUB #1
    JNZ PREENCHER
    JSR VOLTAR_ESTADO
    JMP GAME

IR_ESTADO:
    LDA PTR_ESTADO
    ADD POSICAO
    STA PTR_ESTADO

    LDA PTR_ESTADO+1
    ADC #0
    STA PTR_ESTADO+1
    
    LDA @PTR_ESTADO
    RET

VOLTAR_ESTADO:
    LDA PTR_ESTADO
    SUB POSICAO
    STA PTR_ESTADO

    LDA PTR_ESTADO+1
    ADC #0
    STA PTR_ESTADO+1

    RET

PREENCHER:
    LDA #1
    STA @PTR_ESTADO
    JSR VOLTAR_ESTADO
    JMP GAME
    
OUTPUT_TEXTO:
    LDA  @PTR_TEXTO
    OR   #0
    JZ   OUTPUT_TEXTO_FIM
    OUT  2
    LDA  #2
    TRAP @PTR_TEXTO
    LDA  PTR_TEXTO
    ADD  #1
    STA  PTR_TEXTO
    LDA  PTR_TEXTO+1
    ADC  #0
    STA  PTR_TEXTO+1
    JMP  OUTPUT_TEXTO

OUTPUT_TEXTO_FIM:
    RET

POSICAO: DB 4
ESTADO: DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ;estado de cada quadrado; 0:vazio; 1:cheio
PTR_ESTADO: DW ESTADO
CURSOR: DB 64, 32, 6, 252, 0
CIRCULO: DB 22, 11, 6, 255, 0
ENTRADA: DB 0

TEXTO: STR "Bem vindo ao jogo da velha. As teclas disponiveis são essas:\na - esquerda\ns - baixo\nd - direita\nw - cima\nz - confirmar\nx - sair do jogo"
    DB 0
PTR_TEXTO: DW TEXTO 

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
           
            
           
            