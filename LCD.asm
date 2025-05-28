; ELECTRÓNICA DIGITAL II
    
; --------  Proyecto  ---------
    
; Autor:
    ; Ignacio Vizgarra
    
; Profesor:
    ; Martin Del Barco
     
; Fecha: 23/05/2025

LIST    P=16F887
#include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    #DEFINE RS	    PORTC, RC0
    #DEFINE E	    PORTC, RC1
    #DEFINE DATOS   PORTB
    #DEFINE SALIDA  TRISB
    
    CBLOCK  0x20
    T1
    T2
    T3 
    CONT
    CONT2
    ENDC
    
    ORG	    0X00
    GOTO    INICIO
    ORG	    0X05
INICIO
     BANKSEL	SALIDA
     CLRF	SALIDA
     BCF	TRISC,RC0
     BCF	TRISC,RC1
     BANKSEL	DATOS
     CLRF	DATOS
     
     
     CLRF	CONT
     MOVLW	.7 
     MOVWF	CONT2
     
     MOVF	CONT,W	    ;SE REPITE 7 VECES POR EL CONTADOR EN 7, 7 VALROES CONFIGURADOS 
     CALL	LCD_CONFIG
     CALL	WRITE_LCD
     DECFSZ	CONT2
     GOTO	$-4
     
     CLRF	CONT
     MOVLW	.14
     MOVWF	CONT2  
     
     MOVF	CONT,W	    ;SE REPITE 14 VECES POR EL CONTADOR EN 14, 14 DATOS 
     CALL	LCD_DATA
     CALL	WRITE_LCD
     DECFSZ	CONT2
     GOTO	$-4
     
FIN
     GOTO	FIN
     
LCD_CONFIG
     BCF	RS 
     BCF	E
     ADDWF	PCL,F
     DT		.2,.2,.8,.0,.15,.0,.1  ;NIBBLE ALTO 2 VECES, DESPUES NIBBLE BAJO
 
LCD_DATA
     BSF	RS 
     ADDWF	PCL,F
     DT		.4,.3,.4,.15,.4,.4,.4,.9,.4,.7,.4,.15,.5,.3
     
LCD_PULSE ;PULSITO HABILITADOR
     BSF	E  
     CALL	RETARDO_1ms
     BCF	E
     CALL	RETARDO_1ms
     RETURN
     
WRITE_LCD
     MOVWF	DATOS
     CALL	LCD_PULSE
     INCF	CONT,F
     RETURN
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
RETARDO_1s
     MOVLW	.5
     MOVWF	T3
X3  CALL	RETARDO_100ms
     DECFSZ	T3
     GOTO	X3
     RETURN
RETARDO_100ms
            MOVLW   .100
            MOVWF   T2
X2          CALL    RETARDO_1ms
            DECFSZ  T2
            GOTO    X2
            RETURN

;////////// 1ms ////////////
RETARDO_1ms
            MOVLW   .249
            MOVWF   T1
X1          NOP
	    DECFSZ  T1
	    GOTO    X1
	    RETURN
	    
	    END