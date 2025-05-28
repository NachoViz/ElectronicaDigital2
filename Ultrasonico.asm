; *******************************************************************
; Nombre: Control HC-SR04 con PIC16F887 usando Timer0 y contador de overflows
; Autor: Tu Nombre (adaptado de tu solicitud)
; Fecha: 24/05/2025
; Descripción: Mide distancia con HC-SR04 y enciende un LED si
;              un objeto está lo suficientemente cerca (distancia < UMBRAL_CM).
;              Usa Timer0 para medir el pulso ECHO y cuenta sus desbordamientos.
; *******************************************************************

LIST P=16F887
#include <P16F887.INC>

; --- CONFIGURACIÓN DEL MICROCONTROLADOR ---
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

; --- DEFINICIONES DE PINES ---
#DEFINE TRIG_PIN    PORTB,0    ; Pin de salida para el Trigger del HC-SR04
#DEFINE ECHO_PIN    PORTB,1    ; Pin de entrada para el Echo del HC-SR04
#DEFINE LED_CERCANO PORTC,0    ; Pin de salida para el LED de "cercano"

; --- VARIABLES EN RAM ---
CBLOCK 0x20
    PulseDuration_TMR0 ; Valor final de TMR0 cuando el pulso ECHO termina
    TMR0_Overflows     ; Contador de veces que TMR0 se desborda (0-255 a 0)
    CounterDelay       ; Contador para pequeños retardos (e.g., 10us para TRIG)

    ; Variables para guardar contexto en la ISR (IMPORTANTE)
    W_TEMP             ; Para guardar el registro W
    STATUS_TEMP        ; Para guardar el registro STATUS
ENDC

; --- VALOR UMBRAL DE DISTANCIA (en cm) ---
; Si la distancia es menor a este valor, el LED se encenderá.
; Calculo del umbral en "ticks" del Timer0 (1 tick = 0.5us)
; Distancia (cm) = (ticks * 0.5us) / 58 us/cm = ticks / 116
; ticks = Distancia * 116
; Ejemplo: UMBRAL_CM = 10 cm -> ticks = 10 * 116 = 1160 ticks
; 1160 ticks = 4 desbordamientos de TMR0 (4 * 256 = 1024) + 136 ticks restantes (1160 - 1024)
#DEFINE UMBRAL_TMR0_LOW   D'136' ; Parte baja del umbral en ticks para TMR0
#DEFINE UMBRAL_TMR0_OVF   D'4'   ; Número de overflows para el umbral

; --- VECTORES DE RESET E INTERRUPCIÓN ---
    ORG 0x00        ; Vector de Reset
    GOTO INIT       ; Salta a la inicialización

    ORG 0x04        ; Vector de Interrupción
    GOTO ISR        ; Salta a la rutina de servicio de interrupción (ISR)

; *******************************************************************
; --- RUTINA DE SERVICIO DE INTERRUPCIÓN (ISR) ---
; Esta rutina se ejecuta cuando ocurre una interrupción.
; Aquí manejaremos la lectura del pulso ECHO y el desbordamiento de TMR0.
; *******************************************************************
ISR
    ; Guardar contexto
    MOVWF W_TEMP        ; Guarda W en W_TEMP
    SWAPF STATUS,W      ; Intercambia STATUS con W
    MOVWF STATUS_TEMP   ; Guarda STATUS en STATUS_TEMP

    ; --- 1. Interrupción por desbordamiento de Timer0 (T0IF) ---
    BTFSC INTCON, T0IF  ; ¿Fue interrupción de TMR0 overflow?
    GOTO TMR0_Overflow  ; Sí, ir a manejar el desbordamiento

    ; --- 2. Interrupción por cambio en el pin ECHO (RBIF) ---
    BTFSC INTCON, RBIF  ; ¿Fue interrupción por cambio de estado en RB (ECHO_PIN)?
    GOTO RB_Change      ; Sí, ir a manejar cambio en RB

    ; Si llegamos aquí, es otra interrupción o un error (no esperado en este ejemplo)
    GOTO EndISR         ; Simplemente salir

TMR0_Overflow:
    ; Timer0 se desbordó (pasó de 255 a 0)
    BCF INTCON, T0IF    ; Limpiar flag de interrupción de TMR0
    INCF TMR0_Overflows, F ; Incrementar el contador de desbordamientos
    GOTO EndISR         ; Salir de la ISR

RB_Change:
    ; Interrupción por cambio de estado en un pin del Puerto B (ECHO_PIN)
    BCF INTCON, RBIF    ; Limpiar flag de interrupción de RB

    BTFSS ECHO_PIN      ; ¿El pin ECHO subió a HIGH? (flanco de subida)
    GOTO EchoFalling_T0 ; No, es flanco de bajada

    ; --- Flanco de Subida (ECHO pasó de LOW a HIGH) ---
    ; Aquí el pulso ECHO comienza, iniciamos el Timer0 y reseteamos el contador de overflows.
    CLRF TMR0           ; Limpiar TMR0
    CLRF TMR0_Overflows ; Reiniciar contador de desbordamientos de TMR0
    BSF INTCON, T0IE    ; Habilitar interrupciones por desbordamiento de TMR0
    ; El TMR0 ya está corriendo si se configuró así en OPTION_REG

    GOTO EndISR

EchoFalling_T0:
    ; --- Flanco de Bajada (ECHO pasó de HIGH a LOW) ---
    ; Aquí el pulso ECHO termina, detenemos el Timer0 (deshabilitando su interrupción)
    ; y leemos su valor final.
    BCF INTCON, T0IE    ; Deshabilitar interrupciones por desbordamiento de TMR0
    MOVF TMR0, W        ; Mover el valor actual de TMR0 a W
    MOVWF PulseDuration_TMR0 ; Guardar el valor final de TMR0

    GOTO EndISR

EndISR:
    ; Restaurar contexto
    SWAPF STATUS_TEMP,W ; Restaura STATUS
    MOVWF STATUS        ;
    SWAPF W_TEMP,F      ; Restaura W
    SWAPF W_TEMP,W      ;

    RETFIE              ; Retorno de interrupción (habilita interrupciones de nuevo)

; *******************************************************************
; --- INICIALIZACIÓN DEL SISTEMA ---
; *******************************************************************
INIT
    ; --- Configuración del Oscilador Interno (8MHz) ---
    BANKSEL OSCCON      ; Cambiar al banco donde está OSCCON (Banco 1)
    MOVLW 0x70          ; IRCF<2:0> = 111 (8MHz), SCS = 0 (Oscilador interno)
    MOVWF OSCCON        ;
    BANKSEL PORTA       ; Volver al Banco 0 (o cualquier otro banco común)

    ; --- Configuración de Puertos I/O ---
    ; Deshabilitar comparadores y ADC si no se usan (para usar pines como digitales)
    BANKSEL ANSEL       ; Cambiar al banco donde está ANSEL (Banco 1)
    CLRF ANSEL          ; Todos los pines ANx como digitales (PORTA, PORTB, PORTE)
    CLRF ANSELH         ; Todos los pines ANx como digitales (PORTB)

    ; Configurar pines como entrada/salida
    BANKSEL TRISB       ; Cambiar al banco donde está TRISB (Banco 1)
    BSF TRISB, 1 ; ECHO_PIN como entrada (recibe el pulso)
    BCF TRISB, 0 ; TRIG_PIN como salida (envía el pulso)

    BANKSEL TRISC       ; Cambiar al banco donde está TRISC (Banco 1)
    BCF TRISC, 0 ; LED_CERCANO como salida

    BANKSEL PORTA       ; Volver al Banco 0

    ; Limpiar puertos de salida al inicio (asegurar estados conocidos)
    CLRF PORTB
    CLRF PORTC

    ; --- Configuración de Timer0 ---
    BANKSEL OPTION_REG  ; Cambiar al banco donde está OPTION_REG (Banco 1)
    MOVLW 0x08          ; Bit 5 (T0CS) = 0: TMR0 clock source es Fosc/4 (2MHz)
                        ; Bit 3 (PSA) = 1: No se usa preescaler para TMR0 (Preescaler asignado a WDT)
                        ; Bit 7 (RBPU) = 0: Pull-ups de PortB habilitados (si se necesitan)
                        ; Bits 2:0 (PS<2:0>) = 000: Preescaler 1:1 para TMR0 (si PSA=0)
                        ; En este caso, queremos un preescaler de 1:1 para TMR0.
                        ; Si PSA=1, el preescaler está en el WDT.
                        ; Si PSA=0, el preescaler está en TMR0.
                        ; Queremos TMR0 source Fosc/4, sin preescaler.
                        ; Por lo tanto: T0CS=0, PSA=0, PS<2:0>=000.
                        ; Esto significa OPTION_REG = 0b_0000_0000 = 0x00
    CLRF OPTION_REG     ; TMR0 clock source Fosc/4, preescaler 1:1, sin asignación a WDT
                        ; Cada incremento toma 1 / (8MHz/4) = 0.5us
    BANKSEL TMR0        ; Volver al Banco 0 (TMR0 está en Banco 0)
    CLRF TMR0           ; Limpiar TMR0

    ; --- Configuración de Interrupciones ---
    BANKSEL INTCON      ; Cambiar al banco donde está INTCON (Banco 0)
    BCF INTCON, GIE     ; Deshabilitar Interrupciones Globales mientras configuramos
    BCF INTCON, PEIE    ; Deshabilitar Interrupciones Periféricas

    ; Configuración de Interrupción por Cambio de Estado en Puerto B (RBIF)
    BANKSEL IOCB        ; Cambiar al banco donde está IOCB (Banco 1)
    BSF IOCB, 1         ; Habilitar interrupción en cambio para RB1 (ECHO_PIN)
    BANKSEL INTCON      ; Volver al Banco 0

    BCF INTCON, RBIF    ; Limpiar flag de interrupción de RB
    BSF INTCON, RBIE    ; Habilitar interrupción por cambio en Puerto B

    BCF INTCON, T0IF    ; Limpiar flag de interrupción de TMR0
    BCF INTCON, T0IE    ; DESHABILITAR TMR0 INTERRUPCIÓN (se habilitará en flanco de subida de ECHO)

    BSF INTCON, GIE     ; Habilitar Interrupciones Globales

; *******************************************************************
; --- Rutina Principal ---
; *******************************************************************
MAIN_LOOP
    ; Asegurar que el LED esté apagado antes de una nueva medición
    BCF LED_CERCANO

    ; --- 1. Enviar pulso de Trigger al HC-SR04 ---
    BCF TRIG_PIN        ; Asegurar que TRIG esté en LOW
    CALL Delay_us_2     ; Pequeño retardo para asegurar LOW
    BSF TRIG_PIN        ; Poner TRIG en HIGH (inicio del pulso)
    CALL Delay_us_10    ; Retardo de 10us (duración del pulso de activación)
    BCF TRIG_PIN        ; Poner TRIG en LOW (fin del pulso)

    ; --- 2. Esperar un tiempo máximo para la medición ---
    ; Si el ECHO nunca llega o llega muy tarde (objeto muy lejos),
    ; el Timer0_Overflows podría seguir aumentando.
    ; Podemos poner un tiempo de espera máximo aquí para evitar un bucle infinito
    ; o para simplemente asumir que si pasa mucho tiempo, el objeto está lejos.
    CALL RETARDO_50MS ; Un retardo para dar tiempo a la ISR a capturar el pulso

    ; --- 3. Comparar Distancia con el Umbral ---
    ; La lógica de comparación es un poco más compleja ahora que tenemos overflows.
    ; Necesitamos comparar (TMR0_Overflows : PulseDuration_TMR0) con (UMBRAL_TMR0_OVF : UMBRAL_TMR0_LOW).

    ; Comparar primero los overflows
    MOVF TMR0_Overflows, W  ; Mover el número de overflows a W
    SUBLW UMBRAL_TMR0_OVF   ; Restar el umbral de overflows (W = UMBRAL_TMR0_OVF - TMR0_Overflows)

    BTFSS STATUS, C         ; Si (TMR0_Overflows < UMBRAL_TMR0_OVF), Carry se SETEA (no borrow)
    GOTO DistanceTooFar     ; La distancia es mayor o igual al umbral (más overflows)

    ; Si el carry está claro, significa que TMR0_Overflows < UMBRAL_TMR0_OVF.
    ; Esto significa que está potencialmente cerca.
    ; Si TMR0_Overflows > UMBRAL_TMR0_OVF, ya es muy lejos -> se maneja por el BTFSS STATUS,C.
    ; Si TMR0_Overflows == UMBRAL_TMR0_OVF, entonces necesitamos comparar PulseDuration_TMR0.
    ; Si TMR0_Overflows < UMBRAL_TMR0_OVF, entonces definitivamente está más cerca.

    ; Si los overflows son iguales (Z bit está set), entonces comparamos la parte baja
    BTFSS STATUS, Z         ; ¿Los overflows fueron iguales?
    GOTO DistanceIsClose    ; Si no fueron iguales (menor num de overflows), la distancia es cercana.

    ; Si los overflows son iguales (Z bit está set), ahora comparamos los valores de TMR0
    MOVF PulseDuration_TMR0, W ; Mover el valor final de TMR0 a W
    SUBLW UMBRAL_TMR0_LOW   ; Restar el umbral de la parte baja (W = UMBRAL_TMR0_LOW - PulseDuration_TMR0)

    BTFSC STATUS, C         ; Si (PulseDuration_TMR0 >= UMBRAL_TMR0_LOW), Carry se CLEARS (hay borrow)
    GOTO DistanceTooFar     ; Si PulseDuration_TMR0 >= UMBRAL_TMR0_LOW, es muy lejos

DistanceIsClose:
    ; Si llegamos aquí, la distancia es menor que el umbral (objeto cercano)
    BSF LED_CERCANO         ; Encender LED
    GOTO ContinueLoop

DistanceTooFar:
    ; La distancia es mayor o igual al umbral
    BCF LED_CERCANO         ; Apagar LED

ContinueLoop:
    ; Pequeño retardo antes de la siguiente medición para evitar lecturas rápidas
    CALL RETARDO_200MS

    GOTO MAIN_LOOP          ; Repetir el proceso

; *******************************************************************
; --- SUBRUTINAS DE RETARDOS ---
; Los retardos son los mismos que en el ejemplo anterior.
; Ajusta los valores de contador según tu Fosc (8MHz).
; 1 instrucción = 0.5us

; Retardo de aproximadamente 2 microsegundos
Delay_us_2
    MOVLW D'4' ; (4 ciclos * 0.5us/ciclo = 2us)
    MOVWF CounterDelay
Delay_us_2_Loop
    DECFSZ CounterDelay, F
    GOTO Delay_us_2_Loop
    RETURN

; Retardo de aproximadamente 10 microsegundos
Delay_us_10
    MOVLW D'20' ; (20 ciclos * 0.5us/ciclo = 10us)
    MOVWF CounterDelay
Delay_us_10_Loop
    DECFSZ CounterDelay, F
    GOTO Delay_us_10_Loop
    RETURN

; Retardo de 50 milisegundos (para dar tiempo al ECHO)
RETARDO_50MS
    MOVLW .100               ; Valor ajustable
    MOVWF CounterDelay ; Usamos CounterDelay para no redefinir las variables de retardo
Loop50MS_1
    MOVLW .250
    MOVWF W_TEMP ; Usar W_TEMP como contador interno
Loop50MS_2
    DECFSZ W_TEMP, F
    GOTO Loop50MS_2
    DECFSZ CounterDelay, F
    GOTO Loop50MS_1
    RETURN

; Retardo de 200 milisegundos (entre mediciones)
RETARDO_200MS
    MOVLW .200               ; Valor ajustable
    MOVWF CounterDelay
Loop200MS_1
    MOVLW .250
    MOVWF W_TEMP
Loop200MS_2
    DECFSZ W_TEMP, F
    GOTO Loop200MS_2
    DECFSZ CounterDelay, F
    GOTO Loop200MS_1
    RETURN

; *******************************************************************
; --- NOTAS IMPORTANTES ---
; 1. **Precisión del Umbral:** El cálculo del umbral en TMR0_OVF y UMBRAL_TMR0_LOW
;    es crucial. Para 10cm, necesitas 1160 ticks.
;    1160 / 256 (Timer0 max) = 4.53 overflows. Así que 4 overflows y 1160 - (4*256) = 1160 - 1024 = 136 ticks restantes.
;    UMBRAL_TMR0_OVF = 4
;    UMBRAL_TMR0_LOW = 136
;    Asegúrate de que tus cálculos sean correctos para el Fosc y preescaler de TMR0.

; 2. **RB1 (ECHO_PIN) como Interrupción en Cambio:** La línea `BSF IOCB, 1` asume que ECHO_PIN es RB1.
;    Si cambias ECHO_PIN a otro pin de PORTB, debes cambiar este número de bit.

; 3. **Rango de Medición:** Con este método de contador de overflows, puedes medir distancias
;    mucho mayores que con Timer0 directo. El límite estará dado por la confiabilidad
;    del HC-SR04 y por el rango de tu contador de overflows.
; *******************************************************************

    END