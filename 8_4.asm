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
    ENDC
    
    ORG	    0X00
    GOTO    INICIO
    ORG	    0X04
    GOTO    ISR
    ORG	    0X05
    
INICIO
    BANKSEL ANSEL
    CLRF    ANSEL
    BANKSEL TRISA
    BSF	    TRISA,4
    BCF	    TRISB,0
    BANKSEL PORTB
    CLRF    PORTB
    BANKSEL OPTION_REG
    BSF	    OPTION_REG,T0CS
    BCF	    OPTION_REG,T0SE
    BSF	    OPTION_REG,PSA
    BSF	    INTCON,GIE
    BSF	    INTCON,T0IE
    
    
    MOVLW   .254
    MOVWF   TMR0
    
    NOP
    NOP
    NOP
    NOP
    SLEEP
    
ISR
    BTFSS   INTCON,T0IF
    GOTO    FIN
    BCF	    INTCON,T0IF
    MOVLW   .250
    MOVWF   TMR0
    
    BSF	    PORTB,0
    CALL    RETARDO
    BCF	    PORTB,0 
    CALL    RETARDO
FIN   
    RETFIE
    
	
RETARDO
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