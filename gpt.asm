LIST        P=16F887
    #include <P16F887.INC>

__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

    CBLOCK  0x20        ; Ejemplo de ubicación en la memoria de propósito general
    CONT
    NUEVE
    ENDC

    ORG     0x00
    GOTO    INICIO

    ORG     0x05
INICIO
    BANKSEL TRISD
    BSF     TRISB,0     ; RB0 como entrada (para el botón)
    CLRF    TRISD       ; Puerto D como salida para el display
    BANKSEL ANSELH
    CLRF    ANSELH
    CLRF    ANSEL

    BANKSEL PORTD
    CLRF    CONT        ; Inicializar el contador a 0
    MOVLW   .9          ; Cargar 9 al registro W
    MOVWF   NUEVE       ; Establecer el límite superior del contador

BUCLE_PRINCIPAL
    BTFSS   PORTB, 0    ; Verificar si el botón en RB0 está presionado (nivel bajo)
    GOTO    FREEZE_LOOP ; Si está presionado, ir a la sección de "congelamiento"

    ; --- Sección de Conteo y Visualización ---
    INCF    CONT, F     ; Incrementar el contador
    MOVF    CONT, W     ; Mover el valor del contador a W
    SUBWF   NUEVE, W    ; Restar NUEVE de W
    BTFSC   STATUS, Z   ; Verificar si el resultado es cero (CONT llegó a NUEVE)
    CLRF    CONT        ; Si es cero, reiniciar el contador

    MOVF    CONT, W     ; Mover el valor actual de CONT a W para la tabla
    CALL    TABLA       ; Buscar el código del segmento en la tabla
    MOVWF   PORTD       ; Mostrar el dígito en el display conectado a Puerto D

    ; --- Retardo de 1 segundo ---
    CALL    DELAY_1S

    GOTO    BUCLE_PRINCIPAL ; Volver al inicio del bucle principal

FREEZE_LOOP
    ; --- "Congelar" el display (apagarlo) ---
    MOVLW   0x00        ; Apagar todos los segmentos (para cátodo común)
    MOVWF   PORTD
    CLRF    CONT        ; Reiniciar el contador

    ; --- Retardo de "congelamiento" (opcional) ---
    CALL    DELAY_1S

    GOTO    BUCLE_PRINCIPAL ; Volver al bucle principal después de "congelar"

TABLA
    ADDWF   PCL, F
    RETLW   0x3F        ; 0
    RETLW   0x06        ; 1
    RETLW   0x5B        ; 2
    RETLW   0x4F        ; 3
    RETLW   0x66        ; 4
    RETLW   0x6D        ; 5
    RETLW   0x7D        ; 6
    RETLW   0x07        ; 7
    RETLW   0x7F        ; 8
    RETLW   0x67        ; 9

; Función de retardo de aproximadamente 1 segundo (asumiendo oscilador de 4 MHz)
DELAY_1S
    MOVLW   D'12'       ; Ajuste fino del contador externo
    MOVWF   CONTADOR1

BUCLE_EXTERNO
    MOVLW   D'208'      ; Ajuste fino del contador medio
    MOVWF   CONTADOR2

BUCLE_MEDIO
    MOVLW   D'249'      ; Ajuste fino del contador interno
    MOVWF   CONTADOR3

BUCLE_INTERNO
    NOP
    NOP
    DECFSZ  CONTADOR3, F
    GOTO    BUCLE_INTERNO

    DECFSZ  CONTADOR2, F
    GOTO    BUCLE_MEDIO

    DECFSZ  CONTADOR1, F
    GOTO    BUCLE_EXTERNO

    RETURN

; Variables para los contadores del retardo
    CBLOCK  0x22
    CONTADOR1
    CONTADOR2
    CONTADOR3
    ENDC

    END