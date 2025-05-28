; TP2 - ELECTRÓNICA DIGITAL II
    
; --------  Ejercicio 6.1  ---------
    
; Autores:
    ; Ignacio Vizgarra
    ; Julieta Pérez Echeverría
    
; Profesor:
    ; Martin Del Barco
    
 ; Fecha: 17/05/2025

     LIST    P=16F887
     #include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

     CBLOCK 0x20
     COLUMNA
     FILA
     COL_EN
     COL_EN_T
   
     ENDC
    
     N_ROW EQU 4
     N_COL EQU 4
     
         ORG 0x00
         GOTO INICIO
      
         ORG 0x05
INICIO
	 BANKSEL TRISB
	 MOVLW 0xF0
	 MOVWF TRISB           ; PUERTO B: high como entrada y low como salida
	 BCF OPTION_REG, 7     ; Habilito resistencias pull up del puerto B
	 MOVLW 0xF0
	 MOVWF WPUB            ; Solo la parte high (para las entradas)
	 BANKSEL ANSELH
	 CLRF ANSELH           ; PUERTO B: como puerto digital

	 BANKSEL PORTB           ; Nada pulsado inicialmente
	 MOVLW 0xF0            ; Pongo las entradas y las salidas en 0
	 MOVWF PORTB
	 CLRF COLUMNA
	 CLRF FILA
	 
LOOP
	 CALL EXPLORACION
	 GOTO LOOP
	 
EXPLORACION
	 ; En primer lugar, reviso si alguna de las entradas está en 0
	 SWAPF PORTB, W
	 ANDLW 0x0F                ; Me quedo solo con las entradas del puerto B en la parte baja
	 MOVWF COL_EN
	 MOVWF COL_EN_T
	 MOVLW 0x0F
	 SUBWF COL_EN, W           ; Resto con 00001111 para ver si hay alguna tecla pulsada
	 BTFSC STATUS, Z
	 GOTO FINEXP               ; Si el resultado es 0, no hay nada pulsado, me voy
	 CLRF COLUMNA              ; Sino, inicio exploración con contadores de fila y columna en 0
	 CLRF FILA
	 GOTO COLUMNADETECTOR
	 
COLUMNADETECTOR	 
	 ; En segundo lugar, si hay una tecla pulsada, busco de qué columna es => busco el 0 en las entradas
	 RRF COL_EN_T, F
	 BTFSS STATUS, C
	 GOTO FILADETECTOR
	 INCF COLUMNA, F
	 MOVLW N_COL
	 SUBWF COLUMNA, W
	 BTFSS STATUS, Z
	 GOTO COLUMNADETECTOR
	 CLRF COLUMNA
	 GOTO FINEXP
	 
FILADETECTOR
	 ; Luego, una vez que tengo la columna, ahora detecto la fila recorriendo las salidas del puerto B con un cero
	 ; Cuando me de la misma entrada que la anterior, esa es la fila de la tecla que se pulsó
	 MOVF FILA, W
	 CALL EN_ROW
	 MOVWF PORTB
	 
	 NOP
	 NOP
	 NOP
	 
	 SWAPF PORTB, W
	 ANDLW 0x0F
	 SUBWF COL_EN, W
	 BTFSC STATUS, Z
	 GOTO FINDETECTOR
	 INCF FILA, F
	 MOVLW N_ROW
	 SUBWF FILA, W
	 BTFSS STATUS, Z
	 GOTO FILADETECTOR
	 CLRF FILA
	 GOTO FINEXP
	 
FINDETECTOR
	 BCF STATUS, C
	 RLF FILA, F
	 RLF FILA, W
	 ADDWF COLUMNA, W
	 CALL TABLAASCIIHEX
	 MOVWF 0x30
	 
FINEXP
	 MOVLW 0xF0
	 MOVWF PORTB
	 RETURN
	 
	 
EN_ROW
	 ADDWF PCL, F
	 RETLW 0x0E             ; Columna 0
	 RETLW 0x0D             ; Columna 1
	 RETLW 0x0B             ; Columna 2
	 RETLW 0x07             ; Columna 3
	 
TABLAASCIIHEX
    ADDWF PCL, F         ; Usa W como índice para saltar a la línea correcta
    RETLW 0x30           ; 0 ? '0'
    RETLW 0x31           ; 1 ? '1'
    RETLW 0x32           ; 2 ? '2'
    RETLW 0x33           ; 3 ? '3'
    RETLW 0x34           ; 4 ? '4'
    RETLW 0x35           ; 5 ? '5'
    RETLW 0x36           ; 6 ? '6'
    RETLW 0x37           ; 7 ? '7'
    RETLW 0x38           ; 8 ? '8'
    RETLW 0x39           ; 9 ? '9'
    RETLW 0x41           ; 10 ? 'A'
    RETLW 0x42           ; 11 ? 'B'
    RETLW 0x43           ; 12 ? 'C'
    RETLW 0x44           ; 13 ? 'D'
    RETLW 0x45           ; 14 ? 'E'
    RETLW 0x46           ; 15 ? 'F'


	 END