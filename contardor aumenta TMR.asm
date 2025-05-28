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
    CONT1
    T1
    T2
    T3
    FLAG
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
    BSF	    STATUS,RP1
    CLRF    ANSEL
    MOVLW   B'11010001'
    MOVWF   OPTION_REG   ;ACA HABILITO EL INTERDG-T0SE-PSA,TMR0
   
    BCF	    STATUS,RP1
    CLRF    TRISA
    BCF	    STATUS,RP0
    
    MOVLW   0x64	;'0110 0100' = 100
    MOVWF   TMR0	;T[s]= ((256-TMR0)*PSA+2) * Tinstr
			;tiempo de latencia del tmr0 + 3 
    
    BCF	    INTCON,T0IF
    BSF	    INTCON,T0IE
    BSF	    INTCON,GIE
    
    MOVLW   D'5'
    MOVWF   CONT1
    CLRF    PORTA
    GOTO    $
    
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
    MOVLW   0x64 ; REFRESCO EL CONTADOR APENAS ENTRA LA INTERRUPCION
    MOVWF   TMR0
    DECFSZ  CONT1,F
    GOTO    L1
    MOVLW   D'5'	;T_TMR0*5
    MOVWF   CONT1
    INCF    FLAG,F
    BTFSS   FLAG,0
    BCF	    PORTA,0
    BTFSC   FLAG,0
    BCF	    PORTA,0
L1    
    BCF	    INTCON,T0IF

FINITY
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
    
    END
    