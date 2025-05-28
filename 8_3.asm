; ELECTRÓNICA DIGITAL II
    
; --------  Ejercicio 5.4  ---------
    
; Autor:
    ; Ignacio Vizgarra
    
; Profesor:
    ; Martin Del Barco
     
; Fecha: 19/05/2025

LIST    P=16F887
#include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    CBLOCK  0x20
    T1
    T2
    T3
    CONT
    PORTB_ANTERIOR
    ENDC
    
    ORG	    0X00
    GOTO    INICIO
    ORG	    0X04
    GOTO    ISR
    ORG	    0X05
INICIO
    BANKSEL ANSELH
    CLRF    ANSEL
    BANKSEL TRISB
    BCF   TRISB,RB0
    BSF  TRISC,RC0
    BSF  PIE1,TMR1IE
    
    BANKSEL T1CON
    BSF  T1CON,TMR1CS
    BCF  T1CON,T1SYNC
    BCF  T1CON,TMR1ON
    BCF  T1CON,T1CKPS1
    BCF  T1CON,T1CKPS0
    
    BSF	    INTCON,GIE
    BSF	    INTCON,PEIE
    
    
    MOVLW   .63487
    MOVWF   TMR1
    
 
ISR
    BTFSS   PIR1,TMR1IF
    GOTO    ISR
LOOP
    CALL DELAY_1S
    BANKSEL PORTB
    BSF	PORTB,RB0
    CALL DELAY_1S
    BCF	PORTB,RB0
    GOTO LOOP
    
	
DELAY_1S
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