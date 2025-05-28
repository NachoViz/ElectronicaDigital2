
    LIST    P=16F887
     
    #include <P16f887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

    
    CBLOCK 0x20
    CONT      
    PREV_CONT 
    T1    
    AUX     
    ENDC
    
     
    ORG 0x00
    GOTO INICIO
     
    ORG 0x05
INICIO     
    BANKSEL ANSELH
    CLRF ANSELH
    BANKSEL TRISA
    MOVLW 0xF0
    MOVFW TRISB
    BSF TRISA,RB4
    
    BANKSEL PORTB
    CLRF PORTB
L1
    MOVF PORTA,W
    MOVWF AUX
    CALL RETARDO
    
    BTFSC PORTA,RA4
    GOTO L1
    BTFSS AUX,4
    GOTO L1
    CALL CONTAR
    GOTO L1
    
CONTAR
    INCF PORTB,F
    MOVLW 0x0F
    ANDWF PORTB,F
    RETURN
    
RETARDO
    MOVLW .255
    MOVWF T1
B1
    DECFSZ T1,F
    GOTO B1
    RETURN
    
    END

