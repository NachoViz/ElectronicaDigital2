; ELECTRÓNICA DIGITAL II
    
; --------  Ejercicio 5.5  ---------
    
; Autor:
    ; Julieta Pérez Echeverría
    
; Profesor:
    ; Martin Del Barco
     
; Fecha: 14/05/2025

     LIST    P=16F887
     #include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

         CBLOCK 0x20
	 W_TEMP
	 STATUS_TEMP
	 AUX
	 ESTADO
	 FLAG
	 CONTADOR_3_SEG
	 CONTADOR250
	 CONT1
	 CONT2
	 CONT3
	 ENDC
	 
         ORG 0x00
         GOTO INICIO
     
         ORG 0x04
         GOTO SRI
     
         ORG 0x05
INICIO
	 CALL INICIALIZACION
	 
LOOP	 
	 BTFSC ESTADO, 0
	 CALL REPOSO
	 BTFSC ESTADO, 1
	 CALL PARPADEO
	 BTFSC ESTADO, 2
	 CALL ESPERA
	 GOTO LOOP
	 
INICIALIZACION
	 ; CONFIGURACIÓN DE LOS PUERTOS
	 BANKSEL ANSELH
	 CLRF ANSELH
	 BANKSEL TRISD
	 CLRF TRISD
	 BSF TRISB, 0
	 BSF TRISA, 4
	 
	 ; CONFIGURACIÓN DE LAS INTERRUPCIONES
	 BANKSEL OPTION_REG
	 ; RB0
	 BCF OPTION_REG, 7
	 BSF WPUB, 0
	 BCF OPTION_REG, INTEDG
	 BSF INTCON, INTE
	 ; TMR0
	  BSF INTCON, T0IE
	  BCF OPTION_REG, T0CS
	  BCF OPTION_REG, PSA
	  BSF OPTION_REG, PS2
	  BCF OPTION_REG, PS1
	  BCF OPTION_REG, PS0
	  BANKSEL PORTD
	  MOVLW D'6'               ; Valor inicial TMR0=6
	  MOVWF TMR0
	 
	 ; HABILITO INTERRUPCIONES
	 BSF INTCON, GIE
	 
	 ; INICIO LAS VARIABLES CON LAS QUE VOY A TRABAJAR
	 CLRF ESTADO
	 BSF ESTADO, 0                                ; Inicio en el estado 01 (REPOSO)
	 CLRF W_TEMP
	 CLRF STATUS_TEMP
	 CLRF FLAG
	 MOVLW D'100'
	 MOVWF CONTADOR_3_SEG
	 MOVLW D'250'
	 MOVWF CONTADOR250
	 CLRF PORTD
	 
	 RETURN
	 
REPOSO
	 ; DETECTAR FLANCO DE BAJADA EN RA4 POR POLLING
        MOVF PORTA, W
	MOVWF AUX                ; Guardo RB0 (t-1) en la variable AUX
	CALL RETARDO             ; Espero. La lectura del pulsador se realiza cada 1 segundo. El tiempo entre el estadoa actual y el anterior es de 1 segundo
	BTFSC PORTA, RA4         ; Si RB0(t)=1 el flanco NO es de bajada ==> vuelvo al bucle
	RETURN
	BTFSS AUX, 4             ; Si RB0(t)= 0 y AUX=RB0(t-1)=0 el flanco NO es de bajada ==> vuelvo al bucle
	RETURN
	BCF ESTADO, 0
	BCF ESTADO, 2
	BSF ESTADO, 1 
	RETURN
	
PARPADEO
	; PARPADEO CADA 1 SEGUNDO EN EL PUERTO D HASTA QUE CAMBIO DE ESTADO A ESPERA 
         BTFSS FLAG, 1
         RETURN              ; Esperar a que TMR0 marque el retardo
         BCF FLAG, 1         ; Limpiar el flag
         COMF PORTD, F       ; Invertir LEDs
         BTFSS FLAG, 2       ; ¿Se pidió interrupción?
         RETURN
         BCF FLAG, 2
         BCF ESTADO, 0
         BCF ESTADO, 1
         BSF ESTADO, 2 
         RETURN

	 
ESPERA
    BTFSS FLAG, 1         ; ¿Pasó 1 segundo?
    RETURN                ; No ? salir

    BCF FLAG, 1           ; Sí ? limpiar flag
    DECFSZ CONTADOR_3_SEG
    RETURN                ; Aún no pasaron 3 segundos

    ; Si llegó a 0
    MOVLW D'100'
    MOVWF CONTADOR_3_SEG
    BCF ESTADO, 2
    BCF ESTADO, 0
    BSF ESTADO, 1         ; Volver a parpadeo
    RETURN
	 
	
	
SRI
	 ; GUARDO CONTEXTO
	 MOVWF W_TEMP
	 SWAPF STATUS, W
	 MOVWF STATUS_TEMP
	 
	 ;TESTEO DE DÓNDE VINO LA INTERRPCIÓN Y DERIVO
	 BTFSC INTCON, INTF
	 CALL SUBRRUTINA_RB0
	 BTFSC INTCON, T0IF
	 CALL SUBRRUTINA_TMR0
	 
	 ; RECUPERO CONTEXTO
	 SWAPF STATUS_TEMP, W
	 MOVWF STATUS
	 SWAPF W_TEMP, F
	 SWAPF W_TEMP, W
	 RETFIE
	
	 
SUBRRUTINA_RB0
	 BCF INTCON, INTF
	 BSF FLAG, 2
	 RETURN
	 

SUBRRUTINA_TMR0
	  BCF INTCON, T0IF
	  MOVLW D'6'
	  MOVWF TMR0
	  DECFSZ CONTADOR250, F
	  GOTO WUW
	  GOTO WOW
	
WOW
	  BSF FLAG, 1
	  MOVLW D'250'
	  MOVWF CONTADOR250
	  RETURN
WUW
	  BCF FLAG, 1
	  RETURN
	  
	; RETARDO DE 20 mseg
RETARDO
     MOVLW   .80         ; Bucle externo: 80
     MOVWF   CONT1
LOOP1
     MOVLW   .250        ; Bucle interno: 250
     MOVWF   CONT2
LOOP2
     NOP                 ; 1 ciclo
     NOP                 ; 1 ciclo
     DECFSZ  CONT2, F    ; 1 ciclo, 2 si salta
     GOTO    LOOP2       ; 2 ciclos
     DECFSZ  CONT1, F
     GOTO    LOOP1
     RETURN

	 
	 
	 END