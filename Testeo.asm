; Escribir un programa que lea de dos teclas conectadas a RB1 y RB2 y actúe sobre un relé conectado en RB3.
;1. Si están ambas teclas abiertas el relé está abierto.
;2. Si RB2 está abierta y RB1 cerrada se activa el relé por 1 minuto.
;3. Si RB2 está cerrada y RB1 abierta se activa el relé por 2 minutos.
;4. Si están ambas cerradas se activa el relé por 3 minutos.
;Cualquier cambio en las teclas mientras esté activado el relé no debe modificar la salida.
    
    list p=16f887
    #INCLUDE<PIC16f887>
    
; CONFIG1
; __config 0x20F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
    CBLOCK  0x20
    AUX
    T1
    T2
    T3
    ENDC
    
    CBLOCK  0X70
    STATUS_TEMP
    W_TEMP
    ENDC
    
    ORG	    0x00
    GOTO    INICIO
    ORG	    0X04
    GOTO    ISR
    ORG	    0X05
INICIO
    BANKSEL ANSELH
    CLRF    ANSELH
    
    MOVLW   B'11110111'
    BANKSEL TRISB
    MOVWF   TRISB
    BANKSEL PORTB
    CLRF    PORTB
    BANKSEL INTCON
    BSF	    INTCON,RBIF
    BCF	    INTCON,RBIE
    BsF	    INTCON,GIE
    ;OPTION_REG
    BSF	    IOCB,1
    BSF	    IOCB,2
    NOP
    GOTO    $-1
    
ISR
    MOVWF   W_TEMP 
    SWAPF   STATUS,W
    MOVWF   STATUS_TEMP
    
    BANKSEL PORB
    MOVF    PORTB,W
    MOVWF   AUX 
    ANDWF   0x06
    MOVWF   AUX
    MOVLW   0x06
    XORWF   AUX
    
    BCF	    PORTB,RB3
    
    BTFSC   STATUS,Z
    CALL    RESTAURAR
    RETFIE
    
RESTAURAR
    CALL    DELAY_1SEG
    BANKSEL TRISB
    SWAPF   STATUS_TEMP,W
    MOVWF   STATUS
    MOVF    W_TEMP,W
    BCF	    INTCON,RBIF
    RETURN
    
    
DELAY_1SEG
    	MOVLW	D'20'
	MOVWF	T1
L1	
	MOVLW	D'100'
	MOVWF	T2
L2
	MOVLW	D'200'
	MOVWF	T3
L3
	DECFSZ	T3,F
	GOTO	L3
	DECFSZ	T2,F
	GOTO	L2
	DECFSZ	T1,F
	GOTO	L1
	RETURN
    END