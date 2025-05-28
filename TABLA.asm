
    LIST    P=16F887
     
    #include <P16f887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    #DEFINE LED PORTB,RB0
    #DEFINE PULSADOR PORTC,RC0
    
    CBLOCK 0X20
    T1
    T2
    T3
    AUX
    CONTADOR
    ENDC
    
    ORG 0X00
    GOTO INICIO
    
    ORG 0X05
INICIO
    BANKSEL ANSELH
    CLRF    ANSELH
    BANKSEL TRISB
    CLRF    TRISB
    BANKSEL PORTB
    CLRF    PORTB
    
FIN
    MOVLW	.0
    MOVWF	CONTADOR
					     ;MODIFICAR PARA DESPUES DEL 5
    MOVLW	.5
    MOVWF	AUX
X1
    MOVF	CONTADOR,W
    
    CALL    	DATOS
    MOVWF   	PORTB
    INCF	CONTADOR 
    CALL    	RETARDO
					     ;DESPUES DE LA CUENTA PONER PCL Y CONTADOR = 0
    DECFSZ	AUX,F
    GOTO	X1
    
    
    GOTO    FIN
    
DATOS
    ADDWF	PCL,F
    RETLW 	.1
    RETLW 	.2
    RETLW 	.3
    RETLW 	.4
    RETLW 	.5
    
    
RETARDO
    MOVLW   D'5'
    MOVWF   T1
L1
    MOVLW   D'100'
    MOVWF   T2
L2
    MOVLW   D'200'
    MOVWF   T3
L3
    NOP
    DECFSZ  T3, F
    GOTO    L3
    DECFSZ  T2, F
    GOTO    L2
    DECFSZ  T1, F
    GOTO    L1
    RETURN
 
    END