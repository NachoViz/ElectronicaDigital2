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
    PORTB_ANT 
    FLAG1
    FLAG2
    ESTADO
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
    BANKSEL ANSEL
    CLRF    ANSEL
    BANKSEL TRISB
    MOVLW   .6	   ;0000 0110
    MOVWF   TRISB   
    BCF	    OPTION_REG,INTEDG
    BSF	    INTCON,GIE
    BSF	    INTCON,T0IE
    BSF	    INTCON,RBIE
    BSF	    IOCB,RB1
    BSF	    IOCB,RB2

    BANKSEL PORTB
    MOVF    PORTB,W
    MOVWF   PORTB_TEMP
    CLRF    PORTB
    
    MOVLW   .0
    MOVWF   FLAG1
    
TRABAJAR
    CLRF    ESTADO
    BSF	    ESTADO,0
    CLRF    W_TEMP
    CLRF    STATUS_TEMP
    RETURN

MAIN
    BANKSEL PORTB
    MOVF    PORTB,W
    MOVWF   PORTB_TEMP
    BTFSC   ESTADO,0	    ;RB1=RB2=1
    CALL    ESTADO1
    BTFSC   ESTADO,1	    ;COMPARTE CON ESTADO1 EL RB2 = 1 / PONE EL RB1 = 0
    CALL    ESTADO2
    BTFSC   ESTADO,2	    ;INVIERTE RB2=0/RB1=1
    CALL    ESTADO3
    BTFSC   ESTADO,3	    ;RB1=RB2=0
    CALL    ESTADO4
    GOTO    MAIN
    
    
ISR
    MOVWF   W_TEMP 
    SWAPF   STATUS,W
    MOVWF   STATUS_TEMP
    BTFSC   INTCON, RBIF
    GOTO    ISR
    
    BANKSEL PORTB
    MOVF    PORTB,W
    MOVWF   PORTB_ACTUAL
    
    
    
VUELVO
    BTFSS   FLAG2,0
    GOTO    ESTADO2
VUELVO2
    BTFSC   FLAG
    GOTO    ESTADO3
VUELVO3
    BTFSC   INTCON,RBIF
    GOTO    ESTADO4
    
    
    
ESTADO1
    CLRF    FLAG1
    
    RETURN
    
ESTADO2
    BSF	    FLAG1
    MOVF    PORTB,RB1
    BTFSS   PORTB,RB1
    CALL    DELAY_1MIN
    
    
DELAY_1MIN
	MOVLW	D'150'
	MOVWF	T1
L1	
	MOVLW	D'400'
	MOVWF	T2
L2
	MOVLW	D'400'
	MOVWF	T3
L3
	DECFSZ	T3,F
	GOTO	L3
	DECFSZ	T2,F
	GOTO	L2
	DECFSZ	T1,F
	GOTO	L1
	RETURN