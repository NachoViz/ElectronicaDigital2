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
    CLRF    ANSELH
    BANKSEL TRISB
    MOVLW   0XF0
    MOVWF   TRISB
    MOVLW   B'10000110'
    MOVWF   OPTION_REG
    
    BSF	    INTCON,GIE
    BSF	    INTCON,T0IE
    BSF	    INTCON,RBIE
    
    MOVLW   .0
    MOVWF   CONT
 
ISR
    BTFSS   INTCON,RBIF
    GOTO    ISR_TMR0
    
    BCF	    INTCON,RBIE
VUELVO
    MOVLW   .0
    MOVWF   TMR0
    INCF    CONT,F
    MOVLW   .3
    XORWF   CONT
    BTFSS   STATUS,Z
    GOTO    VUELVO
    BSF	    INTCON,T0IE
    BCF	    INTCON,RBIF
    RETFIE
ISR_TMR0
    BTFSS   INTCON,T0IF
    GOTO    END_ISR
    BCF	    INTCON,T0IF
    BCF	    INTCON,T0IE
    BSF	    INTCON,RBIE
END_ISR	
    RETFIE
    
    END

    
    