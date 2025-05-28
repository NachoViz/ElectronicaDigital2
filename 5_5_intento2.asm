; ELECTRÓNICA DIGITAL II
    
; --------  Ejercicio 5.5  ---------
    
; Autor:
    ; Ignacio Vizgarra
    
; Profesor:
    ; Martin Del Barco
     
; Fecha: 20/05/2025
    
LIST    P=16F887
#include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    CBLOCK 0X20
    CONT
    T1
    T2
    T3
    ENDC
    
    CBLOCK  0X70
    W_TEMP
    ENDC
    
    ORG 0X00
    GOTO MAIN
    ORG 0X04
    GOTO ISR
    ORG 0X05
MAIN
    BANKSEL	ANSEL
    CLRF	ANSEL
    BANKSEL	TRISB
    CLRF	TRISD
    MOVLW	0X11
    MOVWF	TRISB
    
    BSF		INTCON,INTE
    BSF		INTCON,GIE
    BCF		OPTION_REG,INTEDG
    
    BANKSEL	PORTD
    CLRF	PORTD
    
INICIO
    BTFSC	PORTB,RB4
    GOTO	INICIO
    CALL	DELAY_1SEG
    CALL	DELAY_1SEG
    BANKSEL	PORTD
    MOVLW	0XFF
    MOVWF	PORTD
    CALL	DELAY_1SEG
    CALL	DELAY_1SEG
DELAY_1SEG
    MOVLW	.20
    MOVWF	T1
X1    
    MOVLW	.100
    MOVWF	T2
X2   
    MOVLW   	.200
    MOVWF	T3
X3  
    DECFSZ	T3,F
    GOTO	X3
    DECFSZ	T2,F
    GOTO	X2
    DECFSZ	T1,F
    GOTO	X1
    RETURN
ISR
    BTFSS	INTCON,INTF
    GOTO	END_ISR
    
    BANKSEL	TRISA
    BCF		INTCON,GIE
    BCF		INTCON,RBIE
    BANKSEL	PORTD
    CLRF	PORTD
    CALL	DELAY_1SEG
    CALL	DELAY_1SEG
    CALL	DELAY_1SEG
    BCF		INTCON,INTF
   
END_ISR
    RETFIE
    
    
    END

    