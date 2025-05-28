
     LIST    P=16F887
     #include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
     
    CBLOCK  0x20        ; Ejemplo de ubicación en la memoria de propósito general
    CONTADOR1
    CONTADOR2
    CONTADOR3
    CONT
    NUEVE
    ENDC
    
     
    ORG 0x00
    GOTO INICIO
    
    ORG 0x05
INICIO
    BANKSEL TRISD
    BSF TRISB,0
    CLRF TRISD
    BANKSEL ANSELH
    CLRF ANSELH
    CLRF ANSEL
    
    BANKSEL PORTD
    CLRF CONT
    MOVLW .10
    MOVWF NUEVE
    
    
BUCLE
    BTFSS PORTB, 0
    GOTO FREEZE
    CALL CONTAR
    CALL ACTIVARPORT
    CALL UNSEG
   
    GOTO BUCLE
    
CONTAR
    INCF CONT, F
    MOVF CONT, W
    SUBWF NUEVE, W
    BTFSC STATUS, Z
    CLRF CONT
    RETURN
    
ACTIVARPORT
    MOVF CONT, W
    CALL TABLA
    MOVWF PORTD
    
FREEZE
    CALL UNSEG
    CALL UNSEG
    CALL UNSEG
    CLRF CONT
    
    GOTO BUCLE
    
TABLA
	  ADDWF PCL, F
	  RETLW 0x3F           ;0
	  RETLW 0x06           ;1
	  RETLW 0x5B           ;2
	  RETLW 0x4F           ;3
	  RETLW 0x66           ;4
	  RETLW 0x6D           ;5
	  RETLW 0x7D           ;6
	  RETLW 0x07           ;7
	  RETLW 0x7F           ;8
	  RETLW 0x67           ;9
	  
UNSEG
    MOVLW   D'200'      ; Cargar el valor 200 al registro de trabajo W
    MOVWF   CONTADOR1   ; Mover el valor de W al contador externo 1

BUCLE_EXTERNO
    MOVLW   D'250'      ; Cargar el valor 250 al registro de trabajo W
    MOVWF   CONTADOR2   ; Mover el valor de W al contador externo 2

BUCLE_MEDIO
    MOVLW   D'250'      ; Cargar el valor 250 al registro de trabajo W
    MOVWF   CONTADOR3   ; Mover el valor de W al contador externo 3

BUCLE_INTERNO
    NOP                 ; No Operation (1 ciclo de instrucción)
    NOP                 ; No Operation (1 ciclo de instrucción)
    DECFSZ  CONTADOR3, F; Decrementar CONTADOR3, saltar siguiente si es cero
    GOTO    BUCLE_INTERNO ; Si no es cero, volver al bucle interno
    
    DECFSZ  CONTADOR2, F; Decrementar CONTADOR2, saltar siguiente si es cero
    GOTO    BUCLE_MEDIO   ; Si no es cero, volver al bucle medio
    
    DECFSZ  CONTADOR1, F; Decrementar CONTADOR1, saltar siguiente si es cero
    GOTO    BUCLE_EXTERNO ; Si no es cero, volver al bucle externo
    
    RETURN              ; Fin de la función de retardo
    

    END

