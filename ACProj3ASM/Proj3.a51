;-----------------------------------Constantes e Variaveis-----------------------------------

Verde1        EQU P1.0
Vermelho1     EQU P1.1
Amarelo       EQU P1.2
Verde2        EQU P1.3
Vermelho2     EQU P1.4
segA          EQU P2.0
segB          EQU P2.1
segC          EQU P2.2
segD          EQU P2.3

flag1 BIT 0
flag2 BIT 1

availablePlaces EQU 9
counter         EQU 0

;-----------------------------------Placements-----------------------------------

CSEG AT 0000H
	JMP main

CSEG AT 0003H
	JMP interrupcaoExt0
	
CSEG AT 000BH
	JMP timer0
	
CSEG AT 0013H
	JMP interrupcaoExt1
	
;-----------------------------------Codigo Principal-----------------------------------

CSEG AT 0050H
main:
	MOV SP, #8
    MOV TMOD, #0x02					; Inicializacao do timer e das suas interrupcoes
    MOV TH0, #0x06					; *
    MOV TL0, #0x06					; *
	MOV IP, #00000010b				; *
    SETB ET0						; *
    SETB EA							; *
    SETB EX0						; *
    SETB IT0						; *
    SETB EX1						; *
    SETB IT1						; ***********************************************

	MOV R0, #20
	MOV R1, #200
	MOV R2, #counter
    MOV R3, #availablePlaces

    CLR Verde1						; Verde1 esta ligado
    SETB Vermelho1					; Vermelho1 esta desligado
    SETB Amarelo					; Amarelo esta desligado
    CLR Verde2						; Verde2 esta ligado
    SETB Vermelho2					; Vermelho2 esta desligado
	JMP loopSensor1
	
loopSensor1:
	JB flag1, inicializaTimer0      ; Verifica se a flag1 esta ativada
	JMP loopSensor2

loopSensor2:
	JB flag2, inicializaTimer1		; Verifica se a flag2 esta ativada
	JMP loopSensor1

inicializaTimer0:					; Esta a entrar um carro e tem lugares disponiveis
	SETB TR0
	JMP verificaSegundos
	
inicializaTimer1:
	SETB TR0
	JMP verificaSegundos2
	
verificaSegundos:
	CJNE R2, #5, menorCincoSegundos1 ; Verifica se e menor que 5 segundos
	JMP cincoSegundos1

verificaSegundos2:
	CJNE R2, #5, menorCincoSegundos2 ; Verifica se e menor que 5 segundos
	JMP cincoSegundos2

menorCincoSegundos2:				; Durante 5 segundos
	SETB Verde1						; Liga o Verde1
	CLR Vermelho1					; Desliga o Vermelho1
	CLR Verde2						; Desliga o Verde2
	SETB Vermelho2					; Liga o Vermelho2
	JMP seForZeroSegundo2

menorCincoSegundos1:
	CLR Verde1						; Verde1 esta ligado
	SETB Vermelho1					; Vermelho1 esta desligado
	SETB Verde2						; Verde2 esta desligado
	CLR Vermelho2					; Liga o Vermelho2
	
; Ativacao ou desativacao do amarelo dependendo dos segundos
seForZeroSegundo:
	CJNE R2, #0, seForUmSegundo
	CALL ativarAmarelo
	JMP verificaSegundos
seForUmSegundo:
	CJNE R2, #1, seForDoisSegundos
	CALL desativarAmarelo
	JMP verificaSegundos
seForDoisSegundos:
	CJNE R2, #2, seForTresSegundos
	CALL ativarAmarelo
	JMP verificaSegundos
seForTresSegundos:
	CJNE R2, #3, seForQuatroSegundos
	CALL desativarAmarelo
	JMP verificaSegundos
seForQuatroSegundos:
	CALL ativarAmarelo
	JMP verificaSegundos

; Ativacao ou desativacao do amarelo dependendo dos segundos
seForZeroSegundo2:
	CJNE R2, #0, seForUmSegundo2
	CALL ativarAmarelo
	JMP verificaSegundos2
seForUmSegundo2:
	CJNE R2, #1, seForDoisSegundos2
	CALL desativarAmarelo
	JMP verificaSegundos2
seForDoisSegundos2:
	CJNE R2, #2, seForTresSegundos2
	CALL ativarAmarelo
	JMP verificaSegundos2
seForTresSegundos2:
	CJNE R2, #3, seForQuatroSegundos2
	CALL desativarAmarelo
	JMP verificaSegundos2
seForQuatroSegundos2:
	CALL ativarAmarelo
	JMP verificaSegundos2

cincoSegundos1:
	CALL clear
	DEC R3							; Decrementa o numero de lugares disponiveis
	MOV P2, R3						; Mostrar no Display
	JMP loopSensor1					; Volta ao loop principal

cincoSegundos2:
	CALL clear	
	INC R3							; Incrementa o numero de lugares disponiveis
	MOV P2, R3						; Mostrar no Display
	JMP loopSensor1					; Volta ao loop principal
	
clear:
	CLR Verde1						; Verde1 esta ligado
    SETB Vermelho1					; Vermelho1 esta desligado
    SETB Amarelo					; Amarelo esta desligado
    CLR Verde2						; Verde2 esta ligado
    SETB Vermelho2					; Vermelho2 esta desligado
	MOV R2, #0
	CLR TR0							; Reiniciar o Timer e as flags de input
	CLR flag1						; * 
	CLR flag2						; *
    MOV TH0, #0x06					; *
    MOV TL0, #0x06					; *************************************
	RET
	
desativarAmarelo:
	SETB Amarelo
	RET
	
ativarAmarelo:
	CLR Amarelo
	RET
	
interrupcaoExt0:
    CJNE R3, #0, ativaflag1			; Verifica se o numero de lugares disponiveis e 0 para poder a seguir colocar um carro ou nao
	CLR flag1
    RETI

ativaflag1:
	SETB flag1
	RETI

interrupcaoExt1:
     CJNE R3, #9, ativaflag2		; Verifica se o numero de lugares disponiveis e 9 para poder a seguir retirar um carro ou nao
	 CLR flag2
    RETI

ativaflag2:
	SETB flag2
	RETI

timer0:
	DJNZ R0, final
	MOV R0, #20
	DJNZ R1, final
	CLR TF0
	INC R2							; Incrementa o valor dos segundos apos passar um ciclo de 4000 ( 20 * 200 )
	MOV R1, #200

final:
    RETI

END