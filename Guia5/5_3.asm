; Escribir un programa que lea de dos teclas conectadas a RB1 y RB2 y actúe sobre un relé conectado en RB3.
;1. Si están ambas teclas abiertas el relé está abierto.
;2. Si RB2 está abierta y RB1 cerrada se activa el relé por 1 minuto.
;3. Si RB2 está cerrada y RB1 abierta se activa el relé por 2 minutos.
;4. Si están ambas cerradas se activa el relé por 3 minutos.
;Cualquier cambio en las teclas mientras esté activado el relé no debe modificar la salida.
    
    list p=16f887
    #INCLUDE<PIC16f887>
    
; CONFIG1
; __config 0x20F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
    PORTB_ANT EQU 0X20
    CBLOCK  0X70
    STATUS_TEMP
    W_TEMP
    ENDC
    
    ORG	    0x00
    GOTO    INICIO
    ORG	    0X04
    GOTO    ISR
    ORG	    0X05

INICIO
    BANKSEL ANSEL
    CLRF    ANSEL
    BANKSEL TRISB
    MOVLW   .6	   ;0000 0110
    MOVWF   TRISB
    BSF	    INTCON,GIE
    BSF	    INTCON,PEIE
    
    BANKSEL PORTB
    MOVF    PORTB,W
    MOVWF   PORTB_ANT
    
ISR
    MOVWF   W_TEMP 
    SWAPF   STATUS,W
    MOVWF   STATUS_TEMP
    
    BTFSS   INTCON,RBIF
    
    