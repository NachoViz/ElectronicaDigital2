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
    
#DEFINE TRIG_PIN  PORTB,RB4
#DEFINE ECHO_PIN  PORTB,RB5

    CBLOCK 0X20
    MEMORI1
    RESPUESTA
    CORREGIDOR
    ENDC
    
    ORG 0X00
    GOTO INICIO
    ORG 0X04
    GOTO ISR
    ORG 0X05
    
INICIO
    BAKNSEL TRISB
    BCF	    TRISB,4	;TRIGGER
    BSF	    TRISB,5	;ECHO
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    
    BANKSEL OPTION_REG
    MOVLW   B'00000111'
    MOVWF   OPTION_REG
    
    
    
    
PULSO
    BCF	    TRIG_PIN
    CALL    DELAY_500us
    BSF	    TRIG_PIN
    CALL    DELAY_10us
    BCF	    TRIG_PIN
VUELVO
    BTFSS   ECHO_PIN
    GOTO    VUELVO
    BANKSEL TMR0
    CLRF    TMR0
    BTFSC   ECHO_PIN
    GOTO    $-1
    MOVF    TMR0,W
    MOVWF   RESPUESTA 
    
	   
    