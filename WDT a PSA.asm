; ELECTRÓNICA DIGITAL II
    
; --------  Clase8_ayarde  ---------
;---------PROGRAMA CAMBIA LA ASOCIACION DEL PRESCALER DEL WDT a  TMR0     
    
; Autor:
    ; Ignacio Vizgarra
    
; Profesor:
    ; Martin Del Barco
     
; Fecha: 20/05/2025
    
LIST    P=16F887
#include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_ON & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    CBLOCK 0X20
    CONT
    T1
    T2
    T3
    ENDC
    
    CBLOCK  0X70
    W_TEMP
    STATUS_TEMP
    ENDC
    
    ORG 0X00
    GOTO INICIO
    ORG 0X04
    GOTO ISR
    ORG 0X05
    
INICIO
    BSF	    STATUS,RP0
    CLRWDT  
    
    MOVLW   B'11010000'
    ANDWF   OPTION_REG,W    ;ACA HABILITO EL RBPU-INTERDG-T0SE-PSA,TMR0
    IORLW   B'00000001'	    ;PSA EN :4
    MOVWF   OPTION_REG
    BCF	    STATUS,RP0
    MOVLW   .240
    MOVWF   TMR0	;T[s]= ((256-TMR0)*PSA+2) * Tinstr
    
    BCF	    INTCON,T0IF
    BSF	    INTCON,T0IE
    BSF	    INTCON,GIE
L1
    NOP
    NOP
    NOP
    NOP
    CLRWDT
    NOP
    GOTO L1
    
ISR
    ;--------------------------
    ;Guardo Contexto
    MOVWF   W_TEMP
    SWAPF   STATUS,W
    MOVWF   STATUS_TEMP
    ;---------------------------
    ;Identifico interrupcion
    BTFSC   INTCON,T0IF
    GOTO    ISR_TMR0
    GOTO    FINITY
    
ISR_TMR0
    MOVLW   .240 ; REFRESCO EL CONTADOR APENAS ENTRA LA INTERRUPCION
    MOVWF   TMR0
    BCF	    INTCON,T0IF
    NOP
    NOP
    NOP
    NOP
    NOP
FINITY
    SWAPF   STATUS_TEMP,W
    MOVWF   STATUS
    