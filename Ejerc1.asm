; ELECTRÓNICA DIGITAL II
    
; --------  Parcial_1  ---------
    
    
; Autor:
    ; Ignacio Vizgarra
    
; Profesor:
    ; Martin Del Barco
     
; Fecha: 20/05/2025
    
LIST    P=16F887
#include <P16F887.INC>
    
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_ON & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    CBLOCK 0X20
    CONT1
    T1
    T2
    T3
    FLAG
    ENDC
    
    CBLOCK  0X70
    W_TEMP
    STATUS_TEMP
    ENDC
    
    ORG 0X00
    GOTO INICIO
    ORG 0X04
    GOTO ISR
    ORG 0X05
INICIO
    BANKSEL	ANSEL
    CLRF	ANSEL
    CLRF	ANSELH
    BANKSEL	TRISB
    MOVLW	.1
    